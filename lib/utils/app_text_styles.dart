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

  // ---- figma text styles (all Neue Regrade once the font files land) ----

  static TextStyle _figma(double size, double lineHeight, FontWeight weight) =>
      TextStyle(
        fontFamily: _family,
        fontSize: size.rf,
        fontWeight: weight,
        height: lineHeight / size,
      );

  /// "Book by Service", "Virtual Clinic Services", city names: 17 / 24, 600
  static TextStyle get sectionTitle => _figma(17, 24, FontWeight.w600);

  /// doctor name: 17 / 26, 600
  static TextStyle get cardTitle => _figma(17, 26, FontWeight.w600);

  /// doctor branch line: 15 / 26, 500
  static TextStyle get cardSubtitle => _figma(15, 26, FontWeight.w500);

  /// chips and secondary lines: 14 / 18, 500
  static TextStyle get chip => _figma(14, 18, FontWeight.w500);

  /// speciality tile label: 14 / 16, 500, +2% tracking
  static TextStyle get tileLabel =>
      _figma(14, 16, FontWeight.w500).copyWith(letterSpacing: 0.28.rf);

  /// virtual-clinic card title: 18 / 22, 500
  static TextStyle get virtualTitle => _figma(18, 22, FontWeight.w500);

  /// search placeholder: 16 / 24, 500
  static TextStyle get searchHint => _figma(16, 24, FontWeight.w500);

  /// expert card: title 20 / 24 600, body 14 / 18 400, link 15 / 18 600
  static TextStyle get expertTitle => _figma(20, 24, FontWeight.w600);
  static TextStyle get expertBody => _figma(14, 18, FontWeight.w400);
  static TextStyle get expertLink => _figma(15, 18, FontWeight.w600);

  /// bottom navigation label: 14, 500 inactive / 600 active
  static TextStyle navLabel({required bool active}) =>
      _figma(14, 18, active ? FontWeight.w600 : FontWeight.w500);

  /// doctors header title: 18 / 28, 600
  static TextStyle get screenTitle => _figma(18, 28, FontWeight.w600);

  /// doctor list name: 17 / 26, 700
  static TextStyle get listCardTitle => _figma(17, 26, FontWeight.w700);

  /// filter chip label: 14 / 20, 600, -2% tracking
  static TextStyle get filterChip =>
      _figma(14, 20, FontWeight.w600).copyWith(letterSpacing: -0.28.rf);

  /// rating pill: 12, 600
  static TextStyle get rating => _figma(12, 13, FontWeight.w600);

  /// branches city tab: 15 / 24, +2% tracking, 600 active / 500 inactive
  static TextStyle branchTab({required bool active}) =>
      _figma(15, 24, active ? FontWeight.w600 : FontWeight.w500)
          .copyWith(letterSpacing: 0.3.rf);

  /// branch address line: 14 / 24, 400
  static TextStyle get branchAddress => _figma(14, 24, FontWeight.w400);

  /// pill labels on the branch card (closes at, call, distance): 13.5, 600
  static TextStyle get pillLabel => _figma(13.5, 17, FontWeight.w600);
}
