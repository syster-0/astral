import 'package:astral/k/app_s/aps.dart';
import 'package:astral/wid/home_box.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

// 添加模拟数据模型
class NetworkNode {
  final String id;
  final String name;
  final bool isServer;
  final List<NetworkConnection> connections;

  NetworkNode({
    required this.id,
    required this.name,
    this.isServer = false,
    this.connections = const [],
  });
}

class NetworkConnection {
  final String targetId;
  final int latency; // 毫秒

  NetworkConnection({required this.targetId, required this.latency});
}

class VirtualIpBox extends StatelessWidget {
  const VirtualIpBox({super.key});

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
              Icon(Icons.network_check, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                '网络状态',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              // 添加状态指示器
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    ConnectionState.connected,
                    colorScheme,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(ConnectionState.connected),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              Icon(Icons.public, size: 20, color: colorScheme.primary),
              const Text(
                '虚拟 IP: ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                Aps().ipv4.watch(context),
                style: TextStyle(color: colorScheme.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum ConnectionState { notStarted, connecting, connected }

// 获取状态颜色
Color _getStatusColor(ConnectionState state, ColorScheme colorScheme) {
  switch (state) {
    case ConnectionState.notStarted:
      return Colors.grey;
    case ConnectionState.connecting:
      return Colors.orange;
    case ConnectionState.connected:
      return Colors.green;
  }
}

// 获取状态文本
String _getStatusText(ConnectionState state) {
  switch (state) {
    case ConnectionState.notStarted:
      return '未连接';
    case ConnectionState.connecting:
      return '连接中';
    case ConnectionState.connected:
      return '已连接';
  }
}
