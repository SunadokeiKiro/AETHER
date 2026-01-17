import 'package:flutter/material.dart';

/// Design Tokensの定義クラス
/// DESIGN_TOKENS.md に基づいたトークンシステム
class DesignTokens {
  final ThemePalette palette;
  final ComponentGeometry geometry;
  final TypographyPreset typography;
  final LayoutDensity density;
  final InteractionFlow interaction;

  const DesignTokens({
    required this.palette,
    required this.geometry,
    required this.typography,
    required this.density,
    required this.interaction,
  });

  /// デフォルトテーマ
  static const defaultTheme = DesignTokens(
    palette: ThemePalette.defaultPalette,
    geometry: ComponentGeometry.defaultGeometry,
    typography: TypographyPreset.defaultTypography,
    density: LayoutDensity.defaultDensity,
    interaction: InteractionFlow.defaultInteraction,
  );

  /// Cyberpunkテーマ
  static const cyberpunkTheme = DesignTokens(
    palette: ThemePalette.cyberpunk,
    geometry: ComponentGeometry.sharp,
    typography: TypographyPreset.defaultTypography,
    density: LayoutDensity.defaultDensity,
    interaction: InteractionFlow.defaultInteraction,
  );

  /// Minimalテーマ
  static const minimalTheme = DesignTokens(
    palette: ThemePalette.minimal,
    geometry: ComponentGeometry.rounded,
    typography: TypographyPreset.defaultTypography,
    density: LayoutDensity.spacious,
    interaction: InteractionFlow.defaultInteraction,
  );

  /// Natureテーマ
  static const natureTheme = DesignTokens(
    palette: ThemePalette.nature,
    geometry: ComponentGeometry.organic,
    typography: TypographyPreset.defaultTypography,
    density: LayoutDensity.defaultDensity,
    interaction: InteractionFlow.defaultInteraction,
  );

  /// Sunsetテーマ
  static const sunsetTheme = DesignTokens(
    palette: ThemePalette.sunset,
    geometry: ComponentGeometry.defaultGeometry,
    typography: TypographyPreset.defaultTypography,
    density: LayoutDensity.defaultDensity,
    interaction: InteractionFlow.slow,
  );

  DesignTokens copyWith({
    ThemePalette? palette,
    ComponentGeometry? geometry,
    TypographyPreset? typography,
    LayoutDensity? density,
    InteractionFlow? interaction,
  }) {
    return DesignTokens(
      palette: palette ?? this.palette,
      geometry: geometry ?? this.geometry,
      typography: typography ?? this.typography,
      density: density ?? this.density,
      interaction: interaction ?? this.interaction,
    );
  }
}

/// 色設定
class ThemePalette {
  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color secondaryVariant;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color error;
  final Color success;
  final Color warning;
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onSurface;
  final Color onError;
  final Color outline;

  const ThemePalette({
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.secondaryVariant,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.error,
    required this.success,
    required this.warning,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.onError,
    required this.outline,
  });

  static const defaultPalette = ThemePalette(
    primary: Color(0xFF6366F1),
    primaryVariant: Color(0xFF4338CA),
    secondary: Color(0xFFF59E0B),
    secondaryVariant: Color(0xFFD97706),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF334155),
    error: Color(0xFFEF4444),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF1A1A1A),
    onBackground: Color(0xFFF8FAFC),
    onSurface: Color(0xFFF1F5F9),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF64748B),
  );

  static const cyberpunk = ThemePalette(
    primary: Color(0xFF00FFFF),
    primaryVariant: Color(0xFF00CCCC),
    secondary: Color(0xFFFF00FF),
    secondaryVariant: Color(0xFFCC00CC),
    background: Color(0xFF0A0A14),
    surface: Color(0xFF14142B),
    surfaceVariant: Color(0xFF252550),
    error: Color(0xFFFF0055),
    success: Color(0xFF00FF88),
    warning: Color(0xFFFFFF00),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFFFFFFFF),
    onSurface: Color(0xFFF0F0F0),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF4A9999),
  );

  static const minimal = ThemePalette(
    primary: Color(0xFF171717),
    primaryVariant: Color(0xFF404040),
    secondary: Color(0xFF737373),
    secondaryVariant: Color(0xFF525252),
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F5F5),
    error: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    warning: Color(0xFFCA8A04),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onBackground: Color(0xFF171717),
    onSurface: Color(0xFF262626),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFD4D4D4),
  );

  static const nature = ThemePalette(
    primary: Color(0xFF22C55E),
    primaryVariant: Color(0xFF16A34A),
    secondary: Color(0xFF84CC16),
    secondaryVariant: Color(0xFF65A30D),
    background: Color(0xFF14532D),
    surface: Color(0xFF166534),
    surfaceVariant: Color(0xFF15803D),
    error: Color(0xFFEF4444),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFFDCFCE7),
    onSurface: Color(0xFFBBF7D0),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF4ADE80),
  );

  static const sunset = ThemePalette(
    primary: Color(0xFFF97316),
    primaryVariant: Color(0xFFEA580C),
    secondary: Color(0xFFEC4899),
    secondaryVariant: Color(0xFFDB2777),
    background: Color(0xFF1C1917),
    surface: Color(0xFF292524),
    surfaceVariant: Color(0xFF3D3835),
    error: Color(0xFFEF4444),
    success: Color(0xFF22C55E),
    warning: Color(0xFFFBBF24),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onBackground: Color(0xFFFFFBEB),
    onSurface: Color(0xFFFEF7E0),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFA8A29E),
  );
}

