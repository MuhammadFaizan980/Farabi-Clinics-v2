import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// brand button: 52 tall, radius 14, `#CC1C1C` fill with white 16 / 600 label.
/// the outlined variant is red text on a red hairline.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    // the disabled fill is the brand red at ~40%, like the website's button
    final fill = isOutlined
        ? Colors.transparent
        : (isEnabled
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.4));

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
                        color:
                            isOutlined ? AppColors.primary : AppColors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
