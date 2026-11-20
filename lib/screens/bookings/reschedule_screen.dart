import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/booking/booking_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/booking/booking_widgets.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/more/more_header.dart';
import 'reschedule_vm.dart';

class RescheduleScreen extends StatelessWidget {
  const RescheduleScreen({super.key, required this.args});

  final RescheduleArgsModel args;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toString();

    return ViewModelBuilder<RescheduleVm>.reactive(
      viewModelBuilder: () => RescheduleVm(args.booking),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) {
        final secondary = AppTextStyles.profileBody.copyWith(
          color: AppColors.inkSecondary,
        );

        return Scaffold(
          backgroundColor: AppColors.listBackground,
          body: Column(
            children: [
              MoreHeader(
                title: LocaleKeys.bookings_reschedule_title.tr(),
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    16.rw,
                    8.rh,
                    16.rw,
                    16.rh,
                  ),
                  children: [
                    BookingSection(
                      title: vm.booking.bookingNumber,
                      child: SizedBox(
                        height: 85.rh,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 16.rw,
                          ),
                          itemCount: vm.dates.length,
                          separatorBuilder: (_, __) => SizedBox(width: 12.rw),
                          itemBuilder: (context, index) {
                            final date = vm.dates[index];
                            return BookingDayChip(
                              date: date,
                              locale: locale,
                              selected:
                                  vm.date?.day == date.day &&
                                  vm.date?.month == date.month,
                              onTap: () => vm.selectDate(date),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 4.rh),
                    BookingSection(
                      title: LocaleKeys.booking_choose_time.tr(),
                      child: Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 16.rw,
                        ),
                        child: vm.loadingSlots
                            ? Center(
                                child: SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.r,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : vm.doctorOff
                            ? Text(
                                LocaleKeys.booking_doctor_off.tr(),
                                style: secondary,
                              )
                            : vm.slots.isEmpty
                            ? Text(
                                LocaleKeys.booking_no_slots.tr(),
                                style: secondary,
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final chipWidth =
                                      (constraints.maxWidth - 20.rw) / 3;
                                  return Wrap(
                                    spacing: 10.rw,
                                    runSpacing: 10.rh,
                                    children: [
                                      for (final slot in vm.slots)
                                        SizedBox(
                                          width: chipWidth,
                                          child: BookingTimeChip(
                                            label: _clock(
                                              slot.startTime,
                                              locale,
                                            ),
                                            selected:
                                                vm.slot?.slot == slot.slot,
                                            enabled: slot.isBookable,
                                            onTap: () => vm.selectSlot(slot),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              BottomActionBar(
                label: LocaleKeys.bookings_confirm_new_time.tr(),
                isLoading: vm.isBusy,
                onPressed: vm.canConfirm ? vm.confirm : null,
                leading: vm.errorMessage == null
                    ? null
                    : AppErrorBanner(message: vm.errorMessage!),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// "14:30" -> "2:30 PM", the same labels the booking page uses
String _clock(String time, String locale) {
  final parts = time.split(':');
  final hour = parts.isEmpty ? null : int.tryParse(parts[0]);
  final minute = parts.length < 2 ? null : int.tryParse(parts[1]);
  if (hour == null || minute == null) return time;
  return DateFormat.jm(locale).format(DateTime(2000, 1, 1, hour, minute));
}
