import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/booking/booking_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/swipe_to_pay.dart';
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
              if (checkout != null)
                _PayBar(vm: vm, checkout: checkout),
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
        : DateFormat.jm(locale).format(DateTime(
            2000, 1, 1, int.tryParse(time[0]) ?? 0, int.tryParse(time[1]) ?? 0));

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 16.rh, 16.rw, 24.rh),
      children: [
        InfoCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkout.doctorName ??
                          vm.args.doctor.names.display(language),
                      style: AppTextStyles.listCardTitle
                          .copyWith(color: AppColors.ink),
                    ),
                    Text(
                      checkout.serviceName ?? '',
                      style: AppTextStyles.cardSubtitle
                          .copyWith(color: AppColors.inkSecondary),
                    ),
                    SizedBox(height: 4.rh),
                    Text(
                      checkout.totalFormatted ?? '',
                      style: AppTextStyles.rowTitle
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.rh),
        InfoCard(
          child: Column(
            children: [
              _EditRow(
                title: LocaleKeys.checkout_branch.tr(),
                value: checkout.branchName ?? '',
                onEdit: () => Navigator.of(context).maybePop(),
              ),
              Divider(height: 24.rh, color: AppColors.hairline8),
              _EditRow(
                title: LocaleKeys.checkout_datetime.tr(),
                value: '$dateLabel | $timeLabel',
                onEdit: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.rh),
        _Promo(vm: vm),
        if (vm.qitafEnabled) ...[
          SizedBox(height: 12.rh),
          _Qitaf(vm: vm),
        ],
        SizedBox(height: 12.rh),
        InfoCard(
          title: LocaleKeys.checkout_details.tr(),
          child: Column(
            children: [
              for (final line in checkout.lines)
                _Line(label: line.title, value: line.formatted),
              if (vm.redemption != null)
                _Line(
                  label: LocaleKeys.checkout_qitaf_applied.tr(),
                  value: '- ${vm.redemption!.amount?.toStringAsFixed(2)}',
                ),
              Divider(height: 20.rh, color: AppColors.hairline8),
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
          SizedBox(height: 12.rh),
          InfoCard(
            title: LocaleKeys.checkout_methods.tr(),
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

class _EditRow extends StatelessWidget {
  const _EditRow({
    required this.title,
    required this.value,
    required this.onEdit,
  });

  final String title;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.rowTitle.copyWith(color: AppColors.ink),
              ),
              Text(
                value,
                style: AppTextStyles.cardSubtitle
                    .copyWith(color: AppColors.inkSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: Icon(Icons.edit_outlined, size: 20.rw),
        ),
      ],
    );
  }
}

class _Promo extends StatelessWidget {
  const _Promo({required this.vm});

  final CheckoutVm vm;

  @override
  Widget build(BuildContext context) {
    final applied = vm.appliedCoupon != null;
    return InfoCard(
      title: LocaleKeys.checkout_promo.tr(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppTextField(
              controller: vm.couponController,
              label: '',
              hint: LocaleKeys.checkout_promo_hint.tr(),
              errorText: vm.couponError == null
                  ? null
                  : (vm.couponError!.startsWith('errors.')
                      ? vm.couponError!.tr()
                      : vm.couponError),
              onChanged: (_) {},
            ),
          ),
          SizedBox(width: 10.rw),
          Padding(
            padding: EdgeInsetsDirectional.only(top: 28.rh),
            child: SizedBox(
              width: 96.rw,
              child: AppButton(
                label: applied
                    ? LocaleKeys.checkout_remove.tr()
                    : LocaleKeys.checkout_apply.tr(),
                isLoading: vm.applyingCoupon,
                onPressed: applied ? vm.removeCoupon : vm.applyCoupon,
              ),
            ),
          ),
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
            style: AppTextStyles.cardSubtitle
                .copyWith(color: AppColors.inkSecondary),
          ),
          SizedBox(height: 12.rh),
          if (redemption != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${LocaleKeys.checkout_qitaf_applied.tr()}: '
                    '${redemption.amount?.toStringAsFixed(0)}',
                    style:
                        AppTextStyles.rowTitle.copyWith(color: AppColors.ink),
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

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.rowTitle.copyWith(color: AppColors.ink)
        : AppTextStyles.cardSubtitle.copyWith(color: AppColors.ink);
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 6.rh),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.cardSubtitle
                  .copyWith(color: AppColors.inkSecondary),
            ),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }
}

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
        margin: EdgeInsetsDirectional.only(bottom: 8.rh),
        padding: EdgeInsetsDirectional.symmetric(
            horizontal: 14.rw, vertical: 12.rh),
        decoration: BoxDecoration(
          color: selected ? AppColors.redSelected6 : AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.hairline8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.iconGrey,
              size: 22.rw,
            ),
            SizedBox(width: 12.rw),
            Expanded(
              child: Text(
                gateway.label,
                style: AppTextStyles.rowTitle.copyWith(color: AppColors.ink),
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
          16.rw, 12.rh, 16.rw, 12.rh + bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null) ...[
            AppErrorBanner(
              message: error.startsWith('booking.') ||
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
              style: AppTextStyles.cardSubtitle
                  .copyWith(color: AppColors.inkSecondary),
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
