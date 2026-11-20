import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_assets.dart';
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
import '../../widgets/common/info_card.dart';
import '../../widgets/discovery/doctor_card.dart';
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
                title: branch?.names.display(language) ??
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
    final address = (branch.address ?? '').trim();

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 16.rh, 16.rw, 24.rh),
      children: [
        _BranchCard(branch: branch, language: language, address: address),
        if (branch.services.isNotEmpty) ...[
          SizedBox(height: 12.rh),
          InfoCard(
            title: LocaleKeys.specialities_choose_speciality.tr(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final service in branch.services) ...[
                    _ServiceTile(
                      label: service.names.display(language),
                      imageUrl: service.imageUrl,
                    ),
                    SizedBox(width: 12.rw),
                  ],
                ],
              ),
            ),
          ),
          for (final service in branch.services) ...[
            SizedBox(height: 12.rh),
            _ServiceSection(vm: vm, service: service, language: language),
          ],
        ],
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.language,
    required this.address,
  });

  final BranchDataModel branch;
  final String language;
  final String address;

  @override
  Widget build(BuildContext context) {
    final image = branch.image;
    final placeholder = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE9EA), Color(0xFFFFF7F7)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.apartment_outlined,
          size: 40.rw,
          color: AppColors.primary,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120.rh,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image == null || image.isEmpty)
                  placeholder
                else
                  CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => placeholder,
                  ),
                // a rating is shown only when the api has one (the site
                // prints a fixed 4.8 on every branch; that is not copied)
                if (branch.ratingCount > 0)
                  PositionedDirectional(
                    top: 8.rh,
                    end: 8.rw,
                    child: Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 8.rw,
                        vertical: 4.rh,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14.rw,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 4.rw),
                          Text(
                            branch.ratingAverage.toStringAsFixed(1),
                            style: AppTextStyles.rating
                                .copyWith(color: AppColors.ink),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.names.display(language),
                  style: AppTextStyles.listCardTitle
                      .copyWith(color: AppColors.ink),
                ),
                SizedBox(height: 6.rh),
                Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.iconLocationPin,
                      width: 18.rw,
                      height: 18.rw,
                    ),
                    SizedBox(width: 6.rw),
                    Expanded(
                      child: Text(
                        address.isEmpty
                            ? LocaleKeys.branches_address_unavailable.tr()
                            : address,
                        style: AppTextStyles.branchAddress
                            .copyWith(color: AppColors.inkSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.label, this.imageUrl});

  final String label;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.medical_services_outlined,
      size: 26.rw,
      color: AppColors.primary,
    );
    return SizedBox(
      width: 68.rw,
      child: Column(
        children: [
          Container(
            width: 56.rw,
            height: 56.rw,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.listBackground,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? fallback
                : CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: 32.rw,
                    height: 32.rw,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => fallback,
                  ),
          ),
          SizedBox(height: 6.rh),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

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
    return InfoCard(
      child: FutureBuilder<List<DoctorDataModel>>(
        future: vm.doctorsFor(service.id),
        builder: (context, snapshot) {
          final loading = snapshot.connectionState != ConnectionState.done;
          final doctors = snapshot.data ?? const <DoctorDataModel>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.names.display(language),
                style: AppTextStyles.listCardTitle
                    .copyWith(color: AppColors.ink),
              ),
              SizedBox(height: 4.rh),
              Row(
                children: [
                  Container(
                    width: 6.rw,
                    height: 6.rw,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3DB26B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.rw),
                  Text(
                    loading
                        ? '…'
                        : LocaleKeys.specialities_doctors_available
                            .tr(args: ['${doctors.length}']),
                    style: AppTextStyles.cardSubtitle
                        .copyWith(color: AppColors.inkSecondary),
                  ),
                ],
              ),
              if (!loading && doctors.isEmpty) ...[
                SizedBox(height: 16.rh),
                const _NoDoctors(),
              ] else if (doctors.isNotEmpty) ...[
                SizedBox(height: 12.rh),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final doctor in doctors) ...[
                          GestureDetector(
                            onTap: () => AppNavigator.push(
                              AppRoutes.doctorDetail,
                              arguments: IdArgsModel(id: doctor.id),
                            ),
                            child: SizedBox(
                              width: 190.rw,
                              child: DoctorCard(
                                doctor: doctor,
                                language: language,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.rw),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
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
            style:
                AppTextStyles.caption.copyWith(color: AppColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}
