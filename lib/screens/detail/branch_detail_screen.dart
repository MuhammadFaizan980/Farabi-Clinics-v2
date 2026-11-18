import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/discovery/detail_args_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_state_views.dart';
import 'branch_detail_vm.dart';

class BranchDetailScreen extends StatelessWidget {
  const BranchDetailScreen({super.key, required this.args});

  final IdArgsModel args;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<BranchDetailVm>.reactive(
      viewModelBuilder: () => BranchDetailVm(args.id),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) {
        final branch = vm.branch;
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            title: Text(
              LocaleKeys.branch_detail_title.tr(),
              style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
            ),
          ),
          body: vm.isBusy
              ? const AppShimmerList(itemCount: 4)
              : vm.hasFailure || branch == null
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
                            branch.names.display(language),
                            style: AppTextStyles.h2
                                .copyWith(color: colors.textPrimary),
                          ),
                          SizedBox(height: 6.rh),
                          Text(
                            branch.address ??
                                LocaleKeys.branch_detail_unavailable.tr(),
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: colors.textSecondary),
                          ),
                          SizedBox(height: 16.rh),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  // disabled rather than hidden, so the
                                  // affordance stays predictable
                                  onPressed: vm.canCall ? () {} : null,
                                  icon: Icon(Icons.call, size: 16.r),
                                  label: Text(
                                    LocaleKeys.branch_detail_call.tr(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.rw),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: vm.canOpenMap ? () {} : null,
                                  icon: Icon(Icons.map_outlined, size: 16.r),
                                  label: Text(
                                    LocaleKeys.branch_detail_directions.tr(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (branch.region != null) ...[
                            SizedBox(height: 18.rh),
                            Text(
                              branch.region!.names.display(language),
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
