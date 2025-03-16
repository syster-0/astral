// 导入必要的Flutter包和自定义模块
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:system_tray/system_tray.dart';
import 'dart:io';
import 'screens/Home.dart';
import 'config/themeconfiguration.dart';
import 'config/app_config.dart';
import 'package:astral/utils/up.dart'; // 添加这行导入

// 定义应用程序的主要StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// 应用程序的状态管理类
class _MyAppState extends State<MyApp> {
  // 主题相关的状态变量
  late ThemeMode _themeMode;
  late bool useMaterial3;
  late Color _seedColor;
  int _currentIndex = 0;

  // 系统托盘相关变量
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();

  @override
  void initState() {
    super.initState();
    // 从配置中加载设置
    final config = AppConfig();
    _themeMode = config.themeMode;
    useMaterial3 = true;
    _seedColor = config.seedColor;

    // 初始化系统托盘
    initSystemTray();

    // 添加版本检查（在下一帧执行确保context可用）
    Future.microtask(() {
      final updateChecker = UpdateChecker(
        owner: 'ldoubil',
        repo: 'astral',
      );
      if (mounted) {
        updateChecker.scheckForUpdates(context);
      }
    });
  }

  // 初始化系统托盘
  Future<void> initSystemTray() async {
    // 设置托盘图标
    String path = 'assets/icon.ico';

    // 初始化托盘
    await _systemTray.initSystemTray(
      title: "ASTRAL",
      iconPath: path,
    );

    // 设置托盘菜单
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: '打开应用', onClicked: (menuItem) => _appWindow.show()),
      MenuItemLabel(label: '退出', onClicked: (menuItem) => exit(0)),
    ]);

    // 设置托盘菜单
    await _systemTray.setContextMenu(menu);

    // 设置托盘点击事件
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        _appWindow.show();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

  // 切换主题模式的方法
  void toggleThemeMode() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
      AppConfig().setThemeMode(_themeMode);
    });
  }

  // 更改主题色的方法
  void changeSeedColor(Color color) {
    // 使用 Future.microtask 延迟状态更新，避免在当前帧中触发重建
    setState(() {
      _seedColor = color;
      AppConfig().setSeedColor(color);
    });
  }

  // 更改底部导航栏选中索引的方法
  void changeIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 返回应用程序的根Widget
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 隐藏调试标签
      localizationsDelegates: const [
        // 添加国际化支持
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Insert this line
      supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
      theme: ThemeConfig.getLightTheme(
        useMaterial3: useMaterial3,
        seedColor: _seedColor,
      ).copyWith(
          textTheme: Typography.material2021().black.apply(
                fontFamily: 'MiSans',
              ),
          primaryTextTheme: Typography.material2021().black.apply(
                fontFamily: 'MiSans',
              )),
      darkTheme: ThemeConfig.getDarkTheme(
        useMaterial3: useMaterial3,
        seedColor: _seedColor,
      ).copyWith(
        textTheme: Typography.material2021().white.apply(
              fontFamily: 'MiSans',
            ),
        primaryTextTheme: Typography.material2021().white.apply(
              fontFamily: 'MiSans',
            ),
      ),
      themeMode: _themeMode, // 设置当前主题模式
      home: MainScreen(
        // 设置主屏幕
        // 切换主题模式的回调函数
        toggleThemeMode: toggleThemeMode,
        // 更改主题色的回调函数
        changeSeedColor: changeSeedColor,
        // 当前主题模式状态
        currentThemeMode: _themeMode,
        // 当前选中的底部导航栏索引
        currentIndex: _currentIndex,
        // 更改底部导航栏索引的回调函数
        changeIndex: changeIndex,
        // 当前主题色
        seedColor: _seedColor,
      ),
    );
  }
}
