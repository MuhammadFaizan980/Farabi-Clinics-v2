import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// the red title block of the more frame: 108 tall including the status bar,
/// bottom radius 16, title centred (18 / 28 semibold white).
class MoreHeader extends StatelessWidget {
  const MoreHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      height: top + 64.rh,
      width: double.infinity,
      alignment: Alignment.topCenter,
      padding: EdgeInsetsDirectional.only(top: top + 20.rh),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(16.r),
          bottomEnd: Radius.circular(16.r),
        ),
      ),
      child: Text(
        title,
        style: AppTextStyles.screenTitle.copyWith(color: AppColors.white),
      ),
    );
  }
}
