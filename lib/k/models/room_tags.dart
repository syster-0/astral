import 'package:isar/isar.dart';
part 'room_tags.g.dart';

@collection
class RoomTags {
  /// 主键自增
  Id id = Isar.autoIncrement;
  // 标签 可作为索引 不能为空
  @Index(unique: true, replace: true)
  String tag = "";

  // 是否选中
  bool selected = false;

  //构造
  RoomTags(this.tag, this.selected);
}
