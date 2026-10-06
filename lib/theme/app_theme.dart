import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF12324A);
  static const muted = Color(0xFF5C7A90);
  static const foam = Color(0xFFF4FBFF);
  static const card = Color(0xFFF8FCFF);
  static const coral = Color(0xFFD45353);
  static const deep = Color(0xFF08345C);
  static const ocean = Color(0xFF0C6EAE);
  static const sky = Color(0xFF1596D2);
  static const aqua = Color(0xFF3EC6E6);

  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A4F86), Color(0xFF127FBE), Color(0xFF3EBFDE)],
  );

  static const button = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0B6FB0), Color(0xFF22B7E0)],
  );

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF08345C).withValues(alpha: 0.16),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ocean,
        primary: AppColors.ocean,
        surface: AppColors.card,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      splashColor: AppColors.aqua.withValues(alpha: 0.16),
      highlightColor: Colors.transparent,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.deep,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
