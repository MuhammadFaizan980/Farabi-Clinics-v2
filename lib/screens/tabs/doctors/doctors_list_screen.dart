import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../../data/constants/app_assets.dart';
import '../../../data/constants/locale_keys.g.dart';
import '../../../data/models/discovery/detail_args_models.dart';
import '../../../router/app_navigator.dart';
import '../../../router/app_routes.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/color/app_colors.dart';
import '../../../utils/extensions/responsive_extensions.dart';
import '../../../utils/extensions/vm_init_extension.dart';
import '../../../widgets/common/app_state_views.dart';
import '../../../widgets/discovery/doctor_card.dart';
import '../../../widgets/doctors/doctors_header.dart';
import 'doctors_list_vm.dart';

class DoctorsListScreen extends StatelessWidget {
  const DoctorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<DoctorsListVm>.reactive(
      viewModelBuilder: DoctorsListVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Stack(
          children: [
            Column(
              children: [
                DoctorsHeader(
                  title: LocaleKeys.doctors_available_title.tr(),
                  searchHint: LocaleKeys.doctors_find_hint.tr(),
                  searchController: vm.searchController,
                  onSearchSubmitted: vm.onSearchSubmitted,
                  regionLabel: vm.selectedRegion?.names.display(language) ??
                      LocaleKeys.doctors_all_regions.tr(),
                  regions: vm.regions,
                  language: language,
                  onRegionSelected: vm.setRegion,
                  chips: [
                    DoctorsFilterChip(
                      label: LocaleKeys.doctors_all.tr(),
                      selected: vm.serviceId == null,
                      onTap: () => vm.setService(null),
                    ),
                    for (final service in vm.services)
                      DoctorsFilterChip(
                        label: service.names.display(language),
                        selected: vm.serviceId == service.id,
                        onTap: () => vm.setService(service.id),
                      ),
                  ],
                ),
                Expanded(child: _Body(vm: vm, language: language)),
              ],
            ),
            PositionedDirectional(
              end: 20.rw,
              bottom: 41.rh,
              child: _FilterButton(onTap: () => _openFilters(context, vm)),
            ),
          ],
        ),
      ),
    );
  }

  /// the only filter the api and view model support beyond region, search and
  /// speciality is gender, so that is what the sheet offers for now.
  void _openFilters(BuildContext context, DoctorsListVm vm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.rw, 0, 24.rw, 24.rh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.doctors_gender.tr(),
                style:
                    AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: 12.rh),
              Wrap(
                spacing: 8.rw,
                children: [
                  _GenderOption(
                    label: LocaleKeys.doctors_all.tr(),
                    selected: vm.gender == null,
                    onTap: () {
                      vm.setGender(null);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  _GenderOption(
                    label: LocaleKeys.doctors_gender_male.tr(),
                    selected: vm.gender == 'Male',
                    onTap: () {
                      vm.setGender('Male');
                      Navigator.pop(sheetContext);
                    },
                  ),
                  _GenderOption(
                    label: LocaleKeys.doctors_gender_female.tr(),
                    selected: vm.gender == 'Female',
                    onTap: () {
                      vm.setGender('Female');
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64.rw,
        height: 64.rw,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.redRing8, width: 1.5),
        ),
        child: SvgPicture.asset(
          AppAssets.iconFilter,
          width: 24.rw,
          height: 24.rw,
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.rh,
        alignment: Alignment.center,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20.rw),
        decoration: BoxDecoration(
          color: selected ? AppColors.redSelected6 : AppColors.white,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.hairline8,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.filterChip.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.vm, required this.language});

  final DoctorsListVm vm;
  final String language;

  @override
  Widget build(BuildContext context) {
    if (vm.isBusy) return const AppShimmerList();

    if (vm.hasFailure) {
      return AppErrorView(
        message: _localisedError(vm.errorMessage!),
        retryLabel: LocaleKeys.common_retry.tr(),
        onRetry: vm.load,
      );
    }

    if (vm.isEmpty) {
      return RefreshIndicator(
        onRefresh: vm.refresh,
        child: ListView(
          children: [
            SizedBox(height: 80.rh),
            AppEmptyView(
              title: LocaleKeys.doctors_no_doctors.tr(),
              subtitle: LocaleKeys.common_empty_subtitle.tr(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.fromSTEB(24.rw, 12.rh, 24.rw, 120.rh),
        itemCount: vm.doctors.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: 16.rh),
        itemBuilder: (context, index) {
          if (index == vm.doctors.length) return _Footer(vm: vm);
          final doctor = vm.doctors[index];
          return GestureDetector(
            onTap: () => AppNavigator.push(
              AppRoutes.doctorDetail,
              arguments: IdArgsModel(id: doctor.id),
            ),
            child: DoctorCard(doctor: doctor, language: language),
          );
        },
      ),
    );
  }

  /// the api client hands back a key for transport failures and a server string
  /// for everything else; both have to end up localised.
  String _localisedError(String raw) {
    const keys = {
      'timeout': LocaleKeys.errors_timeout,
      'no_connection': LocaleKeys.errors_no_connection,
      'unexpected': LocaleKeys.errors_unexpected,
    };
    final key = keys[raw];
    return key == null ? raw : key.tr();
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.vm});

  final DoctorsListVm vm;

  @override
  Widget build(BuildContext context) {
    if (vm.loadMoreFailed) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 16.rh),
        child: Center(
          child: TextButton(
            onPressed: vm.loadMore,
            child: Text(
              LocaleKeys.doctors_load_more_failed.tr(),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ),
      );
    }

    if (vm.isLoadingMore) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 16.rh),
        child: Center(
          child: SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(strokeWidth: 2.r),
          ),
        ),
      );
    }

    if (vm.hasMore) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 16.rh),
        child: Center(
          child: TextButton(
            onPressed: vm.loadMore,
            child: Text(
              LocaleKeys.common_continue_label.tr(),
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 16.rh),
      child: Center(
        child: Text(
          LocaleKeys.doctors_end_of_list.tr(),
          style: AppTextStyles.caption.copyWith(color: AppColors.greyLight),
        ),
      ),
    );
  }
}
