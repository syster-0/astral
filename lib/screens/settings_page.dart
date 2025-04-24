import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.settings),
                title: Text('网络设置'),
              ),

              // 压缩算法下拉单选
              ListTile(
                title: const Text('P2P打洞'),
                subtitle: const Text('优先采用什么协议'),
                trailing: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: DropdownButton<String>(
                        value:
                            Aps().defaultProtocol.watch(context).isEmpty
                                ? 'tcp'
                                : Aps().defaultProtocol.watch(context),
                        items: const [
                          DropdownMenuItem(
                            value: 'tcp',
                            child: Text('TCP', style: TextStyle(fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: 'udp',
                            child: Text('UDP', style: TextStyle(fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: 'ws',
                            child: Text(
                              'WebSocket',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'wss',
                            child: Text('WSS', style: TextStyle(fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: 'quic',
                            child: Text('QUIC', style: TextStyle(fontSize: 14)),
                          ),
                        ],
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (value) {
                          if (value != null) {
                            Aps().updateDefaultProtocol(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              SwitchListTile(
                title: const Text('是否启用加密'),
                subtitle: const Text('会自动设置MTU'),
                value: Aps().enableEncryption.watch(context),
                onChanged: (value) {
                  Aps().updateEnableEncryption(value);
                },
              ),

              SwitchListTile(
                title: const Text('延迟优先'),
                subtitle: const Text('是否优先考虑延迟'),
                value: Aps().latencyFirst.watch(context),
                onChanged: (value) {
                  Aps().updateLatencyFirst(value);
                },
              ),

              SwitchListTile(
                title: const Text('出口节点'),
                subtitle: const Text('是否启用出口节点'),
                value: Aps().enableExitNode.watch(context),
                onChanged: (value) {
                  Aps().updateEnableExitNode(value);
                },
              ),

              SwitchListTile(
                title: const Text('TUN设备'),
                subtitle: const Text('是否禁用TUN设备'),
                value: Aps().noTun.watch(context),
                onChanged: (value) {
                  Aps().updateNoTun(value);
                },
              ),

              SwitchListTile(
                title: Row(
                  children: [
                    const Text('smoltcp网络栈'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '不推荐',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                subtitle: const Text('轻量级 TCP/IP 协议栈'),
                value: Aps().useSmoltcp.watch(context),
                onChanged: (value) {
                  Aps().updateUseSmoltcp(value);
                },
              ),

              SwitchListTile(
                title: const Text('禁用P2P'),
                subtitle: const Text('如果打洞困难可以禁用p2p'),
                value: Aps().disableP2p.watch(context),
                onChanged: (value) {
                  Aps().updateDisableP2p(value);
                },
              ),

              SwitchListTile(
                title: const Text('中继对等RPC'),
                subtitle: const Text('是否中继所有对等RPC'),
                value: Aps().relayAllPeerRpc.watch(context),
                onChanged: (value) {
                  Aps().updateRelayAllPeerRpc(value);
                },
              ),

              SwitchListTile(
                title: const Text('禁用UDP打洞'),
                subtitle: const Text('是否禁用UDP打洞'),
                value: Aps().disableUdpHolePunching.watch(context),
                onChanged: (value) {
                  Aps().updateDisableUdpHolePunching(value);
                },
              ),

              SwitchListTile(
                title: const Text('启用多线程'),
                subtitle: const Text('是否启用多线程'),
                value: Aps().multiThread.watch(context),
                onChanged: (value) {
                  Aps().updateMultiThread(value);
                },
              ),

              // 压缩算法下拉单选
              ListTile(
                title: const Text('压缩算法'),
                subtitle: const Text('选择数据压缩方式'),
                trailing: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: DropdownButton<int>(
                        value: Aps().dataCompressAlgo.watch(context),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('默认', style: TextStyle(fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text('不压缩', style: TextStyle(fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              '高性能压缩(Zstd)',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (value) {
                          if (value != null) {
                            Aps().updateDataCompressAlgo(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              SwitchListTile(
                title: const Text('绑定设备'),
                subtitle: const Text('只使用物理网卡,防止和其他虚拟网卡沟通'),
                value: Aps().bindDevice.watch(context),
                onChanged: (value) {
                  Aps().updateBindDevice(value);
                },
              ),

              SwitchListTile(
                title: const Text('启用KCP代理'),
                subtitle: const Text('是否启用 KCP 代理'),
                value: Aps().enableKcpProxy.watch(context),
                onChanged: (value) {
                  Aps().updateEnableKcpProxy(value);
                },
              ),

              SwitchListTile(
                title: const Text('用KCP输入'),
                subtitle: const Text('否接收 KCP 协议的数据'),
                value: Aps().disableKcpInput.watch(context),
                onChanged: (value) {
                  Aps().updateDisableKcpInput(value);
                },
              ),

              SwitchListTile(
                title: const Text('禁用中继KCP'),
                subtitle: const Text('是否为其他节点转发 KCP 流量'),
                value: Aps().disableRelayKcp.watch(context),
                onChanged: (value) {
                  Aps().updateDisableRelayKcp(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
