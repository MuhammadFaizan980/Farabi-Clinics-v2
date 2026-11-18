import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_border_radius.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import 'register_vm.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<RegisterVm>.reactive(
      viewModelBuilder: RegisterVm.new,
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.auth_register_title.tr(),
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
          ),
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
                  LocaleKeys.auth_register_subtitle.tr(),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: 20.rh),
                if (vm.validationKey != null) ...[
                  AppErrorBanner(message: vm.validationKey!.tr()),
                  SizedBox(height: 12.rh),
                ] else if (vm.errorMessage != null) ...[
                  AppErrorBanner(message: vm.errorMessage!),
                  SizedBox(height: 12.rh),
                ],
                AppTextField(
                  controller: vm.firstNameController,
                  label: LocaleKeys.auth_first_name_label.tr(),
                  errorText: vm.fieldError('first_name'),
                  onChanged: vm.onFieldChanged,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 14.rh),
                AppTextField(
                  controller: vm.lastNameController,
                  label: LocaleKeys.auth_last_name_label.tr(),
                  errorText: vm.fieldError('last_name'),
                  onChanged: vm.onFieldChanged,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 14.rh),
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
                SizedBox(height: 14.rh),
                Text(
                  LocaleKeys.auth_id_type_label.tr(),
                  style: AppTextStyles.bodySemiBold
                      .copyWith(color: colors.textPrimary),
                ),
                SizedBox(height: 6.rh),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 12.rw),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: AppBorderRadius.sm,
                    border: Border.all(color: colors.border, width: 1.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: vm.idType?.value,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: vm.idTypes
                          .map(
                            (type) => DropdownMenuItem<int>(
                              value: type.value,
                              child: Text(
                                type.label(language),
                                style: AppTextStyles.bodyLarge
                                    .copyWith(color: colors.textPrimary),
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => vm.setIdType(
                        vm.idTypes.firstWhere((type) => type.value == value),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.rh),
                AppTextField(
                  controller: vm.idNumberController,
                  label: LocaleKeys.auth_id_number_label.tr(),
                  keyboardType: TextInputType.number,
                  digitsOnly: true,
                  errorText: vm.fieldError('citizen_id_number'),
                  onChanged: vm.onFieldChanged,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 14.rh),
                AppTextField(
                  controller: vm.passwordController,
                  label: LocaleKeys.auth_password_label.tr(),
                  obscure: true,
                  errorText: vm.fieldError('password'),
                  onChanged: vm.onFieldChanged,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 14.rh),
                AppTextField(
                  controller: vm.confirmPasswordController,
                  label: LocaleKeys.auth_confirm_password_label.tr(),
                  obscure: true,
                  onChanged: vm.onFieldChanged,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 24.rh),
                AppButton(
                  label: LocaleKeys.auth_sign_up.tr(),
                  isLoading: vm.isBusy,
                  onPressed: vm.canSubmit ? vm.submit : null,
                ),
                SizedBox(height: 20.rh),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
