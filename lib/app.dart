import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:astral/fun/reg.dart';
import 'package:astral/screens/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:astral/k/app_s/aps.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// 仅在桌面平台导入系统托盘

class KevinApp extends StatefulWidget {
  const KevinApp({super.key});
  @override
  State<KevinApp> createState() => _KevinAppState();
}

class _KevinAppState extends State<KevinApp> {
  final _aps = Aps();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    if (!kIsWeb) {
      registerUriProtocol();
    }
    _appLinks = AppLinks();

    // 处理初始链接
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // 监听后续链接
    _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'astral') {
      print('Received astral link: ${uri.toString()}');
      // 在这里添加业务逻辑处理
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        // 添加国际化支持
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Insert this line
      supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _aps.themeColor.watch(context), // 设置当前主题颜色,
        brightness: Brightness.light,
      ).copyWith(
        textTheme: Typography.material2021().black.apply(fontFamily: 'MiSans'),
        primaryTextTheme: Typography.material2021().black.apply(
          fontFamily: 'MiSans',
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _aps.themeColor.watch(context),
        brightness: Brightness.dark,
      ).copyWith(
        textTheme: Typography.material2021().white.apply(fontFamily: 'MiSans'),
        primaryTextTheme: Typography.material2021().white.apply(
          fontFamily: 'MiSans',
        ),
      ),
      themeMode: _aps.themeMode.watch(context), // 设置当前主题模式
      home: MainScreen(),
    );
  }
}
