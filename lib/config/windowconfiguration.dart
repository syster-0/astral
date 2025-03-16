import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> setupWindow() async {
  WindowOptions windowOptions = const WindowOptions(
    size: Size(850, 520),
    minimumSize: Size(300, 300),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // 隐藏标题栏
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