/// 形状設定
class ComponentGeometry {
  final double borderRadiusSm;
  final double borderRadiusMd;
  final double borderRadiusLg;
  final double borderRadiusXl;
  final double elevationSm;
  final double elevationMd;
  final double elevationLg;
  final double borderWidth;

  const ComponentGeometry({
    required this.borderRadiusSm,
    required this.borderRadiusMd,
    required this.borderRadiusLg,
    required this.borderRadiusXl,
    required this.elevationSm,
    required this.elevationMd,
    required this.elevationLg,
    required this.borderWidth,
  });

  static const defaultGeometry = ComponentGeometry(
    borderRadiusSm: 4,
    borderRadiusMd: 8,
    borderRadiusLg: 16,
    borderRadiusXl: 24,
    elevationSm: 2,
    elevationMd: 4,
    elevationLg: 8,
    borderWidth: 1,
  );

  static const sharp = ComponentGeometry(
    borderRadiusSm: 0,
    borderRadiusMd: 2,
    borderRadiusLg: 4,
    borderRadiusXl: 8,
    elevationSm: 0,
    elevationMd: 2,
    elevationLg: 4,
    borderWidth: 2,
  );

  static const rounded = ComponentGeometry(
    borderRadiusSm: 8,
    borderRadiusMd: 16,
    borderRadiusLg: 24,
    borderRadiusXl: 32,
    elevationSm: 0,
    elevationMd: 0,
    elevationLg: 0,
    borderWidth: 1,
  );

  static const organic = ComponentGeometry(
    borderRadiusSm: 12,
    borderRadiusMd: 20,
    borderRadiusLg: 28,
    borderRadiusXl: 36,
    elevationSm: 2,
    elevationMd: 4,
    elevationLg: 6,
    borderWidth: 0,
  );

  BorderRadius get buttonRadius => BorderRadius.circular(borderRadiusMd);
  BorderRadius get cardRadius => BorderRadius.circular(borderRadiusLg);
  BorderRadius get inputRadius => BorderRadius.circular(borderRadiusSm);
}

/// タイポグラフィ設定
class TypographyPreset {
  final String primaryFontFamily;
  final String displayFontFamily;
  final double fontSizeXs;
  final double fontSizeSm;
  final double fontSizeBase;
  final double fontSizeLg;
  final double fontSizeXl;
  final double fontSize2xl;
  final double fontSize3xl;
  final double fontSize4xl;

  const TypographyPreset({
    required this.primaryFontFamily,
    required this.displayFontFamily,
    required this.fontSizeXs,
    required this.fontSizeSm,
    required this.fontSizeBase,
    required this.fontSizeLg,
    required this.fontSizeXl,
    required this.fontSize2xl,
    required this.fontSize3xl,
    required this.fontSize4xl,
  });

  static const defaultTypography = TypographyPreset(
    primaryFontFamily: 'Inter',
    displayFontFamily: 'Outfit',
    fontSizeXs: 10,
    fontSizeSm: 12,
    fontSizeBase: 14,
    fontSizeLg: 16,
    fontSizeXl: 20,
    fontSize2xl: 24,
    fontSize3xl: 32,
    fontSize4xl: 40,
  );
}

/// レイアウト密度設定
class LayoutDensity {
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacing2xl;
  final double densityMultiplier;

  const LayoutDensity({
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.spacing2xl,
    required this.densityMultiplier,
  });

  static const defaultDensity = LayoutDensity(
    spacingXs: 4,
    spacingSm: 8,
    spacingMd: 16,
    spacingLg: 24,
    spacingXl: 32,
    spacing2xl: 48,
    densityMultiplier: 1.0,
  );

  static const spacious = LayoutDensity(
    spacingXs: 5,
    spacingSm: 10,
    spacingMd: 20,
    spacingLg: 30,
    spacingXl: 40,
    spacing2xl: 60,
    densityMultiplier: 1.25,
  );

  static const compact = LayoutDensity(
    spacingXs: 3,
    spacingSm: 6,
    spacingMd: 12,
    spacingLg: 18,
    spacingXl: 24,
    spacing2xl: 36,
    densityMultiplier: 0.75,
  );
}

/// インタラクション設定
class InteractionFlow {
  final Duration durationFast;
  final Duration durationNormal;
  final Duration durationSlow;
  final Curve easingStandard;
  final Curve easingEmphasized;

  const InteractionFlow({
    required this.durationFast,
    required this.durationNormal,
    required this.durationSlow,
    required this.easingStandard,
    required this.easingEmphasized,
  });

  static const defaultInteraction = InteractionFlow(
    durationFast: Duration(milliseconds: 150),
    durationNormal: Duration(milliseconds: 300),
    durationSlow: Duration(milliseconds: 500),
    easingStandard: Curves.easeInOut,
    easingEmphasized: Curves.easeOutBack,
  );

  static const slow = InteractionFlow(
    durationFast: Duration(milliseconds: 200),
    durationNormal: Duration(milliseconds: 400),
    durationSlow: Duration(milliseconds: 700),
    easingStandard: Curves.easeInOut,
    easingEmphasized: Curves.easeOutCubic,
  );
}
