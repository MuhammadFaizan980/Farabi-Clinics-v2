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
import 'offers_vm.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<OffersVm>.reactive(
      viewModelBuilder: OffersVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.offers_title.tr(),
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
                      // the dev dataset has no offers, so this is the state
                      // that actually ships today
                      ? AppEmptyView(
                          title: LocaleKeys.offers_no_offers.tr(),
                          subtitle: LocaleKeys.offers_subtitle.tr(),
                        )
                      : RefreshIndicator(
                          onRefresh: vm.refresh,
                          child: ListView.separated(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 20.rw,
                              vertical: 12.rh,
                            ),
                            itemCount: vm.offers.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 12.rh),
                            itemBuilder: (context, index) {
                              final offer = vm.offers[index];
                              return Container(
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
                                      offer.names.display(language),
                                      style: AppTextStyles.bodySemiBold
                                          .copyWith(
                                              color: colors.textPrimary),
                                    ),
                                    if (offer.description != null) ...[
                                      SizedBox(height: 6.rh),
                                      Text(
                                        offer.description!,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
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
