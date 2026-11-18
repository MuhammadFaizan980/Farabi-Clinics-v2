import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../data/constants/locale_keys.g.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/color/app_theme_colors.dart';
import '../../../utils/extensions/responsive_extensions.dart';
import '../../../utils/extensions/vm_init_extension.dart';
import '../../../widgets/common/app_state_views.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../data/models/discovery/detail_args_models.dart';
import '../../../router/app_navigator.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/discovery/doctor_card.dart';
import 'doctors_list_vm.dart';

class DoctorsListScreen extends StatelessWidget {
  const DoctorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final language = context.locale.languageCode;

    return ViewModelBuilder<DoctorsListVm>.reactive(
      viewModelBuilder: DoctorsListVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            LocaleKeys.doctors_title.tr(),
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 20.rw,
                  vertical: 8.rh,
                ),
                child: AppTextField(
                  controller: vm.searchController,
                  label: LocaleKeys.doctors_search_hint.tr(),
                  hint: LocaleKeys.doctors_search_hint.tr(),
                  onChanged: (_) {},
                  textInputAction: TextInputAction.search,
                ),
              ),
              Expanded(child: _Body(vm: vm, language: language)),
            ],
          ),
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
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 20.rw,
          vertical: 12.rh,
        ),
        itemCount: vm.doctors.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: 12.rh),
        itemBuilder: (context, index) {
          if (index == vm.doctors.length) return _Footer(vm: vm);
          final doctor = vm.doctors[index];
          return InkWell(
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
    final colors = AppThemeColors.of(context);

    if (vm.loadMoreFailed) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 16.rh),
        child: Center(
          child: TextButton(
            onPressed: vm.loadMore,
            child: Text(
              LocaleKeys.doctors_load_more_failed.tr(),
              style: AppTextStyles.bodyMedium.copyWith(color: colors.error),
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
              style: AppTextStyles.bodyMedium.copyWith(color: colors.primary),
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
          style: AppTextStyles.caption.copyWith(color: colors.textMuted),
        ),
      ),
    );
  }
}
