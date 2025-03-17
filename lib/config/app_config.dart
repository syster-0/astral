import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'cof.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  static late ConfigManager _configManager;
  static late String _configDirectory;

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  // 初始化配置
  static Future<void> init() async {
    // 获取可执行文件所在目录而不是当前工作目录
    _configDirectory = File(Platform.resolvedExecutable).parent.path;
    final configPath = path.join(_configDirectory, 'config.yaml');

    _configManager = ConfigManager(
      filePath: configPath,
      defaultConfig: {
        'theme': {
          'mode': 'system',
          'seedColor': Colors.blue.value,
        },
        'server': {
          'list': [
            {
              'url': 'public.easytier.cn:11010',
              'name': '公共服务器',
              'selected': true,
            }
          ],
        },
        'room': {
          'name': 'kevin',
          'password': 'kevin',
        },
        'user': {
          'name': Platform.localHostname,
        },
        'network': {
          'virtualIP': '',
          'dynamicIP': true,
        },
        'system': {
          'closeToTray': true,
          'enablePing': true, // 添加全局ping开关默认配置
        },
      },
    );

    await _configManager.load();
    
    // 验证配置格式，如果不正确则使用默认值覆盖
    validateAndFixConfig();
  }
  
  // 验证配置格式并修复不正确的配置
  static void validateAndFixConfig() {
    // 验证主题设置
    _validateThemeConfig();
    
    // 验证服务器列表
    _validateServerListConfig();
    
    // 验证房间设置
    _validateRoomConfig();
    
    // 验证用户设置
    _validateUserConfig();
    
    // 验证网络设置
    _validateNetworkConfig();
    
    // 验证系统设置
    _validateSystemConfig();
    
    // 保存修复后的配置
    _configManager.save();
  }
  
  // 验证主题配置
  static void _validateThemeConfig() {
    // 验证主题模式
    final String? themeMode = _configManager.get<String>('theme.mode');
    if (themeMode == null || 
        !['system', 'light', 'dark'].contains(themeMode.toLowerCase())) {
      _configManager.set('theme.mode', 'system');
    }
    
    // 验证主题色
    final int? seedColor = _configManager.get<int>('theme.seedColor');
    if (seedColor == null) {
      _configManager.set('theme.seedColor', Colors.blue.value);
    }
  }
  
  // 验证服务器列表配置
  static void _validateServerListConfig() {
    final dynamic serverList = _configManager.get('server.list');
    bool isValid = true;
    
    if (serverList is! List) {
      isValid = false;
    } else {
      for (var server in serverList) {
        if (server is! Map || 
            !server.containsKey('url') || 
            !server.containsKey('name') || 
            !server.containsKey('selected')) {
          isValid = false;
          break;
        }
      }
    }
    
    if (!isValid) {
      _configManager.set('server.list', [
        {
          'url': 'public.easytier.cn:11010',
          'name': '公共服务器',
          'selected': true,
        }
      ]);
    }
  }
  
  // 验证房间配置
  static void _validateRoomConfig() {
    final String? roomName = _configManager.get<String>('room.name');
    if (roomName == null || roomName.isEmpty) {
      _configManager.set('room.name', 'kevin');
    }
    
    final String? roomPassword = _configManager.get<String>('room.password');
    if (roomPassword == null || roomPassword.isEmpty) {
      _configManager.set('room.password', 'kevin');
    }
  }
  
  // 验证用户配置
  static void _validateUserConfig() {
    final String? username = _configManager.get<String>('user.name');
    if (username == null || username.isEmpty) {
      _configManager.set('user.name', Platform.localHostname);
    }
  }
  
  // 验证网络配置
  static void _validateNetworkConfig() {
    final String? virtualIP = _configManager.get<String>('network.virtualIP');
    if (virtualIP == null) {
      _configManager.set('network.virtualIP', '');
    }
    
    final bool? dynamicIP = _configManager.get<bool>('network.dynamicIP');
    if (dynamicIP == null) {
      _configManager.set('network.dynamicIP', true);
    }
  }
  
  // 验证系统配置
  static void _validateSystemConfig() {
    final bool? closeToTray = _configManager.get<bool>('system.closeToTray');
    if (closeToTray == null) {
      _configManager.set('system.closeToTray', true);
    }
    
    final bool? enablePing = _configManager.get<bool>('system.enablePing');
    if (enablePing == null) {
      _configManager.set('system.enablePing', true);
    }
  }

  // 主题设置
  ThemeMode get themeMode {
    final String? value = _configManager.get<String>('theme.mode');
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == 'ThemeMode.$value',
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final modeString = mode.toString().split('.').last.toLowerCase();
    _configManager.set('theme.mode', modeString);
    await _configManager.save();
  }

  // 主题色设置
  Color get seedColor {
    final int? value = _configManager.get<int>('theme.seedColor');
    return value != null ? Color(value) : Colors.blue;
  }

  Future<void> setSeedColor(Color color) async {
    _configManager.set('theme.seedColor', color.value);
    await _configManager.save();
  }

  // 服务器列表设置
  List<Map<String, dynamic>> get serverList {
    final dynamic value = _configManager.get('server.list');
    if (value is List) {
      return List<Map<String, dynamic>>.from(
        value.map((item) => Map<String, dynamic>.from(item as Map)),
      );
    }
    return [
      {
        'url': 'public.easytier.cn:11010',
        'name': '公共服务器',
        'selected': true,
      }
    ];
  }

  Future<void> setServerList(List<Map<String, dynamic>> servers) async {
    _configManager.set('server.list', servers);
    await _configManager.save();
  }

  // 房间名设置
  String get roomName {
    return _configManager.get<String>('room.name') ?? 'kevin';
  }

  Future<void> setRoomName(String name) async {
    _configManager.set('room.name', name);
    await _configManager.save();
  }

  // 房间密码设置
  String get roomPassword {
    return _configManager.get<String>('room.password') ?? 'kevin';
  }

  Future<void> setRoomPassword(String password) async {
    _configManager.set('room.password', password);
    await _configManager.save();
  }

  // 用户名设置
  String get username {
    return _configManager.get<String>('user.name') ?? Platform.localHostname;
  }

  Future<void> setUsername(String name) async {
    _configManager.set('user.name', name);
    await _configManager.save();
  }

  // 虚拟IP设置
  String get virtualIP {
    return _configManager.get<String>('network.virtualIP') ?? '';
  }

  Future<void> setVirtualIP(String ip) async {
    _configManager.set('network.virtualIP', ip);
    await _configManager.save();
  }

  // 关闭按钮进入托盘
  bool get closeToTray {
    return _configManager.get<bool>('system.closeToTray') ?? true;
  }

  Future<void> setCloseToTray(bool enabled) async {
    _configManager.set('system.closeToTray', enabled);
    await _configManager.save();
  }

  // 动态获取IP设置
  bool get dynamicIP {
    return _configManager.get<bool>('network.dynamicIP') ?? true;
  }

  Future<void> setDynamicIP(bool enabled) async {
    _configManager.set('network.dynamicIP', enabled);
    await _configManager.save();
  }

  // 全局ping开关设置
  bool get enablePing {
    return _configManager.get<bool>('system.enablePing') ?? true;
  }

  Future<void> setEnablePing(bool enabled) async {
    _configManager.set('system.enablePing', enabled);
    await _configManager.save();
  }
}
