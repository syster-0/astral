import 'package:astral/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:astral/src/rust/frb_generated.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform, Directory;
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'config/windowconfiguration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_config.dart';
import 'utils/kv_state.dart';
import 'package:astral/utils/app_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化应用信息
  await AppInfoUtil.init();
  // 初始化日志系统
  await Logger.getInstance();
  Logger.info('应用启动');
  // 设置Flutter错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error('Flutter错误: ${details.exception}');
    Logger.error('堆栈跟踪: ${details.stack}');
    // 继续将错误报告给Flutter
    FlutterError.dumpErrorToConsole(details);
  };
  // 为Android平台设置配置目录
  if (Platform.isAndroid) {
    final appDir = await getApplicationDocumentsDirectory();
    AppConfig.setConfigDir(appDir.path);
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    // 设置窗口属性
    await setupWindow();
  }
  await RustLib.init();
  await AppConfig.init();

  // 初始化应用信息
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}
