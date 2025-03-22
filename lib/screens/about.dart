// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:astral/utils/app_info.dart';
import 'dart:math' as math;

// 贡献者模型
class Contributor {
  final String name;
  final String? socialAccount;
  final String? avatarUrl; // 新增头像URL字段
  final String? description; // 将badges改为description，可以为空

  Contributor({
    required this.name,
    this.socialAccount,
    this.avatarUrl,
    this.description,
  });
}

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Contributor> contributors = [
    Contributor(
      name: "sycglier",
      avatarUrl:
          "http://q.qlogo.cn/headimg_dl?dst_uin=2911141099&spec=640&img_type=jpg", // 可以设置头像URL
      description: "woohhhhh-重要贡献者", // 一句话描述
    ),
    Contributor(
      name: "忧郁の棉花",
      avatarUrl:
          "http://q.qlogo.cn/headimg_dl?dst_uin=3422240662&spec=640&img_type=jpg",
      description: "提供公共服务器列表维护支持",
    ),
    // Contributor(
    //   name: "玩家三",
    //   socialAccount: "@player3",
    //   avatarUrl: null,
    //   description: "测试与文档编写",
    // ),
    // 可以添加更多贡献者
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
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
              // 静态图标
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
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
              const SizedBox(height: 20),
              // 应用名称
              Text(
                'ASTRAL',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              // 版本号
              Text(
                AppInfoUtil.getVersion(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              // 静态卡片
              _buildCard(
                context,
                '特别鸣谢',
                '特别感谢EasyTier作者所做的工作和帮助，为本项目提供了重要的技术支持。如果您有功能需求或遇到bug，欢迎加入我们的QQ群获取帮助和了解最新动态。',
                Icons.favorite,
              ),

              const SizedBox(height: 20),
              // 贡献者列表标题
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '贡献玩家名单',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(width: 10),
                  _buildAnimatedStar(),
                ],
              ),
              const SizedBox(height: 15),
              // 贡献者列表
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: contributors
                        .map((contributor) =>
                            _buildContributorTile(context, contributor))
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              // 静态按钮
              ElevatedButton.icon(
                icon: const Icon(Icons.group_add),
                label: const Text('加入QQ群: 1030199465'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              const SizedBox(height: 15),
              // 复制QQ群号按钮
              ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('复制QQ群号: 1030199465'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () async {
                  await Clipboard.setData(
                      const ClipboardData(text: '1030199465'));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QQ群号已复制到剪贴板')),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              // 版权信息
              Text(
                '© ${DateTime.now().year} ASTRAL Team',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributorTile(BuildContext context, Contributor contributor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像显示，优先使用avatarUrl，如果没有则显示名字首字母
          contributor.avatarUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(
                    contributor.avatarUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 加载失败时显示首字母头像
                      return _buildInitialAvatar(context, contributor);
                    },
                  ),
                )
              : _buildInitialAvatar(context, contributor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contributor.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (contributor.socialAccount != null)
                  Text(
                    contributor.socialAccount!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                if (contributor.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      contributor.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 新增方法：创建首字母头像
  Widget _buildInitialAvatar(BuildContext context, Contributor contributor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          contributor.name.substring(0, 1),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBadge(String badge) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = math.sin(_controller.value * math.pi * 2) * 0.1 + 1.0;
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              badge,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStar() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: const Text(
            '✨',
            style: TextStyle(fontSize: 24),
          ),
        );
      },
    );
  }
}
