import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import 'splash_vm.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SplashVm>.reactive(
      viewModelBuilder: SplashVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.bootstrap),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.logoWordmarkWhite,
                width: 190.rw,
                height: 39.rh,
              ),
              SizedBox(height: 12.rh),
              Text(
                LocaleKeys.splash_tagline.tr(),
                style: AppTextStyles.authSubtitle.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 32.rh),
              SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.r,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
