import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.asset,
    required this.selectedAsset,
    required this.label,
  });

  /// the unselected and the selected Figma icon; both are two-tone, so they
  /// are drawn as they are, never tinted
  final String asset;
  final String selectedAsset;
  final String label;
}

/// figma bottom bar: 72 of content (26px icon 13 below the top edge, 14pt
/// label), white with a 1px top border, plus the device's bottom inset. the
/// active item is red and carries a short red bar on the top edge.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AppBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 72.rh + bottom,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _NavTab(
                  item: items[i],
                  active: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.ink;

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (active)
              Container(
                width: 36.rw,
                height: 3.rh,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(3.r),
                    bottomEnd: Radius.circular(3.r),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsetsDirectional.only(top: 12.rh),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    active ? item.selectedAsset : item.asset,
                    width: 26.rw,
                    height: 26.rw,
                  ),
                  SizedBox(height: 6.rh),
                  Text(
                    item.label,
                    style: AppTextStyles.navLabel(
                      active: active,
                    ).copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
