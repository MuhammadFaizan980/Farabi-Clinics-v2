import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/support/support_models.dart';
import '../../router/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_dropdown_field.dart';
import '../../widgets/common/app_error_banner.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/more/more_header.dart';
import 'job_apply_vm.dart';

/// the application form, with the same fields, required marks, date format,
/// CV rule (PDF or DOCX, 5 MB) and two consents as the site. it posts to the
/// job's applications endpoint as multipart.
class JobApplyScreen extends StatelessWidget {
  const JobApplyScreen({super.key, required this.job});

  final JobDataModel job;

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<JobApplyVm>.reactive(
      viewModelBuilder: () => JobApplyVm(job),
      builder: (context, vm, child) {
        String req(String key) => '${key.tr()} *';
        String? err(TextEditingController c) => vm.isEmptyField(c)
            ? LocaleKeys.careers_required.tr()
            : null;

        return Scaffold(
          backgroundColor: AppColors.listBackground,
          body: Column(
            children: [
              MoreHeader(
                title: LocaleKeys.careers_apply_title.tr(),
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: vm.submitted
                    ? _Done(
                        onBack: () => Navigator.of(context).popUntil(
                          (r) =>
                              r.settings.name == AppRoutes.careers || r.isFirst,
                        ),
                      )
                    : ListView(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.rw, 16.rh, 16.rw, 24.rh),
                        children: [
                          Text(
                            job.names.display(language),
                            style: AppTextStyles.authTitle
                                .copyWith(color: AppColors.ink),
                          ),
                          SizedBox(height: 14.rh),
                          if (vm.errorMessage != null) ...[
                            AppErrorBanner(
                              message: vm.errorMessage!.startsWith('errors.')
                                  ? vm.errorMessage!.tr()
                                  : vm.errorMessage == 'unexpected'
                                      ? LocaleKeys.errors_unexpected.tr()
                                      : vm.errorMessage!,
                            ),
                            SizedBox(height: 12.rh),
                          ],
                          _Group(
                            title: LocaleKeys.careers_personal_info.tr(),
                            children: [
                              AppTextField(
                                controller: vm.nameController,
                                label: req(LocaleKeys.careers_full_name),
                                errorText: err(vm.nameController),
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                              ),
                              AppTextField(
                                controller: vm.emailController,
                                label: req(LocaleKeys.careers_email),
                                keyboardType: TextInputType.emailAddress,
                                errorText: vm.emailInvalid
                                    ? LocaleKeys.careers_required.tr()
                                    : null,
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                              ),
                              AppTextField(
                                controller: vm.phoneController,
                                label: req(LocaleKeys.careers_phone),
                                hint: LocaleKeys.auth_mobile_hint.tr(),
                                keyboardType: TextInputType.phone,
                                digitsOnly: true,
                                maxLength: 10,
                                errorText: err(vm.phoneController),
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                              ),
                              AppTextField(
                                controller: vm.dobController,
                                label: req(LocaleKeys.careers_dob),
                                hint: 'DD / MM / YYYY',
                                keyboardType: TextInputType.number,
                                maxLength: 14,
                                errorText: vm.dobInvalid
                                    ? LocaleKeys.careers_dob_invalid.tr()
                                    : null,
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                                formatters: [_DobFormatter()],
                              ),
                            ],
                          ),
                          _Group(
                            title: LocaleKeys.careers_professional_details.tr(),
                            children: [
                              AppTextField(
                                controller: vm.positionController,
                                label: req(LocaleKeys.careers_current_position),
                                errorText: err(vm.positionController),
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                              ),
                              AppDropdownField<String>(
                                label: req(LocaleKeys.careers_years_experience),
                                hint: LocaleKeys.careers_select.tr(),
                                value: vm.experience,
                                items: [
                                  for (final o in JobApplyOptions.experience)
                                    DropdownMenuItem(
                                      value: o.value,
                                      child: Text(o.labelKey.tr()),
                                    ),
                                ],
                                onChanged: vm.setExperience,
                              ),
                              AppTextField(
                                controller: vm.licenseController,
                                label: req(LocaleKeys.careers_license),
                                errorText: err(vm.licenseController),
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                              ),
                              AppDropdownField<String>(
                                label: req(LocaleKeys.careers_specialization),
                                hint: LocaleKeys.careers_select.tr(),
                                value: vm.specialization,
                                items: [
                                  for (final o in JobApplyOptions
                                      .specializations)
                                    DropdownMenuItem(
                                      value: o.value,
                                      child: Text(o.labelKey.tr()),
                                    ),
                                ],
                                onChanged: vm.setSpecialization,
                              ),
                            ],
                          ),
                          _Group(
                            title: LocaleKeys.careers_education.tr(),
                            children: [
                              AppTextField(
                                controller: vm.degreeController,
                                label: req(LocaleKeys.careers_degree),
                                errorText: err(vm.degreeController),
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                              ),
                              AppTextField(
                                controller: vm.institutionController,
                                label: req(LocaleKeys.careers_institution),
                                errorText: err(vm.institutionController),
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                              ),
                              AppDropdownField<int>(
                                label: req(LocaleKeys.careers_graduation_year),
                                hint: LocaleKeys.careers_select.tr(),
                                value: vm.graduationYear,
                                items: [
                                  for (final y in vm.graduationYears)
                                    DropdownMenuItem(
                                      value: y,
                                      child: Text('$y'),
                                    ),
                                ],
                                onChanged: vm.setGraduationYear,
                              ),
                            ],
                          ),
                          _Group(
                            title: LocaleKeys.careers_resume.tr(),
                            children: [
                              OutlinedButton.icon(
                                onPressed: vm.pickCv,
                                icon: const Icon(Icons.upload_file_outlined),
                                label: Text(
                                  vm.cvName ??
                                      LocaleKeys.careers_choose_file.tr(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size.fromHeight(48.rh),
                                  foregroundColor: AppColors.ink,
                                ),
                              ),
                              Text(
                                vm.cvError?.tr() ??
                                    LocaleKeys.careers_cv_hint.tr(),
                                style: AppTextStyles.caption.copyWith(
                                  color: vm.cvError == null
                                      ? AppColors.inkSecondary
                                      : AppColors.error,
                                ),
                              ),
                              if (vm.cvName != null)
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: TextButton(
                                    onPressed: vm.removeCv,
                                    child: Text(LocaleKeys.careers_cancel.tr()),
                                  ),
                                ),
                            ],
                          ),
                          _Group(
                            title: LocaleKeys.careers_cover_section.tr(),
                            children: [
                              AppTextField(
                                controller: vm.coverController,
                                label: req(LocaleKeys.careers_cover_letter),
                                errorText: err(vm.coverController),
                                onChanged: vm.onFieldChanged,
                              ),
                            ],
                          ),
                          _Group(
                            title: LocaleKeys.careers_references.tr(),
                            children: [
                              AppTextField(
                                controller: vm.refNameController,
                                label: LocaleKeys.careers_ref_name.tr(),
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                              ),
                              AppTextField(
                                controller: vm.refRelationController,
                                label: LocaleKeys.careers_ref_relationship.tr(),
                                onChanged: vm.onFieldChanged,
                                textInputAction: TextInputAction.next,
                              ),
                              AppTextField(
                                controller: vm.refContactController,
                                label: LocaleKeys.careers_ref_contact.tr(),
                                onChanged: vm.onFieldChanged,
                              ),
                              _Consent(
                                label: LocaleKeys.careers_certify.tr(),
                                value: vm.certify,
                                onChanged: vm.setCertify,
                              ),
                              _Consent(
                                label: LocaleKeys.careers_agree.tr(),
                                value: vm.agree,
                                onChanged: vm.setAgree,
                              ),
                            ],
                          ),
                          AppButton(
                            label: LocaleKeys.careers_submit_application.tr(),
                            isLoading: vm.isBusy,
                            onPressed: vm.isBusy ? null : vm.submit,
                          ),
                          SizedBox(height: 10.rh),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.fromHeight(48.rh),
                              foregroundColor: AppColors.ink,
                            ),
                            child: Text(LocaleKeys.careers_cancel.tr()),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 12.rh),
      child: InfoCard(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: 14.rh),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _Consent extends StatelessWidget {
  const _Consent({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            activeColor: AppColors.primary,
            onChanged: (v) => onChanged(v ?? false),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: 12.rh),
              child: Text(
                label,
                style: AppTextStyles.cardSubtitle
                    .copyWith(color: AppColors.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64.rw, color: AppColors.success),
          SizedBox(height: 16.rh),
          Text(
            LocaleKeys.careers_success_title.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.authTitle.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: 8.rh),
          Text(
            LocaleKeys.careers_success_body.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.cardSubtitle
                .copyWith(color: AppColors.inkSecondary),
          ),
          SizedBox(height: 24.rh),
          AppButton(label: LocaleKeys.careers_back_to_jobs.tr(), onPressed: onBack),
        ],
      ),
    );
  }
}

/// types "DD / MM / YYYY" for you: digits only, separators inserted
class _DobFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 2 || i == 4) buffer.write(' / ');
      buffer.write(limited[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
