import 'package:flutter/material.dart';

class AppColors {
  // Prevent accidental instantiation
  AppColors._();

  /// =========================
  /// Brand Colors
  /// =========================

  /// Primary brand color
  static const Color primaryColor = Color(0xFF145E90); // Deep blue

  /// Accent / highlight color
  static const Color accentColor =
      Color.fromARGB(255, 127, 192, 215); // Olive gold

  /// Pure white (text, cards, surfaces)
  static const Color white = Color(0xFFFFFFFF);

  /// =========================
  /// UI Support Colors
  /// =========================

  /// App background (soft neutral to reduce eye strain)
  static const Color backgroundColor = Color(0xFFF6F7F9);

  /// Divider / border color
  static const Color borderColor = Color(0xFFE0E0E0);

  /// Disabled / hint text
  static const Color hintTextColor = Color(0xFF9E9E9E);

  /// Primary text color
  static const Color textPrimary = Color(0xFF1E1E1E);

  /// Secondary text color
  static const Color textSecondary = Color(0xFF616161);
}
