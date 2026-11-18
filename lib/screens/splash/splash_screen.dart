import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import 'splash_vm.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return ViewModelBuilder<SplashVm>.reactive(
      viewModelBuilder: SplashVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.bootstrap),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LocaleKeys.app_name.tr(),
                style: AppTextStyles.h1.copyWith(color: colors.primary),
              ),
              SizedBox(height: 8.rh),
              Text(
                LocaleKeys.splash_tagline.tr(),
                style:
                    AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: 28.rh),
              SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.r,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
