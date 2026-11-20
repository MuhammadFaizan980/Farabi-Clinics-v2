import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// brand button: 52 tall, radius 14, `#CC1C1C` fill with white 16 / 600 label.
/// the outlined variant is red text on a red hairline. the [figma] variant is
/// the app-frame button: 48 tall, radius 10, a #CC1C1C to #B30E0E gradient
/// with a 1.5 black 16% inner edge and a soft shadow.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.figma = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool figma;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    // the disabled fill is the brand red at ~40%, like the website's button
    final fill = isOutlined
        ? Colors.transparent
        : (isEnabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.4));

    if (figma && !isOutlined) {
      return Semantics(
        button: true,
        enabled: isEnabled,
        label: label,
        child: Opacity(
          opacity: isEnabled ? 1 : 0.4,
          child: Container(
            width: double.infinity,
            height: 48.rh,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, Color(0xFFB30E0E)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  offset: Offset(2, -4),
                  blurRadius: 24,
                ),
              ],
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0x29000000), width: 1.5),
            ),
            child: Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(10.r),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: isEnabled ? onPressed : null,
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.r,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Text(
                          label,
                          style: AppTextStyles.screenTitle.copyWith(
                            fontSize: 16.rf,
                            height: 1,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: SizedBox(
        width: double.infinity,
        height: 52.rh,
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: isOutlined
                ? const BorderSide(color: AppColors.primary, width: 1)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.r,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOutlined ? AppColors.primary : AppColors.white,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: AppTextStyles.button.copyWith(
                        color: isOutlined ? AppColors.primary : AppColors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
