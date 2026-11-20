import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../data/constants/locale_keys.g.dart';
import '../../../data/models/discovery/detail_args_models.dart';
import '../../../router/app_navigator.dart';
import '../../../router/app_routes.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/color/app_colors.dart';
import '../../../utils/extensions/responsive_extensions.dart';
import '../../../utils/extensions/vm_init_extension.dart';
import '../../../widgets/branches/branches_header.dart';
import '../../../widgets/common/app_state_views.dart';
import '../../../widgets/specialities/specialities_widgets.dart';
import 'specialities_vm.dart';

/// the site's mobile specialities page: region tabs in the red header, a
/// "Choose Speciality" tile card, then (once a speciality is picked) its
/// services with their doctors. reached from the Home search, the Home service
/// tiles, the virtual-clinic cards, the AI button and More.
class SpecialitiesScreen extends StatelessWidget {
  const SpecialitiesScreen({super.key, this.initialMainServiceId});

  final int? initialMainServiceId;

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<SpecialitiesVm>.reactive(
      viewModelBuilder: () =>
          SpecialitiesVm(initialMainServiceId: initialMainServiceId),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Column(
          children: [
            BranchesHeader(
              title: LocaleKeys.specialities_choose_title.tr(),
              onBack: () => Navigator.of(context).maybePop(),
              tabs: [
                for (final region in vm.regions)
                  BranchesTab(
                    label: region.names.display(language),
                    selected: vm.regionId == region.id,
                    onTap: () => vm.selectRegion(region.id),
                  ),
              ],
            ),
            Expanded(child: _Body(vm: vm, language: language)),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.vm, required this.language});

  final SpecialitiesVm vm;
  final String language;

  @override
  Widget build(BuildContext context) {
    if (vm.hasFailure) {
      return AppErrorView(
        message: LocaleKeys.errors_unexpected.tr(),
        retryLabel: LocaleKeys.common_retry.tr(),
        onRetry: vm.onInit,
      );
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(16.rw, 16.rh, 16.rw, 32.rh),
        children: [
          SpecialityPicker(
            title: LocaleKeys.specialities_choose_speciality.tr(),
            services: vm.mainServices,
            selectedId: vm.mainServiceId,
            language: language,
            onSelected: (service) => vm.selectMainService(service.id),
          ),
          SizedBox(height: 16.rh),
          if (!vm.hasSelection)
            Padding(
              padding: EdgeInsetsDirectional.only(top: 24.rh),
              child: Text(
                LocaleKeys.specialities_select_hint.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.cardSubtitle
                    .copyWith(color: AppColors.inkSecondary),
              ),
            )
          else if (vm.isBusy)
            const SizedBox(height: 360, child: AppShimmerList(itemCount: 3))
          else if (vm.isEmpty)
            AppEmptyView(title: LocaleKeys.specialities_no_services.tr())
          else
            for (final entry in vm.services) ...[
              SpecialityServiceCard(
                entry: entry,
                language: language,
                onDoctorTap: (doctor) => AppNavigator.push(
                  AppRoutes.doctorDetail,
                  arguments: IdArgsModel(id: doctor.id),
                ),
              ),
              SizedBox(height: 12.rh),
            ],
        ],
      ),
    );
  }
}
