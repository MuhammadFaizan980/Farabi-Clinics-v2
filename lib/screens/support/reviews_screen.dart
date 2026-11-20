import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../widgets/more/more_header.dart';
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
    return Scaffold(
      backgroundColor: AppColors.listBackground,
      body: Column(
        children: [
          MoreHeader(
            title: LocaleKeys.more_reviews.tr(),
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                16.rw,
                8.rh,
                16.rw,
                16.rh,
              ),
              children: [
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    18.rw,
                    12.rh,
                    18.rw,
                    12.rh,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.reviews_page_title.tr(),
                        style: AppTextStyles.listCardTitle.copyWith(
                          color: AppColors.ink,
                          height: 24 / 17,
                        ),
                      ),
                      SizedBox(height: 6.rh),
                      Text(
                        LocaleKeys.reviews_page_subtitle.tr(),
                        style: AppTextStyles.profileBody.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final review in _reviews) ...[
                  SizedBox(height: 4.rh),
                  Container(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      18.rw,
                      12.rh,
                      18.rw,
                      12.rh,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review[0].tr(),
                          style: AppTextStyles.profileBody.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 10.rh),
                        Text(
                          review[1].tr(),
                          style: AppTextStyles.rowTitle.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          review[2].tr(),
                          style: AppTextStyles.fieldError.copyWith(
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
