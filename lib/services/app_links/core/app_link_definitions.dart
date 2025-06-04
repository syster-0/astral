import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class AppLinkDefinitions {
  static final AppLinkDefinitions _instance = AppLinkDefinitions._internal();
  factory AppLinkDefinitions() => _instance;
  AppLinkDefinitions._internal();

  late AppLinks _appLinks;
  bool _isInitialized = false;

  /// 初始化 App Links
  void initialize() {
    if (_isInitialized) return;
    
    _appLinks = AppLinks();
    _isInitialized = true;
    debugPrint('AppLinkDefinitions 初始化完成');
  }

  /// 获取初始链接
  Future<Uri?> getInitialLink() async {
    if (!_isInitialized) {
      throw StateError('AppLinkDefinitions 未初始化，请先调用 initialize()');
    }
    
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        debugPrint('获取到初始链接: $initialLink');
        return initialLink;
      }
      return null;
    } catch (e) {
      debugPrint('获取初始链接失败: $e');
      return null;
    }
  }

  /// 获取链接流 - 这是 app_link_registry.dart 中需要的方法
  Stream<Uri> get linkStream {
    if (!_isInitialized) {
      throw StateError('AppLinkDefinitions 未初始化，请先调用 initialize()');
    }
    
    return _appLinks.uriLinkStream;
  }

  /// 验证是否是有效的 Astral 链接 - 这是 app_link_registry.dart 中需要的方法
  bool isValidAstralLink(Uri uri) {
    // 检查是否是 astral 协议
    if (uri.scheme != 'astral') {
      debugPrint('无效的链接协议: ${uri.scheme}，期望: astral');
      return false;
    }
    
    // 检查是否有有效的 host
    if (uri.host.isEmpty) {
      debugPrint('链接缺少 host: $uri');
      return false;
    }
    
    return true;
  }

  /// 解析链接获取基本信息
  Map<String, dynamic> parseLink(Uri uri) {
    if (!isValidAstralLink(uri)) {
      return {'valid': false, 'error': '无效的链接格式'};
    }
    
    return {
      'valid': true,
      'scheme': uri.scheme,
      'host': uri.host,
      'path': uri.path,
      'queryParameters': uri.queryParameters,
      'fragment': uri.fragment,
    };
  }

  /// 打印链接调试信息
  void printLinkDebugInfo(Uri uri) {
    debugPrint('=== 链接调试信息 ===');
    debugPrint('完整 URI: $uri');
    debugPrint('协议: ${uri.scheme}');
    debugPrint('主机: ${uri.host}');
    debugPrint('路径: ${uri.path}');
    debugPrint('查询参数: ${uri.queryParameters}');
    debugPrint('片段: ${uri.fragment}');
    debugPrint('是否有效: ${isValidAstralLink(uri)}');
    debugPrint('==================');
  }

  /// 释放资源
  void dispose() {
    _isInitialized = false;
    debugPrint('AppLinkDefinitions 资源已释放');
  }
}