import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// white rounded card (radius 16, hairline border) with an optional heading
/// (17 / 24 bold), the building block of the profile-style frames: 18 side
/// padding, 12 top and bottom, 6 between the heading and the body.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.titleInset = 0,
  });

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// extra start inset for the heading when the card's own padding is tighter
  /// than the heading's 18 (cards that hold full-width rows)
  final double titleInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? EdgeInsetsDirectional.fromSTEB(18.rw, 12.rh, 18.rw, 12.rh),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsetsDirectional.only(start: titleInset.rw),
              child: Text(
                title!,
                style: AppTextStyles.listCardTitle.copyWith(
                  color: AppColors.ink,
                  height: 24 / 17,
                ),
              ),
            ),
            SizedBox(height: 6.rh),
          ],
          child,
        ],
      ),
    );
  }
}
