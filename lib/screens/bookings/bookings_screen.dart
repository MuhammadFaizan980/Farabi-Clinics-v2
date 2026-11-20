import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/booking/booking_models.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/common/money_text.dart';
import '../../widgets/sheet/app_sheet.dart';
import 'bookings_vm.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BookingsVm>.reactive(
      viewModelBuilder: BookingsVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Column(
          children: [
            _BookingsHeader(
              title: LocaleKeys.bookings_title.tr(),
              loggedIn: vm.isLoggedIn,
              tab: vm.tab,
              onTab: vm.setTab,
              onBack: AppNavigator.canPop ? () => AppNavigator.pop() : null,
            ),
            Expanded(
              child: !vm.isLoggedIn
                  ? Center(
                      child: Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 32.rw,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LocaleKeys.bookings_sign_in_required.tr(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.rowTitle.copyWith(
                                color: AppColors.ink,
                              ),
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
                        if (vm.actionError != null)
                          Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 24.rw,
                              vertical: 4.rh,
                            ),
                            child: AppErrorBanner(
                              message: vm.actionError!.startsWith('bookings.')
                                  ? vm.actionError!.tr()
                                  : vm.actionError!,
                            ),
                          ),
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
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      24.rw,
                                      8.rh,
                                      24.rw,
                                      16.rh,
                                    ),
                                    itemCount: vm.bookings.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 8.rh),
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
          ],
        ),
      ),
    );
  }
}

/// red header of the appointments frame: 139 tall including the status bar,
/// the title 20 below it and three tabs (15 / 24, selected semibold) over a
/// 92 x 2 yellow underline.
class _BookingsHeader extends StatelessWidget {
  const _BookingsHeader({
    required this.title,
    required this.loggedIn,
    required this.tab,
    required this.onTab,
    this.onBack,
  });

  final String title;
  final bool loggedIn;
  final BookingTab tab;
  final ValueChanged<BookingTab> onTab;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final labels = {
      BookingTab.upcoming: LocaleKeys.bookings_upcoming.tr(),
      BookingTab.completed: LocaleKeys.bookings_completed.tr(),
      BookingTab.cancelled: LocaleKeys.bookings_cancelled.tr(),
    };

    return Container(
      height: top + 95.rh,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(16.r),
          bottomEnd: Radius.circular(16.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: top + 20.rh,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle.copyWith(color: AppColors.white),
            ),
          ),
          if (onBack != null)
            PositionedDirectional(
              start: 8.rw,
              top: top + 14.rh,
              child: IconButton(
                onPressed: onBack,
                icon: const BackButtonIcon(),
                color: AppColors.white,
                iconSize: 22.rw,
              ),
            ),
          if (loggedIn)
            Positioned(
              left: 0,
              right: 0,
              top: top + 65.rh,
              child: Row(
                children: [
                  for (final entry in labels.entries)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTab(entry.key),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: [
                            Text(
                              entry.value,
                              style: AppTextStyles.branchTab(
                                active: tab == entry.key,
                              ).copyWith(color: AppColors.white),
                            ),
                            SizedBox(height: 4.rh),
                            Container(
                              width: 92.rw,
                              height: 2.rh,
                              color: tab == entry.key
                                  ? AppColors.tabUnderline
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
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
    final locale = context.locale.toString();
    final start = booking.startClinicTime;
    final dateLabel = start == null
        ? ''
        : DateFormat.yMMMEd(locale).format(start);
    final timeLabel = start == null ? '' : DateFormat.jm(locale).format(start);
    final service = booking.services.isEmpty
        ? null
        : booking.services.first.name;
    final subStyle = AppTextStyles.branchAddress.copyWith(
      color: AppColors.inkSecondary,
      fontWeight: FontWeight.w500,
      height: 18 / 14,
    );

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
          if (booking.canReschedule)
            GestureDetector(
              onTap: () => vm.openReschedule(booking),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 32.rw,
                height: 32.rw,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0x05211722),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppAssets.iconEditPencil,
                  width: 16.rw,
                  height: 16.rw,
                ),
              ),
            ),
        ],
      );
    }

    return Container(
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
                    SizedBox(height: 2.rh),
                    Text(
                      service ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.overviewBody.copyWith(
                        color: AppColors.inkSecondary,
                        height: 18 / 14.5,
                        fontSize: 15.rf,
                      ),
                    ),
                    SizedBox(height: 6.rh),
                    if ((booking.totalFormatted ?? '').isNotEmpty)
                      Container(
                        height: 27.rh,
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 12.rw,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MoneyText(
                              booking.totalFormatted!,
                              iconSize: 11,
                              style: AppTextStyles.listCardTitle.copyWith(
                                color: AppColors.primary,
                                fontSize: 14.rf,
                                height: 18 / 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 23.rh,
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 10.rw),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      booking.bookingNumber,
                      style: AppTextStyles.rating.copyWith(
                        color: AppColors.chipInk,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.rf,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.rh),
                  Text(
                    // the api already localises this label
                    booking.statusLabel,
                    style: AppTextStyles.fieldError.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.rh),
          const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
          SizedBox(height: 12.rh),
          row(
            asset: AppAssets.iconBranchTile,
            title: LocaleKeys.checkout_branch.tr(),
            value: Text(
              booking.branchName ?? '',
              style: subStyle.copyWith(fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(height: 8.rh),
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
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 8.rw),
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
          // driven by the server flags, never by comparing statuses
          if (booking.canCancel || booking.canReschedule) ...[
            SizedBox(height: 14.rh),
            Row(
              children: [
                if (booking.canReschedule)
                  Expanded(
                    child: _CardButton(
                      label: LocaleKeys.bookings_reschedule.tr(),
                      filled: true,
                      onTap: () => vm.openReschedule(booking),
                    ),
                  ),
                if (booking.canReschedule && booking.canCancel)
                  SizedBox(width: 8.rw),
                if (booking.canCancel)
                  Expanded(
                    child: _CardButton(
                      label: LocaleKeys.bookings_cancel.tr(),
                      filled: false,
                      onTap: vm.cancelling
                          ? null
                          : () => _confirmCancel(context, vm, booking),
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
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.event_busy_outlined,
      title: LocaleKeys.bookings_cancel_confirm_title.tr(),
      message: LocaleKeys.bookings_cancel_confirm_body.tr(),
      confirmLabel: LocaleKeys.bookings_yes_cancel.tr(),
      cancelLabel: LocaleKeys.bookings_keep.tr(),
    );
    if (confirmed) await vm.cancel(booking);
  }
}

/// the two half-width buttons under a booking: Reschedule (solid red) and
/// Cancel (plain), 40 tall, radius 10
class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : AppColors.white,
      borderRadius: BorderRadius.circular(10.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40.rh,
          alignment: Alignment.center,
          decoration: filled
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.cardBorder),
                ),
          child: Text(
            label,
            style: AppTextStyles.rowTitle.copyWith(
              color: filled ? AppColors.white : AppColors.inkSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
