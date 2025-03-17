import 'dart:io';
import 'dart:async';

class PingUtil {
  static Future<int?> ping(String host) async {
    Socket? socket;
    try {
      // 从 host:port 格式中提取主机名
      final hostname = host.split(':')[0];
      final port = host.split(':')[1]; // 修正变量名 post -> port

      // 使用 Socket 连接来测量实际网络延迟
      final startTime = DateTime.now();
      socket = await Socket.connect(hostname, int.parse(port),
          timeout: const Duration(seconds: 2));
      final endTime = DateTime.now();

      // 计算延迟时间
      return endTime.difference(startTime).inMilliseconds;
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    } finally {
      // 确保在所有情况下都关闭 socket 连接
      socket?.destroy();
      socket = null;
    }
  }
}
