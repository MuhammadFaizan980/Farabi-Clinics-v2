import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_dropdown_field.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/more/more_header.dart';
import 'contact_us_vm.dart';

/// the site's contact page: Name, Email, Region (segmented), Branch (by
/// region), Service (by branch), Phone, How did you hear about us, Apply.
/// regions, branches and services all come from the api.
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<ContactUsVm>.reactive(
      viewModelBuilder: ContactUsVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Column(
          children: [
            MoreHeader(
              title: LocaleKeys.contact_title.tr(),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding:
                    EdgeInsetsDirectional.fromSTEB(16.rw, 16.rh, 16.rw, 24.rh),
                children: [
                  Text(
                    LocaleKeys.contact_heading.tr(),
                    style: AppTextStyles.authTitle
                        .copyWith(color: AppColors.ink),
                  ),
                  SizedBox(height: 8.rh),
                  Text(
                    LocaleKeys.contact_intro.tr(),
                    style: AppTextStyles.cardSubtitle
                        .copyWith(color: AppColors.inkSecondary),
                  ),
                  SizedBox(height: 16.rh),
                  InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (vm.sent) ...[
                          Text(
                            LocaleKeys.contact_success.tr(),
                            style: AppTextStyles.rowTitle
                                .copyWith(color: AppColors.success),
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
                          label: '${LocaleKeys.contact_name.tr()} *',
                          onChanged: vm.onFieldChanged,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 14.rh),
                        AppTextField(
                          controller: vm.emailController,
                          label: LocaleKeys.contact_email.tr(),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: vm.onFieldChanged,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 14.rh),
                        Text(
                          LocaleKeys.contact_region.tr(),
                          style: AppTextStyles.fieldLabel
                              .copyWith(color: AppColors.ink),
                        ),
                        SizedBox(height: 8.rh),
                        _RegionPicker(vm: vm, language: language),
                        SizedBox(height: 14.rh),
                        AppDropdownField<int>(
                          label: '${LocaleKeys.contact_branch.tr()} *',
                          hint: LocaleKeys.contact_select_branch.tr(),
                          value: vm.branchId,
                          items: [
                            for (final branch in vm.branches)
                              DropdownMenuItem(
                                value: branch.id,
                                child: Text(
                                  branch.names.display(language),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: vm.setBranch,
                        ),
                        SizedBox(height: 14.rh),
                        // locked until a branch is chosen, as on the site
                        Opacity(
                          opacity: vm.branchId == null ? 0.5 : 1,
                          child: IgnorePointer(
                            ignoring: vm.branchId == null,
                            child: AppDropdownField<int>(
                              label: '${LocaleKeys.contact_service.tr()} *',
                              hint: LocaleKeys.contact_select_service.tr(),
                              value: vm.serviceId,
                              items: [
                                for (final service in vm.services)
                                  DropdownMenuItem(
                                    value: service.id,
                                    child: Text(
                                      service.names.display(language),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: vm.setService,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.rh),
                        AppTextField(
                          controller: vm.phoneController,
                          label: '${LocaleKeys.contact_phone.tr()} *',
                          hint: LocaleKeys.auth_mobile_hint.tr(),
                          keyboardType: TextInputType.phone,
                          digitsOnly: true,
                          maxLength: 10,
                          onChanged: vm.onFieldChanged,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 14.rh),
                        AppDropdownField<String>(
                          label: '${LocaleKeys.contact_about_us.tr()} *',
                          hint: LocaleKeys.contact_select_option.tr(),
                          value: vm.aboutUs,
                          items: [
                            for (final source in vm.sources)
                              DropdownMenuItem(
                                value: source,
                                child: Text('contact.source_$source'.tr()),
                              ),
                          ],
                          onChanged: vm.setAboutUs,
                        ),
                        SizedBox(height: 24.rh),
                        AppButton(
                          label: LocaleKeys.contact_submit.tr(),
                          isLoading: vm.isBusy,
                          onPressed: vm.canSubmit ? vm.submit : null,
                        ),
                      ],
                    ),
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

/// the site's segmented region control: tapping the chosen region again clears
/// it, which brings every branch back
class _RegionPicker extends StatelessWidget {
  const _RegionPicker({required this.vm, required this.language});

  final ContactUsVm vm;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.rh,
      decoration: AppFieldDecoration.box(),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 6.rw,
          vertical: 6.rh,
        ),
        itemCount: vm.regions.length,
        separatorBuilder: (_, __) => SizedBox(width: 4.rw),
        itemBuilder: (context, i) {
          final region = vm.regions[i];
          final selected = vm.regionId == region.id;
          return GestureDetector(
            onTap: () => vm.setRegion(selected ? null : region.id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
              decoration: BoxDecoration(
                color: selected ? AppColors.redSelected6 : Colors.transparent,
                borderRadius: BorderRadius.circular(10.r),
                border: selected
                    ? Border.all(color: AppColors.primary, width: 1.2)
                    : null,
              ),
              child: Text(
                region.names.display(language),
                style: AppTextStyles.filterChip.copyWith(
                  color: selected ? AppColors.primary : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
