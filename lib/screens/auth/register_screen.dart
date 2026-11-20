import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/auth/auth_scaffold.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_dropdown_field.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/country_phone_field.dart';
import 'register_vm.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<RegisterVm>.reactive(
      viewModelBuilder: RegisterVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => AuthScaffold(
        title: LocaleKeys.auth_register_title.tr(),
        subtitle: LocaleKeys.auth_register_subtitle.tr(),
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
            // first and last name side by side, as on the website
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: vm.firstNameController,
                    label: LocaleKeys.auth_first_name_label.tr(),
                    hint: LocaleKeys.auth_first_name_hint.tr(),
                    errorText: vm.fieldError('first_name'),
                    onChanged: vm.onFieldChanged,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(width: 12.rw),
                Expanded(
                  child: AppTextField(
                    controller: vm.lastNameController,
                    label: LocaleKeys.auth_last_name_label.tr(),
                    hint: LocaleKeys.auth_last_name_hint.tr(),
                    errorText: vm.fieldError('last_name'),
                    onChanged: vm.onFieldChanged,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.rh),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDropdownField<int>(
                    label: LocaleKeys.auth_id_type_label.tr(),
                    hint: LocaleKeys.auth_id_type_hint.tr(),
                    value: vm.idType?.value,
                    items: vm.idTypes
                        .map(
                          (type) => DropdownMenuItem<int>(
                            value: type.value,
                            child: Text(
                              type.label(language),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) => vm.setIdType(
                      vm.idTypes.firstWhere((type) => type.value == value),
                    ),
                  ),
                ),
                SizedBox(width: 12.rw),
                Expanded(
                  child: AppTextField(
                    controller: vm.idNumberController,
                    label: LocaleKeys.auth_id_number_label.tr(),
                    hint: LocaleKeys.auth_id_number_hint.tr(),
                    errorText: vm.fieldError('citizen_id_number'),
                    onChanged: vm.onFieldChanged,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.rh),
            CountryPhoneField(
              controller: vm.phone,
              onChanged: () => vm.onFieldChanged(''),
            ),
            SizedBox(height: 16.rh),
            AppTextField(
              controller: vm.passwordController,
              label: LocaleKeys.auth_password_label.tr(),
              hint: LocaleKeys.auth_password_create_hint.tr(),
              obscure: true,
              errorText: vm.fieldError('password'),
              onChanged: vm.onFieldChanged,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 24.rh),
            AppButton(
              label: LocaleKeys.auth_create_account.tr(),
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
                    LocaleKeys.auth_have_account.tr(),
                    style: AppTextStyles.link.copyWith(
                      color: AppColors.inkSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AuthLink(
                    label: LocaleKeys.auth_sign_in.tr(),
                    onTap: vm.goToLogin,
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
