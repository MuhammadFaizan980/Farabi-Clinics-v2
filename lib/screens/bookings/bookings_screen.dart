import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_border_radius.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/booking/booking_models.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_state_views.dart';
import 'bookings_vm.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return ViewModelBuilder<BookingsVm>.reactive(
      viewModelBuilder: BookingsVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.bookings_title.tr(),
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: !vm.isLoggedIn
              ? Center(
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 32.rw),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.bookings_sign_in_required.tr(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: colors.textPrimary),
                        ),
                        SizedBox(height: 16.rh),
                        AppButton(
                          label: LocaleKeys.auth_sign_in.tr(),
                          onPressed: () =>
                              AppNavigator.push(AppRoutes.login),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    _Filters(vm: vm),
                    Expanded(
                      child: vm.isBusy
                          ? const AppShimmerList()
                          : vm.hasFailure
                              ? AppErrorView(
                                  message: LocaleKeys.errors_unexpected.tr(),
                                  retryLabel: LocaleKeys.common_retry.tr(),
                                  onRetry: vm.load,
                                )
                              : vm.isEmpty
                                  ? AppEmptyView(
                                      title: LocaleKeys.bookings_none.tr(),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: vm.refresh,
                                      child: ListView.separated(
                                        padding:
                                            EdgeInsetsDirectional.symmetric(
                                          horizontal: 20.rw,
                                          vertical: 12.rh,
                                        ),
                                        itemCount: vm.bookings.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: 12.rh),
                                        itemBuilder: (context, index) =>
                                            _BookingCard(
                                          booking: vm.bookings[index],
                                          vm: vm,
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

class _Filters extends StatelessWidget {
  const _Filters({required this.vm});

  final BookingsVm vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 20.rw,
        vertical: 8.rh,
      ),
      child: Row(
        children: [
          _FilterChip(
            label: LocaleKeys.bookings_all.tr(),
            selected: vm.statusFilter == null,
            onTap: () => vm.setFilter(null),
          ),
          SizedBox(width: 8.rw),
          _FilterChip(
            label: LocaleKeys.bookings_upcoming.tr(),
            selected: vm.statusFilter == vm.createdStatus,
            onTap: () => vm.setFilter(vm.createdStatus),
          ),
          SizedBox(width: 8.rw),
          _FilterChip(
            label: LocaleKeys.bookings_cancelled.tr(),
            selected: vm.statusFilter == vm.cancelledStatus,
            onTap: () => vm.setFilter(vm.cancelledStatus),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.pill,
      child: Container(
        height: 44.rh,
        alignment: Alignment.center,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
        decoration: BoxDecoration(
          color: selected ? colors.primarySoft : colors.surface,
          borderRadius: AppBorderRadius.pill,
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: 1.r,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.vm});

  final BookingDataModel booking;
  final BookingsVm vm;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final start = booking.startLocal;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.bookingNumber,
                  style: AppTextStyles.bodySemiBold
                      .copyWith(color: colors.textPrimary),
                ),
              ),
              Text(
                // the api already localises this label
                booking.statusLabel,
                style: AppTextStyles.caption.copyWith(color: colors.primary),
              ),
            ],
          ),
          SizedBox(height: 6.rh),
          if (booking.doctorName != null)
            Text(
              booking.doctorName!,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: colors.textPrimary),
            ),
          if (booking.branchName != null)
            Text(
              booking.branchName!,
              style: AppTextStyles.caption
                  .copyWith(color: colors.textSecondary),
            ),
          if (start != null) ...[
            SizedBox(height: 4.rh),
            Text(
              // stored utc, shown local
              '${start.day}/${start.month}/${start.year}  '
              '${start.hour.toString().padLeft(2, '0')}:'
              '${start.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.caption
                  .copyWith(color: colors.textSecondary),
            ),
          ],
          if (booking.canCancel || booking.canReschedule) ...[
            SizedBox(height: 10.rh),
            Row(
              children: [
                // driven by the server flags, never by comparing statuses
                if (booking.canReschedule)
                  TextButton(
                    onPressed: () => vm.openReschedule(booking),
                    child: Text(LocaleKeys.bookings_reschedule.tr()),
                  ),
                if (booking.canCancel)
                  TextButton(
                    onPressed: vm.cancelling
                        ? null
                        : () => _confirmCancel(context, vm, booking),
                    child: Text(
                      LocaleKeys.bookings_cancel.tr(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: colors.error),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    BookingsVm vm,
    BookingDataModel booking,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.bookings_cancel_confirm_title.tr()),
        content: Text(LocaleKeys.bookings_cancel_confirm_body.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(LocaleKeys.bookings_keep.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(LocaleKeys.bookings_yes_cancel.tr()),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await vm.cancel(booking);
  }
}
