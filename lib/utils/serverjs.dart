import 'dart:convert';

// 主入口类
class StatusPageData {
  final Config config;
  final Incident incident;
  final List<PublicGroup> publicGroupList;

  StatusPageData({
    required this.config,
    required this.incident,
    required this.publicGroupList,
  });

  factory StatusPageData.fromJson(Map<String, dynamic> json) => StatusPageData(
        config: Config.fromJson(json['config']),
        incident: Incident.fromJson(json['incident']),
        publicGroupList: List<PublicGroup>.from(
            json['publicGroupList'].map((x) => PublicGroup.fromJson(x))),
      );
}

// 配置信息
class Config {
  final String slug;
  final String title;
  final String description;
  final String icon;
  final String theme;
  final bool published;
  final bool showTags;
  final String customCSS;
  final String footerText;
  final bool showPoweredBy;
  final dynamic googleAnalyticsId;
  final bool showCertificateExpiry;

  Config({
    required this.slug,
    required this.title,
    required this.description,
    required this.icon,
    required this.theme,
    required this.published,
    required this.showTags,
    required this.customCSS,
    required this.footerText,
    required this.showPoweredBy,
    this.googleAnalyticsId,
    required this.showCertificateExpiry,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        slug: json['slug'],
        title: json['title'],
        description: json['description'],
        icon: json['icon'],
        theme: json['theme'],
        published: json['published'],
        showTags: json['showTags'],
        customCSS: json['customCSS'],
        footerText: json['footerText'],
        showPoweredBy: json['showPoweredBy'],
        googleAnalyticsId: json['googleAnalyticsId'],
        showCertificateExpiry: json['showCertificateExpiry'],
      );
}

// 事件信息
class Incident {
  final int id;
  final String style;
  final String title;
  final String content;
  final int pin;
  final DateTime createdDate;
  final DateTime lastUpdatedDate;

  Incident({
    required this.id,
    required this.style,
    required this.title,
    required this.content,
    required this.pin,
    required this.createdDate,
    required this.lastUpdatedDate,
  });

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        id: json['id'],
        style: json['style'],
        title: json['title'],
        content: json['content'],
        pin: json['pin'],
        createdDate: DateTime.parse(json['createdDate']),
        lastUpdatedDate: DateTime.parse(json['lastUpdatedDate']),
      );
}

// 公共服务器组
class PublicGroup {
  final int id;
  final String name;
  final int weight;
  final List<Monitor> monitorList;

  PublicGroup({
    required this.id,
    required this.name,
    required this.weight,
    required this.monitorList,
  });

  factory PublicGroup.fromJson(Map<String, dynamic> json) => PublicGroup(
        id: json['id'],
        name: json['name'],
        weight: json['weight'],
        monitorList: List<Monitor>.from(
            json['monitorList'].map((x) => Monitor.fromJson(x))),
      );
}

// 监控项
class Monitor {
  final int id;
  final String name;
  final int sendUrl;
  final String type;
  final List<Tag> tags;
  final int? certExpiryDaysRemaining;
  final bool? validCert;

  Monitor({
    required this.id,
    required this.name,
    required this.sendUrl,
    required this.type,
    required this.tags,
    this.certExpiryDaysRemaining,
    this.validCert,
  });

  factory Monitor.fromJson(Map<String, dynamic> json) => Monitor(
        id: json['id'],
        name: json['name'],
        sendUrl: json['sendUrl'],
        type: json['type'],
        tags: List<Tag>.from(json['tags'].map((x) => Tag.fromJson(x))),
        certExpiryDaysRemaining: json['certExpiryDaysRemaining'],
        validCert: json['validCert'],
      );
}

// 标签
class Tag {
  final int id;
  final int monitorId;
  final int tagId;
  final String value;
  final String name;
  final String color;

  Tag({
    required this.id,
    required this.monitorId,
    required this.tagId,
    required this.value,
    required this.name,
    required this.color,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'],
        monitorId: json['monitor_id'],
        tagId: json['tag_id'],
        value: json['value'],
        name: json['name'],
        color: json['color'],
      );
}

// // 使用示例
// void main() {
//   final jsonString = '''{/* 你的原始JSON数据 */}''';

//   final data = StatusPageData.fromJson(jsonDecode(jsonString));

//   // 示例：获取第一个服务器组的名称
//   print('第一组名称: ${data.publicGroupList.first.name}');

//   // 示例：列出所有可中转的服务器
//   final transferableServers = data.publicGroupList
//       .expand((group) => group.monitorList)
//       .where((monitor) => monitor.tags.any((tag) => tag.name == '可中转'))
//       .toList();

//   print('可中转服务器数量: ${transferableServers.length}');
// }
