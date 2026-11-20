import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/more/more_header.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/common/app_text_field.dart';
import 'profile_vm.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileVm>.reactive(
      viewModelBuilder: ProfileVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Column(
          children: [
            MoreHeader(
              title: LocaleKeys.profile_title.tr(),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: vm.isBusy && vm.mobile.isEmpty
                  ? const AppShimmerList(itemCount: 5)
                  : ListView(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.rw,
                        8.rh,
                        16.rw,
                        16.rh,
                      ),
                      children: [
                        if (vm.errorMessage != null) ...[
                          AppErrorBanner(
                            message: vm.errorMessage!.startsWith('errors.')
                                ? vm.errorMessage!.tr()
                                : vm.errorMessage!,
                          ),
                          SizedBox(height: 4.rh),
                        ],
                        if (vm.saved) ...[
                          Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 4.rw,
                              vertical: 4.rh,
                            ),
                            child: Text(
                              LocaleKeys.profile_saved.tr(),
                              style: AppTextStyles.profileBody.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                        InfoCard(
                          title: LocaleKeys.profile_title.tr(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.rh),
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
                                style: AppTextStyles.profileBody.copyWith(
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                LocaleKeys.profile_mobile_not_editable.tr(),
                                style: AppTextStyles.fieldError.copyWith(
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                              SizedBox(height: 4.rh),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            BottomActionBar(
              label: LocaleKeys.profile_save.tr(),
              isLoading: vm.isBusy,
              onPressed: vm.canSave ? vm.save : null,
            ),
          ],
        ),
      ),
    );
  }
}
