import 'package:flutter/material.dart';

import '../../data/constants/app_border_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

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
    final colors = AppThemeColors.of(context);
    final isEnabled = onPressed != null && !isLoading;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: SizedBox(
        width: double.infinity,
        // 48dp clears the 44pt minimum touch target
        height: 48.rh,
        child: Material(
          color: isOutlined
              ? Colors.transparent
              : (isEnabled ? colors.primary : colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.sm,
            side: isOutlined
                ? BorderSide(color: colors.primary, width: 1.r)
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
                          isOutlined ? colors.primary : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: AppTextStyles.button.copyWith(
                        color: isOutlined
                            ? colors.primary
                            : (isEnabled ? Colors.white : colors.textMuted),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
