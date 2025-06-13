import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// 简单的WebSocket测试服务器
class WebSocketTestServer {
  HttpServer? _server;
  final Set<WebSocket> _connections = {};
  int? _port;
  
  /// 启动测试服务器
  Future<void> start({int port = 37628}) async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      _port = _server!.port;
      print('WebSocket测试服务器启动成功，端口: $_port');
      
      _server!.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          try {
            final webSocket = await WebSocketTransformer.upgrade(request);
            _handleConnection(webSocket, request.connectionInfo?.remoteAddress.address ?? 'unknown');
          } catch (e) {
            print('WebSocket升级失败: $e');
          }
        } else {
          // 返回简单的HTTP响应
          request.response.headers.contentType = ContentType.html;
          request.response.write('''
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket测试服务器</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>WebSocket测试服务器</h1>
    <p>服务器正在运行，端口: $_port</p>
    <p>连接数: ${_connections.length}</p>
    <script>
        const ws = new WebSocket('ws://localhost:$_port');
        ws.onopen = function() {
            console.log('WebSocket连接已建立');
            ws.send(JSON.stringify({
                type: 'test',
                message: '来自浏览器的测试消息',
                timestamp: Date.now()
            }));
        };
        ws.onmessage = function(event) {
            console.log('收到消息:', event.data);
        };
        ws.onclose = function() {
            console.log('WebSocket连接已关闭');
        };
        ws.onerror = function(error) {
            console.error('WebSocket错误:', error);
        };
    </script>
</body>
</html>
          ''');
          await request.response.close();
        }
      });
      
    } catch (e) {
      print('启动WebSocket测试服务器失败: $e');
      rethrow;
    }
  }
  
  /// 处理新连接
  void _handleConnection(WebSocket webSocket, String remoteAddress) {
    print('新的WebSocket连接: $remoteAddress');
    _connections.add(webSocket);
    
    // 发送欢迎消息
    final welcomeMessage = {
      'type': 'welcome',
      'message': '欢迎连接到WebSocket测试服务器',
      'serverPort': _port,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    webSocket.add(jsonEncode(welcomeMessage));
    
    // 监听消息
    webSocket.listen(
      (dynamic message) {
        try {
          print('收到消息: $message');
          final data = jsonDecode(message.toString());
          
          // 回显消息给发送者
          final echoMessage = {
            'type': 'echo',
            'originalMessage': data,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
          webSocket.add(jsonEncode(echoMessage));
          
          // 广播给其他连接
          _broadcast(jsonEncode({
            'type': 'broadcast',
            'from': remoteAddress,
            'message': data,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          }), exclude: webSocket);
          
        } catch (e) {
          print('处理消息失败: $e');
        }
      },
      onDone: () {
        print('WebSocket连接关闭: $remoteAddress');
        _connections.remove(webSocket);
      },
      onError: (error) {
        print('WebSocket连接错误: $error');
        _connections.remove(webSocket);
      },
    );
  }
  
  /// 广播消息给所有连接（可排除指定连接）
  void _broadcast(String message, {WebSocket? exclude}) {
    final deadConnections = <WebSocket>[];
    
    for (final connection in _connections) {
      if (connection == exclude) continue;
      
      try {
        connection.add(message);
      } catch (e) {
        print('广播消息失败: $e');
        deadConnections.add(connection);
      }
    }
    
    // 清理失效连接
    for (final dead in deadConnections) {
      _connections.remove(dead);
    }
  }
  
  /// 停止服务器
  Future<void> stop() async {
    // 关闭所有连接
    for (final connection in _connections) {
      try {
        await connection.close();
      } catch (e) {
        print('关闭WebSocket连接失败: $e');
      }
    }
    _connections.clear();
    
    // 关闭服务器
    try {
      await _server?.close();
      _server = null;
      print('WebSocket测试服务器已停止');
    } catch (e) {
      print('停止WebSocket测试服务器失败: $e');
    }
  }
  
  /// 获取服务器端口
  int? get port => _port;
  
  /// 获取连接数
  int get connectionCount => _connections.length;
}

/// 测试函数
Future<void> testWebSocketServer() async {
  final server = WebSocketTestServer();
  
  try {
    await server.start();
    print('测试服务器已启动，访问 http://localhost:${server.port} 进行测试');
    
    // 运行10分钟后自动停止
    Timer(const Duration(minutes: 10), () async {
      print('测试时间结束，停止服务器...');
      await server.stop();
    });
    
  } catch (e) {
    print('测试服务器启动失败: $e');
  }
}