import 'package:hive/hive.dart';

part 'timer_preset_model.g.dart';

/// タイマープリセットのHiveモデル
@HiveType(typeId: 3)
class TimerPresetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  int durationSeconds;

  @HiveField(3)
  bool isBuiltIn;

  TimerPresetModel({
    required this.id,
    required this.label,
    required this.durationSeconds,
    this.isBuiltIn = false,
  });

  /// コピーを作成
  TimerPresetModel copyWith({
    String? label,
    int? durationSeconds,
    bool? isBuiltIn,
  }) {
    return TimerPresetModel(
      id: id,
      label: label ?? this.label,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }
}
