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

//服务器列表
  List<Map<String, dynamic>> get serverList => _config.serverList;
  set serverList(List<Map<String, dynamic>> value) {
    List<Map<String, dynamic>> convertedList = value.map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
    _config.setServerList(convertedList);
    notifyListeners();
  }

  //获取选中的服务器
  //获取选中的服务器
  List<String> get serverIP {
    try {
      final selected =
          serverList.where((server) => server['selected'] == true).toList();

      if (selected.isEmpty && serverList.isNotEmpty) {
        final firstServer = serverList.first;
        if (firstServer['url'] is String) {
          return [firstServer['url'] as String];
        }
        return [];
      }

      return selected
          .where((server) => server['url'] is String)
          .map((server) => server['url'] as String)
          .toList();
    } catch (e) {
      debugPrint('获取服务器IP时出错: $e');
      
      return [];
    }
  }

  //设置服务器选中状态
  void setServerSelected(String url, bool selected) {
    final servers = serverList;
    for (var i = 0; i < servers.length; i++) {
      if (servers[i]['url'] == url) {
        servers[i]['selected'] = selected;
      }
    }
    serverList = servers;
  }

  // 节点列表
  List<KVNodeInfo> _nodes = [];
  List<KVNodeInfo> get nodes => _nodes;
  set nodes(List<KVNodeInfo> value) {
    _nodes = value;
    notifyListeners();
  }
}
