import 'dart:async';
import 'package:astral/utils/app_info.dart';
import 'package:astral/utils/up.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/ping_util.dart';
import 'package:astral/utils/kv_state.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

final updateChecker = UpdateChecker(
  owner: 'ldoubil',
  repo: 'astral',
);

class _SettingsPageState extends State<SettingsPage> {
  late List<String> _serverList;
  late String _currentServer;
  final _appConfig = AppConfig();
  bool _closeToTray = false; // 添加关闭进入托盘变量
  bool _pingEnabled = true; // 添加全局ping开关

  String serverIP = "";
  // 添加 ping 相关状态
  Map<String, int?> pingResults = {};

  @override
  void initState() {
    super.initState();
    _serverList = _appConfig.serverList;
    _currentServer = _appConfig.currentServer;
    serverIP = _appConfig.currentServer;
    _closeToTray = _appConfig.closeToTray; // 初始化托盘设置
    // 初始化全局ping开关
    _pingEnabled = _appConfig.enablePing;

    // 初始化 ping 状态
    for (var server in _serverList) {
      pingResults[server] = null;
    }

    // 开始 ping 所有服务器
    _startPingAllServers();
  }

  // 添加一个计时器变量来控制 ping 操作
  Timer? _pingTimer;

  // 新增方法：开始 ping 所有服务器
  void _startPingAllServers() {
    // 取消之前的计时器（如果存在）
    _pingTimer?.cancel();

    // 创建新的计时器，使用设置的间隔时间
    _pingTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_pingEnabled) {
        for (var server in _serverList) {
          _pingServerOnce(server);
        }
      }
    });
  }

  @override
  void dispose() {
    // 取消计时器
    _pingTimer?.cancel();
    _pingTimer = null;
    super.dispose();
  }

  // 执行单次 ping 操作
  Future<void> _pingServerOnce(String server) async {
    final pingResult = await PingUtil.ping(server);

    if (mounted) {
      setState(() {
        pingResults[server] = pingResult;
      });
    }
  }

  // 切换全局ping状态
  void _togglePingStatus(bool value) {
    setState(() {
      _pingEnabled = value;
      _appConfig.setEnablePing(_pingEnabled);
      if (!_pingEnabled) {
        // 如果关闭ping，清空所有结果
        for (var server in _serverList) {
          pingResults[server] = null;
        }
      }
    });
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

      setState(() {
        _serverList.removeAt(index);
        _appConfig.setServerList(_serverList);

        // 移除 ping 状态
        pingResults.remove(server);

        if (_currentServer == server && _serverList.isNotEmpty) {
          _currentServer = _serverList[0];
          _appConfig.setCurrentServer(_currentServer);
        }
      });
    }
  }

  // 添加构建 ping 显示组件的方法
  Widget _buildPingWidget(String server) {
    final pingResult = pingResults[server];
    if (!_pingEnabled) {
      return const Text('Ping已关闭', style: TextStyle(color: Colors.grey));
    } else if (pingResult == null) {
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

  @override
  Widget build(BuildContext context) {
    // updateChecker.checkForUpdates(context);
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
                children: [
                  // 在服务器列表前添加当前服务器的 ping 状态显示
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _serverList.length,
                    itemBuilder: (context, index) {
                      final server = _serverList[index];

                      return ListTile(
                        leading: const Icon(Icons.computer),
                        title: Row(
                          children: [
                            Text('服务器 ${index + 1}'),
                            const SizedBox(width: 8),
                            _buildPingWidget(server),
                          ],
                        ),
                        subtitle: Text(server),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                            _appConfig.setCurrentServer(_currentServer);
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
              SwitchListTile(
                title: const Text('启用服务器Ping测试'),
                subtitle: const Text('定期测试所有服务器的网络延迟'),
                value: _pingEnabled,
                onChanged: _togglePingStatus,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.info),
                title: Text('应用版本'),
                subtitle: Text(AppInfoUtil.getVersion()),
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('检查更新'),
                onTap: () {
                  updateChecker.checkForUpdates(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
