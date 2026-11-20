import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_locales.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/auth/auth_scaffold.dart';
import '../../widgets/common/app_button.dart';
import 'language_selection_vm.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LanguageSelectionVm>.reactive(
      viewModelBuilder: LanguageSelectionVm.new,
      builder: (context, vm, child) => AuthScaffold(
        title: LocaleKeys.language_title.tr(),
        subtitle: LocaleKeys.language_subtitle.tr(),
        child: Column(
          children: [
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
            SizedBox(height: 28.rh),
            AppButton(
              label: LocaleKeys.common_continue_label.tr(),
              isLoading: vm.isBusy,
              onPressed: () async {
                final locale = await vm.confirm();
                if (!context.mounted) return;
                await context.setLocale(locale);
                if (context.mounted) {
                  await AppNavigator.resetTo(AppRoutes.shell);
                }
              },
            ),
          ],
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
    return Semantics(
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 56.rh,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.redSelected6 : AppColors.fieldFill,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.hairline8,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.fieldText.copyWith(
                    color: AppColors.ink,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              // state is carried by an icon too, not colour alone
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 22.rw,
                color: isSelected ? AppColors.primary : AppColors.iconGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
