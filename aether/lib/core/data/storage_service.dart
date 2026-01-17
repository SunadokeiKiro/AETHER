import 'package:hive_flutter/hive_flutter.dart';
import 'models/memo_model.dart';
import 'models/folder_model.dart';
import 'models/alarm_model.dart';
import 'models/timer_preset_model.dart';
import 'models/settings_model.dart';
import 'models/calculator_history_model.dart';

/// Hiveストレージの初期化と管理を行うサービス
class StorageService {
  static const String memosBoxName = 'memos';
  static const String foldersBoxName = 'folders';
  static const String alarmsBoxName = 'alarms';
  static const String timerPresetsBoxName = 'timer_presets';
  static const String settingsBoxName = 'settings';
  static const String calculatorHistoryBoxName = 'calculator_history';

  static bool _initialized = false;

  /// Hiveを初期化し、全てのボックスを開く
  static Future<void> initialize() async {
    if (_initialized) return;

    // アダプター登録
    Hive.registerAdapter(MemoModelAdapter());
    Hive.registerAdapter(FolderModelAdapter());
    Hive.registerAdapter(AlarmModelAdapter());
    Hive.registerAdapter(TimerPresetModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
    Hive.registerAdapter(CalculatorHistoryModelAdapter());

    // ボックスを開く
    await Hive.openBox<MemoModel>(memosBoxName);
    await Hive.openBox<FolderModel>(foldersBoxName);
    await Hive.openBox<AlarmModel>(alarmsBoxName);
    await Hive.openBox<TimerPresetModel>(timerPresetsBoxName);
    await Hive.openBox<SettingsModel>(settingsBoxName);
    await Hive.openBox<CalculatorHistoryModel>(calculatorHistoryBoxName);

    _initialized = true;
  }

  /// メモボックス取得
  static Box<MemoModel> get memosBox => Hive.box<MemoModel>(memosBoxName);

  /// フォルダボックス取得
  static Box<FolderModel> get foldersBox => Hive.box<FolderModel>(foldersBoxName);

  /// アラームボックス取得
  static Box<AlarmModel> get alarmsBox => Hive.box<AlarmModel>(alarmsBoxName);

  /// タイマープリセットボックス取得
  static Box<TimerPresetModel> get timerPresetsBox => Hive.box<TimerPresetModel>(timerPresetsBoxName);

  /// 設定ボックス取得
  static Box<SettingsModel> get settingsBox => Hive.box<SettingsModel>(settingsBoxName);

  /// 電卓履歴ボックス取得
  static Box<CalculatorHistoryModel> get calculatorHistoryBox => Hive.box<CalculatorHistoryModel>(calculatorHistoryBoxName);

  /// 全ボックスをクリア（デバッグ用）
  static Future<void> clearAll() async {
    await memosBox.clear();
    await foldersBox.clear();
    await alarmsBox.clear();
    await timerPresetsBox.clear();
    await settingsBox.clear();
    await calculatorHistoryBox.clear();
  }
}

