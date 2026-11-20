import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/auth/auth_scaffold.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/country_phone_field.dart';
import 'forgot_password_vm.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ForgotPasswordVm>.reactive(
      viewModelBuilder: ForgotPasswordVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => AuthScaffold(
        title: vm.sent ? null : LocaleKeys.auth_forgot_title.tr(),
        subtitle: vm.sent ? null : LocaleKeys.auth_forgot_subtitle.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.sent) ...[
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 8.rh),
                    Icon(Icons.check_circle,
                        size: 56.rw, color: AppColors.success),
                    SizedBox(height: 12.rh),
                    Text(
                      LocaleKeys.auth_forgot_sent_title.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.authTitle
                          .copyWith(color: AppColors.ink),
                    ),
                    SizedBox(height: 8.rh),
                    Text(
                      LocaleKeys.auth_forgot_sent_message.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.authSubtitle
                          .copyWith(color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (vm.validationKey != null) ...[
                AppErrorBanner(message: vm.validationKey!.tr()),
                SizedBox(height: 14.rh),
              ] else if (vm.errorMessage != null) ...[
                AppErrorBanner(message: vm.errorMessage!),
                SizedBox(height: 14.rh),
              ],
              CountryPhoneField(
                controller: vm.phone,
                onChanged: () => vm.onFieldChanged(''),
              ),
              SizedBox(height: 24.rh),
              AppButton(
                label: LocaleKeys.auth_forgot_send_link.tr(),
                isLoading: vm.isBusy,
                onPressed: vm.canSubmit ? vm.submit : null,
              ),
            ],
            SizedBox(height: 16.rh),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6.rw,
                children: [
                  Text(
                    LocaleKeys.auth_go_back_to.tr(),
                    style: AppTextStyles.link.copyWith(
                      color: AppColors.inkSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AuthLink(
                    label: LocaleKeys.auth_sign_in.tr(),
                    onTap: vm.goBackToSignIn,
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
