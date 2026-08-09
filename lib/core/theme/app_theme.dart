import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
      scrim: Colors.black54,
      inverseSurface: AppColors.onSurface,
      onInverseSurface: AppColors.surface,
      inversePrimary: const Color(0xFF6B9FFF),
    );

    final display = GoogleFonts.dmSansTextTheme();
    final body = GoogleFonts.interTextTheme();

    final textTheme = body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: AppColors.onBackground,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 32,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        color: AppColors.onBackground,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        fontSize: 28,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: AppColors.onBackground,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        fontSize: 26,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: AppColors.onBackground,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        fontSize: 24,
      ),
      titleLarge: display.titleLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      titleMedium: display.titleMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      titleSmall: display.titleSmall?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: AppColors.onSurface,
        fontSize: 15,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: AppColors.onSurfaceVariant,
        fontSize: 12,
        height: 1.5,
      ),
      labelLarge: display.labelLarge?.copyWith(
        color: AppColors.onPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.15,
      ),
      labelMedium: display.labelMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        color: AppColors.outline,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.6,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      dividerColor: AppColors.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.headlineSmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabledContainer,
          disabledForegroundColor: AppColors.disabled,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          elevation: 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelMedium,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        side: const BorderSide(color: AppColors.outlineVariant, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
