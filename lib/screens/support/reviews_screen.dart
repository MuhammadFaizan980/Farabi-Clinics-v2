import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/constants/app_border_radius.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// the site's reviews page is static marketing copy (no api), so the three
/// testimonials ship in the translation files.
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  static const List<List<String>> _reviews = [
    [
      LocaleKeys.reviews_page_r1_quote,
      LocaleKeys.reviews_page_r1_name,
      LocaleKeys.reviews_page_r1_detail,
    ],
    [
      LocaleKeys.reviews_page_r2_quote,
      LocaleKeys.reviews_page_r2_name,
      LocaleKeys.reviews_page_r2_detail,
    ],
    [
      LocaleKeys.reviews_page_r3_quote,
      LocaleKeys.reviews_page_r3_name,
      LocaleKeys.reviews_page_r3_detail,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          LocaleKeys.more_reviews.tr(),
          style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 20.rw,
            vertical: 12.rh,
          ),
          children: [
            Text(
              LocaleKeys.reviews_page_title.tr(),
              style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: 8.rh),
            Text(
              LocaleKeys.reviews_page_subtitle.tr(),
              style: AppTextStyles.bodyMedium
                  .copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: 18.rh),
            for (final review in _reviews)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: 12.rh),
                child: Container(
                  padding: EdgeInsetsDirectional.all(14.r),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppBorderRadius.md,
                    border: Border.all(color: colors.border, width: 1.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review[0].tr(),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: colors.textPrimary),
                      ),
                      SizedBox(height: 10.rh),
                      Text(
                        review[1].tr(),
                        style: AppTextStyles.bodySemiBold
                            .copyWith(color: colors.textPrimary),
                      ),
                      Text(
                        review[2].tr(),
                        style: AppTextStyles.caption
                            .copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
