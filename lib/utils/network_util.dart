import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

// 定义FFI接口
typedef GetNetworkInterfaceMetricsNative = Pointer<Utf8> Function();
typedef GetNetworkInterfaceMetrics = Pointer<Utf8> Function();

class NetworkUtil {
  static final DynamicLibrary _dylib = () {
    if (Platform.isWindows) {
      return DynamicLibrary.open('astral_core.dll');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('libastral_core.dylib');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libastral_core.so');
    } else {
      throw UnsupportedError('不支持的平台');
    }
  }();

  static final GetNetworkInterfaceMetrics _getNetworkInterfaceMetrics =
      _dylib.lookupFunction<GetNetworkInterfaceMetricsNative,
          GetNetworkInterfaceMetrics>('get_network_interface_metrics');

  // 获取网卡跃点列表
  static Map<String, int> getInterfaceMetrics() {
    try {
      final resultPtr = _getNetworkInterfaceMetrics();
      final resultString = resultPtr.toDartString();

      // 释放内存
      calloc.free(resultPtr);

      // 解析JSON字符串为Map
      final Map<String, dynamic> jsonResult = jsonDecode(resultString);

      // 转换为<String, int>格式
      final Map<String, int> metrics = {};
      jsonResult.forEach((key, value) {
        if (value is int) {
          metrics[key] = value;
        } else if (value is String) {
          metrics[key] = int.tryParse(value) ?? 0;
        }
      });

      return metrics;
    } catch (e) {
      print('获取网卡跃点列表失败: $e');
      return {};
    }
  }
}
