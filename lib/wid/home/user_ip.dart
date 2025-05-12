import 'package:astral/wid/home_box.dart';
import 'package:flutter/material.dart';
import 'package:astral/k/app_s/aps.dart';

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

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 从 Aps 获取初始值
      _usernameController.text = _aps.PlayerName.value;
      _virtualIPController.text = _aps.ipv4.value;

      // 监听状态变化更新UI
      effect(() {
        final value = _aps.PlayerName.value;
        final value2 = _aps.ipv4.value;
        if (_usernameController.text != value) {
          _usernameController.text = value;
        }
        if (_virtualIPController.text != value2) {
          _virtualIPController.text = value2;
        }
      });
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
    var isValidIP = _isValidIPv4(_aps.ipv4.value);

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
              if (Aps().Connec_state.watch(context) == CoState.connected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '已锁定',
                    style: TextStyle(
                      color: colorScheme.onSecondaryContainer,
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
            enabled:
                (Aps().Connec_state.watch(context) == CoState.connected)
                    ? false
                    : true,
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
                      !_aps.dhcp.watch(context) &&
                      (Aps().Connec_state.watch(context) != CoState.connected),
                  onChanged: (value) {
                    if (!_aps.dhcp.watch(context)) {
                      setState(() {
                        isValidIP =
                            _aps.dhcp.watch(context) || _isValidIPv4(value);
                      });
                      _aps.updateIpv4(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: '虚拟网IP',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lan, color: colorScheme.primary),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    errorText:
                        !isValidIP && !_aps.dhcp.watch(context)
                            ? '请输入有效的IPv4地址'
                            : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Switch(
                    value: _aps.dhcp.watch(context),
                    onChanged: (value) {
                      if (Aps().Connec_state.watch(context) == CoState.idle) {
                        _aps.updateDhcp(value);
                      }
                    },
                  ),
                  Text(
                    _aps.dhcp.watch(context) ? "自动" : "手动",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          if (_aps.dhcp.watch(context))
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
