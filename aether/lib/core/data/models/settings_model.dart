import 'package:hive/hive.dart';

part 'settings_model.g.dart';

/// アプリ設定のHiveモデル
@HiveType(typeId: 4)
class SettingsModel extends HiveObject {
  static const String defaultKey = 'app_settings';

  @HiveField(0)
  String themePreset;

  @HiveField(1)
  String language;

  @HiveField(2)
  bool geminiEnabled;

  @HiveField(3)
  String geminiModel; // 'pro' or 'flash'

  SettingsModel({
    this.themePreset = 'default',
    this.language = 'ja',
    this.geminiEnabled = true,
    this.geminiModel = 'flash',
  });

  /// コピーを作成
  SettingsModel copyWith({
    String? themePreset,
    String? language,
    bool? geminiEnabled,
    String? geminiModel,
  }) {
    return SettingsModel(
      themePreset: themePreset ?? this.themePreset,
      language: language ?? this.language,
      geminiEnabled: geminiEnabled ?? this.geminiEnabled,
      geminiModel: geminiModel ?? this.geminiModel,
    );
  }
}
