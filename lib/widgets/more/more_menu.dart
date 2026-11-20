import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// 15 / 16 bold heading with +2% tracking, 22 in from the screen edge.
class MoreSectionHeading extends StatelessWidget {
  const MoreSectionHeading({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 22.rw, end: 22.rw),
      child: Text(
        text,
        style: AppTextStyles.sectionHeading.copyWith(color: Colors.black),
      ),
    );
  }
}

/// menu row: 382 x 70, radius 14, 1px black 4% border; 18px icon, title 15 / 20
/// semibold, subtitle 14 / 18 medium and a trailing chevron. a row without a
/// subtitle centres its title.
class MoreMenuRow extends StatelessWidget {
  const MoreMenuRow({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconAsset,
    this.fallbackIcon,
    this.destructive = false,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String? iconAsset;
  final IconData? fallbackIcon;
  final VoidCallback onTap;
  final bool destructive;

  /// replaces the chevron (a switch, for the language row)
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleColor = destructive ? AppColors.logout : AppColors.ink;

    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 70.rh,
          margin: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
          padding: EdgeInsetsDirectional.symmetric(horizontal: 18.rw),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: destructive ? AppColors.logoutBorder : AppColors.rowBorder4,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20.rw,
                height: 20.rw,
                child: iconAsset != null
                    ? SvgPicture.asset(iconAsset!)
                    : Icon(
                        fallbackIcon,
                        size: 18.rw,
                        color: AppColors.iconGrey,
                      ),
              ),
              SizedBox(width: 20.rw),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: (destructive
                              ? AppTextStyles.logoutTitle
                              : AppTextStyles.rowTitle)
                          .copyWith(color: titleColor),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.rowSubtitle
                            .copyWith(color: AppColors.inkSecondary),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (!destructive)
                SvgPicture.asset(
                  AppAssets.moreChevron,
                  width: 18.rw,
                  height: 18.rw,
                  matchTextDirection: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
