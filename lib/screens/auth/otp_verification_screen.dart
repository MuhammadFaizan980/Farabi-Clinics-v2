import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/auth/otp_args_model.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import 'otp_verification_vm.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key, required this.args});

  final OtpArgsModel args;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return ViewModelBuilder<OtpVerificationVm>.reactive(
      viewModelBuilder: () => OtpVerificationVm(args),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 20.rw,
              vertical: 12.rh,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.auth_otp_title.tr(),
                  style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                ),
                SizedBox(height: 6.rh),
                Text(
                  LocaleKeys.auth_otp_subtitle.tr(
                    namedArgs: {'count': '6', 'mobile': vm.mobile},
                  ),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: 24.rh),
                if (vm.validationKey != null) ...[
                  AppErrorBanner(
                    message: vm.validationKey!.tr(namedArgs: {'count': '6'}),
                  ),
                  SizedBox(height: 12.rh),
                ] else if (vm.errorMessage != null) ...[
                  AppErrorBanner(message: vm.errorMessage!),
                  SizedBox(height: 12.rh),
                ],
                AppTextField(
                  controller: vm.otpController,
                  label: LocaleKeys.auth_otp_verify.tr(),
                  keyboardType: TextInputType.number,
                  digitsOnly: true,
                  maxLength: 6,
                  errorText: vm.fieldError('otp'),
                  onChanged: vm.onOtpChanged,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 12.rh),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: vm.canResend ? vm.resend : null,
                      child: Text(
                        vm.canResend
                            ? LocaleKeys.auth_otp_resend.tr()
                            : LocaleKeys.auth_otp_resend_in.tr(
                                namedArgs: {
                                  'seconds': '${vm.secondsRemaining}',
                                },
                              ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: vm.canResend
                              ? colors.primary
                              : colors.textMuted,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: vm.changeNumber,
                      child: Text(
                        LocaleKeys.auth_change_number.tr(),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.rh),
                AppButton(
                  label: LocaleKeys.auth_otp_verify.tr(),
                  isLoading: vm.isBusy,
                  onPressed: vm.canSubmit ? vm.verify : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
