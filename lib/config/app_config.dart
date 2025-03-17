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
          'list': ['public.easytier.cn:11010'],
          'current': 'public.easytier.cn:11010',
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
  List<String> get serverList {
    final List? value = _configManager.get<List>('server.list');
    return value?.cast<String>() ?? ['public.easytier.cn:11010'];
  }

  Future<void> setServerList(List<String> servers) async {
    _configManager.set('server.list', servers);
    await _configManager.save();
  }

  // 当前选中的服务器设置
  String get currentServer {
    return _configManager.get<String>('server.current') ??
        'public.easytier.cn:11010';
  }

  Future<void> setCurrentServer(String server) async {
    _configManager.set('server.current', server);
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
