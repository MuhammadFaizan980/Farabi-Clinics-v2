import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

class VirtualServiceItem {
  const VirtualServiceItem({required this.icon, required this.label});

  final String icon;
  final String label;
}

/// "Virtual Clinic Services": 180 x 134 cards (radius 20) with a top-down red
/// to white gradient, a 28px icon, a two-line title and the arrow bottom-right.
/// there is no endpoint behind these yet, so the cards are display only.
class HomeVirtualServices extends StatelessWidget {
  const HomeVirtualServices({super.key, required this.items});

  final List<VirtualServiceItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 134.rh,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20.rw),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.rw),
        itemBuilder: (context, index) => _Card(item: items[index]),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.item});

  final VirtualServiceItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.rw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.redBorder4, width: 1),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.redTint20, Color(0x00FFFFFF)],
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            start: 14.rw,
            top: 14.rh,
            child: SvgPicture.asset(item.icon, width: 28.rw, height: 28.rw),
          ),
          PositionedDirectional(
            start: 16.rw,
            top: 71.rh,
            width: 124.rw,
            child: Text(
              item.label,
              style: AppTextStyles.virtualTitle.copyWith(color: AppColors.ink),
            ),
          ),
          PositionedDirectional(
            end: 16.rw,
            bottom: 18.rh,
            child: SvgPicture.asset(
              AppAssets.iconVirtualArrow,
              width: 18.rw,
              height: 18.rw,
            ),
          ),
        ],
      ),
    );
  }
}
