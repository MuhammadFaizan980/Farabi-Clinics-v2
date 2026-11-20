import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../widgets/more/more_header.dart';
import 'static_pages_content.dart';

/// renders one of the site's static pages (about, privacy, terms) from its
/// block list. there is no api behind these, the copy ships in the app.
class StaticPageScreen extends StatelessWidget {
  const StaticPageScreen({
    super.key,
    required this.titleKey,
    required this.blocks,
  });

  final String titleKey;
  final List<StaticBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listBackground,
      body: Column(
        children: [
          MoreHeader(
            title: titleKey.tr(),
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
                    6.rh,
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
                      for (final block in blocks) _Block(block: block),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block});

  final StaticBlock block;

  @override
  Widget build(BuildContext context) {
    final text = block.key.tr();

    switch (block.type) {
      case StaticBlockType.heading:
        return Padding(
          padding: EdgeInsetsDirectional.only(top: 18.rh, bottom: 6.rh),
          child: Text(
            text,
            style: AppTextStyles.listCardTitle.copyWith(
              color: AppColors.ink,
              height: 24 / 17,
            ),
          ),
        );
      case StaticBlockType.bullet:
        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: 6.rh),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(top: 8.rh, end: 10.rw),
                child: Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.profileBody.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        );
      case StaticBlockType.body:
        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: 12.rh),
          child: Text(
            text,
            style: AppTextStyles.profileBody.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
        );
    }
  }
}
