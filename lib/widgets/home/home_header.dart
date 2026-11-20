import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/app_border_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// red header with the wordmark, bell and profile icons, and the search bar
/// that overlaps its bottom edge. geometry is the figma home frame (414 wide):
/// header 133 tall including the 44 status bar, search 373 x 52 at y 105.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.searchHint,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.languageLabel,
    required this.onLanguageTap,
    this.onBellTap,
  });

  /// short code of the language the toggle switches to ("AR" / "EN")
  final String languageLabel;
  final VoidCallback onLanguageTap;

  final String searchHint;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: top + 113.rh,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: top + 89.rh,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(16.r),
                  bottomEnd: Radius.circular(16.r),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 24.rw,
            top: top + 21.rh,
            child: SvgPicture.asset(
              AppAssets.logoWordmarkWhite,
              width: 102.53.rw,
              height: 21.rh,
            ),
          ),
          PositionedDirectional(
            end: 83.rw,
            top: top + 24.rh,
            child: GestureDetector(
              onTap: onLanguageTap,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 20.rw,
                child: Center(
                  child: Text(
                    languageLabel,
                    style: AppTextStyles.chip.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 53.rw,
            top: top + 24.rh,
            child: _HeaderIcon(
              asset: AppAssets.iconBell,
              onTap: onBellTap,
            ),
          ),
          PositionedDirectional(
            end: 23.rw,
            top: top + 24.rh,
            child: _HeaderIcon(
              asset: AppAssets.iconUser,
              onTap: onProfileTap,
            ),
          ),
          PositionedDirectional(
            start: 20.rw,
            end: 21.rw,
            top: top + 61.rh,
            height: 52.rh,
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: onSearchTap,
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.sm,
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.iconSearch,
                        width: 18.rw,
                        height: 18.rw,
                      ),
                      SizedBox(width: 9.rw),
                      Expanded(
                        child: Text(
                          searchHint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.searchHint
                              .copyWith(color: AppColors.inkSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.asset, this.onTap});

  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 20.rw,
        height: 20.rw,
        child: SvgPicture.asset(asset),
      ),
    );
  }
}
