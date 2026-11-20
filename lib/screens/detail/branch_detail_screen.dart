import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/discovery/detail_args_models.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_state_views.dart';
import '../../utils/launcher.dart';
import '../../widgets/branches/branch_card.dart';
import '../../widgets/specialities/specialities_widgets.dart';
import '../tabs/specialities/specialities_vm.dart' show ServiceWithDoctors;
import '../../widgets/more/more_header.dart';
import 'branch_detail_vm.dart';

/// the site's branch page: red header with the branch name, an image card
/// (rating only when the api has one, name, address), a "Choose Speciality"
/// rail of the branch's services, then one section per service with its
/// doctors or the "No Doctor Available" state. all of it is branch, service
/// and doctor data from the api.
class BranchDetailScreen extends StatelessWidget {
  const BranchDetailScreen({super.key, required this.args});

  final IdArgsModel args;

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<BranchDetailVm>.reactive(
      viewModelBuilder: () => BranchDetailVm(args.id),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) {
        final branch = vm.branch;
        return Scaffold(
          backgroundColor: AppColors.listBackground,
          body: Column(
            children: [
              MoreHeader(
                title:
                    branch?.names.display(language) ??
                    LocaleKeys.branch_detail_title.tr(),
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: vm.isBusy
                    ? const AppShimmerList(itemCount: 3)
                    : vm.hasFailure || branch == null
                    ? AppErrorView(
                        message: LocaleKeys.errors_unexpected.tr(),
                        retryLabel: LocaleKeys.common_retry.tr(),
                        onRetry: vm.load,
                      )
                    : RefreshIndicator(
                        onRefresh: vm.refresh,
                        child: _Content(
                          vm: vm,
                          branch: branch,
                          language: language,
                        ),
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
  const _Content({
    required this.vm,
    required this.branch,
    required this.language,
  });

  final BranchDetailVm vm;
  final BranchDataModel branch;
  final String language;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 8.rh, 16.rw, 16.rh),
      children: [
        BranchCard(
          branch: branch,
          language: language,
          addressFallback: LocaleKeys.branches_address_unavailable.tr(),
          callLabel: LocaleKeys.branches_call.tr(),
          onTap: () {},
          onCall: () => dial(branch.phone ?? ''),
        ),
        if (branch.services.isNotEmpty) ...[
          SizedBox(height: 4.rh),
          SpecialityPicker(
            title: LocaleKeys.specialities_choose_speciality.tr(),
            services: branch.services,
            selectedId: null,
            language: language,
            onSelected: (_) {},
          ),
          for (final service in branch.services) ...[
            SizedBox(height: 4.rh),
            _ServiceSection(vm: vm, service: service, language: language),
          ],
        ],
      ],
    );
  }
}

/// one service of the branch: the shared specialities card (title, count, rail
/// of doctors) once the doctors have loaded, or the "No Doctor Available" state
class _ServiceSection extends StatelessWidget {
  const _ServiceSection({
    required this.vm,
    required this.service,
    required this.language,
  });

  final BranchDetailVm vm;
  final ServiceDataModel service;
  final String language;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DoctorDataModel>>(
      future: vm.doctorsFor(service.id),
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final doctors = snapshot.data ?? const <DoctorDataModel>[];

        return SpecialityServiceCard(
          entry: ServiceWithDoctors(
            service: service,
            doctors: doctors,
            doctorCount: doctors.length,
          ),
          language: language,
          loading: loading,
          emptyChild: loading ? null : const _NoDoctors(),
          onDoctorTap: (doctor) => AppNavigator.push(
            AppRoutes.doctorDetail,
            arguments: IdArgsModel(id: doctor.id),
          ),
        );
      },
    );
  }
}

class _NoDoctors extends StatelessWidget {
  const _NoDoctors();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 64.rw,
            height: 64.rw,
            decoration: const BoxDecoration(
              color: AppColors.listBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_off_outlined,
              size: 30.rw,
              color: AppColors.iconGrey,
            ),
          ),
          SizedBox(height: 10.rh),
          Text(
            LocaleKeys.branches_no_doctor_title.tr(),
            style: AppTextStyles.rowTitle.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: 4.rh),
          Text(
            LocaleKeys.branches_no_doctor_body.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
