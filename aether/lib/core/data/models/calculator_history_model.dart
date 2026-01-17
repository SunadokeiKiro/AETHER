import 'package:hive/hive.dart';

part 'calculator_history_model.g.dart';

/// 電卓履歴のHiveモデル
@HiveType(typeId: 5)
class CalculatorHistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String expression;

  @HiveField(2)
  final String result;

  @HiveField(3)
  final DateTime timestamp;

  CalculatorHistoryModel({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}
