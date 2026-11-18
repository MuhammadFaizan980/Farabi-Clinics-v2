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
import 'specialities_vm.dart';

class SpecialitiesScreen extends StatelessWidget {
  const SpecialitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<SpecialitiesVm>.reactive(
      viewModelBuilder: SpecialitiesVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.specialities_title.tr(),
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: vm.isBusy
              ? const AppShimmerList(itemCount: 8)
              : vm.hasFailure
                  ? AppErrorView(
                      message: LocaleKeys.errors_unexpected.tr(),
                      retryLabel: LocaleKeys.common_retry.tr(),
                      onRetry: vm.load,
                    )
                  : vm.isEmpty
                      ? AppEmptyView(
                          title:
                              LocaleKeys.specialities_no_specialities.tr(),
                        )
                      : RefreshIndicator(
                          onRefresh: vm.refresh,
                          child: GridView.builder(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 20.rw,
                              vertical: 12.rh,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12.rh,
                              crossAxisSpacing: 12.rw,
                              childAspectRatio: 1.35,
                            ),
                            itemCount: vm.specialities.length,
                            itemBuilder: (context, index) {
                              final item = vm.specialities[index];
                              return InkWell(
                                onTap: () => AppNavigator.push(
                                  AppRoutes.serviceDetail,
                                  arguments: IdArgsModel(id: item.id),
                                ),
                                child: Container(
                                padding: EdgeInsetsDirectional.all(12.r),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 36.r,
                                      height: 36.r,
                                      decoration: BoxDecoration(
                                        color: colors.primarySoft,
                                        borderRadius: AppBorderRadius.sm,
                                      ),
                                      child: Icon(
                                        Icons.medical_services_outlined,
                                        size: 18.r,
                                        color: colors.primary,
                                      ),
                                    ),
                                    Text(
                                      item.names.display(language),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySemiBold
                                          .copyWith(
                                              color: colors.textPrimary),
                                    ),
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
