import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_border_radius.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import 'contact_us_vm.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<ContactUsVm>.reactive(
      viewModelBuilder: ContactUsVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.contact_title.tr(),
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 20.rw,
              vertical: 12.rh,
            ),
            children: [
              if (vm.sent) ...[
                Text(
                  LocaleKeys.contact_success.tr(),
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: colors.success),
                ),
                SizedBox(height: 12.rh),
              ],
              if (vm.errorMessage != null) ...[
                AppErrorBanner(
                  message: vm.errorMessage!.startsWith('errors.')
                      ? vm.errorMessage!.tr()
                      : vm.errorMessage!,
                ),
                SizedBox(height: 12.rh),
              ],
              AppTextField(
                controller: vm.nameController,
                label: LocaleKeys.contact_name.tr(),
                errorText: vm.fieldError('name'),
                onChanged: vm.onFieldChanged,
              ),
              SizedBox(height: 14.rh),
              AppTextField(
                controller: vm.phoneController,
                label: LocaleKeys.contact_phone.tr(),
                keyboardType: TextInputType.phone,
                digitsOnly: true,
                maxLength: 10,
                errorText: vm.fieldError('phone_number'),
                onChanged: vm.onFieldChanged,
              ),
              SizedBox(height: 14.rh),
              AppTextField(
                controller: vm.emailController,
                label: LocaleKeys.contact_email.tr(),
                keyboardType: TextInputType.emailAddress,
                errorText: vm.fieldError('email'),
                onChanged: vm.onFieldChanged,
              ),
              SizedBox(height: 14.rh),
              _Dropdown<int>(
                label: LocaleKeys.contact_branch.tr(),
                value: vm.branchId,
                items: {
                  for (final branch in vm.branches)
                    branch.id: branch.names.display(language),
                },
                onChanged: vm.setBranch,
              ),
              SizedBox(height: 14.rh),
              _Dropdown<int>(
                label: LocaleKeys.contact_service.tr(),
                value: vm.serviceId,
                items: {
                  for (final service in vm.services)
                    service.id: service.names.display(language),
                },
                onChanged: vm.setService,
              ),
              SizedBox(height: 14.rh),
              _Dropdown<String>(
                label: LocaleKeys.contact_about_us.tr(),
                value: vm.aboutUs,
                items: {
                  for (final source in vm.sources)
                    source: 'contact.source_$source'.tr(),
                },
                onChanged: vm.setAboutUs,
              ),
              SizedBox(height: 24.rh),
              AppButton(
                label: LocaleKeys.contact_submit.tr(),
                isLoading: vm.isBusy,
                onPressed: vm.canSubmit ? vm.submit : null,
              ),
              SizedBox(height: 20.rh),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySemiBold.copyWith(color: colors.textPrimary),
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
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              hint: Text(
                LocaleKeys.contact_choose.tr(),
                style:
                    AppTextStyles.bodyLarge.copyWith(color: colors.textMuted),
              ),
              items: items.entries
                  .map(
                    (entry) => DropdownMenuItem<T>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: colors.textPrimary),
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
