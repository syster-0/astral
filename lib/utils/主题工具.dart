import 'package:flutter/material.dart';

String getThemeModeText(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => '浅色模式',
    ThemeMode.dark => '深色模式',
    ThemeMode.system => '跟随系统',
  };
}
