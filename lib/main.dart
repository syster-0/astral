import 'dart:async';
import 'dart:io';

import 'package:astral/fun/up.dart';
import 'package:astral/k/database/app_data.dart';
import 'package:astral/k/mod/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:astral/src/rust/frb_generated.dart';
import 'package:astral/app.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:developer';

// 修改后的main.dart文件内容
void main() async {
  // 添加Zone错误致命检测（必须放在最顶部）
  BindingBase.debugZoneErrorsAreFatal = true;
  log('应用启动初始化开始');

  runZonedGuarded(
    () async {
      log('初始化Flutter绑定');
      WidgetsFlutterBinding.ensureInitialized();

      log('开始初始化数据库');
      await AppDatabase().init();
      log('数据库初始化完成');

      log('初始化应用信息工具');
      AppInfoUtil.init();

      log('加载Rust库');
      await RustLib.init();
      log('Rust库加载完成');

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        log('初始化窗口管理器');
        await WindowManagerUtils.initializeWindow();
        log('窗口管理器初始化完成');
      }

      log('配置Sentry监控');
      await SentryFlutter.init((options) {
        options.dsn =
            'https://8ddef9dc25ba468431473fc15187df30@o4509285217402880.ingest.de.sentry.io/4509285224087632';
      });
      log('Sentry配置完成');

      log('启动应用界面');
      runApp(const KevinApp());
    },
    (exception, stackTrace) async {
      log('发生未捕获异常: $exception');
      await Sentry.captureException(exception, stackTrace: stackTrace);
    },
  );
}
