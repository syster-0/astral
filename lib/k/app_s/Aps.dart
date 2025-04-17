import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:astral/k/database/app_data.dart';
export 'package:signals_flutter/signals_flutter.dart';

/// 全局状态管理类
class Aps {
  //单例模式
  Aps._internal() {
    _initThemeSettings();
  }
  static final Aps _instance = Aps._internal();
  factory Aps() => _instance;

  // 初始化主题设置
  Future<void> _initThemeSettings() async {
    final database = AppDatabase();
    themeMode.value = await database.themeSettings.getThemeMode();
    themeColor.value = Color(await database.themeSettings.getThemeColor());
  }

  /// **********************************************************************************************************
  /// 主题颜色
  final Signal<Color> themeColor = signal(Colors.blue);
  // 更新主题颜色
  Future<void> updateThemeColor(Color color) async {
    themeColor.value = color;
    await AppDatabase().themeSettings.updateThemeColor(color.toARGB32());
  }

  /// **********************************************************************************************************
  /// 主题模式
  final Signal<ThemeMode> themeMode = signal(ThemeMode.system); // 初始化为跟随系统
  // 更新主题模式
  Future<void> updateThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await AppDatabase().themeSettings.updateThemeMode(mode);
  }

  /// **********************************************************************************************************

  /// 软件名
  final Signal<String> appName = signal('Astro Game'); // 初始化为Astro Game
  // 更新软件名
  Future<void> updateAppName(String name) async {
    appName.value = name;
  }

  /// **********************************************************************************************************

  /// 获取屏幕分割宽度 区分手机和桌面
  final Signal<double> screenSplitWidth = signal(480); // 初始化为480
  //更新屏幕分割宽度
  void updateScreenSplitWidth(double width) {
    screenSplitWidth.value = width;
    // 判断是否为桌面
    isDesktop.value = width > 480;
  }

  /// **********************************************************************************************************

  /// 是否为桌面
  final Signal<bool> isDesktop = signal(false); // 初始化为false
  /// **********************************************************************************************************

  // 添加鼠标悬停状态跟踪
  final Signal<int?> hoveredIndex = signal(null);

  // 更新鼠标悬停状态
  void updateHoveredIndex(int? index) {
    hoveredIndex.value = index;
  }

  /// **********************************************************************************************************

  // 构建导航项
  final Signal<int> selectedIndex = Signal(0);
  // 更新导航项
  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  /// **********************************************************************************************************
}
