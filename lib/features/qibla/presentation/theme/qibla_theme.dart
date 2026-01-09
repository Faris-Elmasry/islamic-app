import 'package:flutter/material.dart';

/// App Theme Constants for Qibla Feature
///
/// Centralized theme management following DRY principle.
/// Uses the existing app color scheme.
class QiblaTheme {
  // Primary Colors
  static const Color primaryDark = Color(0xFF263238); // blueGrey[900]
  static const Color primaryMedium = Color(0xFF37474F); // blueGrey[800]
  static const Color primaryLight = Color(0xFF455A64); // blueGrey[700]

  // Accent Colors
  static const Color accentColor = Color(0xFF009688); // teal
  static const Color accentLight = Color(0xFF4DB6AC); // teal[300]
  static const Color accentDark = Color(0xFF00796B); // teal[700]

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // green
  static const Color successLight = Color(0xFF81C784); // green[300]
  static const Color warningColor = Color(0xFFFF9800); // orange
  static const Color errorColor = Color(0xFFF44336); // red

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // white70
  static const Color textMuted = Color(0x80FFFFFF); // white50

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, Color(0xFF1A237E)], // blueGrey to indigo
  );

  static const LinearGradient compassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryMedium, primaryDark],
  );

  static const RadialGradient qiblaIndicatorGradient = RadialGradient(
    colors: [successLight, successColor],
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  // Border Radius
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(12));

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16,
    color: textSecondary,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14,
    color: textMuted,
  );

  static TextStyle degreeStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    shadows: [
      Shadow(
        color: accentColor.withOpacity(0.5),
        blurRadius: 10,
      ),
    ],
  );
}
