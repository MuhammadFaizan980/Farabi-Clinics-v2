import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/auth/otp_args_model.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/auth/auth_scaffold.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import 'reset_password_vm.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.args});

  final ResetPasswordArgsModel args;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ResetPasswordVm>.reactive(
      viewModelBuilder: () => ResetPasswordVm(args),
      builder: (context, vm, child) => AuthScaffold(
        title: LocaleKeys.auth_reset_title.tr(),
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
              controller: vm.passwordController,
              label: LocaleKeys.auth_new_password_label.tr(),
              obscure: true,
              errorText: vm.fieldError('password'),
              onChanged: vm.onFieldChanged,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 16.rh),
            AppTextField(
              controller: vm.confirmController,
              label: LocaleKeys.auth_confirm_password_label.tr(),
              obscure: true,
              onChanged: vm.onFieldChanged,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 24.rh),
            AppButton(
              label: LocaleKeys.auth_reset_submit.tr(),
              isLoading: vm.isBusy,
              onPressed: vm.canSubmit ? vm.submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
