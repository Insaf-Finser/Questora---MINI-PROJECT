import 'package:flutter/material.dart';
import 'package:quest/core/config/theme/app_colors.dart';

class AppTheme{
  static final lightTheme = ThemeData(
    primaryColor : AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    brightness:Brightness.light,
    elevatedButtonTheme : ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor : AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    brightness:Brightness.dark,
    elevatedButtonTheme : ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
}