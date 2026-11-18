import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../tabs/branches/branches_list_screen.dart';
import '../tabs/doctors/doctors_list_screen.dart';
import '../tabs/home/home_screen.dart';
import '../tabs/more/more_screen.dart';
import '../tabs/specialities/specialities_screen.dart';
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
          children: const [
            HomeScreen(),
            DoctorsListScreen(),
            BranchesListScreen(),
            SpecialitiesScreen(),
            MoreScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: vm.index,
          onDestinationSelected: vm.setIndex,
          backgroundColor: colors.surface,
          height: 68.rh,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: LocaleKeys.tabs_home.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_search_outlined),
              selectedIcon: const Icon(Icons.person_search),
              label: LocaleKeys.tabs_doctors.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.location_on_outlined),
              selectedIcon: const Icon(Icons.location_on),
              label: LocaleKeys.tabs_branches.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.medical_services_outlined),
              selectedIcon: const Icon(Icons.medical_services),
              label: LocaleKeys.tabs_specialities.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu),
              selectedIcon: const Icon(Icons.menu_open),
              label: LocaleKeys.tabs_more.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
