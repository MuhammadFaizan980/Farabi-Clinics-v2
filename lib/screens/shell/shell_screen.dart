import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../tabs/branches/branches_list_screen.dart';
import '../tabs/doctors/doctors_list_screen.dart';
import '../tabs/home/home_screen.dart';
import '../tabs/more/more_screen.dart';
import '../tabs/offers/offers_screen.dart';
import 'shell_vm.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return ViewModelBuilder<ShellVm>.reactive(
      viewModelBuilder: ShellVm.new,
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        // IndexedStack keeps each tab's scroll position and loaded data
        body: IndexedStack(
          index: vm.index,
          children: [
            HomeScreen(onSelectTab: vm.setIndex),
            const DoctorsListScreen(),
            const OffersScreen(),
            const BranchesListScreen(),
            const MoreScreen(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          selectedIndex: vm.index,
          onSelected: vm.setIndex,
          items: [
            AppBottomNavItem(
              asset: AppAssets.navHomeOff,
              selectedAsset: AppAssets.navHomeOn,
              label: LocaleKeys.tabs_home.tr(),
            ),
            AppBottomNavItem(
              asset: AppAssets.navDoctorsOff,
              selectedAsset: AppAssets.navDoctorsOn,
              label: LocaleKeys.tabs_doctors.tr(),
            ),
            AppBottomNavItem(
              asset: AppAssets.navOffersOff,
              selectedAsset: AppAssets.navOffersOn,
              label: LocaleKeys.tabs_offers.tr(),
            ),
            AppBottomNavItem(
              asset: AppAssets.navBranchesOff,
              selectedAsset: AppAssets.navBranchesOn,
              label: LocaleKeys.tabs_branches.tr(),
            ),
            AppBottomNavItem(
              asset: AppAssets.navMoreOff,
              selectedAsset: AppAssets.navMoreOn,
              label: LocaleKeys.tabs_more.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
