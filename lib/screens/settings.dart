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
  late List<Map<String, dynamic>> _serverList;
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
    serverIP = _getSelectedServersString();
    _closeToTray = _appConfig.closeToTray; // 初始化托盘设置
    // 初始化全局ping开关
    _pingEnabled = _appConfig.enablePing;

    // 初始化 ping 状态
    for (var server in _serverList) {
      pingResults[server['url']] = null;
    }

    // 开始 ping 所有服务器
    _startPingAllServers();
  }

  // 获取选中的服务器字符串
  String _getSelectedServersString() {
    final selected =
        _serverList.where((server) => server['selected'] == true).toList();
    if (selected.isEmpty && _serverList.isNotEmpty) {
      return _serverList.first['url'];
    }
    return selected.map((server) => server['url']).join(', ');
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
          _pingServerOnce(server['url']);
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
          pingResults[server['url']] = null;
        }
      }
    });
  }

  // 添加服务器对话框
  Future<void> _showAddServerDialog() async {
    final urlController = TextEditingController();
    final nameController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加服务器'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '服务器名称',
                hintText: '自定义名称',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: 'example.com:port',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'url': urlController.text,
                  'name': nameController.text.isNotEmpty
                      ? nameController.text
                      : urlController.text,
                });
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        // 添加新服务器，默认不选中
        _serverList.add({
          'url': result['url'],
          'name': result['name'],
          'selected': false,
        });
        _appConfig.setServerList(_serverList);

        // 初始化新服务器的 ping 状态
        pingResults[result['url']] = null;
      });
    }
  }

  // 编辑服务器对话框
  Future<void> _showEditServerDialog(int index) async {
    final server = _serverList[index];
    final urlController = TextEditingController(text: server['url']);
    final nameController = TextEditingController(text: server['name']);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑服务器'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '服务器名称',
                hintText: '自定义名称',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: 'example.com:port',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'url': urlController.text,
                  'name': nameController.text.isNotEmpty
                      ? nameController.text
                      : urlController.text,
                });
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null) {
      final oldUrl = server['url'];
      setState(() {
        _serverList[index] = {
          'url': result['url'],
          'name': result['name'],
          'selected': server['selected'],
        };
        _appConfig.setServerList(_serverList);

        // 更新 ping 状态
        if (oldUrl != result['url']) {
          pingResults[result['url']] = pingResults[oldUrl];
          pingResults.remove(oldUrl);
        }

        // 更新当前选中的服务器显示
        serverIP = _getSelectedServersString();
        // 使用新的 serverList 方法替代直接设置 serverIP
        Provider.of<KM>(context, listen: false).serverList = _serverList;
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
        pingResults.remove(server['url']);

        // 确保至少有一个服务器被选中
        if (_serverList.isNotEmpty &&
            !_serverList.any((server) => server['selected'] == true)) {
          _serverList.first['selected'] = true;
        }

        // 更新当前选中的服务器显示
        serverIP = _getSelectedServersString();
        // 使用新的 serverList 方法替代直接设置 serverIP
        Provider.of<KM>(context, listen: false).serverList = _serverList;
      });
    }
  }

  // 切换服务器选中状态
  void _toggleServerSelection(int index) {
    setState(() {
      _serverList[index]['selected'] =
          !(_serverList[index]['selected'] ?? false);
      _appConfig.setServerList(_serverList);

      // 更新当前选中的服务器显示
      serverIP = _getSelectedServersString();
      // 使用新的 serverList 方法替代直接设置 serverIP
      Provider.of<KM>(context, listen: false).serverList = _serverList;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_serverList[index]['selected']
                ? '已选中服务器: ${_serverList[index]['name']}'
                : '已取消选中: ${_serverList[index]['name']}')),
      );
    });
  }

  // 添加构建 ping 显示组件的方法
  Widget _buildPingWidget(String url) {
    final pingResult = pingResults[url];
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
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dns),
                title: const Text('已选中的服务器'),
                subtitle: Text(serverIP),
              ),
              ExpansionTile(
                leading: const Icon(Icons.list),
                title: const Text('服务器列表'),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _serverList.length,
                    itemBuilder: (context, index) {
                      final server = _serverList[index];
                      final isSelected = server['selected'] == true;

                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected ? Colors.green : null,
                        ),
                        title: Row(
                          children: [
                            Text(server['name']),
                            const SizedBox(width: 8),
                            _buildPingWidget(server['url']),
                          ],
                        ),
                        subtitle: Text(server['url']),
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
                        onTap: () => _toggleServerSelection(index),
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
