import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../widgets/窗口控制按钮.dart';
import '../widgets/主题选择器.dart';
import '../utils/主题工具.dart';
import '../config/导航配置.dart';

class MainScreen extends StatefulWidget {
  final Function toggleThemeMode;
  final Function(Color) changeSeedColor;
  final ThemeMode currentThemeMode;
  final int currentIndex;
  final Function(int) changeIndex;
  final Color seedColor;

  const MainScreen({
    super.key,
    required this.toggleThemeMode,
    required this.changeSeedColor,
    required this.currentThemeMode,
    required this.currentIndex,
    required this.changeIndex,
    required this.seedColor,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  // 缓存所有页面
  late List<Widget> _pages;
  late List<NavItem> _navItems;
  late AnimationController _titleAnimationController;

  @override
  void initState() {
    super.initState();
    _initPages();

    // 初始化标题动画控制器
    _titleAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当主题模式或种子颜色变化时，重新初始化页面
    if (oldWidget.currentThemeMode != widget.currentThemeMode ||
        oldWidget.seedColor != widget.seedColor) {
      NavigationConfig.clearPageInstances();
      _initPages();
    }
  }

  void _initPages() {
    _navItems = NavigationConfig.getNavItems(
      toggleThemeMode: widget.toggleThemeMode,
      changeSeedColor: widget.changeSeedColor,
      currentThemeMode: widget.currentThemeMode,
    );

    // 预先创建所有页面
    _pages = _navItems.map((item) => item.pageBuilder()).toList();
  }

  // 将侧边栏构建方法整合到MainScreen类中
  Widget buildSidebar(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: List.generate(
          _navItems.length,
          (index) => ListTile(
            leading: Icon(_navItems[index].icon),
            title: Text(_navItems[index].label),
            selected: widget.currentIndex == index,
            onTap: () => widget.changeIndex(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度，用于判断使用哪种导航方式
    final double screenWidth = MediaQuery.of(context).size.width;
    // 设置一个阈值，当宽度大于此值时使用侧边栏
    final bool useSidebar = screenWidth > 600;

    // 创建一个共享的 IndexedStack 实例
    final indexedStack = IndexedStack(
      index: widget.currentIndex,
      children: _pages,
    );

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.tertiary,
            ],
          ).createShader(bounds),
          child: const Text(
            'ASTRAL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        elevation: 2,
        scrolledUnderElevation: 0, // 修改为0，防止滚动时出现阴影变化
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer, // 使用更深沉的主题颜色
        foregroundColor:
            Theme.of(context).colorScheme.onPrimaryContainer, // 对应的前景色
        // 设置滚动时的背景色保持一致
        flexibleSpace: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (details) {
            windowManager.startDragging();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer, // 与backgroundColor保持一致
            ),
          ),
        ),
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        toolbarHeight: 40, // 减小AppBar的高度
        iconTheme: const IconThemeData(size: 18), // 设置所有图标的大小
        actionsIconTheme: const IconThemeData(size: 18), // 设置操作区图标的大小

        actions: [
          IconButton(
            icon: Icon(
              widget.currentThemeMode == ThemeMode.light
                  ? Icons.wb_sunny
                  : widget.currentThemeMode == ThemeMode.dark
                      ? Icons.nightlight_round
                      : Icons.auto_mode,
            ),
            onPressed: () => widget.toggleThemeMode(),
            tooltip: getThemeModeText(widget.currentThemeMode),
            padding: const EdgeInsets.all(8), // 减小按钮内边距
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => showThemeColorPicker(
                context, widget.seedColor, widget.changeSeedColor),
            tooltip: '选择主题颜色',
            padding: const EdgeInsets.all(8), // 减小按钮内边距
          ),
          const WindowControls(),
        ],
      ),
      // 根据屏幕宽度决定使用侧边栏还是底部导航栏
      body: useSidebar
          ? Row(
              children: [
                // 固定显示的侧边栏
                SizedBox(
                  width: 120,
                  child: buildSidebar(context),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // 使用共享的 IndexedStack
                Expanded(
                  child: indexedStack,
                ),
              ],
            )
          : indexedStack,
      // 只在窄屏幕时显示底部导航栏
      bottomNavigationBar: useSidebar
          ? null
          : NavigationBar(
              selectedIndex: widget.currentIndex,
              onDestinationSelected: (index) => widget.changeIndex(index),
              destinations: List.generate(
                _navItems.length,
                (index) => NavigationDestination(
                  icon: Icon(_navItems[index].icon),
                  selectedIcon: Icon(_navItems[index].selectedIcon),
                  label: _navItems[index].label,
                ),
              ),
            ),
    );
  }
}
