import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/auth/auth_scaffold.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import 'forgot_password_vm.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ForgotPasswordVm>.reactive(
      viewModelBuilder: ForgotPasswordVm.new,
      builder: (context, vm, child) => AuthScaffold(
        title: LocaleKeys.auth_forgot_title.tr(),
        subtitle: LocaleKeys.auth_forgot_subtitle.tr(),
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
    );
  }
}
