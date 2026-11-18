import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/booking/booking_models.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/common/app_button.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.args});

  final BookingSuccessArgsModel args;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final booking = args.booking;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 24.rw),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 56.r, color: colors.success),
              SizedBox(height: 16.rh),
              Text(
                LocaleKeys.booking_success_title.tr(),
                style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
              ),
              SizedBox(height: 6.rh),
              Text(
                LocaleKeys.booking_success_body.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: 20.rh),
              Text(
                LocaleKeys.booking_reference.tr(),
                style: AppTextStyles.caption
                    .copyWith(color: colors.textSecondary),
              ),
              // booking_number, not the numeric id — this is what a patient
              // can quote at the branch
              Text(
                booking.bookingNumber,
                style: AppTextStyles.h3.copyWith(color: colors.primary),
              ),
              SizedBox(height: 32.rh),
              AppButton(
                label: LocaleKeys.booking_view_bookings.tr(),
                onPressed: () => AppNavigator.resetTo(AppRoutes.bookings),
              ),
              SizedBox(height: 10.rh),
              AppButton(
                label: LocaleKeys.common_back.tr(),
                isOutlined: true,
                onPressed: () => AppNavigator.resetTo(AppRoutes.shell),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
