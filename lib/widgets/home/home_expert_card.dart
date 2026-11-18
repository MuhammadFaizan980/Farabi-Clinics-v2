import 'package:flutter/material.dart';

import '../../data/constants/app_assets.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// "Get Expert Medical Consultation": 372 x 169 white card, radius 16, 1px
/// black 4% border and a soft upward shadow. the doctor image (168 x 190) sits
/// 22 above the card's top edge, as in the frame.
class HomeExpertCard extends StatelessWidget {
  const HomeExpertCard({
    super.key,
    required this.title,
    required this.body,
    required this.linkLabel,
    required this.onLinkTap,
  });

  final String title;
  final String body;
  final String linkLabel;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: 20.rw),
      height: 169.rh,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: Offset(2.rw, -4.rh),
            blurRadius: 24.r,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            end: 23.rw,
            top: -22.rh,
            child: Image.asset(
              AppAssets.imageExpertConsult,
              width: 168.rw,
              height: 190.rh,
              fit: BoxFit.contain,
            ),
          ),
          PositionedDirectional(
            start: 16.rw,
            top: 16.rh,
            width: 215.rw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 183.rw,
                  child: Text(
                    title,
                    style: AppTextStyles.expertTitle
                        .copyWith(color: Colors.black),
                  ),
                ),
                SizedBox(height: 6.rh),
                Text(
                  body,
                  style: AppTextStyles.expertBody
                      .copyWith(color: Colors.black.withValues(alpha: 0.64)),
                ),
                SizedBox(height: 16.rh),
                GestureDetector(
                  onTap: onLinkTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        linkLabel,
                        style: AppTextStyles.expertLink.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4.rw),
                      Icon(
                        Icons.north_east,
                        size: 14.rw,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
