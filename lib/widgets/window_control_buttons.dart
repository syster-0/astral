import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../config/app_config.dart';
import 'package:tray_manager/tray_manager.dart';
class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => windowManager.minimize(),
          tooltip: '最小化',
        ),
        IconButton(
          icon: const Icon(Icons.crop_square),
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
          tooltip: '最大化/还原',
        ),
        IconButton(
  icon: const Icon(Icons.close),
  onPressed: () async {
    if (AppConfig().closeToTray) {
      await windowManager.hide(); // 隐藏主窗口
      await trayManager.setToolTip('FLN2N 正在后台运行'); // 设置托盘提示
    } else {
      windowManager.close();
    }
  },
  tooltip: '关闭',
),
      ],
    );
  }
}
