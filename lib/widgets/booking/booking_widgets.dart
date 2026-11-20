import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// white section card of the booking frames: 16 radius, heading (17 / 24 bold)
/// inset 18, then the body edge to edge
class BookingSection extends StatelessWidget {
  const BookingSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(0, 12.rh, 0, 16.rh),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 18.rw, end: 18.rw),
            child: Text(
              title,
              style: AppTextStyles.listCardTitle.copyWith(
                color: AppColors.ink,
                height: 24 / 17,
              ),
            ),
          ),
          SizedBox(height: 8.rh),
          child,
        ],
      ),
    );
  }
}

/// a selectable card (branch or treatment): 116 tall, radius 14, a 36 icon tile
/// 12 / 14 from the corner and the name (16 / 18 semibold) with an optional
/// address line (14 / 18) 14 below it. selected cards are tinted red, the
/// others carry a 4% hairline.
/// the 54 x 85 day tile: weekday (12.5 / 20) over the date (16 semibold). the
/// selected day is a solid red tile with the date in a white 32 circle.
class BookingDayChip extends StatelessWidget {
  const BookingDayChip({
    super.key,
    required this.date,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final String locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 54.rw,
          height: 85.rh,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: selected ? null : Border.all(color: bookingHairline),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.rh),
              Text(
                DateFormat.E(locale).format(date),
                style: AppTextStyles.dayLabel.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.white : const Color(0x66000000),
                ),
              ),
              SizedBox(height: 10.rh),
              Container(
                width: 32.rw,
                height: 32.rw,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.white : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${date.day}',
                  style: AppTextStyles.dayNumber.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? AppColors.primary : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ink at 8%, the hairline of unselected tiles and chips
const Color bookingHairline = Color(0x14211722);

/// a time slot: 40 tall pill, white with a hairline; the chosen one is solid
/// red with a soft red ring, an unavailable one is struck through and faded.
class BookingTimeChip extends StatelessWidget {
  const BookingTimeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textColor = !enabled
        ? const Color(0x52797777)
        : selected
        ? AppColors.white
        : AppColors.ink;

    return Semantics(
      selected: selected,
      enabled: enabled,
      button: true,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 40.rh,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : enabled
                ? AppColors.white
                : const Color(0x05211722),
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : enabled
                  ? bookingHairline
                  : AppColors.cardBorder,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      spreadRadius: 3.r,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.profileBody.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: textColor,
              decoration: enabled ? null : TextDecoration.lineThrough,
              decorationColor: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
