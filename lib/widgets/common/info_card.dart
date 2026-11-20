import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// white rounded card (radius 16, hairline border) with an optional heading,
/// the building block of the site's profile-style screens.
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, this.title, required this.child, this.padding});

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsetsDirectional.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
            ),
            SizedBox(height: 12.rh),
          ],
          child,
        ],
      ),
    );
  }
}
