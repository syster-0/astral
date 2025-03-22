import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/src/rust/frb_generated.dart';
import 'package:astral/utils/logger.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

// 定义FFI接口

class NetworkUtil {
  // 获取网卡跃点列表
  static Future<NetworkInterfaceHops> getInterfaceMetrics() async {
    try {
      NetworkInterfaceHops hops = await getNetworkInterfaceHops();
      return hops;
    } catch (e) {
      Logger.info('获取网卡跃点列表失败: $e');
      return NetworkInterfaceHops(hops: []);
    }
  }
}
