import 'package:flutter/material.dart';

/// Centralized color palette used across the app.
/// Includes AQI colors, UI neutrals and text colors.
class AppColors {
  // AQI / Air quality colors
  static const Color aqiGreen = Color(0xFF36E27B); // Good
  static const Color aqiYellow = Color(0xFFFACC15); // Moderate
  static const Color aqiOrange = Color(0xFFFB923C); // Unhealthy for sensitive
  static const Color aqiRed = Color(0xFFEF4444); // Unhealthy
  static const Color aqiPurple = Color(0xFFA855F7); // Very Unhealthy

  // UI & text colors
  static const Color slateGray = Color(0xFF94A3B8); // Offline / disabled / secondary
  static const Color backgroundGray = Color(0xFFF6F8F7); // Scaffold background
  static const Color textPrimary = Color(0xFF0F172A); // Primary text (Slate 900)
  static const Color textSecondary = Color(0xFF64748B); // Secondary text (Slate 500)

  // Light / background variants for AQI categories (used in badges etc.)
  static const Color categoryGoodLight = Color(0xFFE8FBF0);
  static const Color categoryAcceptableLight = Color(0xFFFFF9E5);
  static const Color categoryBadLight = Color(0xFFFFF6EE);
  static const Color categoryVeryBadLight = Color(0xFFFFEBEB);
  static const Color categoryExtremeLight = Color(0xFFF3E8FF);
  static const Color categoryMaintenanceLight = Color(0xFFF1F5F9);

  // Status badge colors (design)
  static const Color statusGoodBackground = Color(0xFFD7F9E4); // Good Quality background
  static const Color statusGoodText = Color(0xFF15803D); // Good Quality text
  static const Color statusGoodCircle = Color(0xFF36E27B); // Good Quality circle

  static const Color statusModerateBackground = Color(0xFFFEF9C3); // Moderate background
  static const Color statusModerateText = Color(0xFFA16207); // Moderate text
  static const Color statusModerateCircle = Color(0xFFFACC15); // Moderate circle

  static const Color statusUnhealthyForSensitiveBackground = Color(0xFFFFEDD5); // Unhealthy for Sensitive Groups background
  static const Color statusUnhealthyForSensitiveText = Color(0xFFC2410C); // Unhealthy for Sensitive text
  static const Color statusUnhealthyForSensitiveCircle = Color(0xFFFB923C); // Unhealthy for Sensitive circle

  static const Color statusUnhealthyBackground = Color(0xFFFEE2E2); // Unhealthy background
  static const Color statusUnhealthyText = Color(0xFFB91C1C); // Unhealthy text
  static const Color statusUnhealthyCircle = Color(0xFFEF4444); // Unhealthy circle

  static const Color statusVeryUnhealthyBackground = Color(0xFFF3E8FF); // Very Unhealthy background
  static const Color statusVeryUnhealthyText = Color(0xFF7E22CE); // Very Unhealthy text
  static const Color statusVeryUnhealthyCircle = Color(0xFFA855F7); // Very Unhealthy circle

  static const Color statusFueraServicioBackground = Color(0xFFE2E8F0); // Fuera de Servicio background
  static const Color statusFueraServicioText = Color(0xFF64748B); // Fuera de Servicio text
  static const Color statusFueraServicioCircle = Color(0xFF94A3B8); // Fuera de Servicio circle

  // Backwards-compatible aliases (so existing code can keep using older names)
  static const Color categoryGood = aqiGreen;
  static const Color categoryAcceptable = aqiYellow;
  static const Color categoryBad = aqiOrange;
  static const Color categoryVeryBad = aqiRed;
  static const Color categoryExtreme = aqiPurple;
  static const Color categoryMaintenance = slateGray;

  // Optional helper to map an AQI level to a color
  static Color colorForAqiLevel(AqiLevel level) {
    switch (level) {
      case AqiLevel.good:
        return aqiGreen;
      case AqiLevel.moderate:
        return aqiYellow;
      case AqiLevel.unhealthyForSensitive:
        return aqiOrange;
      case AqiLevel.unhealthy:
        return aqiRed;
      case AqiLevel.veryUnhealthy:
        return aqiPurple;
      case AqiLevel.offline:
        return slateGray;
    }
  }

  // Status helpers (background + text color pairs)
  static StatusColors getColorsForStatus(Status status) {
    switch (status) {
      case Status.good:
        return const StatusColors(background: statusGoodBackground, text: statusGoodText, circle: statusGoodCircle);
      case Status.moderate:
        return const StatusColors(background: statusModerateBackground, text: statusModerateText, circle: statusModerateCircle);
      case Status.unhealthyForSensitive:
        return const StatusColors(background: statusUnhealthyForSensitiveBackground, text: statusUnhealthyForSensitiveText, circle: statusUnhealthyForSensitiveCircle);
      case Status.unhealthy:
        return const StatusColors(background: statusUnhealthyBackground, text: statusUnhealthyText, circle: statusUnhealthyCircle);
      case Status.veryUnhealthy:
        return const StatusColors(background: statusVeryUnhealthyBackground, text: statusVeryUnhealthyText, circle: statusVeryUnhealthyCircle);
      case Status.fueraDeServicio:
        return const StatusColors(background: statusFueraServicioBackground, text: statusFueraServicioText, circle: statusFueraServicioCircle);
    }
  }
}

/// Enum describing AQI buckets used by the app.
enum AqiLevel {
  good,
  moderate,
  unhealthyForSensitive,
  unhealthy,
  veryUnhealthy,
  offline,
}

/// High-level status types used for badges and labels in the UI.
enum Status {
  good,
  moderate,
  unhealthyForSensitive,
  unhealthy,
  veryUnhealthy,
  fueraDeServicio,
}

/// Pair of colors used for status badges: background, text and circle.
class StatusColors {
  final Color background;
  final Color text;
  final Color circle;
  const StatusColors({required this.background, required this.text, required this.circle});
}
