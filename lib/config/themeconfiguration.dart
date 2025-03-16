import 'package:flutter/material.dart';

// 应用主题配置
class ThemeConfig {
  // 默认使用Material 3
  static const bool defaultUseMaterial3 = true;

  // 默认种子颜色
  static const Color defaultSeedColor = Colors.blue;

  // 默认主题模式
  static const ThemeMode defaultThemeMode = ThemeMode.system;

  // 获取亮色主题
  static ThemeData getLightTheme({
    required bool useMaterial3,
    required Color seedColor,
  }) {
    return ThemeData(
      useMaterial3: useMaterial3,
      colorSchemeSeed: seedColor,
      brightness: Brightness.light,
    );
  }

  // 获取暗色主题
  static ThemeData getDarkTheme({
    required bool useMaterial3,
    required Color seedColor,
  }) {
    return ThemeData(
      useMaterial3: useMaterial3,
      colorSchemeSeed: seedColor,
      brightness: Brightness.dark,
    );
  }
}
