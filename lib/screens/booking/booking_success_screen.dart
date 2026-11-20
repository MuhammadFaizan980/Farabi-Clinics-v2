import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/booking/booking_models.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// the Figma "Success" frame: the check illustration, the confirmation copy and
/// a summary card (doctor, branch, date and time) ending in "See all details".
/// the booking reference sits in the chip at the card's top right.
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.args});

  final BookingSuccessArgsModel args;

  @override
  Widget build(BuildContext context) {
    final booking = args.booking;
    final locale = context.locale.toString();
    final start = booking.startClinicTime;
    final dateLabel = start == null
        ? ''
        : DateFormat.yMMMEd(locale).format(start);
    final timeLabel = start == null ? '' : DateFormat.jm(locale).format(start);
    final service = booking.services.isEmpty
        ? null
        : booking.services.first.name;

    return Scaffold(
      backgroundColor: AppColors.listBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.fromSTEB(24.rw, 12.rh, 24.rw, 24.rh),
          child: Column(
            children: [
              Image.asset(
                AppAssets.imageBookingSuccess,
                width: 365.rw,
                height: 225.rh,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 4.rh),
              Text(
                LocaleKeys.booking_success_title.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.successTitle.copyWith(
                  color: const Color(0xFF050505),
                ),
              ),
              SizedBox(height: 8.rh),
              Text(
                LocaleKeys.booking_success_body.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.successBody.copyWith(
                  color: const Color(0xFF525252),
                ),
              ),
              SizedBox(height: 28.rh),
              _SummaryCard(
                booking: booking,
                service: service,
                dateLabel: dateLabel,
                timeLabel: timeLabel,
              ),
              SizedBox(height: 16.rh),
              GestureDetector(
                onTap: () => AppNavigator.resetTo(AppRoutes.shell),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(vertical: 8.rh),
                  child: Text(
                    LocaleKeys.booking_back_home.tr(),
                    style: AppTextStyles.rowTitle.copyWith(
                      color: AppColors.inkSecondary,
                    ),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.booking,
    required this.service,
    required this.dateLabel,
    required this.timeLabel,
  });

  final BookingDataModel booking;
  final String? service;
  final String dateLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    Widget row({
      required String asset,
      required String title,
      required Widget value,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.rw,
            height: 32.rw,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x0FCC1C1C),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SvgPicture.asset(asset, width: 16.rw, height: 16.rw),
          ),
          SizedBox(width: 10.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.rowTitle.copyWith(
                    color: AppColors.ink,
                    height: 18 / 15,
                  ),
                ),
                SizedBox(height: 2.rh),
                value,
              ],
            ),
          ),
        ],
      );
    }

    final subStyle = AppTextStyles.branchAddress.copyWith(
      color: AppColors.inkSecondary,
      fontWeight: FontWeight.w500,
      height: 18 / 14,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 14.rh, 16.rw, 14.rh),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52.rw,
                height: 52.rw,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x3DCC1C1C),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 26.rw,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.doctorName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.listCardTitle.copyWith(
                        color: AppColors.ink,
                        fontSize: 16.rf,
                        height: 20 / 16,
                      ),
                    ),
                    SizedBox(height: 4.rh),
                    Text(
                      service ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.overviewBody.copyWith(
                        color: AppColors.inkSecondary,
                        height: 18 / 14.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 23.rh,
                padding: EdgeInsetsDirectional.symmetric(horizontal: 10.rw),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                // the booking number a patient can quote at the branch
                child: Text(
                  booking.bookingNumber,
                  style: AppTextStyles.rating.copyWith(
                    color: AppColors.chipInk,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.rf,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.rh),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 10.rw),
            child: Column(
              children: [
                row(
                  asset: AppAssets.iconBranchTile,
                  title: LocaleKeys.checkout_branch.tr(),
                  value: Text(
                    booking.branchName ?? '',
                    style: subStyle.copyWith(fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(height: 10.rh),
                row(
                  asset: AppAssets.iconClockTile,
                  title: LocaleKeys.checkout_datetime.tr(),
                  value: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.iconCalendarSmall,
                        width: 16.rw,
                        height: 16.rw,
                      ),
                      SizedBox(width: 4.rw),
                      Flexible(
                        child: Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: subStyle,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 16.rh,
                        margin: EdgeInsetsDirectional.symmetric(
                          horizontal: 8.rw,
                        ),
                        color: const Color(0x52282828),
                      ),
                      SvgPicture.asset(
                        AppAssets.iconClockSmall,
                        width: 16.rw,
                        height: 16.rw,
                      ),
                      SizedBox(width: 4.rw),
                      Text(timeLabel, style: subStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.rh),
          const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
          GestureDetector(
            onTap: () => AppNavigator.resetTo(AppRoutes.bookings),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 48.rh,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.booking_see_all_details.tr(),
                    style: AppTextStyles.screenTitle.copyWith(
                      fontSize: 16.rf,
                      height: 20 / 16,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4.rw),
                  Icon(Icons.north_east, size: 14.rw, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
