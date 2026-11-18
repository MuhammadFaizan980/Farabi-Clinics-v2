import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

class MoreStat {
  const MoreStat({required this.icon, required this.value, required this.label});

  final String icon;
  final String value;
  final String label;
}

/// stats strip: 382 x 74, radius 14, 1px border and a soft drop shadow, three
/// columns split by thin dividers. each column is an 18px icon, a 20 / 24 number
/// and a 14 / 23 label aligned under the number.
class MoreStatsCard extends StatelessWidget {
  const MoreStatsCard({super.key, required this.stats});

  final List<MoreStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.rh,
      margin: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.statShadow,
            offset: Offset(0, 4.rh),
            blurRadius: 8.r,
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 16.rh,
                color: AppColors.divider32,
              ),
            Expanded(child: Center(child: _StatView(stat: stats[i]))),
          ],
        ],
      ),
    );
  }
}

class _StatView extends StatelessWidget {
  const _StatView({required this.stat});

  final MoreStat stat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(top: 3.rh),
          child: SvgPicture.asset(stat.icon, width: 18.rw, height: 18.rw),
        ),
        SizedBox(width: 3.rw),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stat.value,
              style: AppTextStyles.statNumber.copyWith(color: AppColors.ink),
            ),
            Text(
              stat.label,
              style: AppTextStyles.statLabel
                  .copyWith(color: AppColors.inkSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
