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
import 'service_detail_vm.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.args});

  final IdArgsModel args;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<ServiceDetailVm>.reactive(
      viewModelBuilder: () => ServiceDetailVm(args.id),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) {
        final service = vm.service;
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            title: Text(
              LocaleKeys.service_detail_title.tr(),
              style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
            ),
          ),
          body: vm.isBusy
              ? const AppShimmerList(itemCount: 4)
              : vm.hasFailure || service == null
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
                            service.names.display(language),
                            style: AppTextStyles.h2
                                .copyWith(color: colors.textPrimary),
                          ),
                          SizedBox(height: 10.rh),
                          if (service.price != null)
                            Text(
                              '${LocaleKeys.service_detail_price.tr()}: '
                              '${service.price!.toStringAsFixed(2)} '
                              '${LocaleKeys.common_currency.tr()}',
                              style: AppTextStyles.bodySemiBold
                                  .copyWith(color: colors.primary),
                            ),
                          if (service.durationMinutes != null &&
                              service.durationMinutes! > 0) ...[
                            SizedBox(height: 4.rh),
                            Text(
                              '${LocaleKeys.service_detail_duration.tr()}: '
                              '${service.durationMinutes} '
                              '${LocaleKeys.common_mins.tr()}',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ],
                          SizedBox(height: 22.rh),
                          Text(
                            LocaleKeys.service_detail_sub_services.tr(),
                            style: AppTextStyles.h3
                                .copyWith(color: colors.textPrimary),
                          ),
                          SizedBox(height: 8.rh),
                          if (vm.subServices.isEmpty)
                            Text(
                              LocaleKeys.service_detail_no_services.tr(),
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: colors.textSecondary),
                            )
                          else
                            ...vm.subServices.map(
                              (sub) => Padding(
                                padding:
                                    EdgeInsetsDirectional.only(bottom: 8.rh),
                                child: Text(
                                  sub.names.display(language),
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: colors.textPrimary),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
