import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/booking/booking_models.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/money_text.dart';
import '../../widgets/common/swipe_to_pay.dart';
import '../../widgets/discovery/doctor_card.dart' show DoctorRatingPill;
import '../../widgets/more/more_header.dart';
import 'checkout_vm.dart';

/// the site's "Review & Pay" page: what is being booked (with edit links back
/// to the booking page), promo code, STC Qitaf points, the price breakdown,
/// the payment methods from the api and a swipe-to-pay control.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, required this.args});

  final CheckoutArgsModel args;

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<CheckoutVm>.reactive(
      viewModelBuilder: () => CheckoutVm(args),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) {
        final checkout = vm.checkout;
        return Scaffold(
          backgroundColor: AppColors.listBackground,
          body: Column(
            children: [
              MoreHeader(
                title: LocaleKeys.checkout_title.tr(),
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: vm.isBusy
                    ? const AppShimmerList(itemCount: 4)
                    : vm.hasFailure || checkout == null
                    ? AppErrorView(
                        message: LocaleKeys.errors_unexpected.tr(),
                        retryLabel: LocaleKeys.common_retry.tr(),
                        onRetry: vm.onInit,
                      )
                    : _Content(
                        vm: vm,
                        checkout: checkout,
                        language: language,
                        locale: context.locale.toString(),
                      ),
              ),
              if (checkout != null) _PayBar(vm: vm, checkout: checkout),
            ],
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.vm,
    required this.checkout,
    required this.language,
    required this.locale,
  });

  final CheckoutVm vm;
  final CheckoutContextDataModel checkout;
  final String language;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(checkout.appointment.date);
    final time = checkout.appointment.startTime.split(':');
    final dateLabel = date == null
        ? checkout.appointment.date
        : DateFormat.yMMMEd(locale).format(date);
    final timeLabel = time.length < 2
        ? checkout.appointment.startTime
        : DateFormat.jm(locale).format(
            DateTime(
              2000,
              1,
              1,
              int.tryParse(time[0]) ?? 0,
              int.tryParse(time[1]) ?? 0,
            ),
          );

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 8.rh, 16.rw, 16.rh),
      children: [
        _SummaryCard(
          doctor: vm.args.doctor,
          name: checkout.doctorName ?? vm.args.doctor.names.display(language),
          service: checkout.serviceName ?? '',
          total: checkout.totalFormatted ?? '',
        ),
        SizedBox(height: 4.rh),
        InfoCard(
          padding: EdgeInsetsDirectional.all(12.r),
          child: Column(
            children: [
              _EditRow(
                title: LocaleKeys.checkout_branch.tr(),
                tileIcon: AppAssets.iconBranchTile,
                value: Text(
                  checkout.branchName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.branchAddress.copyWith(
                    color: AppColors.inkSecondary,
                    fontWeight: FontWeight.w400,
                    height: 18 / 14,
                  ),
                ),
                onEdit: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(height: 8.rh),
              _EditRow(
                title: LocaleKeys.checkout_datetime.tr(),
                tileIcon: AppAssets.iconClockTile,
                gap: 5,
                value: _DateTimeLine(date: dateLabel, time: timeLabel),
                onEdit: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.rh),
        _Promo(vm: vm),
        if (vm.qitafEnabled) ...[SizedBox(height: 4.rh), _Qitaf(vm: vm)],
        SizedBox(height: 4.rh),
        InfoCard(
          title: LocaleKeys.checkout_details.tr(),
          padding: EdgeInsetsDirectional.fromSTEB(18.rw, 12.rh, 18.rw, 16.rh),
          child: Column(
            children: [
              SizedBox(height: 8.rh),
              for (final line in checkout.lines)
                _Line(label: line.title, value: line.formatted),
              if (vm.redemption != null)
                _Line(
                  label: LocaleKeys.checkout_qitaf_applied.tr(),
                  value: '- ${vm.redemption!.amount?.toStringAsFixed(2)}',
                ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 6.rw,
                  end: 5.rw,
                  top: 6.rh,
                  bottom: 16.rh,
                ),
                child: const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.cardBorder,
                ),
              ),
              _Line(
                label: LocaleKeys.checkout_total.tr(),
                value: checkout.totalFormatted ?? '',
                bold: true,
              ),
              if (vm.redemption != null)
                _Line(
                  label: LocaleKeys.checkout_payable.tr(),
                  value:
                      '${vm.payable.toStringAsFixed(2)} ${checkout.currencySymbol ?? ''}',
                  bold: true,
                ),
            ],
          ),
        ),
        if (vm.gateways.isNotEmpty) ...[
          SizedBox(height: 4.rh),
          InfoCard(
            title: LocaleKeys.checkout_methods.tr(),
            titleInset: 6,
            padding: EdgeInsetsDirectional.fromSTEB(12.rw, 12.rh, 12.rw, 8.rh),
            child: Column(
              children: [
                for (final gateway in vm.gateways)
                  _Method(
                    gateway: gateway,
                    selected: vm.gatewaySlug == gateway.slug,
                    onTap: () => vm.selectGateway(gateway.slug),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// the white summary card: 56 avatar, name (16 / 20 bold), service (14.5 / 18)
/// and the price pill, with the rating chip at the top right.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.doctor,
    required this.name,
    required this.service,
    required this.total,
  });

  final DoctorDataModel doctor;
  final String name;
  final String service;
  final String total;

  @override
  Widget build(BuildContext context) {
    final image = doctor.image;
    final placeholder = Icon(
      Icons.person_outline,
      size: 28.rw,
      color: AppColors.primary.withValues(alpha: 0.5),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 18.rh, 16.rw, 13.rh),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.rw,
                height: 56.rw,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x3DCC1C1C),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: (image == null || image.isEmpty)
                    ? placeholder
                    : CachedNetworkImage(
                        imageUrl: image,
                        width: 56.rw,
                        height: 56.rw,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorWidget: (_, __, ___) => placeholder,
                      ),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: 56.rw),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.listCardTitle.copyWith(
                          color: AppColors.ink,
                          fontSize: 16.rf,
                          height: 20 / 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.rh),
                    Text(
                      service,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.overviewBody.copyWith(
                        color: AppColors.inkSecondary,
                        height: 18 / 14.5,
                      ),
                    ),
                    SizedBox(height: 7.rh),
                    Transform.translate(
                      offset: Offset(-4.rw, 0),
                      child: Container(
                        height: 27.rh,
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 12.rw,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MoneyText(
                              total,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (doctor.ratingCount > 0)
            PositionedDirectional(
              top: -10.rh,
              end: -8.rw,
              child: DoctorRatingPill(rating: doctor.ratingAverage),
            ),
        ],
      ),
    );
  }
}

/// one row of the branch / date card: a 32 tile with the icon, the title
/// (15 / 18 semibold), a value line, and the 36 edit button.
class _EditRow extends StatelessWidget {
  const _EditRow({
    required this.title,
    required this.value,
    required this.onEdit,
    required this.tileIcon,
    this.gap = 2,
  });

  final String title;
  final Widget value;
  final VoidCallback onEdit;
  final String tileIcon;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14.rw, 13.rh, 8.rw, 15.rh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(top: 3.rh),
            child: Container(
              width: 32.rw,
              height: 32.rw,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x0FCC1C1C),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: SvgPicture.asset(tileIcon, width: 16.rw, height: 16.rw),
            ),
          ),
          SizedBox(width: 10.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowTitle.copyWith(
                    color: AppColors.ink,
                    height: 18 / 15,
                  ),
                ),
                SizedBox(height: gap.rh),
                value,
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0, -5.rh),
            child: GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36.rw,
                height: 36.rw,
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
          ),
        ],
      ),
    );
  }
}

