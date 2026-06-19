import 'package:flutter/material.dart';

class VisualConfig {
  // ── Brand palette ────────────────────────────────────────────────────────
  static const Color espressoBrown = Color(0xFF5C3D2E);
  static const Color amber = Color(0xFFF4A261);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color panel = Color(0xFFFFF0DC);
  static const Color panelBorder = Color(0xFF7B5242);

  // ── Backward-compat aliases ───────────────────────────────────────────────
  static const Color coffeeBrown = espressoBrown;
  static const Color caramel = amber;
  static const Color accent = successGreen;

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF52B788);
  static const Color danger = Color(0xFFE63946);
  static const Color gemBlue = Color(0xFF4FC3F7);

  // ── HUD bar ───────────────────────────────────────────────────────────────
  static const Color hudBg = Color(0xFF3D1F0D);
  static const Color hudText = Color(0xFFFFF3E0);
  static const Color hudSubtext = Color(0xFFBCAAA4);

  // ── Per-station card backgrounds ──────────────────────────────────────────
  static const Color stationEspresso = Color(0xFFC1440E);
  static const Color stationGrinder = Color(0xFFD4850A);
  static const Color stationPastry = Color(0xFF8B6BA8);
  static const Color stationDefault = Color(0xFF6B4226);
  static const Color stationLocked = Color(0xFF546E7A);

  // ── Cafe scene ────────────────────────────────────────────────────────────
  static const Color floorHoney = Color(0xFFD4956A);
  static const Color floorPlank = Color(0xFFBF7E52);
  static const Color wallOffWhite = Color(0xFFFDF4E7);
  static const Color counterBrown = Color(0xFF5C3D2E);
  static const Color counterTop = Color(0xFF8B6346);
  static const Color tableWood = Color(0xFFC4895F);
  static const Color chairWood = Color(0xFF9E7B5A);
  static const Color welcomeMat = Color(0xFFE8A87C);

  // ── Geometry ──────────────────────────────────────────────────────────────
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double spaceSm = 10;
  static const double spaceMd = 14;
  static const double spaceLg = 18;

  static ThemeData appTheme() {
    final scheme = ColorScheme.fromSeed(seedColor: espressoBrown).copyWith(
      surface: panel,
      primary: espressoBrown,
      secondary: amber,
      error: danger,
      onPrimary: Colors.white,
      onSurface: espressoBrown,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      visualDensity: VisualDensity.compact,
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.1),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.1),
        titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        bodyMedium: TextStyle(fontSize: 14.5, height: 1.25),
        bodySmall: TextStyle(fontSize: 12.5, height: 1.2),
        labelLarge: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 4,
        shadowColor: const Color(0x445C3D2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: panelBorder, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFFF0DC),
        selectedColor: amber.withValues(alpha: 0.3),
        disabledColor: const Color(0xFFEDDCC8),
        side: const BorderSide(color: panelBorder, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        elevation: 8,
        shadowColor: const Color(0x665C3D2E),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: espressoBrown,
          foregroundColor: Colors.white,
          minimumSize: const Size(96, 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          disabledBackgroundColor: espressoBrown.withValues(alpha: 0.25),
          disabledForegroundColor: Colors.white70,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: espressoBrown,
          minimumSize: const Size(72, 38),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white70,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSm)),
      ),
    );
  }
}
