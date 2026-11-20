import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../data/constants/locale_keys.g.dart';
import '../../../data/models/discovery/detail_args_models.dart';
import '../../../router/app_navigator.dart';
import '../../../router/app_routes.dart';
import '../../../utils/color/app_colors.dart';
import '../../../utils/extensions/responsive_extensions.dart';
import '../../../utils/launcher.dart';
import '../../../utils/extensions/vm_init_extension.dart';
import '../../../widgets/branches/branch_card.dart';
import '../../../widgets/branches/branches_header.dart';
import '../../../widgets/common/app_state_views.dart';
import 'branches_list_vm.dart';

class BranchesListScreen extends StatelessWidget {
  const BranchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<BranchesListVm>.reactive(
      viewModelBuilder: BranchesListVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Column(
          children: [
            BranchesHeader(
              title: LocaleKeys.branches_title.tr(),
              tabs: [
                for (final region in vm.regions)
                  BranchesTab(
                    label: region.names.display(language),
                    selected: vm.regionId == region.id,
                    onTap: () => vm.setRegion(region.id),
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

  final BranchesListVm vm;
  final String language;

  @override
  Widget build(BuildContext context) {
    if (vm.isBusy) return const AppShimmerList();

    if (vm.hasFailure) {
      return AppErrorView(
        message: LocaleKeys.errors_unexpected.tr(),
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
            AppEmptyView(title: LocaleKeys.branches_no_branches.tr()),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.fromSTEB(16.rw, 8.rh, 16.rw, 24.rh),
        itemCount: vm.branches.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.rh),
        itemBuilder: (context, index) {
          final branch = vm.branches[index];
          return BranchCard(
            branch: branch,
            language: language,
            addressFallback: LocaleKeys.branches_address_unavailable.tr(),
            callLabel: LocaleKeys.branches_call.tr(),
            onTap: () => AppNavigator.push(
              AppRoutes.branchDetail,
              arguments: IdArgsModel(id: branch.id),
            ),
            onCall: () => dial(branch.phone ?? ''),
          );
        },
      ),
    );
  }
}
