import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class KM extends ChangeNotifier {
  final _config = AppConfig();
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // 通知监听器重建UI
  }

// 房间名
  String get roomName => _config.roomName;
  set roomName(String value) {
    _config.setRoomName(value);
    notifyListeners(); // 通知监听器重建UI
  }

  //房间密码设置
  String get roomPassword => _config.roomPassword;
  set roomPassword(String value) {
    _config.setRoomPassword(value);
    notifyListeners();
  }

  //用户名设置
  String get username => _config.username;
  set username(String value) {
    _config.setUsername(value);
    notifyListeners();
  }

  //虚拟IP设置
  String get virtualIP => _config.virtualIP;
  set virtualIP(String value) {
    _config.setVirtualIP(value);
    notifyListeners();
  }

  //动态获取IP设置
  bool get dynamicIP => _config.dynamicIP;
  set dynamicIP(bool value) {
    _config.setDynamicIP(value);
    notifyListeners();
  }

  //当前服务器IP
  String get serverIP => _config.currentServer;
  set serverIP(String value) {
    _config.setCurrentServer(value);
    notifyListeners();
  }

  // 节点列表
  List<KVNodeInfo> _nodes = [];
  List<KVNodeInfo> get nodes => _nodes;
  set nodes(List<KVNodeInfo> value) {
    _nodes = value;
    notifyListeners();
  }
}
