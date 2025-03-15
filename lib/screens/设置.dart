import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/ping_util.dart';
import 'package:ASTRAL/utils/状态.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  double _fontSize = 16.0;
  late List<String> _serverList;
  late String _currentServer;
  final _appConfig = AppConfig();
  bool _closeToTray = false; // 添加关闭进入托盘变量

  String serverIP = "";
  // 添加 ping 相关状态
  Map<String, int?> pingResults = {};
  Map<String, bool> isPinging = {};

  @override
  void initState() {
    super.initState();
    _serverList = _appConfig.serverList;
    _currentServer = _appConfig.currentServer;
    serverIP = _appConfig.currentServer;
    _closeToTray = _appConfig.closeToTray; // 初始化托盘设置

    // 初始化 ping 状态
    for (var server in _serverList) {
      pingResults[server] = null;
      isPinging[server] = false;
    }

    // 开始 ping 当前服务器，并设置为持续 ping
    _startPingServer(_currentServer, forceContinuous: true);
  }

  @override
  void dispose() {
    // 停止所有 ping
    for (var server in _serverList) {
      _stopPingServer(server);
    }
    super.dispose();
  }

  // 修改开始 ping 方法，添加强制持续 ping 参数
  void _startPingServer(String server, {bool forceContinuous = false}) {
    if (isPinging[server] == true) return;

    isPinging[server] = true;
    if (forceContinuous) {
      isPinging[server] = true; // 设置为持续 ping 状态
    }
    _pingServer(server);
  }

  // 修改停止 ping 方法
  void _stopPingServer(String server) {
    // 如果是当前服务器，不允许停止
    if (server == _currentServer) return;
    isPinging[server] = false;
  }

  // 执行 ping 操作
  Future<void> _pingServer(String server) async {
    if (isPinging[server] != true) return;

    final pingResult = await PingUtil.ping(server);

    if (mounted) {
      setState(() {
        pingResults[server] = pingResult;
      });

      // 1秒后再次 ping
      Future.delayed(const Duration(seconds: 1), () {
        _pingServer(server);
      });
    }
  }

  // 添加服务器对话框
  Future<void> _showAddServerDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加服务器'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '服务器地址',
            hintText: 'example.com:port',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('添加'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _serverList.add(result);
        _appConfig.setServerList(_serverList);

        // 初始化新服务器的 ping 状态
        pingResults[result] = null;
        isPinging[result] = false;
      });
    }
  }

  // 编辑服务器对话框
  Future<void> _showEditServerDialog(int index) async {
    final controller = TextEditingController(text: _serverList[index]);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑服务器'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '服务器地址',
            hintText: 'example.com:port',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _serverList[index] = result;
        _appConfig.setServerList(_serverList);
      });
    }
  }

  // 删除服务器
  Future<void> _deleteServer(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个服务器吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final server = _serverList[index];

      // 停止 ping
      _stopPingServer(server);

      setState(() {
        _serverList.removeAt(index);
        _appConfig.setServerList(_serverList);

        // 移除 ping 状态
        pingResults.remove(server);
        isPinging.remove(server);

        if (_currentServer == server && _serverList.isNotEmpty) {
          _currentServer = _serverList[0];
          _appConfig.setCurrentServer(_currentServer);
          _startPingServer(_currentServer);
        }
      });
    }
  }

  // 添加构建 ping 显示组件的方法
  Widget _buildPingWidget(String server) {
    final pingResult = pingResults[server];
    if (server == _currentServer || isPinging[server] == true) {
      if (pingResult == null) {
        return const Text('测试中...', style: TextStyle(color: Colors.grey));
      } else {
        return Text(
          '${pingResult}ms',
          style: TextStyle(
            color: pingResult < 100
                ? Colors.green
                : (pingResult < 300 ? Colors.orange : Colors.red),
          ),
        );
      }
    }
    return const Text('点击测试', style: TextStyle(color: Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    serverIP = Provider.of<KM>(context).virtualIP;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dns),
                title: Row(
                  children: [
                    const Text('当前服务器'),
                    const SizedBox(width: 8),
                    _buildPingWidget(_currentServer),
                  ],
                ),
                subtitle: Text(_currentServer),
              ),
              ExpansionTile(
                leading: const Icon(Icons.list),
                title: const Text('服务器列表'),
                onExpansionChanged: (expanded) {
                  // 展开/折叠时处理其他服务器的 ping 状态
                  setState(() {
                    for (var server in _serverList) {
                      if (server != _currentServer) {
                        if (expanded) {
                          // 如果之前是手动开启的，则恢复 ping
                          if (isPinging[server] == true) {
                            _startPingServer(server);
                          }
                        } else {
                          // 折叠时暂停所有非当前服务器的 ping
                          _stopPingServer(server);
                        }
                      }
                    }
                  });
                },
                children: [
                  // 在服务器列表前添加当前服务器的 ping 状态显示
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _serverList.length,
                    itemBuilder: (context, index) {
                      final server = _serverList[index];
                      final pingResult = pingResults[server];

                      // 构建延迟显示组件
                      Widget pingWidget;
                      if (isPinging[server] == true) {
                        if (pingResult == null) {
                          pingWidget = const Text('测试中...',
                              style: TextStyle(color: Colors.grey));
                        } else {
                          pingWidget = Text('${pingResult}ms',
                              style: TextStyle(
                                  color: pingResult < 100
                                      ? Colors.green
                                      : (pingResult < 300
                                          ? Colors.orange
                                          : Colors.red)));
                        }
                      } else {
                        pingWidget = const Text('点击测试',
                            style: TextStyle(color: Colors.grey));
                      }

                      return ListTile(
                        leading: const Icon(Icons.computer),
                        title: Row(
                          children: [
                            Text('服务器 ${index + 1}'),
                            const SizedBox(width: 8),
                            pingWidget,
                          ],
                        ),
                        subtitle: Text(server),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 添加 ping 按钮
                            IconButton(
                              icon: Icon(
                                isPinging[server] == true
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: isPinging[server] == true
                                    ? Colors.blue
                                    : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isPinging[server] == true) {
                                    _stopPingServer(server);
                                  } else {
                                    _startPingServer(server);
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditServerDialog(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteServer(index),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _currentServer = server;
                            Provider.of<KM>(context, listen: false).serverIP =
                                server;
                            // 开始 ping 新选择的服务器
                            _startPingServer(server);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已切换到服务器: $server')),
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('添加新服务器'),
                    onTap: _showAddServerDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 添加应用设置卡片
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.settings),
                title: Text('应用设置'),
              ),
              SwitchListTile(
                title: const Text('关闭时最小化到托盘'),
                subtitle: const Text('关闭窗口时应用将继续在后台运行'),
                value: _closeToTray,
                onChanged: (value) {
                  setState(() {
                    _closeToTray = value;
                    _appConfig.setCloseToTray(value);
                  });
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('应用版本'),
                subtitle: Text('灰度版本'),
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('检查更新'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('灰度版本不支持更新')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
