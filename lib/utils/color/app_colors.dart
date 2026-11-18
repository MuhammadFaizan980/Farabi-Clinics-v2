import 'package:flutter/material.dart';

/// raw brand palette. values lifted verbatim from the v2 website's css custom
/// properties so the app and the site cannot drift apart.
class AppColors {
  AppColors._();

  /// brand red as measured in the figma frames (the website css uses #c21c22)
  static const Color primary = Color(0xFFCC1C1C);
  static const Color primaryLight = Color(0xD9FFECED);
  static const Color pinkLight = Color(0xFFFFECED);
  static const Color secondary = Color(0xFF222222);

  /// figma text colours: headings/body ink and the grey used for secondary text
  static const Color ink = Color(0xFF1D1D24);
  static const Color inkSecondary = Color(0xFF797777);
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

  /// tints measured on the home frame: #edc5c5 @12%, #f1f1f1 @32%, #cc1c1c @20%/4%
  static const Color tileTint = Color(0x1FEDC5C5);
  static const Color stripFill = Color(0x52F1F1F1);
  static const Color redTint20 = Color(0x33CC1C1C);
  static const Color redBorder4 = Color(0x0ACC1C1C);
  static const Color chipFill = Color(0x05211722);

  /// doctors frame: list #f8f8f8, search pill #fbfbfb, hairlines black @8%,
  /// selected chip #cc1c1c @6%, filter button ring #cc1c1c @8%
  static const Color listBackground = Color(0xFFF8F8F8);
  static const Color fieldFill = Color(0xFFFBFBFB);
  static const Color hairline8 = Color(0x14000000);
  static const Color redSelected6 = Color(0x0FCC1C1C);
  static const Color redRing8 = Color(0x14CC1C1C);
  static const Color chipInk = Color(0xFF333333);

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
