import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/common/app_text_field.dart';
import 'profile_vm.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return ViewModelBuilder<ProfileVm>.reactive(
      viewModelBuilder: ProfileVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.profile_title.tr(),
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: vm.isBusy && vm.mobile.isEmpty
              ? const AppShimmerList(itemCount: 5)
              : ListView(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 20.rw,
                    vertical: 12.rh,
                  ),
                  children: [
                    if (vm.errorMessage != null) ...[
                      AppErrorBanner(
                        message: vm.errorMessage!.startsWith('errors.')
                            ? vm.errorMessage!.tr()
                            : vm.errorMessage!,
                      ),
                      SizedBox(height: 12.rh),
                    ],
                    if (vm.saved) ...[
                      Text(
                        LocaleKeys.profile_saved.tr(),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: colors.success),
                      ),
                      SizedBox(height: 12.rh),
                    ],
                    AppTextField(
                      controller: vm.firstNameController,
                      label: LocaleKeys.profile_first_name.tr(),
                      errorText: vm.fieldError('first_name'),
                      onChanged: vm.onFieldChanged,
                    ),
                    SizedBox(height: 14.rh),
                    AppTextField(
                      controller: vm.lastNameController,
                      label: LocaleKeys.profile_last_name.tr(),
                      errorText: vm.fieldError('last_name'),
                      onChanged: vm.onFieldChanged,
                    ),
                    SizedBox(height: 14.rh),
                    AppTextField(
                      controller: vm.emailController,
                      label: LocaleKeys.profile_email.tr(),
                      keyboardType: TextInputType.emailAddress,
                      errorText: vm.fieldError('email'),
                      onChanged: vm.onFieldChanged,
                    ),
                    SizedBox(height: 14.rh),
                    AppTextField(
                      controller: vm.idNumberController,
                      label: LocaleKeys.profile_id_number.tr(),
                      keyboardType: TextInputType.number,
                      digitsOnly: true,
                      errorText: vm.fieldError('citizen_id_number'),
                      onChanged: vm.onFieldChanged,
                    ),
                    SizedBox(height: 18.rh),
                    Text(
                      '${LocaleKeys.profile_mobile.tr()}: ${vm.mobile}',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: colors.textPrimary),
                    ),
                    Text(
                      LocaleKeys.profile_mobile_not_editable.tr(),
                      style: AppTextStyles.caption
                          .copyWith(color: colors.textSecondary),
                    ),
                    SizedBox(height: 24.rh),
                    AppButton(
                      label: LocaleKeys.profile_save.tr(),
                      isLoading: vm.isBusy,
                      onPressed: vm.canSave ? vm.save : null,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
