import 'package:flutter/material.dart';

/// Material 3 themes seeded with the OpenTTD green; light and dark share the
/// same brand palette (docs/dev/architecture → i18n & theming).
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
      scaffoldBackgroundColor: scheme.surface,
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
