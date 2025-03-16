import 'package:flutter/material.dart';
import 'package:ASTRAL/src/rust/frb_generated.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'config/windowconfiguration.dart';
import 'config/app_config.dart';
import 'utils/kv_state.dart';
import 'package:provider/provider.dart'; // 添加这一行
import 'package:tray_manager/tray_manager.dart';
import 'package:ASTRAL/utils/app_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化应用信息
  await AppInfoUtil.init();
  await windowManager.ensureInitialized();
  // 设置窗口属性
  await setupWindow();
  await AppConfig.init();
  // 初始化应用信息
  await RustLib.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => KM(),
      child: const MyApp(),
    ),
  );
}
