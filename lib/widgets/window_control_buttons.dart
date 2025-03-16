import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../config/app_config.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

// Create an instance of Windows Notification with your application name
// application id must be null in packaged mode
final _winNotifyPlugin = WindowsNotification(applicationId: 'Astral');
// create new NotificationMessage instance with id, title, body, and images
NotificationMessage message = NotificationMessage.fromPluginTemplate(
  "astral_minimized",
  "Astral 已最小化到托盘",
  "应用程序正在后台运行，点击托盘图标可以恢复窗口",
  // largeImage: "assets/images/icon.ico",
  // image: file_path
);

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
              // 替换托盘提示为系统通知
              _winNotifyPlugin.showNotificationPluginTemplate(message);
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
