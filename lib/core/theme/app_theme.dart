/// App theme configuration with Material Design 3

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

/// App color scheme based on Islamic themes
class AppColors {
  // Primary Colors (Islamic Blue)
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryContainer = Color(0xFFE3F2FD);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryVariant = Color(0xFF1565C0);
  
  // Secondary Colors (Islamic Purple)
  static const Color secondary = Color(0xFF8E24AA);
  static const Color secondaryContainer = Color(0xFFF3E5F5);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryVariant = Color(0xFF6A1B9A);
  
  // Surface Colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF212121);
  static const Color surfaceContainer = Color(0xFFF8F8F8);
  static const Color surfaceContainerHigh = Color(0xFFEEEEEE);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E0);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color onBackground = Color(0xFF212121);
  
  // Error Colors
  static const Color error = Color(0xFFF44336);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);
  
  // Prayer-Specific Colors
  static const Color fajrColor = Color(0xFF4A148C); // Dark Purple (Dawn)
  static const Color dhuhrColor = Color(0xFFF57C00); // Orange (Noon)
  static const Color asrColor = Color(0xFF2E7D32); // Green (Afternoon)
  static const Color maghribColor = Color(0xFFD84315); // Deep Orange (Sunset)
  static const Color ishaColor = Color(0xFF1565C0); // Blue (Night)
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color outline = Color(0xFF757575);
  static const Color outlineVariant = Color(0xFFBDBDBD);
  
  /// Get prayer color by prayer enum
  static Color getPrayerColor(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajrColor;
      case Prayer.dhuhr:
        return dhuhrColor;
      case Prayer.asr:
        return asrColor;
      case Prayer.maghrib:
        return maghribColor;
      case Prayer.isha:
        return ishaColor;
    }
  }
  
  /// Get prayer color by name string
  static Color getPrayerColorByName(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return fajrColor;
      case 'dhuhr':
        return dhuhrColor;
      case 'asr':
        return asrColor;
      case 'maghrib':
        return maghribColor;
      case 'isha':
        return ishaColor;
      default:
        return primary;
    }
  }
  
  /// Create a color scheme from a seed color
  static ColorScheme fromSeed(Color seed, {bool isDark = false}) {
    final corePalette = CorePalette.of(seed.value);
    final palette = isDark ? corePalette.dark : corePalette.light;
    
    return ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: Color(palette.primary.get(40)),
      onPrimary: Color(palette.primary.get(100)),
      primaryContainer: Color(palette.primary.get(90)),
      onPrimaryContainer: Color(palette.primary.get(10)),
      secondary: Color(palette.secondary.get(40)),
      onSecondary: Color(palette.secondary.get(100)),
      secondaryContainer: Color(palette.secondary.get(90)),
      onSecondaryContainer: Color(palette.secondary.get(10)),
      tertiary: Color(palette.tertiary.get(40)),
      onTertiary: Color(palette.tertiary.get(100)),
      tertiaryContainer: Color(palette.tertiary.get(90)),
      onTertiaryContainer: Color(palette.tertiary.get(10)),
      error: Color(palette.error.get(40)),
      onError: Color(palette.error.get(100)),
      errorContainer: Color(palette.error.get(90)),
      onErrorContainer: Color(palette.error.get(10)),
      background: Color(palette.neutral.get(99)),
      onBackground: Color(palette.neutral.get(10)),
      surface: Color(palette.neutral.get(99)),
      onSurface: Color(palette.neutral.get(10)),
      surfaceVariant: Color(palette.neutralVariant.get(90)),
      onSurfaceVariant: Color(palette.neutralVariant.get(30)),
      outline: Color(palette.neutralVariant.get(50)),
      outlineVariant: Color(palette.neutralVariant.get(80)),
      shadow: Color(palette.neutral.get(0)),
      scrim: Color(palette.neutral.get(0)),
      inverseSurface: Color(palette.neutral.get(20)),
      onInverseSurface: Color(palette.neutral.get(95)),
      inversePrimary: Color(palette.primary.get(80)),
      surfaceTint: Color(palette.primary.get(40)),
    );
  }
}

/// App typography configuration
class AppTextStyles {
  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.25,
    height: 1.12,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.16,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.22,
  );
  
  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );
  
  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
  );
  
  // Custom Styles for App
  static const TextStyle prayerTime = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    height: 1.2,
  );
  
  static const TextStyle prayerName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.3,
  );
  
  static const TextStyle countdownTimer = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );
  
  static const TextStyle locationText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
  );
}

/// Extension for prayer color access
extension PrayerColors on ColorScheme {
  Color get fajrColor => AppColors.fajrColor;
  Color get dhuhrColor => AppColors.dhuhrColor;
  Color get asrColor => AppColors.asrColor;
  Color get maghribColor => AppColors.maghribColor;
  Color get ishaColor => AppColors.ishaColor;
  
  Color getPrayerColor(Prayer prayer) {
    return AppColors.getPrayerColor(prayer);
  }
}

/// App theme builder
class AppThemeBuilder {
  /// Build light theme
  static ThemeData buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColors.fromSeed(AppColors.primary, isDark: false),
      textTheme: _buildTextTheme(Brightness.light),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: _buildAppBarTheme(Brightness.light),
      navigationBarTheme: _buildNavigationBarTheme(Brightness.light),
      cardTheme: _buildCardTheme(Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
      textButtonTheme: _buildTextButtonTheme(Brightness.light),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
      dividerTheme: _buildDividerTheme(Brightness.light),
    );
  }
  
  /// Build dark theme
  static ThemeData buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColors.fromSeed(AppColors.primary, isDark: true),
      textTheme: _buildTextTheme(Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      navigationBarTheme: _buildNavigationBarTheme(Brightness.dark),
      cardTheme: _buildCardTheme(Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
      textButtonTheme: _buildTextButtonTheme(Brightness.dark),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
      dividerTheme: _buildDividerTheme(Brightness.dark),
    );
  }
  
  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? AppColors.onBackground : AppColors.onBackground;
    
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: color),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: color),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: color),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: color),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: color),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: color),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: color),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: color),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: color),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: color),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: color),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: color),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: color),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: color),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: color),
    );
  }
  
  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: brightness == Brightness.light ? AppColors.onPrimary : AppColors.onPrimary,
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
    );
  }
  
  static NavigationBarThemeData _buildNavigationBarTheme(Brightness brightness) {
    return NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.labelMedium;
        }
        return AppTextStyles.labelSmall;
      }),
    );
  }
  
  static CardTheme _buildCardTheme(Brightness brightness) {
    return CardTheme(
      elevation: 1,
      surfaceTintColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  
  static ElevatedButtonThemeData _buildElevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Brightness brightness) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.outline),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static TextButtonThemeData _buildTextButtonTheme(Brightness brightness) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static InputDecorationTheme _buildInputDecorationTheme(Brightness brightness) {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
  
  static DividerThemeData _buildDividerTheme(Brightness brightness) {
    return DividerThemeData(
      color: AppColors.outlineVariant,
      thickness: 1,
      space: 1,
    );
  }
}