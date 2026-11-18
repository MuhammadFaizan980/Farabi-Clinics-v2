import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_border_radius.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_state_views.dart';
import 'careers_vm.dart';

class CareersScreen extends StatelessWidget {
  const CareersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<CareersVm>.reactive(
      viewModelBuilder: CareersVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.careers_title.tr(),
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: vm.isBusy
              ? const AppShimmerList()
              : vm.hasFailure
                  ? AppErrorView(
                      message: LocaleKeys.errors_unexpected.tr(),
                      retryLabel: LocaleKeys.common_retry.tr(),
                      onRetry: vm.load,
                    )
                  : Column(
                      children: [
                        if (vm.departments.isNotEmpty)
                          SizedBox(
                            height: 60.rh,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: 20.rw,
                                vertical: 8.rh,
                              ),
                              children: [
                                _Chip(
                                  label:
                                      LocaleKeys.careers_all_departments.tr(),
                                  selected: vm.department == null,
                                  onTap: () => vm.setDepartment(null),
                                ),
                                ...vm.departments.map(
                                  (dept) => Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      start: 8.rw,
                                    ),
                                    child: _Chip(
                                      label: dept,
                                      selected: vm.department == dept,
                                      onTap: () => vm.setDepartment(dept),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: vm.isEmpty
                              ? AppEmptyView(
                                  title: LocaleKeys.careers_no_jobs.tr(),
                                )
                              : RefreshIndicator(
                                  onRefresh: vm.refresh,
                                  child: ListView.separated(
                                    padding: EdgeInsetsDirectional.symmetric(
                                      horizontal: 20.rw,
                                      vertical: 12.rh,
                                    ),
                                    itemCount: vm.jobs.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 12.rh),
                                    itemBuilder: (context, index) {
                                      final job = vm.jobs[index];
                                      return Container(
                                        padding:
                                            EdgeInsetsDirectional.all(14.r),
                                        decoration: BoxDecoration(
                                          color: colors.surface,
                                          borderRadius: AppBorderRadius.md,
                                          border: Border.all(
                                            color: colors.border,
                                            width: 1.r,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              job.names.display(language),
                                              style: AppTextStyles
                                                  .bodySemiBold
                                                  .copyWith(
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                            if (job.department != null) ...[
                                              SizedBox(height: 2.rh),
                                              Text(
                                                job.department!,
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                            ],
                                            if (job.summary != null) ...[
                                              SizedBox(height: 8.rh),
                                              Text(
                                                job.summary!,
                                                style: AppTextStyles
                                                    .bodyMedium
                                                    .copyWith(
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                            ],
                                            SizedBox(height: 10.rh),
                                            Wrap(
                                              spacing: 8.rw,
                                              runSpacing: 6.rh,
                                              children: [
                                                if (job.employmentType != null)
                                                  _Tag(
                                                      label:
                                                          job.employmentType!),
                                                if (job.experienceRange
                                                    .isNotEmpty)
                                                  _Tag(
                                                    label:
                                                        '${job.experienceRange} '
                                                        '${LocaleKeys.careers_years.tr()}',
                                                  ),
                                                if (job.cityName != null)
                                                  _Tag(label: job.cityName!),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.pill,
      child: Container(
        height: 44.rh,
        alignment: Alignment.center,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 14.rw),
        decoration: BoxDecoration(
          color: selected ? colors.primarySoft : colors.surface,
          borderRadius: AppBorderRadius.pill,
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: 1.r,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 10.rw,
        vertical: 5.rh,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: AppBorderRadius.xs,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
