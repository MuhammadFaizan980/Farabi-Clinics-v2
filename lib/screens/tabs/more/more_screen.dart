import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app_di.dart';
import '../../../data/auth_session.dart';
import '../../../data/base/app_base_model.dart';
import '../../../data/constants/app_border_radius.dart';
import '../../../data/constants/locale_keys.g.dart';
import '../../../router/app_navigator.dart';
import '../../../router/app_routes.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/color/app_theme_colors.dart';
import '../../../utils/extensions/responsive_extensions.dart';
import '../../../widgets/common/app_button.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final session = AppDi.locator<AuthSession>();
    final name = session.patient?.fullName ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          LocaleKeys.more_title.tr(),
          style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 20.rw,
            vertical: 12.rh,
          ),
          children: [
            Container(
              padding: EdgeInsetsDirectional.all(16.r),
              decoration: BoxDecoration(
                color: colors.primarySoft,
                borderRadius: AppBorderRadius.md,
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 26.r, color: colors.primary),
                  SizedBox(width: 12.rw),
                  Expanded(
                    child: Text(
                      session.isLoggedIn
                          ? (name.isEmpty ? LocaleKeys.more_profile.tr() : name)
                          : LocaleKeys.more_sign_in_prompt.tr(),
                      style: AppTextStyles.bodySemiBold
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.rh),
            _MenuRow(
              icon: Icons.person_outline,
              label: LocaleKeys.more_profile.tr(),
              onTap: session.isLoggedIn
                  ? () => AppNavigator.push(AppRoutes.profile)
                  : null,
            ),
            _MenuRow(
              icon: Icons.medical_services_outlined,
              label: LocaleKeys.more_specialities.tr(),
              onTap: () => AppNavigator.push(AppRoutes.specialities),
            ),
            _MenuRow(
              icon: Icons.calendar_month_outlined,
              label: LocaleKeys.more_my_bookings.tr(),
              onTap: () => AppNavigator.push(AppRoutes.bookings),
            ),
            _MenuRow(
              icon: Icons.language_outlined,
              label: LocaleKeys.more_language.tr(),
              onTap: () => AppNavigator.push(AppRoutes.languageSelection),
            ),
            _MenuRow(
              icon: Icons.mail_outline,
              label: LocaleKeys.more_contact_us.tr(),
              onTap: () => AppNavigator.push(AppRoutes.contactUs),
            ),
            _MenuRow(
              icon: Icons.article_outlined,
              label: LocaleKeys.blogs_title.tr(),
              onTap: () => AppNavigator.push(AppRoutes.blogs),
            ),
            _MenuRow(
              icon: Icons.work_outline,
              label: LocaleKeys.more_careers.tr(),
              onTap: () => AppNavigator.push(AppRoutes.careers),
            ),
            _MenuRow(
              icon: Icons.info_outline,
              label: LocaleKeys.more_about.tr(),
              onTap: () => AppNavigator.push(AppRoutes.aboutUs),
            ),
            _MenuRow(
              icon: Icons.star_outline,
              label: LocaleKeys.more_reviews.tr(),
              onTap: () => AppNavigator.push(AppRoutes.reviews),
            ),
            _MenuRow(
              icon: Icons.privacy_tip_outlined,
              label: LocaleKeys.more_privacy.tr(),
              onTap: () => AppNavigator.push(AppRoutes.privacyPolicy),
            ),
            _MenuRow(
              icon: Icons.description_outlined,
              label: LocaleKeys.more_terms.tr(),
              onTap: () => AppNavigator.push(AppRoutes.terms),
            ),
            SizedBox(height: 24.rh),
            if (session.isLoggedIn)
              AppButton(
                label: LocaleKeys.common_logout.tr(),
                isOutlined: true,
                onPressed: () async {
                  await session.clear();
                  AppDi.locator<AppBaseModel>().clear();
                  await AppNavigator.resetTo(AppRoutes.login);
                },
              )
            else
              AppButton(
                label: LocaleKeys.auth_sign_in.tr(),
                onPressed: () => AppNavigator.push(AppRoutes.login),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          // 48dp keeps every row above the 44pt minimum target
          height: 52.rh,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              Icon(icon, size: 20.r, color: colors.textSecondary),
              SizedBox(width: 14.rw),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: colors.textPrimary),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20.r,
                color: onTap == null ? colors.textMuted : colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
