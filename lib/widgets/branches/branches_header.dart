import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

class BranchesTab {
  const BranchesTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// red header of the branches frame: 139 tall including the status bar, bottom
/// radius 16, centred title, and one tab per city. the active tab carries a
/// 32 x 2 yellow underline; inactive tabs are drawn at 64% opacity.
class BranchesHeader extends StatelessWidget {
  const BranchesHeader({super.key, required this.title, required this.tabs});

  final String title;
  final List<BranchesTab> tabs;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      height: top + 95.rh,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(16.r),
          bottomEnd: Radius.circular(16.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: top + 20.rh,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle.copyWith(color: AppColors.white),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: top + 65.rh,
            height: 30.rh,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final tab in tabs)
                        Padding(
                          padding:
                              EdgeInsetsDirectional.symmetric(horizontal: 14.rw),
                          child: _TabView(tab: tab),
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

class _TabView extends StatelessWidget {
  const _TabView({required this.tab});

  final BranchesTab tab;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tab.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: tab.selected ? 1 : 0.64,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppAssets.iconPinOutlineWhite,
                  width: 13.rw,
                  height: 15.rw,
                ),
                SizedBox(width: 8.rw),
                Text(
                  tab.label,
                  style: AppTextStyles.branchTab(active: tab.selected)
                      .copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.rh),
          Container(
            width: 32.rw,
            height: 2.rh,
            color: tab.selected ? AppColors.tabUnderline : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
