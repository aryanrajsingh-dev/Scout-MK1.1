import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/utils/app_theme.dart' as core_theme;

class AppThemeData {
  AppThemeData._();

  static ThemeData dark() {
    final base = ThemeData.dark();

    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: core_theme.AppTheme.background,
      primaryColor: core_theme.AppTheme.accentCyan,
      colorScheme: base.colorScheme.copyWith(
        primary: core_theme.AppTheme.accentCyan,
        secondary: core_theme.AppTheme.accentCyanDark,
      ),
      textTheme: textTheme.copyWith(
        bodySmall: textTheme.bodySmall?.copyWith(fontSize: 11.sp),
        bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 15.sp),
        titleSmall: textTheme.titleSmall?.copyWith(fontSize: 14.sp),
        titleMedium: textTheme.titleMedium?.copyWith(fontSize: 16.sp),
        titleLarge: textTheme.titleLarge?.copyWith(fontSize: 18.sp),
        headlineSmall: textTheme.headlineSmall?.copyWith(fontSize: 20.sp),
        headlineMedium: textTheme.headlineMedium?.copyWith(fontSize: 22.sp),
        headlineLarge: textTheme.headlineLarge?.copyWith(fontSize: 24.sp),
      ).apply(
        bodyColor: core_theme.AppTheme.textPrimary,
        displayColor: core_theme.AppTheme.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
