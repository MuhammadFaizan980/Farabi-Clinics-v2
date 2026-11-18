import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../data/constants/app_border_radius.dart';
import '../../../data/constants/locale_keys.g.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/color/app_theme_colors.dart';
import '../../../utils/extensions/responsive_extensions.dart';
import '../../../utils/extensions/vm_init_extension.dart';
import '../../../widgets/common/app_state_views.dart';
import 'home_vm.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<HomeVm>.reactive(
      viewModelBuilder: HomeVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: vm.isBusy
              ? const AppShimmerList()
              : vm.hasFailure
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
                            '${LocaleKeys.home_greeting.tr()}, '
                            '${vm.patientFirstName ?? LocaleKeys.home_guest.tr()}',
                            style: AppTextStyles.h2
                                .copyWith(color: colors.textPrimary),
                          ),
                          SizedBox(height: 18.rh),
                          _SectionTitle(
                            title: LocaleKeys.home_specialities.tr(),
                          ),
                          SizedBox(height: 10.rh),
                          if (vm.specialities.isEmpty)
                            _InlineEmpty(
                              label:
                                  LocaleKeys.specialities_no_specialities.tr(),
                            )
                          else
                            SizedBox(
                              height: 96.rh,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: vm.specialities.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: 10.rw),
                                itemBuilder: (context, index) => Container(
                                  width: 120.rw,
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
                                      Icon(
                                        Icons.medical_services_outlined,
                                        size: 20.r,
                                        color: colors.primary,
                                      ),
                                      Text(
                                        vm.specialities[index].names
                                            .display(language),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.caption.copyWith(
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 22.rh),
                          _SectionTitle(title: LocaleKeys.home_branches.tr()),
                          SizedBox(height: 10.rh),
                          if (vm.regions.isEmpty)
                            _InlineEmpty(
                              label: LocaleKeys.branches_no_branches.tr(),
                            )
                          else
                            ...vm.regions.map(
                              (region) => Padding(
                                padding:
                                    EdgeInsetsDirectional.only(bottom: 10.rh),
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
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_city_outlined,
                                        size: 18.r,
                                        color: colors.primary,
                                      ),
                                      SizedBox(width: 10.rw),
                                      Expanded(
                                        child: Text(
                                          region.names.display(language),
                                          style: AppTextStyles.bodySemiBold
                                              .copyWith(
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${region.branchesCount}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.symmetric(vertical: 18.rh),
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: AppBorderRadius.md,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
