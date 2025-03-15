// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:ASTRAL/utils/app_info.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 旋转的图标效果
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.tertiary,
                            Theme.of(context).colorScheme.primary,
                          ],
                          stops: const [0.0, 0.3, 0.6, 1.0],
                          transform:
                              GradientRotation(_controller.value * 2 * math.pi),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.games,
                          size: 50,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // 应用名称添加渐变效果
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ).createShader(bounds),
                child: Text(
                  'ASTRAL',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              // 版本号添加动画效果
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  AppInfoUtil.getFullVersion(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 20),
              // 卡片添加动画和阴影效果
              _buildAnimatedCard(
                context,
                '特别鸣谢',
                '特别感谢EasyTier作者所做的工作和帮助，为本项目提供了重要的技术支持。如果您有功能需求或遇到bug，欢迎加入我们的QQ群获取帮助和了解最新动态。',
                Icons.favorite,
                Colors.red,
                delay: 200,
              ),
              // 合并后的卡片

              const SizedBox(height: 30),
              // 按钮添加动画效果
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.group_add),
                  label: const Text('加入QQ群'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    final url = 'https://qm.qq.com/q/ErscyNPTzO';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      // 无法打开链接时显示提示
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('无法打开QQ群链接')),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              // 添加版权信息
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Text(
                  '© ${DateTime.now().year} ASTRAL Team',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(BuildContext context, String title, String content,
      IconData icon, Color iconColor,
      {int delay = 0}) {
    // 根据当前主题调整颜色
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // 确保 opacity 值在有效范围内 (0.0 到 1.0)
        final safeOpacity = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: safeOpacity,
          child: Transform.translate(
            offset: Offset(100 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 8,
        shadowColor: iconColor.withOpacity(isDarkMode ? 0.3 : 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                isDarkMode
                    ? cardColor.withOpacity(0.9).withBlue(cardColor.blue + 5)
                    : iconColor.withOpacity(0.05),
                cardColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(isDarkMode ? 0.05 : 0.1),
                blurRadius: 10,
                spreadRadius: -5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧图标 - 适配深色模式
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(isDarkMode ? 0.2 : 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(isDarkMode ? 0.15 : 0.2),
                        blurRadius: isDarkMode ? 6 : 8,
                        spreadRadius: isDarkMode ? 0 : 1,
                      ),
                    ],
                    gradient: RadialGradient(
                      colors: [
                        iconColor.withOpacity(isDarkMode ? 0.8 : 0.7),
                        iconColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                      ],
                      stops: const [0.0, 1.0],
                      radius: 0.8,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // 右侧内容 - 适配深色模式
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color:
                                  iconColor.withOpacity(isDarkMode ? 0.9 : 0.8),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        color: iconColor.withOpacity(isDarkMode ? 0.4 : 0.3),
                        thickness: 1.5,
                        endIndent: 60,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              letterSpacing: 0.5,
                              color: textColor
                                  ?.withOpacity(isDarkMode ? 0.9 : 1.0),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
