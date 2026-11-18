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
import 'booking_vm.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.args});

  final BookingArgsModel args;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<BookingVm>.reactive(
      viewModelBuilder: () => BookingVm(args.doctor),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.booking_title.tr(),
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
                vm.doctor.names.display(language),
                style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
              ),
              SizedBox(height: 18.rh),

              _Label(text: LocaleKeys.booking_choose_service.tr()),
              SizedBox(height: 8.rh),
              Wrap(
                spacing: 8.rw,
                runSpacing: 8.rh,
                children: vm.services
                    .map(
                      (service) => _Pill(
                        label: service.names.display(language),
                        selected: vm.serviceId == service.id,
                        onTap: () => vm.selectService(service.id),
                      ),
                    )
                    .toList(growable: false),
              ),
              SizedBox(height: 18.rh),

              _Label(text: LocaleKeys.booking_choose_branch.tr()),
              SizedBox(height: 8.rh),
              if (vm.noBranches)
                Text(
                  LocaleKeys.booking_no_branches_for_service.tr(),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: colors.textSecondary),
                )
              else
                Wrap(
                  spacing: 8.rw,
                  runSpacing: 8.rh,
                  children: vm.branches
                      .map(
                        (branch) => _Pill(
                          label: branch.names.display(language),
                          selected: vm.branchId == branch.id,
                          onTap: () => vm.selectBranch(branch.id),
                        ),
                      )
                      .toList(growable: false),
                ),
              SizedBox(height: 18.rh),

              _Label(text: LocaleKeys.booking_choose_date.tr()),
              SizedBox(height: 8.rh),
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

              _Label(text: LocaleKeys.booking_choose_time.tr()),
              SizedBox(height: 8.rh),
              if (vm.loadingSlots)
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(vertical: 12.rh),
                  child: Center(
                    child: SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(strokeWidth: 2.r),
                    ),
                  ),
                )
              else if (vm.doctorOff)
                // a distinct state from "no slots" — the website conflates them
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
              SizedBox(height: 20.rh),

              if (vm.checkout != null) ...[
                _Label(text: LocaleKeys.booking_review.tr()),
                SizedBox(height: 8.rh),
                _ReviewCard(vm: vm),
                SizedBox(height: 18.rh),
                if (vm.gateways.isNotEmpty) ...[
                  _Label(text: LocaleKeys.booking_payment_method.tr()),
                  SizedBox(height: 8.rh),
                  Wrap(
                    spacing: 8.rw,
                    runSpacing: 8.rh,
                    children: vm.gateways
                        .map(
                          (gateway) => _Pill(
                            // the label already carries its own localisation
                            label: gateway.label,
                            selected: vm.gatewaySlug == gateway.slug,
                            onTap: () => vm.selectGateway(gateway.slug),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  SizedBox(height: 18.rh),
                ],
              ],

              if (vm.slotTaken) ...[
                AppErrorBanner(message: vm.slotUnavailableKey.tr()),
                SizedBox(height: 12.rh),
              ] else if (vm.errorMessage != null) ...[
                AppErrorBanner(
                  message: vm.errorMessage!.startsWith('booking.') ||
                          vm.errorMessage!.startsWith('errors.')
                      ? vm.errorMessage!.tr()
                      : vm.errorMessage!,
                ),
                SizedBox(height: 12.rh),
              ],

              AppButton(
                label: LocaleKeys.booking_confirm.tr(),
                isLoading: vm.submitting || vm.loadingCheckout,
                onPressed: vm.canConfirm ? vm.confirm : null,
              ),
              SizedBox(height: 24.rh),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.bodySemiBold
            .copyWith(color: AppThemeColors.of(context).textPrimary),
      );
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
    return Semantics(
      selected: selected,
      enabled: enabled,
      button: true,
      child: InkWell(
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
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.vm});

  final BookingVm vm;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final checkout = vm.checkout!;
    return Container(
      padding: EdgeInsetsDirectional.all(14.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppBorderRadius.md,
        border: Border.all(color: colors.border, width: 1.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(
            label: LocaleKeys.booking_service.tr(),
            value: checkout.serviceName ?? '',
          ),
          _Row(
            label: LocaleKeys.booking_branch.tr(),
            value: checkout.branchName ?? '',
          ),
          _Row(
            label: LocaleKeys.booking_date.tr(),
            value: checkout.appointment.date,
          ),
          _Row(
            label: LocaleKeys.booking_time.tr(),
            value: checkout.appointment.startTime,
          ),
          Divider(height: 18.rh),
          ...checkout.lines.map(
            (line) => _Row(label: line.title, value: line.formatted),
          ),
          _Row(
            label: LocaleKeys.booking_total.tr(),
            value: checkout.totalFormatted ?? '',
            emphasise: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final style = emphasise
        ? AppTextStyles.bodySemiBold.copyWith(color: colors.primary)
        : AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary);
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 6.rh),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: colors.textSecondary),
            ),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }
}
