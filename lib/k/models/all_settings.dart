import 'package:isar/isar.dart';
part 'all_settings.g.dart';

@collection
class AllSettings {
  /// 主键ID，固定为1因为只需要一个实例
  Id id = 1;

  /// 当前启用的房间
  int? room;

  /// 玩家名称
  String? playerName;

  /// 监听列表
  List<String>? listenList;

  ///用户列表简约模式
  bool userListSimple = false;

  /// 关闭最小化到托盘
  bool closeMinimize = true;
}
