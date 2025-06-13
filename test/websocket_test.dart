import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../lib/services/websocket_test_server.dart';

/// WebSocket客户端测试
class WebSocketClientTest {
  WebSocket? _webSocket;
  final String _serverUrl;
  
  WebSocketClientTest(this._serverUrl);
  
  /// 连接到WebSocket服务器
  Future<void> connect() async {
    try {
      print('正在连接到: $_serverUrl');
      _webSocket = await WebSocket.connect(_serverUrl);
      print('WebSocket连接成功');
      
      // 监听消息
      _webSocket!.listen(
        (dynamic message) {
          try {
            final data = jsonDecode(message.toString());
            print('收到服务器消息: ${data['type']} - ${data['message']}');
          } catch (e) {
            print('收到原始消息: $message');
          }
        },
        onDone: () {
          print('WebSocket连接已关闭');
        },
        onError: (error) {
          print('WebSocket连接错误: $error');
        },
      );
      
    } catch (e) {
      print('WebSocket连接失败: $e');
      rethrow;
    }
  }
  
  /// 发送测试消息
  Future<void> sendTestMessage(String message) async {
    if (_webSocket == null) {
      print('WebSocket未连接');
      return;
    }
    
    try {
      final testMessage = {
        'type': 'test_message',
        'content': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'clientId': 'test_client_${DateTime.now().millisecondsSinceEpoch}',
      };
      
      _webSocket!.add(jsonEncode(testMessage));
      print('已发送测试消息: $message');
    } catch (e) {
      print('发送消息失败: $e');
    }
  }
  
  /// 关闭连接
  Future<void> close() async {
    try {
      await _webSocket?.close();
      _webSocket = null;
      print('WebSocket客户端已关闭');
    } catch (e) {
      print('关闭WebSocket客户端失败: $e');
    }
  }
}

/// 运行WebSocket测试
Future<void> runWebSocketTest() async {
  print('=== WebSocket功能测试开始 ===');
  
  // 启动测试服务器
  final server = WebSocketTestServer();
  
  try {
    await server.start(port: 37628);
    print('测试服务器已启动，端口: ${server.port}');
    
    // 等待服务器完全启动
    await Future.delayed(const Duration(seconds: 1));
    
    // 创建多个客户端进行测试
    final clients = <WebSocketClientTest>[];
    
    for (int i = 0; i < 3; i++) {
      final client = WebSocketClientTest('ws://localhost:${server.port}');
      await client.connect();
      clients.add(client);
      
      // 发送测试消息
      await client.sendTestMessage('来自客户端 $i 的测试消息');
      
      // 间隔一下
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    print('已创建 ${clients.length} 个客户端连接');
    print('服务器当前连接数: ${server.connectionCount}');
    
    // 让客户端继续发送一些消息
    for (int round = 0; round < 3; round++) {
      await Future.delayed(const Duration(seconds: 2));
      
      for (int i = 0; i < clients.length; i++) {
        await clients[i].sendTestMessage('第 ${round + 1} 轮消息 - 客户端 $i');
      }
    }
    
    // 测试完成，清理资源
    print('\n=== 开始清理测试资源 ===');
    
    // 关闭所有客户端
    for (final client in clients) {
      await client.close();
    }
    
    // 等待一下再关闭服务器
    await Future.delayed(const Duration(seconds: 1));
    
    // 关闭服务器
    await server.stop();
    
    print('=== WebSocket功能测试完成 ===');
    
  } catch (e) {
    print('测试过程中发生错误: $e');
    await server.stop();
  }
}

/// 主函数
void main() async {
  await runWebSocketTest();
}