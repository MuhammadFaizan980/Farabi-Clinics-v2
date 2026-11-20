import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/auth/auth_scaffold.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import 'login_vm.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.popOnSuccess = false});

  final bool popOnSuccess;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginVm>.reactive(
      viewModelBuilder: () => LoginVm(popOnSuccess: popOnSuccess),
      builder: (context, vm, child) => AuthScaffold(
        title: LocaleKeys.auth_login_title.tr(),
        subtitle: LocaleKeys.auth_login_subtitle.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.validationKey != null) ...[
              AppErrorBanner(message: vm.validationKey!.tr()),
              SizedBox(height: 14.rh),
            ] else if (vm.errorMessage != null) ...[
              AppErrorBanner(message: vm.errorMessage!),
              SizedBox(height: 14.rh),
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
              obscure: true,
              errorText: vm.fieldError('password'),
              onChanged: vm.onFieldChanged,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 8.rh),
            AuthLink(
              label: LocaleKeys.auth_forgot_password.tr(),
              onTap: vm.goToForgotPassword,
            ),
            SizedBox(height: 12.rh),
            AppButton(
              label: LocaleKeys.auth_sign_in.tr(),
              isLoading: vm.isBusy,
              onPressed: vm.canSubmit ? vm.submit : null,
            ),
            SizedBox(height: 16.rh),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6.rw,
                children: [
                  Text(
                    LocaleKeys.auth_no_account.tr(),
                    style: AppTextStyles.link.copyWith(
                      color: AppColors.inkSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AuthLink(
                    label: LocaleKeys.auth_sign_up.tr(),
                    onTap: vm.goToRegister,
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
