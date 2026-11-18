import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 12.rw,
        vertical: 10.rh,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // not colour-only: the icon carries the same meaning
          Icon(Icons.error_outline, size: 16.rw, color: AppColors.error),
          SizedBox(width: 8.rw),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.fieldError.copyWith(
                color: AppColors.error,
                fontSize: 13.rf,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
