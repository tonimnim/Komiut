import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Refined for Pixel Perfection
  static const Color primaryBlue = Color(0xFF1D4ED8); // Deep Vibrant Blue
  static const Color primaryDark = Color(0xFF0F172A); // Dark Slate
  static const Color primaryLight = Color(0xFF3B82F6); // Action Blue

  // Secondary & Semantic
  static const Color primaryGreen = Color(0xFF059669); // Success Green
  static const Color primaryOrange = Color(0xFFF97316); // Warning/Highlight
  static const Color secondaryOrange = Color(0xFFFB923C);
  static const Color secondaryPurple = Color(0xFF8B5CF6);

  // Aliases for driver app compatibility
  static const Color primary = primaryBlue;
  static const Color accent = primaryBlue;

  static const Color success = primaryGreen;
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Neutral colors - Tailored for high-end UI
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color dutyOnline = primaryBlue;
  static const Color dutyOffline = textSecondary;
  
  static const Color statusOnline = primaryGreen;
  static const Color statusOffline = dutyOffline;
  static const Color statusOnTrip = info;

  // Status colors (from remote)
  static const Color completed = Color(0xFF059669);
  static const Color failed = Color(0xFFEF4444);
  static const Color pending = Color(0xFFF59E0B);
  
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color dividerDark = Color(0xFF1F2937);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x0D000000); // Subtle shadow
  static const Color shadow = Color(0x1A000000);
  
  static const Color pillBlueBg = Color(0xFFEFF6FF); // Light blue for pills
  static const Color pillGreenBg = Color(0xFFECFDF5); // Light green for status
  
  // Dark mode specific
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF111827);

  // Premium HSL-based Gradients
  static const LinearGradient premiumBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D4ED8), // Deep Blue
      Color(0xFF3B82F6), // Vibrant Blue
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x0DFFFFFF),
    ],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF9FAFB),
    ],
  );
}
