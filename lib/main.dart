import 'dart:io';

import 'package:astral/fun/up.dart';
import 'package:astral/k/database/app_data.dart';
import 'package:astral/k/mod/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:astral/src/rust/frb_generated.dart';
import 'package:astral/app.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await WindowManagerUtils.initializeWindow();
  }

  // 仅在有效DSN存在时初始化Sentry
  final dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  if (dsn.isNotEmpty) {
    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.debug = false;
      options.environment = 'production';
      options.tracesSampleRate = 1.0;
      options.attachStacktrace = true;
    });

    // Sentry错误处理器
    FlutterError.onError = (FlutterErrorDetails details) {
      Sentry.captureException(details.exception, stackTrace: details.stack);
      FlutterError.dumpErrorToConsole(details);
    };
  } else {
    // 本地错误处理器（无Sentry）
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
    print('⚠️ Sentry disabled - No valid DSN provided');
  }
  await AppDatabase().init();
  AppInfoUtil.init();
  await RustLib.init();
  runApp(const KevinApp());
}
