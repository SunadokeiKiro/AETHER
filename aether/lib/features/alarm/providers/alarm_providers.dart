import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/data/data.dart';

// ============================================================================
// DOMAIN MODEL (UI層用)
// ============================================================================

/// アラームモデル（UI層用）
class Alarm {
  final String id;
  final TimeOfDay time;
  final String label;
  final List<int> repeatDays; // 0=日曜, 6=土曜
  final bool isEnabled;

  Alarm({
    String? id,
    required this.time,
    this.label = '',
    this.repeatDays = const [],
    this.isEnabled = true,
  }) : id = id ?? const Uuid().v4();

  Alarm copyWith({
    TimeOfDay? time,
    String? label,
    List<int>? repeatDays,
    bool? isEnabled,
  }) {
    return Alarm(
      id: id,
      time: time ?? this.time,
      label: label ?? this.label,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  /// 繰り返し曜日をフォーマット
  String get repeatText {
    if (repeatDays.isEmpty) return '1回のみ';
    if (repeatDays.length == 7) return '毎日';
    if (repeatDays.toSet().containsAll({1, 2, 3, 4, 5}) && repeatDays.length == 5) return '平日';
    if (repeatDays.toSet().containsAll({0, 6}) && repeatDays.length == 2) return '週末';

    const dayNames = ['日', '月', '火', '水', '木', '金', '土'];
    final sortedDays = List<int>.from(repeatDays)..sort();
    return sortedDays.map((d) => dayNames[d]).join('、');
  }

  /// フォーマットされた時刻を返す
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Hiveモデルから変換
  factory Alarm.fromModel(AlarmModel model) {
    return Alarm(
      id: model.id,
      time: TimeOfDay(hour: model.hour, minute: model.minute),
      label: model.label,
      repeatDays: model.repeatDays,
      isEnabled: model.isEnabled,
    );
  }

  /// Hiveモデルへ変換
  AlarmModel toModel() {
    return AlarmModel(
      id: id,
      hour: time.hour,
      minute: time.minute,
      label: label,
      repeatDays: repeatDays,
      isEnabled: isEnabled,
    );
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// AlarmRepositoryのProvider
final alarmRepositoryProvider = Provider<AlarmRepository>((ref) => AlarmRepository());

/// アラームリストProvider（永続化対応）
final alarmListProvider = StateNotifierProvider<AlarmListNotifier, List<Alarm>>(
  (ref) => AlarmListNotifier(ref.watch(alarmRepositoryProvider)),
);

class AlarmListNotifier extends StateNotifier<List<Alarm>> {
  final AlarmRepository _repository;

  AlarmListNotifier(this._repository) : super([]) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final models = _repository.getAll();
    state = models.map((m) => Alarm.fromModel(m)).toList();
  }

  Future<void> add(Alarm alarm) async {
    await _repository.save(alarm.toModel());
    state = [...state, alarm];
  }

  Future<void> update(Alarm alarm) async {
    await _repository.save(alarm.toModel());
    state = state.map((a) => a.id == alarm.id ? alarm : a).toList();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = state.where((a) => a.id != id).toList();
  }

  Future<void> toggle(String id) async {
    final alarm = state.firstWhere((a) => a.id == id);
    final updated = alarm.copyWith(isEnabled: !alarm.isEnabled);
    await _repository.save(updated.toModel());
    state = state.map((a) => a.id == id ? updated : a).toList();
  }
}
