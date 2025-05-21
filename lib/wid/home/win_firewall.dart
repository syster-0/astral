import 'package:astral/wid/home_box.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class WinFirewall extends StatefulWidget {
  const WinFirewall({super.key});

  @override
  State<WinFirewall> createState() => _WinFirewallState();
}

class _WinFirewallState extends State<WinFirewall> {
  bool _isLoading = false;
  Map<String, bool> _firewallStatus = {
    'Domain': false,
    'Private': false,
    'Public': false
  };

  @override
  void initState() {
    super.initState();
    _checkFirewallStatus();
  }

  Future<void> _checkFirewallStatus() async {
    setState(() => _isLoading = true);
    try {
      final result = await Process.run('netsh', ['advfirewall', 'show', 'allprofiles', 'state']);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      
      setState(() {
        // 域配置文件
        if (lines.any((line) => line.contains('Domain Profile Settings:'))) {
          final domainState = lines
              .skipWhile((line) => !line.contains('Domain Profile Settings:'))
              .take(3)
              .any((line) => line.trim() == 'State                                 ON');
          _firewallStatus['Domain'] = domainState;
        }
        
        // 专用配置文件
        if (lines.any((line) => line.contains('Private Profile Settings:'))) {
          final privateState = lines
              .skipWhile((line) => !line.contains('Private Profile Settings:'))
              .take(3)
              .any((line) => line.trim() == 'State                                 ON');
          _firewallStatus['Private'] = privateState;
        }
        
        // 公用配置文件
        if (lines.any((line) => line.contains('Public Profile Settings:'))) {
          final publicState = lines
              .skipWhile((line) => !line.contains('Public Profile Settings:'))
              .take(3)
              .any((line) => line.trim() == 'State                                 ON');
          _firewallStatus['Public'] = publicState;
        }
      });
    } catch (e) {
      debugPrint('Error checking firewall status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFirewall(String profile, bool enable) async {
    setState(() => _isLoading = true);
    try {
      final action = enable ? 'on' : 'off';
      await Process.run(
        'netsh', 
        ['advfirewall', 'set', profile.toLowerCase(), 'state', action],
        runInShell: true
      );
      await _checkFirewallStatus();
    } catch (e) {
      debugPrint('Error toggling firewall: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFirewallStatus(String profile, bool isEnabled, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: isEnabled ? colorScheme.primary : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$profile 防火墙',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isEnabled ? colorScheme.secondaryContainer : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isEnabled ? '已启用' : '已禁用',
              style: TextStyle(
                color: isEnabled ? colorScheme.onSecondaryContainer : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _toggleFirewall(profile, !isEnabled),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? Colors.red.shade50 : colorScheme.primaryContainer,
              foregroundColor: isEnabled ? Colors.red : colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(isEnabled ? '关闭' : '开启'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    
    return HomeBox(
      widthSpan: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Windows 防火墙',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: _firewallStatus.entries.map((entry) => 
                _buildFirewallStatus(entry.key, entry.value, colorScheme)
              ).toList(),
            ),
        ],
      ),
    );
  }
}

