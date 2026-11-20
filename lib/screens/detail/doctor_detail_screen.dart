import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/discovery/detail_args_models.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../utils/working_hours.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/doctor/doctor_profile_card.dart';
import '../../widgets/more/more_header.dart';
import 'doctor_detail_vm.dart';

/// the site's doctor profile: red header with the doctor's name, avatar card,
/// stats, overview, services offered, working hours, branches with their own
/// hours, and a fixed Book bar. everything but the labels comes from the doctor
/// and services endpoints.
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.args});

  final IdArgsModel args;

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;
    final locale = context.locale.toString();

    return ViewModelBuilder<DoctorDetailVm>.reactive(
      viewModelBuilder: () => DoctorDetailVm(args.id),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) {
        final doctor = vm.doctor;
        return Scaffold(
          backgroundColor: AppColors.listBackground,
          body: Column(
            children: [
              MoreHeader(
                title: LocaleKeys.doctor_detail_title.tr(),
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: vm.isBusy
                    ? const AppShimmerList(itemCount: 4)
                    : vm.hasFailure || doctor == null
                    ? AppErrorView(
                        message: LocaleKeys.errors_unexpected.tr(),
                        retryLabel: LocaleKeys.common_retry.tr(),
                        onRetry: vm.load,
                      )
                    : RefreshIndicator(
                        onRefresh: vm.refresh,
                        child: _Content(
                          vm: vm,
                          doctor: doctor,
                          language: language,
                          locale: locale,
                        ),
                      ),
              ),
              if (doctor != null)
                BottomActionBar(
                  label: LocaleKeys.doctor_detail_book.tr(),
                  onPressed: vm.bookAppointment,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.vm,
    required this.doctor,
    required this.language,
    required this.locale,
  });

  final DoctorDetailVm vm;
  final DoctorDataModel doctor;
  final String language;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final name = doctor.names.display(language);
    final summary = (doctor.briefSummary ?? '').trim();
    final to = LocaleKeys.common_to.tr();

    // working hours of the doctor: the first branch that has any, which is
    // what the site's single "Working Hours" card stands for
    final hoursSource = doctor.branches.firstWhere(
      (b) => b.workingHours.isNotEmpty,
      orElse: () => const DoctorBranchDataModel(id: 0),
    );
    final hours = summarizeWorkingHours(
      hoursSource.workingHours,
      locale: locale,
      to: to,
    );

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 8.rh, 16.rw, 16.rh),
      children: [
        DoctorProfileCard(doctor: doctor, name: name),
        SizedBox(height: 4.rh),
        _StatsCard(doctor: doctor),
        SizedBox(height: 4.rh),
        InfoCard(
          title: LocaleKeys.doctor_detail_overview.tr(),
          child: Text(
            summary.isNotEmpty
                ? summary
                : LocaleKeys.doctor_detail_overview_fallback.tr(args: [name]),
            style: AppTextStyles.overviewBody.copyWith(color: AppColors.ink),
          ),
        ),
        if (vm.services.isNotEmpty) ...[
          SizedBox(height: 4.rh),
          InfoCard(
            title: LocaleKeys.doctor_detail_services_offered.tr(),
            child: Wrap(
              spacing: 8.rw,
              runSpacing: 8.rh,
              children: [
                for (final service in vm.services)
                  _Chip(label: service.names.display(language)),
              ],
            ),
          ),
        ],
        if (hours.isNotEmpty) ...[
          SizedBox(height: 4.rh),
          InfoCard(
            title: LocaleKeys.doctor_detail_working_hours.tr(),
            child: _HoursLines(lines: hours),
          ),
        ],
        if (doctor.branches.isNotEmpty) ...[
          SizedBox(height: 4.rh),
          InfoCard(
            title: LocaleKeys.doctor_detail_branches_hours.tr(),
            child: SizedBox(
              height: 168.rh,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: doctor.branches.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.rw),
                itemBuilder: (context, i) => _BranchCard(
                  branch: doctor.branches[i],
                  language: language,
                  locale: locale,
                  to: to,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.doctor});

  final DoctorDataModel doctor;

  @override
  Widget build(BuildContext context) {
    const dash = '—';
    final patients = doctor.patientsCount?.toString() ?? dash;
    final years = doctor.experienceYears == null
        ? dash
        : LocaleKeys.doctor_detail_experience_value.tr(
            args: ['${doctor.experienceYears}'],
          );
    final satisfaction = doctor.satisfactionPercentage == null
        ? dash
        : '${doctor.satisfactionPercentage!.round()}%';

    return InfoCard(
      padding: EdgeInsetsDirectional.symmetric(vertical: 13.rh),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Stat(
              iconAsset: AppAssets.iconStatPatients,
              value: patients,
              label: LocaleKeys.doctor_detail_patients.tr(),
            ),
            const _StatDivider(),
            _Stat(
              iconAsset: AppAssets.iconStatExperience,
              value: years,
              label: LocaleKeys.doctor_detail_experience.tr(),
            ),
            const _StatDivider(),
            _Stat(
              iconAsset: AppAssets.iconStatSatisfaction,
              value: satisfaction,
              label: LocaleKeys.doctor_detail_satisfaction.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 x 16 hairline between the stats, #282828 at 32%
class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.55),
      child: Container(width: 1, height: 16.rh, color: const Color(0x52282828)),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.iconAsset,
    required this.value,
    required this.label,
  });

  final String iconAsset;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconAsset, width: 18.rw, height: 18.rw),
              SizedBox(width: 6.rw),
              Text(
                value,
                style: AppTextStyles.statNumber.copyWith(
                  color: AppColors.ink,
                  fontSize: 18.rf,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: AppTextStyles.statLabel.copyWith(
              color: AppColors.inkSecondary,
              fontWeight: FontWeight.w400,
            ),
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
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 14.rw,
        vertical: 8.rh,
      ),
      decoration: BoxDecoration(
        color: AppColors.listBackground,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        label,
        style: AppTextStyles.profileBody.copyWith(color: AppColors.ink),
      ),
    );
  }
}

class _HoursLines extends StatelessWidget {
  const _HoursLines({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: 2.rh),
            child: Text(
              line,
              style: AppTextStyles.profileBody.copyWith(color: AppColors.ink),
            ),
          ),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.language,
    required this.locale,
    required this.to,
  });

  final DoctorBranchDataModel branch;
  final String language;
  final String locale;
  final String to;

  @override
  Widget build(BuildContext context) {
    final hours = summarizeWorkingHours(
      branch.workingHours,
      locale: locale,
      to: to,
    );

    return GestureDetector(
      onTap: () => AppNavigator.push(
        AppRoutes.branchDetail,
        arguments: IdArgsModel(id: branch.id),
      ),
      child: Container(
        width: 200.rw,
        padding: EdgeInsetsDirectional.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.listBackground,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              branch.displayName(language),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.rowTitle.copyWith(color: AppColors.ink),
            ),
            if ((branch.address ?? '').isNotEmpty) ...[
              SizedBox(height: 6.rh),
              Text(
                branch.address!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
            ],
            const Spacer(),
            for (final line in hours.take(2))
              Padding(
                padding: EdgeInsetsDirectional.only(top: 4.rh),
                child: Text(
                  line,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: AppColors.ink),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
