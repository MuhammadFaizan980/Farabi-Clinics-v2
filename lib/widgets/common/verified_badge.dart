import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// the Figma verified badge. the exported svg is a 47px canvas with the 17px
/// badge centred in its shadow padding, so it is drawn at canvas size inside
/// a [size] box.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 17});

  final double size;

  @override
  Widget build(BuildContext context) {
    final box = size.rw;
    final canvas = box * 47 / 17;
    return SizedBox(
      width: box,
      height: box,
      child: OverflowBox(
        maxWidth: canvas,
        maxHeight: canvas,
        child: SvgPicture.asset(
          AppAssets.moreVerified,
          width: canvas,
          height: canvas,
        ),
      ),
    );
  }
}
