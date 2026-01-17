import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data.dart';
import '../data/data.dart';
import 'design_tokens.dart';

/// SettingsRepositoryのProvider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository());

/// 現在のDesign Tokensを管理するProvider
final designTokensProvider = StateNotifierProvider<DesignTokensNotifier, DesignTokens>(
  (ref) => DesignTokensNotifier(ref.watch(settingsRepositoryProvider)),
);

/// テーマプリセット名を管理するProvider（永続化対応）
final themePresetProvider = StateProvider<String>((ref) {
  final settings = ref.watch(settingsRepositoryProvider).getSettings();
  return settings.themePreset;
});

/// MaterialThemeDataを提供するProvider
final themeDataProvider = Provider<ThemeData>((ref) {
  final tokens = ref.watch(designTokensProvider);
  return _buildThemeData(tokens);
});

/// Design Tokensの状態管理（永続化対応）
class DesignTokensNotifier extends StateNotifier<DesignTokens> {
  final SettingsRepository _repository;

  DesignTokensNotifier(this._repository) : super(DesignTokens.defaultTheme) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final settings = _repository.getSettings();
    setPreset(settings.themePreset);
  }

  /// プリセットテーマに変更（永続化も行う）
  Future<void> setPreset(String presetName) async {
    switch (presetName) {
      case 'cyberpunk':
        state = DesignTokens.cyberpunkTheme;
        break;
      case 'minimal':
        state = DesignTokens.minimalTheme;
        break;
      case 'nature':
        state = DesignTokens.natureTheme;
        break;
      case 'sunset':
        state = DesignTokens.sunsetTheme;
        break;
      default:
        state = DesignTokens.defaultTheme;
    }
    await _repository.setTheme(presetName);
  }

  /// カスタムトークンを適用
  void setCustomTokens(DesignTokens tokens) {
    state = tokens;
  }

  /// パレットのみ変更
  void updatePalette(ThemePalette palette) {
    state = state.copyWith(palette: palette);
  }
}

/// Design TokensからMaterialThemeDataを生成
ThemeData _buildThemeData(DesignTokens tokens) {
  final palette = tokens.palette;
  final geometry = tokens.geometry;
  final typography = tokens.typography;
  final density = tokens.density;

  // カラースキーム
  final colorScheme = ColorScheme(
    brightness: _isDarkMode(palette) ? Brightness.dark : Brightness.light,
    primary: palette.primary,
    onPrimary: palette.onPrimary,
    secondary: palette.secondary,
    onSecondary: palette.onSecondary,
    error: palette.error,
    onError: palette.onError,
    surface: palette.surface,
    onSurface: palette.onSurface,
    surfaceContainerHighest: palette.surfaceVariant,
  );

  // テキストテーマ（ローカルバンドルのInterフォントを使用）
  const String fontFamily = 'Inter';
  
  final textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: typography.fontSize4xl,
      fontWeight: FontWeight.bold,
      color: palette.onBackground,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: typography.fontSize3xl,
      fontWeight: FontWeight.bold,
      color: palette.onBackground,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: typography.fontSize2xl,
      fontWeight: FontWeight.w600,
      color: palette.onBackground,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: typography.fontSizeXl,
      fontWeight: FontWeight.w600,
      color: palette.onBackground,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: typography.fontSizeLg,
      fontWeight: FontWeight.w500,
      color: palette.onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: typography.fontSizeBase,
      fontWeight: FontWeight.w500,
      color: palette.onSurface,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: typography.fontSizeBase,
      color: palette.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: typography.fontSizeSm,
      color: palette.onSurface,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: typography.fontSizeBase,
      fontWeight: FontWeight.w500,
      color: palette.onPrimary,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.background,
    textTheme: textTheme,
    
    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: palette.surface,
      foregroundColor: palette.onSurface,
      elevation: 0,
      centerTitle: false,
    ),

    // Card
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: geometry.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: geometry.cardRadius,
      ),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        elevation: geometry.elevationSm,
        padding: EdgeInsets.symmetric(
          horizontal: density.spacingLg,
          vertical: density.spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: geometry.buttonRadius,
        ),
      ),
    ),

    // OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primary,
        side: BorderSide(color: palette.outline, width: geometry.borderWidth),
        padding: EdgeInsets.symmetric(
          horizontal: density.spacingLg,
          vertical: density.spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: geometry.buttonRadius,
        ),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.primary,
        padding: EdgeInsets.symmetric(
          horizontal: density.spacingMd,
          vertical: density.spacingSm,
        ),
      ),
    ),

    // FloatingActionButton
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.primary,
      foregroundColor: palette.onPrimary,
      elevation: geometry.elevationLg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(geometry.borderRadiusXl),
      ),
    ),

    // InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: geometry.inputRadius,
        borderSide: BorderSide(color: palette.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: geometry.inputRadius,
        borderSide: BorderSide(color: palette.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: geometry.inputRadius,
        borderSide: BorderSide(color: palette.primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: density.spacingMd,
        vertical: density.spacingSm,
      ),
    ),

    // BottomSheet - 角丸は最大28に制限して破綻を防ぐ
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(geometry.borderRadiusLg.clamp(16, 28)),
        ),
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: palette.outline,
      thickness: 1,
      space: density.spacingMd,
    ),

    // Icon
    iconTheme: IconThemeData(
      color: palette.onSurface,
      size: 24,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: typography.fontSizeXl,
        fontWeight: FontWeight.w600,
        color: palette.onSurface,
      ),
      contentTextStyle: TextStyle(
        fontSize: typography.fontSizeBase,
        color: palette.outline,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(geometry.borderRadiusXl),
      ),
    ),

    // ListTile
    listTileTheme: ListTileThemeData(
      textColor: palette.onSurface,
      iconColor: palette.outline,
      selectedColor: palette.primary,
      selectedTileColor: palette.primary.withOpacity(0.1),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return palette.onPrimary;
        }
        return palette.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return palette.primary;
        }
        return palette.surfaceVariant;
      }),
    ),
  );
}

/// パレットがダークモードかどうかを判定
bool _isDarkMode(ThemePalette palette) {
  final luminance = palette.background.computeLuminance();
  return luminance < 0.5;
}
