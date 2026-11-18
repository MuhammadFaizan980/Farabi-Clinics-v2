import 'package:flutter/material.dart';

/// raw brand palette. values lifted verbatim from the v2 website's css custom
/// properties so the app and the site cannot drift apart.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFC21C22);
  static const Color primaryLight = Color(0xD9FFECED);
  static const Color pinkLight = Color(0xFFFFECED);
  static const Color secondary = Color(0xFF222222);
  static const Color brightGrey = Color(0xFF2C2C2C);

  static const Color error = Color(0xFFEA5454);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);

  static const Color greyDark = Color(0xFF777777);
  static const Color greyLight = Color(0xFFA9A9A9);
  static const Color lightGrey = Color(0xFFF8F8F8);
  static const Color boulder = Color(0xFFE5E7EB);
  static const Color boulderLight = Color(0xFFF8F8F8);

  /// the site uses an 8-bit-alpha hex here (#2117220a)
  static const Color cardBorder = Color(0x0A211722);
  static const Color doctorBackground = Color(0xFFFDF6F6);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DC);
  static const Color gray500 = Color(0xFF6A7282);
  static const Color gray600 = Color(0xFF4A5565);
  static const Color gray700 = Color(0xFF364153);
  static const Color gray800 = Color(0xFF1E2939);
}
