import 'package:flutter/material.dart';

class AppColors {
  // Dark / OLED Palette
  static const Color pitchBlack = Color(0xFF000000);
  static const Color surface = Color(0xFF161618);
  static const Color cardSurface = Color(0xFF1C1C1E);
  static const Color elevatedSurface = Color(0xFF2C2C2E);

  // Borders & Separators
  static const Color hairline = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)
  static const Color hairlineLight = Color(0x26FFFFFF); // rgba(255, 255, 255, 0.15)
  static const Color borderNeutral = Color(0xFF262626);

  // Accent Colors
  static const Color pitchGreen = Color(0xFF30D158);
  static const Color pitchGreenGlow = Color(0x3330D158);
  static const Color metallicGold = Color(0xFFD4AF37);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color metallicGoldGlow = Color(0x33D4AF37);
  static const Color appleOrange = Color(0xFFFF9F0A);
  static const Color appleRed = Color(0xFFFF453A);

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF636366);

  // Badge colors
  static const Color badgeGreenBg = Color(0x1F30D158); // rgba(48, 209, 88, 0.12)
  static const Color badgeGreenBorder = Color(0x4030D158); // rgba(48, 209, 88, 0.25)

  static const Color badgeGoldBg = Color(0x1FD4AF37); // rgba(212, 175, 55, 0.12)
  static const Color badgeGoldBorder = Color(0x40D4AF37); // rgba(212, 175, 55, 0.25)

  static const Color badgeOrangeBg = Color(0x1FFF9F0A);
  static const Color badgeOrangeBorder = Color(0x40FF9F0A);

  // Light / Day Palette tokens
  static const Color lightScaffoldBg = Color(0xFFF8F9FA); // Warm off-white
  static const Color lightSurface = Color(0xFFF1F3F5);
  static const Color lightCardSurface = Color(0xFFFFFFFF);
  static const Color lightElevatedSurface = Color(0xFFE9ECEF);
  static const Color lightHairline = Color(0x14000000);
  static const Color lightBorderNeutral = Color(0xFFE5E7EB);
  static const Color lightEmeraldGreen = Color(0xFF1B5E20);
  static const Color lightEmeraldGreenAccent = Color(0xFF2E7D32);
  static const Color lightEmeraldGreenGlow = Color(0x262E7D32);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF555B62);
  static const Color lightTextTertiary = Color(0xFF7E868F);
  static const Color lightBadgeGoldBg = Color(0x1AD4AF37);
  static const Color lightBadgeGoldBorder = Color(0x40D4AF37);
  static const Color lightBadgeGreenBg = Color(0x1A2E7D32);
  static const Color lightBadgeGreenBorder = Color(0x382E7D32);

  static const AppThemeColors darkColors = AppThemeColors(
    isDark: true,
    scaffoldBg: pitchBlack,
    surface: surface,
    cardSurface: cardSurface,
    elevatedSurface: elevatedSurface,
    hairline: hairline,
    borderNeutral: borderNeutral,
    accentGreen: pitchGreen,
    greenGlow: pitchGreenGlow,
    metallicGold: metallicGold,
    metallicGoldGlow: metallicGoldGlow,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textTertiary: textTertiary,
    badgeGoldBg: badgeGoldBg,
    badgeGoldBorder: badgeGoldBorder,
    badgeGreenBg: badgeGreenBg,
    badgeGreenBorder: badgeGreenBorder,
    shadowColor: Color(0x66000000),
  );

  static const AppThemeColors lightColors = AppThemeColors(
    isDark: false,
    scaffoldBg: lightScaffoldBg,
    surface: lightSurface,
    cardSurface: lightCardSurface,
    elevatedSurface: lightElevatedSurface,
    hairline: lightHairline,
    borderNeutral: lightBorderNeutral,
    accentGreen: lightEmeraldGreenAccent,
    greenGlow: lightEmeraldGreenGlow,
    metallicGold: metallicGold,
    metallicGoldGlow: Color(0x26D4AF37),
    textPrimary: lightTextPrimary,
    textSecondary: lightTextSecondary,
    textTertiary: lightTextTertiary,
    badgeGoldBg: lightBadgeGoldBg,
    badgeGoldBorder: lightBadgeGoldBorder,
    badgeGreenBg: lightBadgeGreenBg,
    badgeGreenBorder: lightBadgeGreenBorder,
    shadowColor: Color(0x12000000),
  );

  static AppThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColors : lightColors;
  }
}

class AppThemeColors {
  final bool isDark;
  final Color scaffoldBg;
  final Color surface;
  final Color cardSurface;
  final Color elevatedSurface;
  final Color hairline;
  final Color borderNeutral;
  final Color accentGreen;
  final Color greenGlow;
  final Color metallicGold;
  final Color metallicGoldGlow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color badgeGoldBg;
  final Color badgeGoldBorder;
  final Color badgeGreenBg;
  final Color badgeGreenBorder;
  final Color shadowColor;

  const AppThemeColors({
    required this.isDark,
    required this.scaffoldBg,
    required this.surface,
    required this.cardSurface,
    required this.elevatedSurface,
    required this.hairline,
    required this.borderNeutral,
    required this.accentGreen,
    required this.greenGlow,
    required this.metallicGold,
    required this.metallicGoldGlow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.badgeGoldBg,
    required this.badgeGoldBorder,
    required this.badgeGreenBg,
    required this.badgeGreenBorder,
    required this.shadowColor,
  });
}
