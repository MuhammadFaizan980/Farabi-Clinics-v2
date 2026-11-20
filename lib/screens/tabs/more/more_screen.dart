import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../data/constants/app_assets.dart';
import '../../../data/constants/locale_keys.g.dart';
import '../../../router/app_navigator.dart';
import '../../../router/app_routes.dart';
import '../../../utils/color/app_colors.dart';
import '../../../utils/extensions/responsive_extensions.dart';
import '../../../widgets/sheet/app_sheet.dart';
import '../../../widgets/sheet/language_sheet.dart';
import '../../../utils/extensions/vm_init_extension.dart';
import '../../../widgets/more/more_header.dart';
import '../../../widgets/more/more_menu.dart';
import '../../../widgets/more/more_profile_card.dart';
import '../../../widgets/more/more_stats_card.dart';
import 'more_vm.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MoreVm>.reactive(
      viewModelBuilder: MoreVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Column(
          children: [
            MoreHeader(title: LocaleKeys.more_profile_setting.tr()),
            Expanded(
              child: RefreshIndicator(
                onRefresh: vm.load,
                child: ListView(
                  padding: EdgeInsetsDirectional.only(top: 8.rh, bottom: 24.rh),
                  children: [
                    MoreProfileCard(
                      name: vm.isLoggedIn
                          ? (vm.displayName.isEmpty
                              ? LocaleKeys.more_profile.tr()
                              : vm.displayName)
                          : LocaleKeys.more_sign_in_prompt.tr(),
                      initials: vm.initials,
                      subtitle: vm.patient?.patientId == null
                          ? ''
                          : LocaleKeys.more_patient_id
                              .tr(args: [vm.patient!.patientId!]),
                      showPatientIcon: vm.patient?.patientId != null,
                      verified: vm.isVerified,
                      onTap: vm.openProfile,
                    ),
                    if (vm.isLoggedIn) ...[
                      SizedBox(height: 2.rh),
                      MoreStatsCard(
                        stats: [
                          MoreStat(
                            icon: AppAssets.moreStatUpcoming,
                            value: _two(vm.upcomingCount),
                            label: LocaleKeys.more_stat_upcoming.tr(),
                          ),
                          MoreStat(
                            icon: AppAssets.moreStatBooked,
                            value: _two(vm.bookedCount),
                            label: LocaleKeys.more_stat_booked.tr(),
                          ),
                          MoreStat(
                            icon: AppAssets.moreStatVisits,
                            value: _two(vm.visitsCount),
                            label: LocaleKeys.more_stat_visits.tr(),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 24.rh),
                    MoreSectionHeading(text: LocaleKeys.more_your_activity.tr()),
                    SizedBox(height: 10.rh),
                    MoreMenuRow(
                      iconAsset: AppAssets.moreRowAppointments,
                      title: LocaleKeys.more_my_bookings.tr(),
                      subtitle: LocaleKeys.more_appointments_sub.tr(),
                      onTap: () => AppNavigator.push(AppRoutes.bookings),
                    ),
                    SizedBox(height: 24.rh),
                    MoreSectionHeading(
                      text: LocaleKeys.more_account_settings.tr(),
                    ),
                    SizedBox(height: 10.rh),
                    MoreMenuRow(
                      iconAsset: AppAssets.moreRowLanguage,
                      title: LocaleKeys.more_language.tr(),
                      subtitle: LocaleKeys.more_language_sub.tr(),
                      // the Figma "Change Language" sheet; picking the other
                      // language flips the whole app in place, as before
                      onTap: () => showLanguageSheet(context),
                    ),
                    SizedBox(height: 4.rh),
                    MoreMenuRow(
                      iconAsset: AppAssets.moreRowAbout,
                      title: LocaleKeys.more_about.tr(),
                      subtitle: LocaleKeys.more_about_sub.tr(),
                      onTap: () => AppNavigator.push(AppRoutes.aboutUs),
                    ),
                    SizedBox(height: 24.rh),
                    // pages the website has that the figma frame does not show
                    MoreSectionHeading(text: LocaleKeys.more_explore.tr()),
                    SizedBox(height: 10.rh),
                    ..._explore(),
                    SizedBox(height: 24.rh),
                    if (vm.isLoggedIn)
                      MoreMenuRow(
                        iconAsset: AppAssets.moreLogout,
                        title: LocaleKeys.common_logout.tr(),
                        subtitle: LocaleKeys.more_logout_sub.tr(),
                        destructive: true,
                        onTap: () async {
                          final confirmed = await showConfirmSheet(
                            context,
                            icon: Icons.logout,
                            title: LocaleKeys.more_logout_confirm_title.tr(),
                            message: LocaleKeys.more_logout_confirm_body.tr(),
                            confirmLabel: LocaleKeys.common_logout.tr(),
                            cancelLabel: LocaleKeys.common_cancel.tr(),
                          );
                          if (confirmed) await vm.logout();
                        },
                      )
                    else
                      MoreMenuRow(
                        fallbackIcon: Icons.login,
                        title: LocaleKeys.auth_sign_in.tr(),
                        onTap: () => AppNavigator.push(AppRoutes.login),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static List<Widget> _explore() {
    final rows = <(String, IconData, String)>[
      (LocaleKeys.more_specialities, Icons.medical_services_outlined,
          AppRoutes.specialities),
      (LocaleKeys.more_contact_us, Icons.mail_outline, AppRoutes.contactUs),
      (LocaleKeys.blogs_title, Icons.article_outlined, AppRoutes.blogs),
      (LocaleKeys.more_careers, Icons.work_outline, AppRoutes.careers),
      (LocaleKeys.more_reviews, Icons.star_outline, AppRoutes.reviews),
      (LocaleKeys.more_privacy, Icons.privacy_tip_outlined,
          AppRoutes.privacyPolicy),
      (LocaleKeys.more_terms, Icons.description_outlined, AppRoutes.terms),
    ];
    return [
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) SizedBox(height: 4.rh),
        MoreMenuRow(
          fallbackIcon: rows[i].$2,
          title: rows[i].$1.tr(),
          onTap: () => AppNavigator.push(rows[i].$3),
        ),
      ],
    ];
  }
}
