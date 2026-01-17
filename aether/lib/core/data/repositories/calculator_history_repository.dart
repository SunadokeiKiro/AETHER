import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../storage_service.dart';
import '../models/calculator_history_model.dart';

/// 電卓履歴のRepository
class CalculatorHistoryRepository {
  static const int maxHistoryCount = 20;
  
  Box<CalculatorHistoryModel> get _box => StorageService.calculatorHistoryBox;

  /// 全履歴を取得（新しい順）
  List<CalculatorHistoryModel> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// 履歴を追加（古いものは自動削除）
  Future<void> add(String expression, String result) async {
    final id = const Uuid().v4();
    final entry = CalculatorHistoryModel(
      id: id,
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
    );
    await _box.put(id, entry);
    
    // 最大件数を超えたら古いものを削除
    await _trimHistory();
  }

  /// 履歴を削除
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// 全履歴を削除
  Future<void> clear() async {
    await _box.clear();
  }

  /// 最大件数を超えた履歴を削除
  Future<void> _trimHistory() async {
    final all = getAll();
    if (all.length > maxHistoryCount) {
      final toDelete = all.skip(maxHistoryCount);
      for (final entry in toDelete) {
        await _box.delete(entry.id);
      }
    }
  }

  /// 変更を監視
  ValueListenable<Box<CalculatorHistoryModel>> watch() {
    return _box.listenable();
  }
}
