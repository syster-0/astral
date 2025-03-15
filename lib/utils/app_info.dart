import 'package:package_info_plus/package_info_plus.dart';

class AppInfoUtil {
  static PackageInfo? _packageInfo;

  /// 初始化应用信息
  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// 获取应用版本号 (例如: 1.0.0)
  static String getVersion() {
    return _packageInfo?.version ?? '';
  }

  /// 获取应用构建号 (例如: 1)
  static String getBuildNumber() {
    return _packageInfo?.buildNumber ?? '';
  }

  /// 获取完整版本号 (例如: 1.0.0+1)
  static String getFullVersion() {
    final version = getVersion();
    final buildNumber = getBuildNumber();
    return '$version+$buildNumber';
  }

  /// 获取应用名称
  static String getAppName() {
    return _packageInfo?.appName ?? '';
  }

  /// 获取包名
  static String getPackageName() {
    return _packageInfo?.packageName ?? '';
  }
}
