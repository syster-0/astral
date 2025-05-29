import 'package:astral/wid/home_box.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Contributors extends StatefulWidget {
  const Contributors({super.key});

  @override
  State<Contributors> createState() => _ContributorsState();
}

class _ContributorsState extends State<Contributors> {
  // 贡献者数据
  final List<Map<String, dynamic>> contributors = [
    {
      'name': 'ldoubil',
      'role': '项目作者 & 维护者',
      'avatar': 'https://avatars.githubusercontent.com/u/26994456?v=4',
      'github': 'https://github.com/ldoubil',
      'isAuthor': true,
      'contributions': 446,
    },
    {
      'name': 'syster-0',
      'role': '核心贡献者',
      'avatar': 'https://avatars.githubusercontent.com/u/158539129?v=4',
      'github': 'https://github.com/syster-0',
      'isAuthor': false,
      'contributions': 34,
    },
    {
      'name': 'faithleysath',
      'role': '贡献者',
      'avatar': 'https://avatars.githubusercontent.com/u/120073078?v=4',
      'github': 'https://github.com/faithleysath',
      'isAuthor': false,
      'contributions': 6,
    },
    {
      'name': 'dependabot[bot]',
      'role': '自动化助手',
      'avatar': 'https://avatars.githubusercontent.com/in/29110?v=4',
      'github': 'https://github.com/apps/dependabot',
      'isAuthor': false,
      'contributions': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return HomeBox(
      widthSpan: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_outline,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                '贡献者',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...contributors.map((contributor) => _buildContributorItem(
                contributor,
                colorScheme,
              )),
          const SizedBox(height: 8),
          // 查看更多贡献者链接
          InkWell(
            onTap: () => _launchUrl('https://github.com/ldoubil/astral/graphs/contributors'),
            child: Row(
              children: [
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '查看所有贡献者',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorItem(
    Map<String, dynamic> contributor,
    ColorScheme colorScheme,
  ) {
    final bool isAuthor = contributor['isAuthor'] ?? false;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchUrl(contributor['github']!),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isAuthor 
                  ? colorScheme.primary.withOpacity(0.5)
                  : colorScheme.outline.withOpacity(0.2),
              width: isAuthor ? 2 : 1,
            ),
            gradient: isAuthor
                ? LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.05),
                      colorScheme.primary.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Row(
            children: [
              // 头像
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    backgroundImage: NetworkImage(contributor['avatar']!),
                    onBackgroundImageError: (exception, stackTrace) {
                      // 如果头像加载失败，显示默认图标
                    },
                    child: Container(), // 用于在图片加载失败时显示默认图标
                  ),
                  if (isAuthor)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // 贡献者信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          contributor['name']!,
                          style: TextStyle(
                            fontWeight: isAuthor ? FontWeight.w900 : FontWeight.bold,
                            fontSize: isAuthor ? 15 : 14,
                            color: isAuthor ? colorScheme.primary : null,
                          ),
                        ),
                        if (isAuthor) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            color: colorScheme.primary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contributor['role']!,
                      style: TextStyle(
                        color: isAuthor 
                            ? colorScheme.primary.withOpacity(0.8)
                            : colorScheme.secondary,
                        fontSize: 12,
                        fontWeight: isAuthor ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // GitHub 图标
              Icon(
                Icons.code,
                color: isAuthor ? colorScheme.primary : colorScheme.primary.withOpacity(0.7),
                size: isAuthor ? 20 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}