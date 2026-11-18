import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import 'app_text_field.dart';

/// a labelled select that looks like [AppTextField].
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
  });

  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.fieldLabel.copyWith(color: AppColors.ink),
        ),
        SizedBox(height: 8.rh),
        Container(
          height: 52.rh,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
          decoration: AppFieldDecoration.box(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              hint: hint == null
                  ? null
                  : Text(
                      hint!,
                      style: AppTextStyles.fieldText.copyWith(
                        color: AppColors.inkSecondary.withValues(alpha: 0.64),
                      ),
                    ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 22.rw,
                color: AppColors.iconGrey,
              ),
              borderRadius: BorderRadius.circular(14.r),
              style: AppTextStyles.fieldText.copyWith(color: AppColors.ink),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
