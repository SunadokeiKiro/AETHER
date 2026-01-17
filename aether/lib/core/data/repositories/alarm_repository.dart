import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage_service.dart';
import '../models/alarm_model.dart';

/// アラームのRepository
class AlarmRepository {
  Box<AlarmModel> get _box => StorageService.alarmsBox;

  /// 全アラームを取得
  List<AlarmModel> getAll() {
    return _box.values.toList();
  }

  /// IDでアラームを取得
  AlarmModel? getById(String id) {
    return _box.get(id);
  }

  /// アラームを保存（新規作成または更新）
  Future<void> save(AlarmModel alarm) async {
    await _box.put(alarm.id, alarm);
  }

  /// アラームを削除
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// アラームの有効/無効を切り替え
  Future<void> toggle(String id) async {
    final alarm = getById(id);
    if (alarm != null) {
      await save(alarm.copyWith(isEnabled: !alarm.isEnabled));
    }
  }

  /// 変更を監視
  ValueListenable<Box<AlarmModel>> watch() {
    return _box.listenable();
  }
}
