import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // 添加 dart:io 导入以使用 Platform 类

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  static late SharedPreferences _prefs;

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  // 初始化配置
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 主题设置
  static const String _keyThemeMode = 'themeMode';
  ThemeMode get themeMode {
    final String? value = _prefs.getString(_keyThemeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode.toString());
  }

  // 主题色设置
  static const String _keySeedColor = 'seedColor';
  Color get seedColor {
    final int? value = _prefs.getInt(_keySeedColor);
    return value != null ? Color(value) : Colors.blue;
  }

  Future<void> setSeedColor(Color color) async {
    await _prefs.setInt(_keySeedColor, color.value);
  }

  // 服务器列表设置
  static const String _keyServerList = 'serverList';
  List<String> get serverList {
    final List<String>? value = _prefs.getStringList(_keyServerList);
    return value?.isNotEmpty == true ? value! : ['public.easytier.net:11010'];
  }

  Future<void> setServerList(List<String> servers) async {
    await _prefs.setStringList(_keyServerList, servers);
  }

  // 当前选中的服务器设置
  static const String _keyCurrentServer = 'currentServer';
  String get currentServer {
    return _prefs.getString(_keyCurrentServer) ?? 'public.easytier.net:11010';
  }

  Future<void> setCurrentServer(String server) async {
    await _prefs.setString(_keyCurrentServer, server);
  }

  // 房间名设置
  static const String _keyRoomName = 'roomName';
  String get roomName {
    return _prefs.getString(_keyRoomName) ?? 'kevin';
  }

  Future<void> setRoomName(String name) async {
    await _prefs.setString(_keyRoomName, name);
  }

  // 房间密码设置
  static const String _keyRoomPassword = 'roomPassword';
  String get roomPassword {
    return _prefs.getString(_keyRoomPassword) ?? 'kevin';
  }

  Future<void> setRoomPassword(String password) async {
    await _prefs.setString(_keyRoomPassword, password);
  }

  // 用户名设置
  static const String _keyUsername = 'username';
  String get username {
    return _prefs.getString(_keyUsername) ?? Platform.localHostname;
  }

  Future<void> setUsername(String name) async {
    await _prefs.setString(_keyUsername, name);
  }

  // 虚拟IP设置
  static const String _keyVirtualIP = 'virtualIP';
  String get virtualIP {
    return _prefs.getString(_keyVirtualIP) ?? '';
  }

  // 关闭按钮进入托盘
  static const String _keyCloseToTray = 'closeToTray';
  bool get closeToTray {
    return _prefs.getBool(_keyCloseToTray) ?? true;
  }

  Future<void> setCloseToTray(bool enabled) async {
    await _prefs.setBool(_keyCloseToTray, enabled);
  }

  Future<void> setVirtualIP(String ip) async {
    await _prefs.setString(_keyVirtualIP, ip);
  }

  // 动态获取IP设置
  static const String _keyDynamicIP = 'dynamicIP';
  bool get dynamicIP {
    return _prefs.getBool(_keyDynamicIP) ?? true;
  }

  Future<void> setDynamicIP(bool enabled) async {
    await _prefs.setBool(_keyDynamicIP, enabled);
  }
}
