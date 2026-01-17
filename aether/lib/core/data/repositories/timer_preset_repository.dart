import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage_service.dart';
import '../models/timer_preset_model.dart';

/// タイマープリセットのRepository
class TimerPresetRepository {
  Box<TimerPresetModel> get _box => StorageService.timerPresetsBox;

  /// デフォルトプリセット（短い順）
  static final List<TimerPresetModel> defaultPresets = [
    TimerPresetModel(id: 'p3m', label: '3分', durationSeconds: 180, isBuiltIn: true),
    TimerPresetModel(id: 'p5m', label: '5分', durationSeconds: 300, isBuiltIn: true),
    TimerPresetModel(id: 'p10m', label: '10分', durationSeconds: 600, isBuiltIn: true),
    TimerPresetModel(id: 'p15m', label: '15分', durationSeconds: 900, isBuiltIn: true),
    TimerPresetModel(id: 'p30m', label: '30分', durationSeconds: 1800, isBuiltIn: true),
  ];

  /// 全プリセットを取得（デフォルト含む）
  List<TimerPresetModel> getAll() {
    final saved = _box.values.toList();
    if (saved.isEmpty) {
      // デフォルトプリセットを返す（保存はしない）
      return defaultPresets;
    }
    return saved;
  }

  /// 初回起動時にデフォルトプリセットを保存
  Future<void> initializeDefaults() async {
    if (_box.isEmpty) {
      for (final preset in defaultPresets) {
        await _box.put(preset.id, preset);
      }
    }
  }

  /// IDでプリセットを取得
  TimerPresetModel? getById(String id) {
    return _box.get(id);
  }

  /// プリセットを保存
  Future<void> save(TimerPresetModel preset) async {
    await _box.put(preset.id, preset);
  }

  /// プリセットを削除（ビルトインは削除不可）
  Future<void> delete(String id) async {
    final preset = getById(id);
    if (preset != null && !preset.isBuiltIn) {
      await _box.delete(id);
    }
  }

  /// 変更を監視
  ValueListenable<Box<TimerPresetModel>> watch() {
    return _box.listenable();
  }
}
