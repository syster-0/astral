import 'package:astral/k/models/all_settings.dart';
import 'package:astral/k/models/net_config.dart';
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
  }
}
