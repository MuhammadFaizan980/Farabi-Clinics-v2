import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_border_radius.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/booking/booking_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import 'reschedule_vm.dart';

class RescheduleScreen extends StatelessWidget {
  const RescheduleScreen({super.key, required this.args});

  final RescheduleArgsModel args;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return ViewModelBuilder<RescheduleVm>.reactive(
      viewModelBuilder: () => RescheduleVm(args.booking),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.bookings_reschedule_title.tr(),
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 20.rw,
              vertical: 12.rh,
            ),
            children: [
              Text(
                vm.booking.bookingNumber,
                style: AppTextStyles.bodySemiBold
                    .copyWith(color: colors.textPrimary),
              ),
              SizedBox(height: 18.rh),
              SizedBox(
                height: 64.rh,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.dates.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.rw),
                  itemBuilder: (context, index) {
                    final date = vm.dates[index];
                    final selected = vm.date?.day == date.day &&
                        vm.date?.month == date.month;
                    return _Pill(
                      label: '${date.day}/${date.month}',
                      selected: selected,
                      onTap: () => vm.selectDate(date),
                    );
                  },
                ),
              ),
              SizedBox(height: 18.rh),
              if (vm.loadingSlots)
                Center(
                  child: SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(strokeWidth: 2.r),
                  ),
                )
              else if (vm.doctorOff)
                Text(
                  LocaleKeys.booking_doctor_off.tr(),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: colors.textSecondary),
                )
              else if (vm.slots.isEmpty)
                Text(
                  LocaleKeys.booking_no_slots.tr(),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: colors.textSecondary),
                )
              else
                Wrap(
                  spacing: 8.rw,
                  runSpacing: 8.rh,
                  children: vm.slots
                      .map(
                        (slot) => _Pill(
                          label: slot.startTime,
                          selected: vm.slot?.slot == slot.slot,
                          enabled: slot.isBookable,
                          onTap: () => vm.selectSlot(slot),
                        ),
                      )
                      .toList(growable: false),
                ),
              SizedBox(height: 24.rh),
              if (vm.errorMessage != null) ...[
                AppErrorBanner(message: vm.errorMessage!),
                SizedBox(height: 12.rh),
              ],
              AppButton(
                label: LocaleKeys.bookings_confirm_new_time.tr(),
                isLoading: vm.isBusy,
                onPressed: vm.canConfirm ? vm.confirm : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
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
    final colors = AppThemeColors.of(context);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: AppBorderRadius.sm,
      child: Container(
        constraints: BoxConstraints(minHeight: 44.rh, minWidth: 64.rw),
        alignment: Alignment.center,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 14.rw),
        decoration: BoxDecoration(
          color: selected ? colors.primarySoft : colors.surface,
          borderRadius: AppBorderRadius.sm,
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 1.5.r : 1.r,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: enabled ? colors.textPrimary : colors.textMuted,
          ),
        ),
      ),
    );
  }
}
