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
import 'login_vm.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return ViewModelBuilder<LoginVm>.reactive(
      viewModelBuilder: LoginVm.new,
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 20.rw,
              vertical: 24.rh,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.rh),
                Text(
                  LocaleKeys.auth_login_title.tr(),
                  style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                ),
                SizedBox(height: 6.rh),
                Text(
                  LocaleKeys.auth_login_subtitle.tr(),
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
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16.rh),
                AppTextField(
                  controller: vm.passwordController,
                  label: LocaleKeys.auth_password_label.tr(),
                  hint: LocaleKeys.auth_password_hint.tr(),
                  obscure: vm.obscurePassword,
                  errorText: vm.fieldError('password'),
                  onChanged: vm.onFieldChanged,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 10.rh),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: vm.goToForgotPassword,
                    child: Text(
                      LocaleKeys.auth_forgot_password.tr(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: colors.primary),
                    ),
                  ),
                ),
                SizedBox(height: 10.rh),
                AppButton(
                  label: LocaleKeys.auth_sign_in.tr(),
                  isLoading: vm.isBusy,
                  onPressed: vm.canSubmit ? vm.submit : null,
                ),
                SizedBox(height: 16.rh),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.auth_no_account.tr(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: colors.textSecondary),
                    ),
                    TextButton(
                      onPressed: vm.goToRegister,
                      child: Text(
                        LocaleKeys.auth_sign_up.tr(),
                        style: AppTextStyles.bodySemiBold
                            .copyWith(color: colors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
