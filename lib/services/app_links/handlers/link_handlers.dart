import 'package:astral/fun/e_d_room.dart';
import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/foundation.dart';

class LinkHandlers {
  static final _aps = Aps();

  // 处理房间分享链接: astral://room?code=JWT_TOKEN
  static Future<void> handleRoom(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      if (code == null || code.isEmpty) {
        debugPrint('房间分享链接缺少 code 参数');
        return;
      }
      // 去除 code 中的所有空格和换行符
      final cleanedCode = code.replaceAll(RegExp(r'\s+'), '');

      // 解密 JWT 获取房间信息
      final room = decryptRoomFromJWT(cleanedCode);
      if (room == null) {
        debugPrint('无效的房间分享码');
        return;
      }
      // 添加房间到数据库
      await _aps.addRoom(room);
      debugPrint('成功添加分享房间: ${room.name}');
    } catch (e) {
      debugPrint('处理房间分享链接失败: $e');
    }
  }

  // 处理调试链接: astral://debug
  static Future<void> handleDebug(Uri uri) async {
    // 打印链接内容
    debugPrint('链接内容: $uri');
    debugPrint('链接类型: ${uri.runtimeType}');

    // 打印链接各个部分
    debugPrint('scheme: ${uri.scheme}');
    debugPrint('host: ${uri.host}');
    debugPrint('path: ${uri.path}');
    debugPrint('query参数: ${uri.queryParameters}');
    debugPrint('fragment: ${uri.fragment}');
  }
}
