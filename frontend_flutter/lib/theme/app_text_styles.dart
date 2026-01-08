import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Big screen titles (WELCOME, DASHBOARD, etc.)
  static const TextStyle title = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
    letterSpacing: 1.5,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  /// Section headings
  static const TextStyle heading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryColor,
  );

  /// Subtitles / helper text
  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Button text
  static const TextStyle button = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 17,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: AppColors.white,
  );

  /// Input labels
  static const TextStyle label = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
