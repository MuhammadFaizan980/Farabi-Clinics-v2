import 'package:flutter/material.dart';

import 'extensions/responsive_extensions.dart';

/// the website ships four weights of the Farabi family (light / medium /
/// semi-bold / bold). until the licensed font files land we fall back to the
/// platform family but keep the weight ladder identical, so swapping the family
/// in is a one-line change here.
class AppTextStyles {
  AppTextStyles._();

  static const String? _family = null;

  static TextStyle get h1 => TextStyle(
        fontFamily: _family,
        fontSize: 24.rf,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get h2 => TextStyle(
        fontFamily: _family,
        fontSize: 20.rf,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get h3 => TextStyle(
        fontFamily: _family,
        fontSize: 18.rf,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _family,
        fontSize: 16.rf,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _family,
        fontSize: 14.rf,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get bodySemiBold => TextStyle(
        fontFamily: _family,
        fontSize: 14.rf,
        fontWeight: FontWeight.w600,
        height: 1.45,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: _family,
        fontSize: 12.rf,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get button => TextStyle(
        fontFamily: _family,
        fontSize: 16.rf,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );
}
