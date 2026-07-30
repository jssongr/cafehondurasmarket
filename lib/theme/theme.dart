import 'package:flutter/material.dart';

/// NexCarg brand palette.
class AppColors {
  AppColors._();

  // Core navy (headers, primary text)
  static const navy = Color(0xFF0F1F29);
  static const navyLight = Color(0xFF1E3A52);
  static const navyXLight = Color(0xFF2C5468);

  // Brand blue — primary CTAs
  static const blue = Color(0xFF0D47FF);
  static const blueLight = Color(0xFF5470FF);

  // Brand green — success / escrow released
  static const green = Color(0xFF00C896);
  static const greenBg = Color(0xFFDDF9F0);

  // Amber — ratings, highlighted price
  static const amber = Color(0xFFFFB800);
  static const amberLight = Color(0xFFFFE59A);
  static const amberBg = Color(0xFFFFF4D6);
  static const amberText = Color(0xFF8A5B00);

  static const bg = Color(0xFFF1F5F9);
  static const white = Color(0xFFFFFFFF);
  static const gris50 = Color(0xFFF8F9FB);
  static const gris100 = Color(0xFFE7E9ED);
  static const gris300 = Color(0xFFC7CCD4);
  static const grisM = Color(0xFF8A93A3);
  static const texto = Color(0xFF182233);

  static const rojo = Color(0xFFDC2626);
  static const rojoBg = Color(0xFFFEF2F2);
  static const azul = Color(0xFF1E40AF);
  static const azulBg = Color(0xFFDBEAFE);
  static const verde = Color(0xFF15803D);
  static const verdeBg = Color(0xFFDCFCE7);
  static const indigo = Color(0xFF4338CA);
  static const indigoBg = Color(0xFFE0E7FF);
}

class BadgeStyle {
  final Color bg;
  final Color fg;
  const BadgeStyle(this.bg, this.fg);
}

const Map<String, BadgeStyle> badgeColors = {
  'publicada': BadgeStyle(AppColors.azulBg, AppColors.azul),
  'asignada': BadgeStyle(AppColors.amberBg, AppColors.amberText),
  'en_transito': BadgeStyle(AppColors.indigoBg, AppColors.indigo),
  'entregada': BadgeStyle(AppColors.verdeBg, AppColors.verde),
  'cancelada': BadgeStyle(AppColors.rojoBg, AppColors.rojo),
  'verificado': BadgeStyle(AppColors.verdeBg, AppColors.verde),
  'sinVerificar': BadgeStyle(AppColors.rojoBg, AppColors.rojo),
};

const Map<String, String> badgeLabels = {
  'publicada': 'Publicada',
  'asignada': 'Asignada',
  'en_transito': 'En tránsito',
  'entregada': 'Entregada',
  'cancelada': 'Cancelada',
};

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
  static const xxxl = 36.0;
}

class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

final cardShadow = [
  BoxShadow(
    color: AppColors.navy.withValues(alpha: 0.08),
    offset: const Offset(0, 4),
    blurRadius: 12,
  ),
];

final floatingShadow = [
  BoxShadow(
    color: AppColors.navy.withValues(alpha: 0.18),
    offset: const Offset(0, 10),
    blurRadius: 24,
  ),
];

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true, fontFamily: 'AppSans');
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.blue,
      secondary: AppColors.amber,
      surface: AppColors.white,
      error: AppColors.rojo,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.texto,
      displayColor: AppColors.navy,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

/// Dark variant. Custom screens in this app render with explicit AppColors
/// rather than theme lookups, so this currently governs Material-level
/// chrome (dialogs, switches, text fields) rather than every custom surface.
ThemeData buildAppDarkTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark, fontFamily: 'AppSans');
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF0B141C),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.blueLight,
      secondary: AppColors.amber,
      surface: const Color(0xFF16232E),
      error: AppColors.rojo,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
