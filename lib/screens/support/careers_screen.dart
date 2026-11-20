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
import '../../utils/posted_ago.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/more/more_header.dart';
import '../../widgets/sheet/app_sheet.dart';
import 'careers_vm.dart';

/// jobs list: department dropdown and search both query the api, each card
/// opens the job's detail page.
class CareersScreen extends StatelessWidget {
  const CareersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<CareersVm>.reactive(
      viewModelBuilder: CareersVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Column(
          children: [
            MoreHeader(
              title: LocaleKeys.careers_list_title.tr(),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: vm.refresh,
                child: ListView(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    16.rw,
                    16.rh,
                    16.rw,
                    24.rh,
                  ),
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '${LocaleKeys.careers_heading_a.tr()} ',
                        children: [
                          TextSpan(
                            text: LocaleKeys.careers_heading_b.tr(),
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                      style: AppTextStyles.authTitle.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 8.rh),
                    Text(
                      LocaleKeys.careers_intro.tr(),
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    SizedBox(height: 16.rh),
                    AppSelectBox(
                      text:
                          vm.department ??
                          LocaleKeys.careers_all_departments.tr(),
                      onTap: () async {
                        final pick = await showSelectSheet<String?>(
                          context,
                          title: LocaleKeys.careers_department.tr(),
                          selected: vm.department,
                          options: [
                            SheetOption<String?>(
                              value: null,
                              label: LocaleKeys.careers_all_departments.tr(),
                            ),
                            for (final dept in vm.departments)
                              SheetOption<String?>(value: dept, label: dept),
                          ],
                        );
                        if (pick != null) vm.setDepartment(pick.value);
                      },
                    ),
                    SizedBox(height: 12.rh),
                    Container(
                      height: 52.rh,
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 16.rw,
                      ),
                      decoration: AppFieldDecoration.box(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 20.rw,
                            color: AppColors.iconGrey,
                          ),
                          SizedBox(width: 10.rw),
                          Expanded(
                            child: TextField(
                              controller: vm.searchController,
                              onChanged: vm.onSearchChanged,
                              textInputAction: TextInputAction.search,
                              style: AppTextStyles.fieldText.copyWith(
                                color: AppColors.ink,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: LocaleKeys.careers_search_hint.tr(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.rh),
                    if (vm.isBusy)
                      const SizedBox(
                        height: 300,
                        child: AppShimmerList(itemCount: 3),
                      )
                    else if (vm.hasFailure)
                      AppErrorView(
                        message: LocaleKeys.errors_unexpected.tr(),
                        retryLabel: LocaleKeys.common_retry.tr(),
                        onRetry: vm.load,
                      )
                    else if (vm.isEmpty)
                      AppEmptyView(title: LocaleKeys.careers_no_jobs.tr())
                    else
                      for (final job in vm.jobs) ...[
                        _JobCard(job: job, language: language),
                        SizedBox(height: 12.rh),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.language});

  final JobDataModel job;
  final String language;

  @override
  Widget build(BuildContext context) {
    final days = job.postedDaysAgo;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.names.display(language),
            style: AppTextStyles.listCardTitle.copyWith(color: AppColors.ink),
          ),
          if (job.employmentType != null) ...[
            SizedBox(height: 6.rh),
            Container(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 10.rw,
                vertical: 3.rh,
              ),
              decoration: BoxDecoration(
                color: AppColors.redSelected6,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                job.employmentType!,
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ],
          if (job.department != null) ...[
            SizedBox(height: 6.rh),
            Text(
              job.department!,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
          if (job.summary != null) ...[
            SizedBox(height: 8.rh),
            Text(
              job.summary!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
          SizedBox(height: 10.rh),
          if (job.branchName != null)
            _Meta(icon: Icons.place_outlined, text: job.branchName!),
          if (job.experienceRange.isNotEmpty)
            _Meta(
              icon: Icons.work_outline,
              text: '${job.experienceRange} ${LocaleKeys.careers_years.tr()}',
            ),
          if (days != null) _Meta(icon: Icons.schedule, text: postedAgo(days)),
          SizedBox(height: 12.rh),
          OutlinedButton(
            onPressed: () => AppNavigator.push(
              AppRoutes.jobDetail,
              arguments: SlugArgsModel(slug: job.slug),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(44.rh),
              side: BorderSide(color: AppColors.hairline8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              LocaleKeys.careers_view_details.tr(),
              style: AppTextStyles.rowTitle.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 4.rh),
      child: Row(
        children: [
          Icon(icon, size: 16.rw, color: AppColors.primary),
          SizedBox(width: 8.rw),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
