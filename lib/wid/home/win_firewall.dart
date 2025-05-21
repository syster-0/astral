import 'package:astral/wid/home_box.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class WinFirewall extends StatefulWidget {
  const WinFirewall({super.key});

  @override
  State<WinFirewall> createState() => _WinFirewallState();
}

class _WinFirewallState extends State<WinFirewall> {
  bool _isEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFirewallStatus();
  }

  Future<void> _checkFirewallStatus() async {
    setState(() => _isLoading = true);
    try {
      final result = await Process.run('netsh', ['advfirewall', 'show', 'allprofiles', 'state']);
      setState(() {
        _isEnabled = result.stdout.toString().contains('State                                 ON');
      });
    } catch (e) {
      debugPrint('Error checking firewall status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFirewall(bool enable) async {
    setState(() => _isLoading = true);
    try {
      final action = enable ? 'on' : 'off';
      await Process.run('netsh', ['advfirewall', 'set', 'allprofiles', 'state', action], runInShell: true);
      await _checkFirewallStatus();
    } catch (e) {
      debugPrint('Error toggling firewall: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return HomeBox(
      widthSpan: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Windows 防火墙',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Text('状态: ${_isEnabled ? "已启用" : "已禁用"}'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _toggleFirewall(!_isEnabled),
                  child: Text(_isEnabled ? '一键关闭' : '一键开启'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