/// "Tuesday 1, 2025 | 02:00 PM" with the small calendar and clock icons
class _DateTimeLine extends StatelessWidget {
  const _DateTimeLine({required this.date, required this.time});

  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.branchAddress.copyWith(
      color: AppColors.inkSecondary,
      fontWeight: FontWeight.w500,
      height: 18 / 14,
    );
    Widget icon(String asset) =>
        SvgPicture.asset(asset, width: 16.rw, height: 16.rw);

    return Row(
      children: [
        icon(AppAssets.iconCalendarSmall),
        SizedBox(width: 4.rw),
        Flexible(
          child: Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        Container(
          width: 1,
          height: 16.rh,
          margin: EdgeInsetsDirectional.symmetric(horizontal: 8.rw),
          color: const Color(0x52282828),
        ),
        icon(AppAssets.iconClockSmall),
        SizedBox(width: 4.rw),
        Text(time, style: style),
      ],
    );
  }
}

/// promo code card body: a 44 field (radius 10, 4% hairline) and a 91 red
/// Apply button, 8 apart
class _Promo extends StatelessWidget {
  const _Promo({required this.vm});

  final CheckoutVm vm;

  @override
  Widget build(BuildContext context) {
    final applied = vm.appliedCoupon != null;
    final error = vm.couponError == null
        ? null
        : (vm.couponError!.startsWith('errors.')
              ? vm.couponError!.tr()
              : vm.couponError);

    return InfoCard(
      title: LocaleKeys.checkout_promo.tr(),
      padding: EdgeInsetsDirectional.fromSTEB(14.rw, 12.rh, 12.rw, 16.rh),
      titleInset: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.rh),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.rh,
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 14.rw),
                  alignment: AlignmentDirectional.centerStart,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: TextField(
                    controller: vm.couponController,
                    enabled: !applied,
                    textCapitalization: TextCapitalization.characters,
                    style: AppTextStyles.rowTitle.copyWith(
                      color: AppColors.ink,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: LocaleKeys.checkout_promo_hint.tr(),
                      hintStyle: AppTextStyles.rowTitle.copyWith(
                        color: AppColors.inkSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.rw),
              SizedBox(
                width: 91.rw,
                height: 44.rh,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: vm.applyingCoupon
                        ? null
                        : (applied ? vm.removeCoupon : vm.applyCoupon),
                    child: Center(
                      child: vm.applyingCoupon
                          ? SizedBox(
                              width: 18.rw,
                              height: 18.rw,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              applied
                                  ? LocaleKeys.checkout_remove.tr()
                                  : LocaleKeys.checkout_apply.tr(),
                              style: AppTextStyles.rowTitle.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            SizedBox(height: 6.rh),
            Text(
              error,
              style: AppTextStyles.fieldError.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _Qitaf extends StatelessWidget {
  const _Qitaf({required this.vm});

  final CheckoutVm vm;

  @override
  Widget build(BuildContext context) {
    final redemption = vm.redemption;
    return InfoCard(
      title: LocaleKeys.checkout_qitaf.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.checkout_qitaf_body.tr(),
            style: AppTextStyles.cardSubtitle.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          SizedBox(height: 12.rh),
          if (redemption != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${LocaleKeys.checkout_qitaf_applied.tr()}: '
                    '${redemption.amount?.toStringAsFixed(0)}',
                    style: AppTextStyles.rowTitle.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: vm.qitafBusy ? null : vm.removeQitaf,
                  child: Text(LocaleKeys.checkout_remove.tr()),
                ),
              ],
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: vm.qitafMobileController,
                    label: '',
                    keyboardType: TextInputType.phone,
                    digitsOnly: true,
                    maxLength: 10,
                    onChanged: (_) {},
                  ),
                ),
                SizedBox(width: 10.rw),
                Padding(
                  padding: EdgeInsetsDirectional.only(top: 28.rh),
                  child: SizedBox(
                    width: 116.rw,
                    child: AppButton(
                      label: LocaleKeys.checkout_send_code.tr(),
                      isLoading: vm.qitafBusy && !vm.qitafCodeSent,
                      onPressed: vm.sendQitafCode,
                    ),
                  ),
                ),
              ],
            ),
            if (vm.qitafCodeSent) ...[
              SizedBox(height: 12.rh),
              AppTextField(
                controller: vm.qitafOtpController,
                label: LocaleKeys.checkout_qitaf_otp.tr(),
                keyboardType: TextInputType.number,
                digitsOnly: true,
                maxLength: 6,
                onChanged: (_) {},
              ),
              SizedBox(height: 12.rh),
              AppTextField(
                controller: vm.qitafAmountController,
                label: LocaleKeys.checkout_qitaf_amount.tr(),
                keyboardType: TextInputType.number,
                digitsOnly: true,
                onChanged: (_) {},
              ),
              SizedBox(height: 12.rh),
              AppButton(
                label: LocaleKeys.checkout_qitaf_redeem.tr(),
                isLoading: vm.qitafBusy,
                onPressed: vm.redeemQitaf,
              ),
            ],
          ],
          if (vm.qitafError != null) ...[
            SizedBox(height: 8.rh),
            Text(
              vm.qitafError!.startsWith('checkout.') ||
                      vm.qitafError!.startsWith('errors.')
                  ? vm.qitafError!.tr()
                  : vm.qitafError!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

/// a price line: label (15, 500, grey) and the amount (16 / 22 semibold); the
/// bold one is the total (18 semibold)
class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final labelStyle = bold
        ? AppTextStyles.sectionTitle.copyWith(
            color: const Color(0xFF222222),
            fontSize: 18.rf,
            height: 23 / 18,
          )
        : AppTextStyles.profileBody.copyWith(
            color: AppColors.inkSecondary,
            height: 19 / 15,
          );
    final valueStyle = AppTextStyles.sectionTitle.copyWith(
      color: AppColors.ink,
      fontSize: bold ? 18.rf : 16.rf,
      height: bold ? 23 / 18 : 22 / 16,
    );

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: bold ? 0 : 10.rh),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          MoneyText(value, style: valueStyle, iconSize: bold ? 15 : 13),
        ],
      ),
    );
  }
}

