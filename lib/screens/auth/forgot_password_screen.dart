import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import 'forgot_password_vm.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return ViewModelBuilder<ForgotPasswordVm>.reactive(
      viewModelBuilder: ForgotPasswordVm.new,
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
                  LocaleKeys.auth_forgot_title.tr(),
                  style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                ),
                SizedBox(height: 6.rh),
                Text(
                  LocaleKeys.auth_forgot_subtitle.tr(),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: 24.rh),
                if (vm.validationKey != null) ...[
                  AppErrorBanner(message: vm.validationKey!.tr()),
                  SizedBox(height: 12.rh),
                ] else if (vm.errorMessage != null) ...[
                  AppErrorBanner(message: vm.errorMessage!),
                  SizedBox(height: 12.rh),
                ],
                AppTextField(
                  controller: vm.mobileController,
                  label: LocaleKeys.auth_mobile_label.tr(),
                  hint: LocaleKeys.auth_mobile_hint.tr(),
                  keyboardType: TextInputType.phone,
                  digitsOnly: true,
                  maxLength: 10,
                  errorText: vm.fieldError('mobile'),
                  onChanged: vm.onFieldChanged,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 24.rh),
                AppButton(
                  label: LocaleKeys.auth_send_code.tr(),
                  isLoading: vm.isBusy,
                  onPressed: vm.canSubmit ? vm.submit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
