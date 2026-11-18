import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_border_radius.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/discovery/detail_args_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_state_views.dart';
import 'doctor_detail_vm.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.args});

  final IdArgsModel args;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<DoctorDetailVm>.reactive(
      viewModelBuilder: () => DoctorDetailVm(args.id),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) {
        final doctor = vm.doctor;
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            title: Text(
              LocaleKeys.doctor_detail_title.tr(),
              style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
            ),
          ),
          body: vm.isBusy
              ? const AppShimmerList(itemCount: 4)
              : vm.hasFailure || doctor == null
                  ? AppErrorView(
                      message: LocaleKeys.errors_unexpected.tr(),
                      retryLabel: LocaleKeys.common_retry.tr(),
                      onRetry: vm.load,
                    )
                  : RefreshIndicator(
                      onRefresh: vm.refresh,
                      child: ListView(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 20.rw,
                          vertical: 12.rh,
                        ),
                        children: [
                          Text(
                            doctor.names.display(language),
                            style: AppTextStyles.h2
                                .copyWith(color: colors.textPrimary),
                          ),
                          if ((doctor.qualification ?? '').isNotEmpty) ...[
                            SizedBox(height: 4.rh),
                            Text(
                              doctor.qualification!,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ],
                          SizedBox(height: 16.rh),
                          Row(
                            children: [
                              if (doctor.patientsCount != null)
                                _Stat(
                                  label: LocaleKeys.doctor_detail_patients.tr(),
                                  value: '${doctor.patientsCount}',
                                ),
                              if (doctor.experienceYears != null)
                                _Stat(
                                  label:
                                      LocaleKeys.doctor_detail_experience.tr(),
                                  value: '${doctor.experienceYears} '
                                      '${LocaleKeys.doctor_detail_years.tr()}',
                                ),
                            ],
                          ),
                          if ((doctor.briefSummary ?? '').isNotEmpty) ...[
                            SizedBox(height: 18.rh),
                            _Section(
                                title: LocaleKeys.doctor_detail_about.tr()),
                            SizedBox(height: 6.rh),
                            Text(
                              doctor.briefSummary!,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ],
                          if (doctor.branches.isNotEmpty) ...[
                            SizedBox(height: 18.rh),
                            _Section(
                                title: LocaleKeys.doctor_detail_branches.tr()),
                            SizedBox(height: 8.rh),
                            ...doctor.branches.map(
                              (branch) => Padding(
                                padding:
                                    EdgeInsetsDirectional.only(bottom: 8.rh),
                                child: _Chip(label: branch.name ?? ''),
                              ),
                            ),
                          ],
                          if (doctor.specialities.isNotEmpty) ...[
                            SizedBox(height: 10.rh),
                            _Section(
                              title: LocaleKeys.doctor_detail_specialities.tr(),
                            ),
                            SizedBox(height: 8.rh),
                            Wrap(
                              spacing: 8.rw,
                              runSpacing: 8.rh,
                              children: doctor.specialities
                                  .map((s) => _Chip(label: s.name ?? ''))
                                  .toList(growable: false),
                            ),
                          ],
                          SizedBox(height: 28.rh),
                          AppButton(
                            label: LocaleKeys.doctor_detail_book_now.tr(),
                            onPressed: vm.bookAppointment,
                          ),
                          SizedBox(height: 20.rh),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: AppTextStyles.h3
            .copyWith(color: AppThemeColors.of(context).textPrimary),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 20.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: colors.primary),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 12.rw,
        vertical: 8.rh,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: AppBorderRadius.sm,
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
