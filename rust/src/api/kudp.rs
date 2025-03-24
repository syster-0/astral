use std::collections::HashSet;
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::sync::{Arc, atomic::{AtomicBool, Ordering}};
use std::time::Duration;
use tokio::net::UdpSocket;
use tokio::sync::Mutex;
use tokio::time::sleep;
use windows::Win32::NetworkManagement::IpHelper::{GetIpForwardTable, MIB_IPFORWARDROW, MIB_IPFORWARDTABLE};
use windows::Win32::Networking::WinSock::{
    IPPROTO_UDP, MIB_IPROUTE_TYPE_DIRECT, SOCKADDR_IN, SOCKET_ERROR, WSAGetLastError,
    WSAIoctl, FIONBIO, SOL_SOCKET, SO_BROADCAST, IPPROTO_IP, IP_TTL,
};
use windows::Win32::Foundation::{BOOL, HANDLE, SOCKET};
use std::mem::{size_of, MaybeUninit};
use windows::core::{PCSTR, PSTR};
use log::{debug, error, info, warn};

const IP_HEADER_SIZE: usize = 20;
const IP_SRCADDR_POS: usize = 12;
const IP_DSTADDR_POS: usize = 16;
const IP_TTL_POS: usize = 8;

const UDP_HEADER_SIZE: usize = 8;
const UDP_CHECKSUM_POS: usize = 6;

const FORWARDTABLE_INITIAL_SIZE: usize = 4096;

pub struct KudpBroadcaster {
    running: Arc<AtomicBool>,
    task_handle: Option<tokio::task::JoinHandle<()>>,
}

impl KudpBroadcaster {
    pub fn new() -> Self {
        Self {
            running: Arc::new(AtomicBool::new(false)),
            task_handle: None,
        }
    }

    pub async fn start(&mut self) -> Result<(), String> {
        if self.running.load(Ordering::SeqCst) {
            return Err("广播服务已经在运行中".to_string());
        }

        self.running.store(true, Ordering::SeqCst);
        let running = self.running.clone();

        self.task_handle = Some(tokio::spawn(async move {
            if let Err(e) = Self::broadcast_loop(running).await {
                error!("广播服务出错: {}", e);
            }
        }));

        info!("广播服务已启动");
        Ok(())
    }

    pub async fn stop(&mut self) -> Result<(), String> {
        if !self.running.load(Ordering::SeqCst) {
            return Err("广播服务未运行".to_string());
        }

        self.running.store(false, Ordering::SeqCst);
        
        if let Some(handle) = self.task_handle.take() {
            // 等待任务完成
            let _ = handle.await;
        }

        info!("广播服务已停止");
        Ok(())
    }

    async fn broadcast_loop(running: Arc<AtomicBool>) -> Result<(), String> {
        // 初始化网络
        let loopback_address = Ipv4Addr::new(127, 0, 0, 1);
        let broadcast_address = Ipv4Addr::new(255, 255, 255, 255);
        
        info!("广播服务初始化，监听地址: {}", loopback_address);
        
        // 创建监听套接字
        let listen_socket = UdpSocket::bind(SocketAddr::new(IpAddr::V4(loopback_address), 0))
            .await
            .map_err(|e| format!("无法绑定监听套接字: {}", e))?;
        
        info!("监听套接字已绑定到端口: {}", listen_socket.local_addr().unwrap().port());
        
        // 设置套接字为原始模式
        // 注意：在Rust中，我们需要使用socket2或类似库来设置原始套接字
        // 这里简化处理，使用标准UdpSocket
        
        let buffer_size = 4096;
        let mut buffer = vec![0u8; buffer_size];
        
        // 创建转发表缓存
        let forward_table_cache = Arc::new(Mutex::new(Vec::new()));
        
        // 启动定期刷新转发表的任务
        let ft_cache = forward_table_cache.clone();
        let ft_running = running.clone();
        tokio::spawn(async move {
            while ft_running.load(Ordering::SeqCst) {
                if let Ok(table) = Self::get_forward_table() {
                    let mut cache = ft_cache.lock().await;
                    *cache = table;
                }
                sleep(Duration::from_secs(30)).await;
            }
        });

        // 主循环
        while running.load(Ordering::SeqCst) {
            // 接收广播包
            let (len, src_addr) = match listen_socket.recv_from(&mut buffer).await {
                Ok(result) => result,
                Err(e) => {
                    error!("接收数据出错: {}", e);
                    continue;
                }
            };
            
            debug!("收到数据包: 长度={}, 来源={}", len, src_addr);
            
            if len < IP_HEADER_SIZE + UDP_HEADER_SIZE {
                debug!("数据包太小，忽略: {}", len);
                continue;
            }
            
            // 检查是否是广播包
            let dst_ip = Ipv4Addr::new(
                buffer[IP_DSTADDR_POS], 
                buffer[IP_DSTADDR_POS + 1], 
                buffer[IP_DSTADDR_POS + 2], 
                buffer[IP_DSTADDR_POS + 3]
            );
            
            if dst_ip != broadcast_address {
                continue;
            }
            
            // 获取源地址
            let src_ip = Ipv4Addr::new(
                buffer[IP_SRCADDR_POS], 
                buffer[IP_SRCADDR_POS + 1], 
                buffer[IP_SRCADDR_POS + 2], 
                buffer[IP_SRCADDR_POS + 3]
            );
            
            info!("收到广播包: 源IP={}, 目标IP={}, 长度={}", src_ip, dst_ip, len);
            
            // 检查TTL，避免转发循环
            if buffer[IP_TTL_POS] <= 1 {
                debug!("TTL值过低，不转发: TTL={}", buffer[IP_TTL_POS]);
                continue;
            }
            
            // 检查源地址是否是本地地址
            let forward_table = forward_table_cache.lock().await.clone();
            if !Self::find_local_address_in_broadcast_routes(&forward_table, &src_ip, &broadcast_address) {
                debug!("源地址不是本地地址，不转发: {}", src_ip);
                continue;
            }
            
            info!("准备转发广播包: 源IP={}, 数据长度={}", src_ip, len - IP_HEADER_SIZE);
            
            // 转发广播包
            Self::relay_broadcast(&buffer[IP_HEADER_SIZE..len], &forward_table, &src_ip, &loopback_address, &broadcast_address).await;
        }
        
        Ok(())
    }
    
