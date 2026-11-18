import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/constants/app_border_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.maxLength,
    this.digitsOnly = false,
    this.onChanged,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;

  /// already-localised message. the view model decides when this is non-null.
  final String? errorText;
  final bool obscure;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool digitsOnly;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySemiBold.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: 6.rh),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textInputAction: textInputAction,
          onChanged: onChanged,
          inputFormatters:
              digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle:
                AppTextStyles.bodyLarge.copyWith(color: colors.textMuted),
            filled: true,
            fillColor: colors.surfaceAlt,
            contentPadding: EdgeInsetsDirectional.symmetric(
              horizontal: 14.rw,
              vertical: 14.rh,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.sm,
              borderSide: BorderSide(
                color: hasError ? colors.error : colors.border,
                width: 1.r,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.sm,
              borderSide: BorderSide(
                color: hasError ? colors.error : colors.primary,
                width: 1.5.r,
              ),
            ),
            border: OutlineInputBorder(borderRadius: AppBorderRadius.sm),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsetsDirectional.only(top: 4.rh, start: 2.rw),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 13.r, color: colors.error),
                SizedBox(width: 4.rw),
                Expanded(
                  child: Text(
                    errorText!,
                    style:
                        AppTextStyles.caption.copyWith(color: colors.error),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
