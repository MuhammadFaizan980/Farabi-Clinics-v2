import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/auth/otp_args_model.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/auth/auth_scaffold.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import 'otp_verification_vm.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key, required this.args});

  final OtpArgsModel args;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OtpVerificationVm>.reactive(
      viewModelBuilder: () => OtpVerificationVm(args),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => AuthScaffold(
        title: LocaleKeys.auth_otp_title.tr(),
        subtitle: LocaleKeys.auth_otp_subtitle.tr(
          namedArgs: {'count': '6', 'mobile': vm.mobile},
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.validationKey != null) ...[
              AppErrorBanner(
                message: vm.validationKey!.tr(namedArgs: {'count': '6'}),
              ),
              SizedBox(height: 14.rh),
            ] else if (vm.errorMessage != null) ...[
              AppErrorBanner(message: vm.errorMessage!),
              SizedBox(height: 14.rh),
            ],
            AppTextField(
              controller: vm.otpController,
              label: LocaleKeys.auth_otp_verify.tr(),
              keyboardType: TextInputType.number,
              digitsOnly: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              letterSpacing: 8.rw,
              errorText: vm.fieldError('otp'),
              onChanged: vm.onOtpChanged,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 8.rh),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AuthLink(
                  label: vm.canResend
                      ? LocaleKeys.auth_otp_resend.tr()
                      : LocaleKeys.auth_otp_resend_in
                          .tr(namedArgs: {'seconds': '${vm.secondsRemaining}'}),
                  underline: vm.canResend,
                  color: vm.canResend ? AppColors.primary : AppColors.greyLight,
                  onTap: vm.canResend ? vm.resend : null,
                ),
                AuthLink(
                  label: LocaleKeys.auth_change_number.tr(),
                  underline: false,
                  color: AppColors.inkSecondary,
                  onTap: vm.changeNumber,
                ),
              ],
            ),
            SizedBox(height: 12.rh),
            AppButton(
              label: LocaleKeys.auth_otp_verify.tr(),
              isLoading: vm.isBusy,
              onPressed: vm.canSubmit ? vm.verify : null,
            ),
          ],
        ),
      ),
    );
  }
}
