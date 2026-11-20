import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/discovery/detail_args_models.dart';
import '../../data/models/support/support_models.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../utils/launcher.dart';
import '../../utils/posted_ago.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/more/more_header.dart';
import 'job_detail_vm.dart';

/// one job: summary, Apply Now, Download Job Description (only when the post
/// has a file), and the About / Responsibilities / Requirements / Offers /
/// Benefits sections plus the overview table. all of it is the job post.
class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.args});

  final SlugArgsModel args;

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<JobDetailVm>.reactive(
      viewModelBuilder: () => JobDetailVm(args.slug),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) {
        final detail = vm.detail;
        return Scaffold(
          backgroundColor: AppColors.listBackground,
          body: Column(
            children: [
              MoreHeader(
                title: LocaleKeys.careers_detail_title.tr(),
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: vm.isBusy
                    ? const AppShimmerList(itemCount: 3)
                    : vm.hasFailure || detail == null
                        ? AppErrorView(
                            message: LocaleKeys.errors_unexpected.tr(),
                            retryLabel: LocaleKeys.common_retry.tr(),
                            onRetry: vm.load,
                          )
                        : _Content(detail: detail, language: language),
              ),
              if (detail != null)
                BottomActionBar(
                  label: LocaleKeys.careers_apply_now.tr(),
                  onPressed: () => AppNavigator.push(
                    AppRoutes.jobApply,
                    arguments: detail.job,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.detail, required this.language});

  final JobDetailDataModel detail;
  final String language;

  @override
  Widget build(BuildContext context) {
    final job = detail.job;
    final days = job.postedDaysAgo;

    Widget bullets(String title, List<String> items) => items.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsetsDirectional.only(bottom: 12.rh),
            child: InfoCard(
              title: title,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in items)
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 6.rh),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                top: 7.rh, end: 10.rw),
                            child: Container(
                              width: 5.rw,
                              height: 5.rw,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: AppTextStyles.cardSubtitle
                                  .copyWith(color: AppColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 16.rh, 16.rw, 24.rh),
      children: [
        if (job.employmentType != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 10.rw, vertical: 3.rh),
              decoration: BoxDecoration(
                color: AppColors.redSelected6,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                job.employmentType!,
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        SizedBox(height: 8.rh),
        Text(
          job.names.display(language),
          style: AppTextStyles.authTitle.copyWith(color: AppColors.ink),
        ),
        SizedBox(height: 6.rh),
        Text(
          [
            if (job.branchName != null) job.branchName!,
            if (job.experienceRange.isNotEmpty)
              '${job.experienceRange} ${LocaleKeys.careers_years.tr()}',
            if (days != null) postedAgo(days),
          ].join('  |  '),
          style: AppTextStyles.cardSubtitle
              .copyWith(color: AppColors.inkSecondary),
        ),
        if ((job.summary ?? '').isNotEmpty) ...[
          SizedBox(height: 10.rh),
          Text(
            job.summary!,
            style: AppTextStyles.cardSubtitle
                .copyWith(color: AppColors.inkSecondary),
          ),
        ],
        // shown only when the post carries a job-description file
        if ((detail.descriptionUrl ?? '').isNotEmpty) ...[
          SizedBox(height: 14.rh),
          OutlinedButton.icon(
            onPressed: () => openUrl(detail.descriptionUrl!),
            icon: const Icon(Icons.download_outlined),
            label: Text(LocaleKeys.careers_download_jd.tr()),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(46.rh),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ],
        SizedBox(height: 16.rh),
        if ((detail.aboutRole ?? '').isNotEmpty) ...[
          InfoCard(
            title: LocaleKeys.careers_about_role.tr(),
            child: Text(
              detail.aboutRole!,
              style: AppTextStyles.cardSubtitle
                  .copyWith(color: AppColors.inkSecondary),
            ),
          ),
          SizedBox(height: 12.rh),
        ],
        bullets(LocaleKeys.careers_responsibilities.tr(),
            detail.responsibilities),
        bullets(LocaleKeys.careers_requirements.tr(), detail.requirements),
        bullets(LocaleKeys.careers_offers.tr(), detail.offers),
        bullets(LocaleKeys.careers_benefits.tr(), detail.benefits),
        InfoCard(
          title: LocaleKeys.careers_overview.tr(),
          child: Column(
            children: [
              _Row(LocaleKeys.careers_job_title.tr(),
                  job.names.display(language)),
              if (job.department != null)
                _Row(LocaleKeys.careers_department.tr(), job.department!),
              if (job.employmentType != null)
                _Row(LocaleKeys.careers_type.tr(), job.employmentType!),
              if (job.experienceRange.isNotEmpty)
                _Row(LocaleKeys.careers_experience_label.tr(),
                    '${job.experienceRange} ${LocaleKeys.careers_years.tr()}'),
              if (job.branchName != null)
                _Row(LocaleKeys.careers_location_label.tr(), job.branchName!),
              if (days != null)
                _Row(LocaleKeys.careers_posted_label.tr(), postedAgo(days)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 8.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.cardSubtitle
                  .copyWith(color: AppColors.inkSecondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.rowTitle.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
