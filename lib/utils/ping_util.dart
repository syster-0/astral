import 'dart:io';
import 'dart:async';

class PingUtil {
  static Future<int?> ping(String host) async {
    try {
      // 从 host:port 格式中提取主机名
      final hostname = host.split(':')[0];
      final post = host.split(':')[1];

      // 使用 Socket 连接来测量实际网络延迟
      final startTime = DateTime.now();
      final socket = await Socket.connect(hostname, int.parse(post),
          timeout: const Duration(seconds: 2));
      final endTime = DateTime.now();

      // 关闭连接
      await socket.close();

      return endTime.difference(startTime).inMilliseconds;
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }
  }
}
