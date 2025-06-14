import 'dart:async';
import 'package:astral/services/app_links/core/app_link_definitions.dart';
import 'package:astral/services/app_links/handlers/link_handlers.dart';
import 'package:flutter/foundation.dart';

// 简化的链接处理器类型
typedef SimpleHandler = Future<void> Function(Uri uri);

class AppLinkRegistry {
  static final AppLinkRegistry _instance = AppLinkRegistry._internal();
  factory AppLinkRegistry() => _instance;
  AppLinkRegistry._internal();

  final AppLinkDefinitions _linkDefinitions = AppLinkDefinitions();
  StreamSubscription<Uri>? _linkSubscription;
  
  // 简化的处理器映射 - 直接使用 host 作为 key
  final Map<String, SimpleHandler> _handlers = {};
  
  bool _isInitialized = false;
  
  // 注册处理器
  void registerHandler(String host, SimpleHandler handler) {
    _handlers[host] = handler;
   debugPrint('已注册处理器: $host');
  }
  
  // 初始化并注册默认处理器
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _linkDefinitions.initialize();
    
    // 注册默认处理器
    _registerDefaultHandlers();
    
    await _handleInitialLink();
    _registerLinkStream();
    
    _isInitialized = true;
   debugPrint('App Link Registry 初始化完成');
  }
  
  // 注册默认处理器
  void _registerDefaultHandlers() {
    registerHandler('debug', LinkHandlers.handleDebug);
    registerHandler('room', LinkHandlers.handleRoom);
  }
  
  Future<void> _handleInitialLink() async {
    final initialLink = await _linkDefinitions.getInitialLink();
    if (initialLink != null) {
      await _processLink(initialLink);
    }
  }
  
  void _registerLinkStream() {
    _linkSubscription = _linkDefinitions.linkStream.listen(
      (uri) async => await _processLink(uri),
      onError: (err) =>debugPrint('Link stream error: $err'),
    );
  }
  
  // 简化的链接处理
  Future<void> _processLink(Uri uri) async {
    if (!_linkDefinitions.isValidAstralLink(uri)) {
     debugPrint('Invalid scheme: ${uri.scheme}');
      return;
    }
    
    final handler = _handlers[uri.host];
    if (handler != null) {
      try {
        await handler(uri);
       debugPrint('处理完成: ${uri.host}');
      } catch (e) {
       debugPrint('处理失败: ${uri.host}, 错误: $e');
      }
    } else {
     debugPrint('未找到处理器: ${uri.host}');
    }
  }
  
  void dispose() {
    _linkSubscription?.cancel();
    _handlers.clear();
    _isInitialized = false;
  }
  
  bool get isInitialized => _isInitialized;
}