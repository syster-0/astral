import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 公共服务器对话框组件
class PublicServersDialog extends StatefulWidget {
  final List<Map<String, String>> servers;
  final Function(String, String) onAddServer;

  const PublicServersDialog({
    Key? key,
    required this.servers,
    required this.onAddServer,
  }) : super(key: key);

  @override
  State<PublicServersDialog> createState() => _PublicServersDialogState();

  static Future<void> show(
    BuildContext context, 
    Function(String, String) onAddServer,
    List<String> existingUrls,
  ) async {
    // 获取服务器列表时过滤已存在的
    final completer = Completer<void>();
    final filteredServers = <Map<String, String>>[];
    
    // 这里需要实际获取服务器列表
    final allServers = await _fetchPublicServers();
    if (allServers != null) {
      filteredServers.addAll(allServers.where((server) => 
        server.containsKey('url') && 
        !existingUrls.any((existingUrl) => 
          existingUrl.trim().toLowerCase() == server['url']!.trim().toLowerCase())
      ));
    }

    // 根据屏幕宽度选择显示方式
    if (MediaQuery.of(context).size.width > 600) {
      // PC端显示为对话框
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            width: 500,
            height: 600,
            child: PublicServersDialog(
              servers: filteredServers,
              onAddServer: (name, url) {
                // 添加服务器后关闭对话框
                onAddServer(name, url);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已添加服务器: $name')),
                );
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      );
    } else {
      // 移动端显示为底部弹窗
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: PublicServersDialog(
              servers: filteredServers,
              onAddServer: (name, url) {
                // 添加服务器后关闭对话框
                onAddServer(name, url);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已添加服务器: $name')),
                );
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      );
    }
    
    return completer.future;
  }

  static Future<List<Map<String, String>>?> _fetchPublicServers() async {
    try {
      final response = await http.get(
        Uri.parse('https://astral.fan/server.json'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => {
          'name': item['name'] as String,
          'url': item['url'] as String,
        }).toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      // 添加详细的错误日志
      debugPrint('获取公共服务器列表失败: $e');
      return []; // 返回空列表而不是null，避免后续空值异常
    }
  }
}

class _PublicServersDialogState extends State<PublicServersDialog> {
  late List<Map<String, String>> _servers;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 直接使用传入的服务器数据
    _servers = widget.servers;
    _isLoading = false;
    setState(() {}); // 触发初始渲染
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 8, 16), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.public,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '公共服务器',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '点击服务器卡片右方的添加按钮进行添加',
                textAlign: TextAlign.left,
                maxLines: null,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // 服务器列表 - 使用 Expanded 填充剩余空间
        Expanded(
          child: _buildContent(),
        ),

        // 底部按钮
        Padding(
          padding: const EdgeInsets.all(24),
          child: FilledButton(
            onPressed: Navigator.of(context).pop,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 0),
            ),
            child: const Text('关闭'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在获取公共服务器列表...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '获取服务器列表失败',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: _servers.length,
        itemBuilder: (context, index) {
          final server = _servers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  server['name']!,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  server['url']!,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => widget.onAddServer(server['name']!, server['url']!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('添加', style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}