import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/constants/app_border_radius.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import 'app_button.dart';

/// skeleton loader. a bare spinner is not acceptable for list loading.
class AppShimmerList extends StatelessWidget {
  const AppShimmerList({super.key, this.itemCount = 6, this.itemHeight});

  final int itemCount;
  final double? itemHeight;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Shimmer.fromColors(
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 20.rw,
          vertical: 12.rh,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: 12.rh),
        itemBuilder: (_, __) => Container(
          height: itemHeight ?? 92.rh,
          decoration: BoxDecoration(
            color: colors.shimmerBase,
            borderRadius: AppBorderRadius.md,
          ),
        ),
      ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 32.rw),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 44.r, color: colors.textMuted),
            SizedBox(height: 12.rh),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 6.rh),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 32.rw),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 44.r, color: colors.error),
            SizedBox(height: 12.rh),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: 18.rh),
            SizedBox(
              width: 180.rw,
              child: AppButton(
                label: retryLabel,
                isOutlined: true,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
