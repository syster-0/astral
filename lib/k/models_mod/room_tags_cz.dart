import 'package:isar/isar.dart';
import 'package:astral/k/models/room_tags.dart';

class RoomTagsCz {
  final Isar _isar;

  RoomTagsCz(this._isar) {
    init();
  }

  Future<void> init() async {}

  /// 添加标签
  Future<void> addTag(String tagName) async {
    // 检查标签是否已存在
    final existingTag =
        await _isar.roomTags.filter().tagEqualTo(tagName).findFirst();

    if (existingTag == null) {
      final tag = RoomTags(tagName, false);
      await _isar.writeTxn(() async {
        await _isar.roomTags.put(tag);
      });
    }
  }

  /// 删除标签
  Future<void> deleteTag(String tagName) async {
    final tag = await _isar.roomTags.filter().tagEqualTo(tagName).findFirst();

    if (tag != null) {
      await _isar.writeTxn(() async {
        await _isar.roomTags.delete(tag.id);
      });
    }
  }

  /// 获取所有标签
  Future<List<RoomTags>> getAllTags() async {
    return await _isar.roomTags.where().findAll();
  }

  /// 去除所有标签选中 clearAllTagSelections
  Future<void> clearAllTagSelections() async {
    final tags = await _isar.roomTags.where().findAll();

    await _isar.writeTxn(() async {
      for (final tag in tags) {
        tag.selected = false;
        await _isar.roomTags.put(tag);
      }
    });
  }

  /// 设置是否选中标签
  Future<void> setTagSelected(String tagName, bool isSelected) async {
    final tag = await _isar.roomTags.filter().tagEqualTo(tagName).findFirst();

    if (tag != null) {
      await _isar.writeTxn(() async {
        tag.selected = isSelected;
        await _isar.roomTags.put(tag);
      });
    }
  }
}