/// a payment method row: 56 tall, radius 14. the chosen one is tinted red with
/// a ringed radio; the others carry a 4% hairline.
class _Method extends StatelessWidget {
  const _Method({
    required this.gateway,
    required this.selected,
    required this.onTap,
  });

  final PaymentGatewayDataModel gateway;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final logo = gateway.logo;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56.rh,
        margin: EdgeInsetsDirectional.only(bottom: 8.rh),
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
        decoration: BoxDecoration(
          color: selected ? const Color(0x05CC1C1C) : AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.04)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.rw,
              height: 20.rw,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0x1F211722),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: selected
                  ? Container(
                      width: 6.rw,
                      height: 6.rw,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 8.rw),
            Expanded(
              child: Text(
                gateway.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.rowTitle.copyWith(
                  color: AppColors.ink,
                  height: 18 / 15,
                ),
              ),
            ),
            // the logo is the gateway's own image from the api
            if (logo != null && logo.isNotEmpty)
              CachedNetworkImage(
                imageUrl: logo,
                height: 22.rh,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

class _PayBar extends StatelessWidget {
  const _PayBar({required this.vm, required this.checkout});

  final CheckoutVm vm;
  final CheckoutContextDataModel checkout;

  /// the api's own formatted total ("45.00 SAR"); once Qitaf points cover part
  /// of the bill, what is left in the same currency
  String _amountLabel() {
    final formatted = checkout.totalFormatted ?? '';
    if (vm.redemption == null) return formatted;
    final currency = formatted.contains(' ') ? formatted.split(' ').last : '';
    return '${vm.payable.toStringAsFixed(2)} $currency'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final error = vm.payError;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        20.rw,
        12.rh,
        20.rw,
        12.rh + bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.vertical(
          top: Radius.circular(16.r),
        ),
        border: const Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null) ...[
            AppErrorBanner(
              message:
                  error.startsWith('booking.') ||
                      error.startsWith('errors.') ||
                      error.startsWith('checkout.')
                  ? error.tr()
                  : error,
            ),
            SizedBox(height: 10.rh),
          ],
          if (vm.pending != null) ...[
            Text(
              LocaleKeys.checkout_paid_pending.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
            SizedBox(height: 10.rh),
            AppButton(
              label: LocaleKeys.checkout_confirm_payment.tr(),
              isLoading: vm.paying,
              onPressed: vm.confirmPendingPayment,
            ),
          ] else
            SwipeToPay(
              label: LocaleKeys.checkout_swipe.tr(args: [_amountLabel()]),
              enabled: vm.canPay,
              busy: vm.paying,
              onSwiped: vm.pay,
            ),
        ],
      ),
    );
  }
}
