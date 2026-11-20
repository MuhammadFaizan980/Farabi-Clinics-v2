import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// 17 / 24 semibold section heading. the inset differs per section in the
/// figma frame (28 for most, 24 for "Location Base Appointment"), so it is a
/// parameter and not a constant.
class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle({
    super.key,
    required this.text,
    this.inset = 28,
    this.actionLabel,
    this.onAction,
  });

  final String text;
  final double inset;

  /// optional trailing link ("View all")
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: inset.rw, end: 20.rw),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(
                actionLabel!,
                style: AppTextStyles.cardSubtitle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
