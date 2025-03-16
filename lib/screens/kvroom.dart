// 导入必要的包
import 'package:flutter/services.dart'; // 添加这一行导入剪贴板服务

import 'package:astral/utils/kv_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/card.dart';

/// 玩家信息模型类
class PlayerInfo {
  final String name;
  final String ip;
  final int latency; // 延迟(ms)
  final String connectionType; // 连接类型：直链、中转、本机
  final int uploadSpeed; // 上传速度(KB/s)
  final int downloadSpeed; // 下载速度(KB/s)
  final int sentPackets; // 发送包数量
  final int receivedPackets; // 接收包数量
  final double packetLossRate; // 丢包率(%)
  final String etVersion; // ET版本

  PlayerInfo({
    required this.name,
    required this.ip,
    required this.latency,
    required this.connectionType,
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.sentPackets,
    required this.receivedPackets,
    required this.packetLossRate,
    required this.etVersion,
  });
}

/// 房间页面组件
/// 用于显示所有玩家的信息
class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<PlayerInfo> players = [];
  bool isLoading = true;
  // 移除布局类型状态变量

  @override
  void initState() {
    super.initState();
    isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('房间成员'),
        // 移除布局切换按钮
      ),
      body: Consumer<KM>(
        builder: (context, km, child) {
          // 当 KM 更新时，这个 builder 会被重新调用
          // 异步处理数据
          _processNodeData(km);

          if (isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载玩家信息...',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          } else if (players.isEmpty) {
            // 添加空数据状态显示
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无房间成员',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当前没有其他玩家连接到房间',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child:
                              _buildPlayerListItem(players[index], colorScheme),
                        );
                      },
                      childCount: players.length,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  int _getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 1; // 手机屏幕显示1列
    } else if (width < 900) {
      return 2; // 平板或小屏幕显示2列
    } else {
      return 3; // 大屏幕显示3列
    }
  }

  // 处理节点数据 - 合并了原来的两个相似方法
  Future<void> _processNodeData(KM km) async {
    try {
      final nodes = await km.nodes; // 获取最新的节点信息

      // 将节点数据转换为PlayerInfo对象
      List<PlayerInfo> nodePlayerInfos = [];

      for (var node in nodes) {
        // 计算上传下载速度和包数量总和
        int uploadSpeed = 0;
        int downloadSpeed = 0;
        int sentPackets = 0;
        int receivedPackets = 0;
        String connectionType =
            _mapConnectionType(node.cost, node.ipv4, km.virtualIP);

        // 如果有连接信息，计算网络统计数据
        if (node.connections.isNotEmpty) {
          for (var conn in node.connections) {
            uploadSpeed += conn.txBytes.toInt() ~/ 1024; // 转换为KB
            downloadSpeed += conn.rxBytes.toInt() ~/ 1024; // 转换为KB
            sentPackets += conn.txPackets.toInt();
            receivedPackets += conn.rxPackets.toInt();
          }
        }

        // 计算丢包率 (简单估算)
        double packetLossRate = 0.0;
        if (sentPackets > 0 && receivedPackets > 0) {
          packetLossRate = (1.0 - (receivedPackets / sentPackets)).abs() * 100;
          if (packetLossRate > 100) packetLossRate = 100.0;
          packetLossRate = double.parse(packetLossRate.toStringAsFixed(1));
        }

        // 创建PlayerInfo对象
        nodePlayerInfos.add(
          PlayerInfo(
            name: node.hostname,
            ip: node.ipv4, // 临时IP，实际应从节点信息中获取
            latency: (node.latencyMs).toInt(), // 转换为毫秒
            connectionType: connectionType,
            uploadSpeed: uploadSpeed,
            downloadSpeed: downloadSpeed,
            sentPackets: sentPackets,
            receivedPackets: receivedPackets,
            packetLossRate: packetLossRate,
            etVersion: node.version, // 获取版本信息
          ),
        );
      }

      if (!mounted) return; // 检查组件是否仍然挂载

      setState(() {
        players = nodePlayerInfos;
        isLoading = false;
      });
    } catch (e) {
      print("加载节点数据失败: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // 构建玩家信息卡片
  Widget _buildPlayerCard(PlayerInfo player, ColorScheme colorScheme) {
    // 根据延迟值确定颜色
    Color latencyColor = _getLatencyColor(player.latency);

    // 根据连接类型选择图标
    IconData connectionIcon = _getConnectionIcon(player.connectionType);

    return FloatingCard(
      colorScheme: colorScheme,
      maxWidth: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 玩家名称和连接类型
          Row(
            children: [
              Icon(Icons.person, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  player.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConnectionTypeColor(
                      player.connectionType, colorScheme),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      connectionIcon,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      player.connectionType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // IP地址
          _buildInfoRow(
            Icons.lan,
            'IP地址',
            player.ip,
            colorScheme,
            showCopyButton: true,
          ),
          const SizedBox(height: 12),

          // 延迟信息
          _buildInfoRow(
            Icons.speed,
            '延迟',
            '${player.latency} ms',
            colorScheme,
            valueColor: latencyColor,
          ),
          const SizedBox(height: 12),

          // ET版本
          _buildInfoRow(
            Icons.memory,
            'ET版本',
            player.etVersion,
            colorScheme,
          ),

          const Divider(height: 24),

          // 网络数据部分标题
          Row(
            children: [
              Icon(Icons.data_usage, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                '网络数据',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 网络数据信息 - 优化对齐方式
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildNetworkDataItemAligned(
                        '上传',
                        '${player.uploadSpeed} KB/s',
                        Icons.upload,
                        colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildNetworkDataItemAligned(
                        '下载',
                        '${player.downloadSpeed} KB/s',
                        Icons.download,
                        colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildNetworkDataItemAligned(
                        '发送包',
                        '${player.sentPackets}',
                        Icons.send,
                        colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildNetworkDataItemAligned(
                        '接收包',
                        '${player.receivedPackets}',
                        Icons.call_received,
                        colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // 丢包率信息
          _buildInfoRow(
            Icons.error_outline,
            '丢包率',
            '${player.packetLossRate}%',
            colorScheme,
            valueColor: _getPacketLossColor(player.packetLossRate),
          ),
        ],
      ),
    );
  }

  // 构建列表项视图
  Widget _buildPlayerListItem(PlayerInfo player, ColorScheme colorScheme) {
    // 根据延迟值确定颜色
    Color latencyColor = _getLatencyColor(player.latency);
    // 根据连接类型选择图标
    IconData connectionIcon = _getConnectionIcon(player.connectionType);

    // 检测是否为小屏幕设备
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return FloatingCard(
      colorScheme: colorScheme,
      maxWidth: double.infinity,
      child: isSmallScreen
          ? _buildMobilePlayerListItem(
              player, colorScheme, latencyColor, connectionIcon)
          : _buildDesktopPlayerListItem(
              player, colorScheme, latencyColor, connectionIcon),
    );
  }

  // 为移动设备优化的列表项布局
  Widget _buildMobilePlayerListItem(PlayerInfo player, ColorScheme colorScheme,
      Color latencyColor, IconData connectionIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 玩家名称和连接类型
        Row(
          children: [
            Icon(Icons.person, color: colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                player.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    _getConnectionTypeColor(player.connectionType, colorScheme),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    connectionIcon,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    player.connectionType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // IP地址
        _buildInfoRow(
          Icons.lan,
          'IP地址',
          player.ip,
          colorScheme,
          showCopyButton: true,
        ),
        const SizedBox(height: 8),

        // 延迟信息
        _buildInfoRow(
          Icons.speed,
          '延迟',
          '${player.latency} ms',
          colorScheme,
          valueColor: latencyColor,
        ),
        const SizedBox(height: 8),

        // ET版本
        _buildInfoRow(
          Icons.memory,
          'ET版本',
          player.etVersion,
          colorScheme,
        ),
        const SizedBox(height: 8),

        // 丢包率信息
        _buildInfoRow(
          Icons.error_outline,
          '丢包率',
          '${player.packetLossRate}%',
          colorScheme,
          valueColor: _getPacketLossColor(player.packetLossRate),
        ),

        // 网络数据部分
        const Divider(height: 16),

        // 网络数据信息 - 移动设备上使用紧凑布局
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildNetworkDataItem(
                      '上传',
                      '${player.uploadSpeed} KB/s',
                      Icons.upload,
                      colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildNetworkDataItem(
                      '下载',
                      '${player.downloadSpeed} KB/s',
                      Icons.download,
                      colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNetworkDataItem(
                      '发送包',
                      '${player.sentPackets}',
                      Icons.send,
                      colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildNetworkDataItem(
                      '接收包',
                      '${player.receivedPackets}',
                      Icons.call_received,
                      colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 为桌面设备优化的列表项布局
  Widget _buildDesktopPlayerListItem(PlayerInfo player, ColorScheme colorScheme,
      Color latencyColor, IconData connectionIcon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧玩家基本信息
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 玩家名称和连接类型
              Row(
                children: [
                  Icon(Icons.person, color: colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      player.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getConnectionTypeColor(
                          player.connectionType, colorScheme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          connectionIcon,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          player.connectionType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // IP地址
              _buildInfoRow(
                Icons.lan,
                'IP地址',
                player.ip,
                colorScheme,
                showCopyButton: true,
              ),
              const SizedBox(height: 8),

              // ET版本
              _buildInfoRow(
                Icons.memory,
                'ET版本',
                player.etVersion,
                colorScheme,
              ),
            ],
          ),
        ),

        // 中间网络状态信息
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 延迟信息
              _buildInfoRow(
                Icons.speed,
                '延迟',
                '${player.latency} ms',
                colorScheme,
                valueColor: latencyColor,
              ),
              const SizedBox(height: 8),

              // 丢包率信息
              _buildInfoRow(
                Icons.error_outline,
                '丢包率',
                '${player.packetLossRate}%',
                colorScheme,
                valueColor: _getPacketLossColor(player.packetLossRate),
              ),
              const SizedBox(height: 8),

              // 上传下载速度
              Row(
                children: [
                  Expanded(
                    child: _buildNetworkDataItem(
                      '上传',
                      '${player.uploadSpeed} KB/s',
                      Icons.upload,
                      colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildNetworkDataItem(
                      '下载',
                      '${player.downloadSpeed} KB/s',
                      Icons.download,
                      colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 右侧包数据信息
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNetworkDataItem(
                '发送包',
                '${player.sentPackets}',
                Icons.send,
                colorScheme.primary,
              ),
              const SizedBox(height: 8),
              _buildNetworkDataItem(
                '接收包',
                '${player.receivedPackets}',
                Icons.call_received,
                colorScheme.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 更紧凑的网络数据项
  Widget _buildNetworkDataItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 构建信息行
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme, {
    Color? valueColor,
    bool showCopyButton = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        // 添加复制按钮到标签和值之间
        if (showCopyButton)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: '复制$label',
            onPressed: () {
              // 复制到剪贴板
              Clipboard.setData(ClipboardData(text: value));
              // 显示提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已复制: $value'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 构建对齐的网络数据项
  Widget _buildNetworkDataItemAligned(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 根据延迟值获取颜色
  Color _getLatencyColor(int latency) {
    if (latency < 50) {
      return Colors.green;
    } else if (latency < 100) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // 根据丢包率获取颜色
  Color _getPacketLossColor(double lossRate) {
    if (lossRate < 1.0) {
      return Colors.green;
    } else if (lossRate < 5.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // 如果传入数值=1就是p2p 否则是relay 最后判断是不是等于本机IP如果等于就是direct 本机ip传入
  String _mapConnectionType(int connType, String ip, String thisip) {
    // 新增服务器IP判断
    if (ip == "0.0.0.0") {
      return '服务器';
    }
    // 如果是本机IP，返回direct
    if (ip == thisip) {
      return '本机';
    }
    // 根据连接成本判断连接类型
    if (connType == 1) {
      return '直链';
    } else if (connType >= 2) {
      return '中转';
    }
    return '未知';
  }

  // 根据连接类型获取图标
  IconData _getConnectionIcon(String connectionType) {
    // 将连接类型转为小写并进行匹配
    String lowerType = connectionType.toLowerCase();
    // 新增服务器图标
    if (lowerType.contains('server') || lowerType.contains('服务器')) {
      return Icons.dns;
    } else if (lowerType.contains('p2p') || lowerType.contains('直链')) {
      return Icons.link;
    } else if (lowerType.contains('relay') || lowerType.contains('中转')) {
      return Icons.swap_horiz;
    } else if (lowerType.contains('direct') || lowerType.contains('本机')) {
      return Icons.computer;
    } else {
      return Icons.device_unknown;
    }
  }

  // 根据连接类型获取颜色
  Color _getConnectionTypeColor(
      String connectionType, ColorScheme colorScheme) {
    // 将连接类型转为小写并进行匹配
    String lowerType = connectionType.toLowerCase();
    if (lowerType.contains('server') || lowerType.contains('服务器')) {
      return Colors.deepPurple;
    } else if (lowerType.contains('p2p') || lowerType.contains('直链')) {
      return Colors.green;
    } else if (lowerType.contains('relay') || lowerType.contains('中转')) {
      return Colors.orange;
    } else if (lowerType.contains('direct') || lowerType.contains('本机')) {
      return colorScheme.primary;
    } else {
      return Colors.grey;
    }
  }
}
