import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../../data/constants/app_assets.dart';
import '../../../data/constants/locale_keys.g.dart';
import '../../../data/models/discovery/detail_args_models.dart';
import '../../../router/app_navigator.dart';
import '../../../router/app_routes.dart';
import '../../../utils/color/app_colors.dart';
import '../../../utils/extensions/responsive_extensions.dart';
import '../../../utils/extensions/vm_init_extension.dart';
import '../../../widgets/common/app_state_views.dart';
import '../../../widgets/home/home_banner.dart';
import '../../../widgets/home/home_doctors_rail.dart';
import '../../../widgets/home/home_expert_card.dart';
import '../../../widgets/home/home_header.dart';
import '../../../widgets/home/home_regions_rail.dart';
import '../../../widgets/home/home_section_title.dart';
import '../../../widgets/home/home_service_grid.dart';
import '../../../widgets/home/home_virtual_services.dart';
import 'home_vm.dart';

/// tab indexes inside the shell, used by the "go to" shortcuts on this screen
const int _doctorsTab = 1;
const int _branchesTab = 3;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<HomeVm>.reactive(
      viewModelBuilder: HomeVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) {
        final header = HomeHeader(
          searchHint: LocaleKeys.home_search_hint.tr(),
          onSearchTap: () => onSelectTab(_doctorsTab),
          onProfileTap: () => AppNavigator.push(
            vm.isLoggedIn ? AppRoutes.profile : AppRoutes.login,
          ),
        );

        return Scaffold(
          backgroundColor: AppColors.white,
          body: vm.isBusy
              ? Column(
                  children: [
                    header,
                    const Expanded(child: AppShimmerList()),
                  ],
                )
              : vm.hasFailure
                  ? Column(
                      children: [
                        header,
                        Expanded(
                          child: AppErrorView(
                            message: LocaleKeys.errors_unexpected.tr(),
                            retryLabel: LocaleKeys.common_retry.tr(),
                            onRetry: vm.load,
                          ),
                        ),
                      ],
                    )
                  : RefreshIndicator(
                      onRefresh: vm.refresh,
                      edgeOffset: MediaQuery.paddingOf(context).top,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          header,
                          if (vm.offers.isNotEmpty) ...[
                            SizedBox(height: 12.rh),
                            Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: 20.rw,
                              ),
                              child: HomeBanner(
                                offers: vm.offers,
                                index: vm.bannerIndex,
                                onIndexChanged: vm.setBannerIndex,
                              ),
                            ),
                          ],
                          if (vm.specialities.isNotEmpty) ...[
                            SizedBox(height: 12.rh),
                            HomeServiceGrid(
                              title: LocaleKeys.home_book_by_service.tr(),
                              services: vm.visibleSpecialities,
                              language: language,
                              expanded: vm.servicesExpanded,
                              canExpand: vm.canExpandServices,
                              onToggle: vm.toggleServicesExpanded,
                              onServiceTap: (service) => AppNavigator.push(
                                AppRoutes.serviceDetail,
                                arguments: IdArgsModel(id: service.id),
                              ),
                            ),
                          ],
                          SizedBox(height: 24.rh),
                          HomeSectionTitle(
                            text: LocaleKeys.home_virtual_title.tr(),
                          ),
                          SizedBox(height: 10.rh),
                          HomeVirtualServices(
                            items: [
                              VirtualServiceItem(
                                icon: AppAssets.iconVirtualVideo,
                                label: LocaleKeys.home_video_consultation.tr(),
                              ),
                              VirtualServiceItem(
                                icon: AppAssets.iconVirtualAudio,
                                label: LocaleKeys.home_audio_consultation.tr(),
                              ),
                            ],
                          ),
                          if (vm.doctors.isNotEmpty) ...[
                            SizedBox(height: 27.rh),
                            HomeSectionTitle(
                              text: LocaleKeys.home_available_doctors.tr(),
                            ),
                            SizedBox(height: 15.rh),
                            HomeDoctorsRail(
                              doctors: vm.doctors,
                              language: language,
                              onDoctorTap: (doctor) => AppNavigator.push(
                                AppRoutes.doctorDetail,
                                arguments: IdArgsModel(id: doctor.id),
                              ),
                            ),
                          ],
                          SizedBox(height: 26.rh),
                          HomeExpertCard(
                            title: LocaleKeys.home_expert_title.tr(),
                            body: LocaleKeys.home_expert_body.tr(),
                            linkLabel: LocaleKeys.home_expert_link.tr(),
                            onLinkTap: () =>
                                AppNavigator.push(AppRoutes.contactUs),
                          ),
                          if (vm.regions.isNotEmpty) ...[
                            SizedBox(height: 20.rh),
                            HomeSectionTitle(
                              text: LocaleKeys.home_location_title.tr(),
                              inset: 24,
                            ),
                            SizedBox(height: 13.rh),
                            HomeRegionsRail(
                              items: [
                                for (final region in vm.regionsByDoctors)
                                  HomeRegionItem(
                                    name: region.names.display(language),
                                    imageAsset: AppAssets.regionImage(
                                      region.names.nameEn,
                                    ),
                                    doctorsLabel:
                                        LocaleKeys.home_doctors_available.tr(
                                      args: ['${vm.doctorsIn(region.id)}'],
                                    ),
                                    onTap: () => onSelectTab(_branchesTab),
                                  ),
                              ],
                            ),
                          ],
                          SizedBox(height: 32.rh),
                          Center(
                            child: SvgPicture.asset(
                              AppAssets.logoCbahi,
                              width: 208.rw,
                              height: 65.rh,
                            ),
                          ),
                          SizedBox(height: 32.rh),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
