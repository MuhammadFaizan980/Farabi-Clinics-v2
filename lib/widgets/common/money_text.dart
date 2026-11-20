import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// an amount as the api formats it ("45.00 SAR"). a Saudi riyal amount is drawn
/// the Figma way, the riyal sign before the number; anything else is shown
/// exactly as the api sent it.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.formatted, {
    super.key,
    required this.style,
    this.iconSize = 13,
    this.gap = 3,
  });

  final String formatted;
  final TextStyle style;
  final double iconSize;
  final double gap;

  static final _sar = RegExp(r'^\s*(-?[+\-]?[\d.,]+)\s*(SAR|ر\.س|ريال)\s*$');

  @override
  Widget build(BuildContext context) {
    final match = _sar.firstMatch(formatted);
    if (match == null) return Text(formatted, style: style);

    final color = style.color ?? Colors.black;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAssets.iconSar,
          width: iconSize.rw,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        SizedBox(width: gap.rw),
        Text(match.group(1)!, style: style),
      ],
    );
  }
}
