import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

/// アラームのHiveモデル
@HiveType(typeId: 2)
class AlarmModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  int hour;

  @HiveField(2)
  int minute;

  @HiveField(3)
  String label;

  @HiveField(4)
  List<int> repeatDays; // 0=日曜, 6=土曜

  @HiveField(5)
  bool isEnabled;

  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = '',
    this.repeatDays = const [],
    this.isEnabled = true,
  });

  /// コピーを作成
  AlarmModel copyWith({
    int? hour,
    int? minute,
    String? label,
    List<int>? repeatDays,
    bool? isEnabled,
  }) {
    return AlarmModel(
      id: id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      repeatDays: repeatDays ?? List.from(this.repeatDays),
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
