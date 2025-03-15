import 'package:flutter/material.dart';
import '../screens/首页.dart';
import '../screens/设置.dart';
import '../screens/关于.dart';
import '../screens/房间.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function() pageBuilder; // 修改为函数，延迟创建页面

  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.pageBuilder,
  });
}

class NavigationConfig {
  // 保存已创建的页面实例
  static final Map<int, Widget> _pageInstances = {};

  static List<NavItem> getNavItems({
    required Function toggleThemeMode,
    required Function(Color) changeSeedColor,
    required ThemeMode currentThemeMode,
  }) {
    return [
      NavItem(
        label: '首页',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        pageBuilder: () => _getOrCreatePage(
            0,
            () => HomePage(
                  toggleThemeMode: toggleThemeMode,
                  changeSeedColor: changeSeedColor,
                  currentThemeMode: currentThemeMode,
                )),
      ),
      NavItem(
        label: '房间',
        icon: Icons.room_outlined,
        selectedIcon: Icons.room,
        pageBuilder: () => _getOrCreatePage(1, () => const RoomPage()),
      ),
      NavItem(
        label: '设置',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        pageBuilder: () => _getOrCreatePage(2, () => const SettingsPage()),
      ),
      NavItem(
        label: '关于',
        icon: Icons.info_outlined,
        selectedIcon: Icons.info,
        pageBuilder: () => _getOrCreatePage(3, () => const InfoPage()),
      ),
    ];
  }

  // 获取或创建页面实例
  static Widget _getOrCreatePage(int index, Widget Function() creator) {
    if (!_pageInstances.containsKey(index)) {
      _pageInstances[index] = creator();
    }
    return _pageInstances[index]!;
  }

  // 清除缓存的页面实例（在需要重新创建页面时调用，如主题变更）
  static void clearPageInstances() {
    _pageInstances.clear();
  }
}
