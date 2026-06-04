import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFFE35335);
  static const Color primaryLight = Color(0xFFF56B4A);
  static const Color primaryDark = Color(0xFFC73E1F);

  // Secondary
  static const Color secondary = Color(0xFF2D3748);
  static const Color secondaryLight = Color(0xFF4A5568);
  static const Color secondaryDark = Color(0xFF1A202C);

  // Background / surface
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7FAFC);
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textDisabled = Color(0xFFA0AEC0);

  // Status
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF4299E1);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFCBD5E0);

  // Input
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color inputPlaceholder = textTertiary;

  // Navigation
  static const Color navBarBackground = Color(0xFFFFFFFF);
  static const Color navBarSelected = primary;
  static const Color navBarUnselected = Color(0xFFA0AEC0);

  // Shadows
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x2A000000);

  // Misc
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Dark mode
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkInputBackground = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surface],
  );
}
