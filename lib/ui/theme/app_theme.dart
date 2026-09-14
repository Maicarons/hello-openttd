import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';

/// Material 3 themes seeded with the OpenTTD green; light and dark share the
/// same brand palette (docs/dev/architecture → i18n & theming).
///
/// `useSystemChineseFont` fixes CJK typography: the Flutter engine default is
/// a Latin font, which renders Chinese glyphs at "normal" weight only and
/// fakes bold — this applies a proper per-platform Chinese fallback
/// (Microsoft YaHei UI / PingFang SC / Noto Sans CJK).
class AppTheme {
  AppTheme._();

  static const seed = Color(0xFF2E7D32);

  static ThemeData light() => _from(Brightness.light);

  static ThemeData dark() => _from(Brightness.dark);

  static ThemeData _from(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: scheme.surface,
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    ).useSystemChineseFont(brightness);
  }
}
