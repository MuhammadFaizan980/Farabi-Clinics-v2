import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_border_radius.dart';
import '../../data/constants/app_locales.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/common/app_button.dart';
import 'language_selection_vm.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return ViewModelBuilder<LanguageSelectionVm>.reactive(
      viewModelBuilder: LanguageSelectionVm.new,
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 20.rw),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.rh),
                Text(
                  LocaleKeys.language_title.tr(),
                  style: AppTextStyles.h1.copyWith(color: colors.textPrimary),
                ),
                SizedBox(height: 6.rh),
                Text(
                  LocaleKeys.language_subtitle.tr(),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: 24.rh),
                _LanguageTile(
                  label: LocaleKeys.language_english.tr(),
                  isSelected: vm.isSelected(AppLocales.english),
                  onTap: () => vm.select(AppLocales.english),
                ),
                SizedBox(height: 12.rh),
                _LanguageTile(
                  label: LocaleKeys.language_arabic.tr(),
                  isSelected: vm.isSelected(AppLocales.arabic),
                  onTap: () => vm.select(AppLocales.arabic),
                ),
                const Spacer(),
                AppButton(
                  label: LocaleKeys.common_continue_label.tr(),
                  isLoading: vm.isBusy,
                  onPressed: () async {
                    final locale = await vm.confirm();
                    if (context.mounted) await context.setLocale(locale);
                  },
                ),
                SizedBox(height: 20.rh),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.sm,
        child: Container(
          height: 56.rh,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
          decoration: BoxDecoration(
            color: isSelected ? colors.primarySoft : colors.surface,
            borderRadius: AppBorderRadius.sm,
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: isSelected ? 1.5.r : 1.r,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: colors.textPrimary),
                ),
              ),
              // state is carried by an icon too, not colour alone
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20.r,
                color: isSelected ? colors.primary : colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
