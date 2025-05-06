import 'dart:io';

import 'package:astral/k/models/all_settings.dart';
import 'package:astral/k/models/room.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:isar/isar.dart';

class AllSettingsCz {
  final Isar _isar;

  AllSettingsCz(this._isar) {
    init();
  }

  Future<void> init() async {
    // 初始化时检查是否存在AllSettings实例，如果不存在则创建一个新的实例
    final allSettings = await _isar.allSettings.get(1);
    if (allSettings == null) {
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(AllSettings());
      });
    }
    // 检查 playerName 是否为空，如果为空则设置为主机名
    if (allSettings != null && allSettings.playerName == null) {
      String deviceName = await _getDeviceName(); // 获取设备名称
      await _isar.writeTxn(() async {
        allSettings.playerName = deviceName; // 设置默认名称
        await _isar.allSettings.put(allSettings);
      });
    }

    /// 检查 listenList 是否为空，如果为空则设置为默认值
    if (allSettings != null && allSettings.listenList == null) {
      await _isar.writeTxn(() async {
        allSettings.listenList = [
          "tcp://0.0.0.0:11010",
          "udp://0.0.0.0:11010",
          "tcp://[::]:11010",
          "udp://[::]:11010",
        ]; // 设置默认值
        await _isar.allSettings.put(allSettings);
      });
    }
  }

  // getListenList
  Future<List<String>> getListenList() async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config?.listenList == null) return [];
    return config!.listenList!;
  }

  // 设置监听列表
  Future<void> setListenList(List<String> listenList) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.listenList = listenList;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 删除监听列表
  Future<void> deleteListenList(int index) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.listenList!.removeAt(index);
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 添加监听列表
  Future<void> addListenList(String listen) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.listenList!.add(listen);
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 修改监听列表
  Future<void> updateListenList(int index, String listen) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.listenList![index] = listen;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 设置房间
  Future<void> updateRoom(Room room) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.room = room.id;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 获取当前房间ID
  Future<Room?> getRoom() async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config?.room == null) return null;
    return await _isar.rooms.get(config!.room!);
  }

  // 获取所有设置
  Future<AllSettings?> getAllSettings() async {
    return await _isar.allSettings.get(1);
  }

  // 设定玩家名称
  Future<void> setPlayerName(String name) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.playerName = name;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 获取玩家名称
  Future<String> getPlayerName() async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config?.playerName == null) {
      String deviceName = await _getDeviceName();
      await setPlayerName(deviceName);
      return deviceName;
    }
    return config!.playerName!;
  }
}

// 在同一个文件中添加这个方法
Future<String> _getDeviceName() async {
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    } else if (Platform.isWindows) {
      WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.computerName;
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo macOSInfo = await deviceInfo.macOsInfo;
      return macOSInfo.computerName;
    } else if (Platform.isLinux) {
      LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.name;
    }

    return "Default Player"; // 如果无法获取设备名称，则使用默认名称
  } catch (e) {
    return "Default Player"; // 错误处理，返回默认名称
  }
}
