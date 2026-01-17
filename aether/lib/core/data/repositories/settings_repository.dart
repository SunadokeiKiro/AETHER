import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage_service.dart';
import '../models/settings_model.dart';

/// 設定のRepository
class SettingsRepository {
  Box<SettingsModel> get _box => StorageService.settingsBox;

  /// 現在の設定を取得
  SettingsModel getSettings() {
    return _box.get(SettingsModel.defaultKey) ?? SettingsModel();
  }

  /// 設定を保存
  Future<void> saveSettings(SettingsModel settings) async {
    await _box.put(SettingsModel.defaultKey, settings);
  }

  /// テーマを変更
  Future<void> setTheme(String themePreset) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(themePreset: themePreset));
  }

  /// 言語を変更
  Future<void> setLanguage(String language) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(language: language));
  }

  /// Gemini有効/無効を変更
  Future<void> setGeminiEnabled(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(geminiEnabled: enabled));
  }

  /// Geminiモデルを変更
  Future<void> setGeminiModel(String model) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(geminiModel: model));
  }

  /// 変更を監視
  ValueListenable<Box<SettingsModel>> watch() {
    return _box.listenable();
  }
}