    fn get_forward_table() -> Result<Vec<MIB_IPFORWARDROW>, String> {
        unsafe {
            let mut table_size = FORWARDTABLE_INITIAL_SIZE as u32;
            let mut buffer = vec![0u8; table_size as usize];
            
            loop {
                let result = GetIpForwardTable(
                    Some(buffer.as_mut_ptr() as *mut MIB_IPFORWARDTABLE),
                    &mut table_size,
                    0,
                );
                
                if result == 0 {
                    // 成功获取转发表
                    let table = *(buffer.as_ptr() as *const MIB_IPFORWARDTABLE);
                    let num_entries = table.dwNumEntries;
                    
                    let mut rows = Vec::with_capacity(num_entries as usize);
                    let entries_ptr = &table.table as *const MIB_IPFORWARDROW;
                    
                    for i in 0..num_entries {
                        let row = *entries_ptr.offset(i as isize);
                        rows.push(row);
                    }
                    
                    return Ok(rows);
                } else if result == 122 { // ERROR_INSUFFICIENT_BUFFER
                    // 缓冲区太小，重新分配
                    buffer = vec![0u8; table_size as usize];
                } else {
                    return Err(format!("获取转发表失败，错误码: {}", result));
                }
            }
        }
    }
    
    fn find_local_address_in_broadcast_routes(
        forward_table: &[MIB_IPFORWARDROW],
        src_ip: &Ipv4Addr,
        broadcast_ip: &Ipv4Addr
    ) -> bool {
        let src_addr = u32::from(*src_ip).to_be();
        let broadcast_addr = u32::from(*broadcast_ip).to_be();
        
        for row in forward_table {
            if row.dwForwardDest != broadcast_addr {
                continue;
            }
            
            if row.dwForwardMask != u32::MAX {
                continue;
            }
            
            if row.dwForwardType != MIB_IPROUTE_TYPE_DIRECT {
                continue;
            }
            
            if row.dwForwardNextHop == src_addr {
                return true;
            }
        }
        
        false
    }
    
    async fn relay_broadcast(
        payload: &[u8],
        forward_table: &[MIB_IPFORWARDROW],
        src_ip: &Ipv4Addr,
        loopback_ip: &Ipv4Addr,
        broadcast_ip: &Ipv4Addr
    ) {
        let src_addr = u32::from(*src_ip).to_be();
        let loopback_addr = u32::from(*loopback_ip).to_be();
        let broadcast_addr = u32::from(*broadcast_ip).to_be();
        
        let mut tasks = Vec::new();
        let mut sent_interfaces = HashSet::new();
        
        info!("开始转发广播包: 源IP={}, 数据长度={}", src_ip, payload.len());
        
        for row in forward_table {
            if row.dwForwardDest != broadcast_addr {
                continue;
            }
            
            if row.dwForwardMask != u32::MAX {
                continue;
            }
            
            if row.dwForwardType != MIB_IPROUTE_TYPE_DIRECT {
                continue;
            }
            
            if row.dwForwardNextHop == loopback_addr || row.dwForwardNextHop == src_addr {
                continue;
            }
            
            let next_hop = row.dwForwardNextHop;
            if sent_interfaces.contains(&next_hop) {
                continue;
            }
            
            sent_interfaces.insert(next_hop);
            
            // 转换为Ipv4Addr
            let next_hop_bytes = next_hop.to_be_bytes();
            let next_hop_ip = Ipv4Addr::new(
                next_hop_bytes[0],
                next_hop_bytes[1],
                next_hop_bytes[2],
                next_hop_bytes[3],
            );
            
            info!("转发广播包到接口: {}", next_hop_ip);
            
            let payload_vec = payload.to_vec();
            let broadcast_ip = *broadcast_ip;
            
            // 异步发送广播
            let task = tokio::spawn(async move {
                if let Err(e) = Self::send_broadcast(&next_hop_ip, &broadcast_ip, &payload_vec).await {
                    error!("发送广播失败: {}", e);
                }
            });
            
            tasks.push(task);
        }
        
        info!("广播包将被转发到 {} 个接口", tasks.len());
        
        // 等待所有发送任务完成
        for task in tasks {
            let _ = task.await;
        }
        
        info!("广播包转发完成");
    }
    
