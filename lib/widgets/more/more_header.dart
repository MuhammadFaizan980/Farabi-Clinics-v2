import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// the red title block of the more frame: 108 tall including the status bar,
/// bottom radius 16, title centred (18 / 28 semibold white).
class MoreHeader extends StatelessWidget {
  const MoreHeader({super.key, required this.title, this.onBack});

  final String title;

  /// shows a back chevron at the leading edge when set (pushed screens)
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      height: top + 64.rh,
      width: double.infinity,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(16.r),
          bottomEnd: Radius.circular(16.r),
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: top + 20.rh,
            start: 0,
            end: 0,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle.copyWith(color: AppColors.white),
            ),
          ),
          if (onBack != null)
            PositionedDirectional(
              top: top + 14.rh,
              start: 8.rw,
              child: IconButton(
                onPressed: onBack,
                icon: const BackButtonIcon(),
                color: AppColors.white,
                iconSize: 22.rw,
              ),
            ),
        ],
      ),
    );
  }
}
