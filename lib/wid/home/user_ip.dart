import 'package:astral/wid/home_box.dart';
import 'package:flutter/material.dart';
import 'package:astral/k/app_s/aps.dart';

enum ConnectionState { notStarted, connecting, connected }

class UserIpBox extends StatefulWidget {
  const UserIpBox({super.key});

  @override
  State<UserIpBox> createState() => _UserIpBoxState();
}

class _UserIpBoxState extends State<UserIpBox> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _virtualIPController = TextEditingController();

  final FocusNode _usernameControllerFocusNode = FocusNode();
  final FocusNode _virtualIPFocusNode = FocusNode();

  final Aps _aps = Aps();

  bool _isAutoIP = true;
  final ConnectionState _connectionState = ConnectionState.notStarted;

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 从 Aps 获取初始值
      _usernameController.text = _aps.PlayerName.value;
      _virtualIPController.text = _aps.ipv4.value;
      _isAutoIP = _aps.dhcp.value;

      // 监听状态变化更新UI
      effect(() {
        final value = _aps.PlayerName.value;
        if (_usernameController.text != value) {
          _usernameController.text = value;
        }
      });

      // _aps.ipv4.addListener((value) {
      //   if (_virtualIPController.text != value) {
      //     _virtualIPController.text = value;
      //   }
      // });

      // _aps.dhcp.addListener((value) {
      //   if (_isAutoIP != value) {
      //     setState(() {
      //       _isAutoIP = value;
      //     });
      //   }
      // });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _virtualIPController.dispose();
    _usernameControllerFocusNode.dispose();
    _virtualIPFocusNode.dispose();
    super.dispose();
  }

  bool _isValidIPv4(String ip) {
    final RegExp ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegex.hasMatch(ip);
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    // 验证 IP 的有效性
    var isValidIP = _isAutoIP || _isValidIPv4(_virtualIPController.text);

    return HomeBox(
      widthSpan: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Icon(Icons.person, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                '用户信息',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              // 添加状态指示器
              if (_connectionState == ConnectionState.connected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '已锁定',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 用户名输入框
          TextField(
            controller: _usernameController,
            focusNode: _usernameControllerFocusNode,
            enabled: _connectionState != ConnectionState.connected,
            onChanged: (value) {
              _aps.updatePlayerName(value);
            },
            decoration: InputDecoration(
              labelText: '用户名',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.person, color: colorScheme.primary),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 12),

          // IP设置部分
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _virtualIPController,
                  focusNode: _virtualIPFocusNode,
                  enabled:
                      !_isAutoIP &&
                      _connectionState != ConnectionState.connected,
                  onChanged: (value) {
                    setState(() {
                      isValidIP = _isAutoIP || _isValidIPv4(value);
                    });
                  },
                  onEditingComplete: () {
                    if (!_isAutoIP) {
                      _aps.ipv4.value = _virtualIPController.text;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: '虚拟网IP',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lan, color: colorScheme.primary),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    errorText: !isValidIP && !_isAutoIP ? '请输入有效的IPv4地址' : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Switch(
                    value: _isAutoIP,
                    onChanged:
                        _connectionState != ConnectionState.connected
                            ? (value) {
                              setState(() {
                                _isAutoIP = value;
                              });
                              _aps.dhcp.value = value;
                              if (!value) {
                                _aps.ipv4.value = _virtualIPController.text;
                              }
                            }
                            : null,
                  ),
                  Text(_isAutoIP ? "自动" : "手动", style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          if (_isAutoIP)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '系统将自动分配虚拟网IP',
                style: TextStyle(color: colorScheme.secondary, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
