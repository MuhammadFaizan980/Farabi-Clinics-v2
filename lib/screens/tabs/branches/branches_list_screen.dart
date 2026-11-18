import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../data/constants/app_border_radius.dart';
import '../../../data/constants/locale_keys.g.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/color/app_theme_colors.dart';
import '../../../utils/extensions/responsive_extensions.dart';
import '../../../utils/extensions/vm_init_extension.dart';
import '../../../data/models/discovery/detail_args_models.dart';
import '../../../router/app_navigator.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/common/app_state_views.dart';
import 'branches_list_vm.dart';

class BranchesListScreen extends StatelessWidget {
  const BranchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<BranchesListVm>.reactive(
      viewModelBuilder: BranchesListVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.branches_title.tr(),
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
                  : vm.isEmpty
                      ? AppEmptyView(
                          title: LocaleKeys.branches_no_branches.tr(),
                        )
                      : RefreshIndicator(
                          onRefresh: vm.refresh,
                          child: ListView.separated(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 20.rw,
                              vertical: 12.rh,
                            ),
                            itemCount: vm.branches.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 12.rh),
                            itemBuilder: (context, index) {
                              final branch = vm.branches[index];
                              return InkWell(
                                onTap: () => AppNavigator.push(
                                  AppRoutes.branchDetail,
                                  arguments: IdArgsModel(id: branch.id),
                                ),
                                child: Container(
                                padding: EdgeInsetsDirectional.all(14.r),
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
                                      branch.names.display(language),
                                      style: AppTextStyles.bodySemiBold
                                          .copyWith(
                                              color: colors.textPrimary),
                                    ),
                                    SizedBox(height: 4.rh),
                                    Text(
                                      branch.address ??
                                          LocaleKeys
                                              .branches_address_unavailable
                                              .tr(),
                                      style: AppTextStyles.caption.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    if (branch.region != null) ...[
                                      SizedBox(height: 6.rh),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.map_outlined,
                                            size: 13.r,
                                            color: colors.textMuted,
                                          ),
                                          SizedBox(width: 4.rw),
                                          Text(
                                            branch.region!.names
                                                .display(language),
                                            style: AppTextStyles.caption
                                                .copyWith(
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ),
    );
  }
}