    async fn send_broadcast(
        src_ip: &Ipv4Addr,
        dst_ip: &Ipv4Addr,
        payload: &[u8]
    ) -> Result<(), String> {
        debug!("准备发送广播: 源IP={}, 目标IP={}, 数据长度={}", src_ip, dst_ip, payload.len());
        
        // 创建UDP套接字
        let socket = UdpSocket::bind(SocketAddr::new(IpAddr::V4(*src_ip), 0))
            .await
            .map_err(|e| format!("绑定发送套接字失败: {}", e))?;
        
        // 设置广播选项
        socket.set_broadcast(true)
            .map_err(|e| format!("设置广播选项失败: {}", e))?;
        
        // 计算UDP校验和
        let mut payload_with_checksum = payload.to_vec();
        Self::compute_udp_checksum(&mut payload_with_checksum, src_ip, dst_ip);
        
        // 发送数据
        let bytes_sent = socket.send_to(&payload_with_checksum, SocketAddr::new(IpAddr::V4(*dst_ip), 0))
            .await
            .map_err(|e| format!("发送广播数据失败: {}", e))?;
        
        info!("广播数据已发送: 源IP={}, 目标IP={}, 发送字节数={}", src_ip, dst_ip, bytes_sent);
        
        Ok(())
    }
    
    fn compute_udp_checksum(payload: &mut [u8], src_ip: &Ipv4Addr, dst_ip: &Ipv4Addr) {
        // 先将校验和字段置为0
        payload[UDP_CHECKSUM_POS] = 0;
        payload[UDP_CHECKSUM_POS + 1] = 0;
        
        let payload_size = payload.len();
        let src_addr = u32::from(*src_ip);
        let dst_addr = u32::from(*dst_ip);
        
        let mut checksum: u32 = 0;
        
        // 计算UDP伪头部校验和
        checksum += ((src_addr >> 16) & 0xFFFF) as u32;
        checksum += (src_addr & 0xFFFF) as u32;
        checksum += ((dst_addr >> 16) & 0xFFFF) as u32;
        checksum += (dst_addr & 0xFFFF) as u32;
        checksum += u32::from(IPPROTO_UDP);
        checksum += payload_size as u32;
        
        // 计算UDP数据校验和
        let mut i = 0;
        while i < payload_size - 1 {
            let word = ((payload[i] as u32) << 8) | (payload[i + 1] as u32);
            checksum += word;
            i += 2;
        }
        
        // 如果有奇数个字节，处理最后一个字节
        if payload_size % 2 == 1 {
            checksum += (payload[payload_size - 1] as u32) << 8;
        }
        
        // 折叠进位
        while checksum >> 16 != 0 {
            checksum = (checksum & 0xFFFF) + (checksum >> 16);
        }
        
        // 取反
        let checksum = !(checksum as u16);
        
        // 写回校验和字段
        payload[UDP_CHECKSUM_POS] = (checksum >> 8) as u8;
        payload[UDP_CHECKSUM_POS + 1] = (checksum & 0xFF) as u8;
    }
}

impl Drop for KudpBroadcaster {
    fn drop(&mut self) {
        // 确保在结构体被丢弃时停止广播服务
        let runtime = tokio::runtime::Runtime::new().unwrap();
        if self.running.load(Ordering::SeqCst) {
            runtime.block_on(async {
                let _ = self.stop().await;
            });
        }
    }
}

// 提供一个简单的工厂函数，方便创建实例
pub fn create_broadcaster() -> KudpBroadcaster {
    KudpBroadcaster::new()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_broadcaster_lifecycle() {
        let mut broadcaster = KudpBroadcaster::new();
        
        // 测试启动
        let start_result = broadcaster.start().await;
        assert!(start_result.is_ok(), "启动广播服务失败: {:?}", start_result);
        
        // 等待一段时间
        tokio::time::sleep(Duration::from_secs(2)).await;
        
        // 测试停止
        let stop_result = broadcaster.stop().await;
        assert!(stop_result.is_ok(), "停止广播服务失败: {:?}", stop_result);
    }
}