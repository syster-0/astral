import 'package:astral/k/app_s/Aps.dart';
import 'package:astral/k/database/app_data.dart';
import 'package:astral/k/mod/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:astral/src/rust/frb_generated.dart';
import 'package:astral/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 绑定已初始化
  await AppDatabase().init(); // 初始化数据库
  Aps(); // 初始化全局状态管理类
  WindowManagerUtils.initializeWindow(); // 初始化窗口管理器
  await RustLib.init(); // 初始化 Rust 库
  runApp(const KevinApp()); // 运行应用程序
}
