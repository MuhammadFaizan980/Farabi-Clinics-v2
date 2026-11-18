import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
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
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          titleKey.tr(),
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
            for (final block in blocks) _Block(block: block),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block});

  final StaticBlock block;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final text = block.key.tr();

    switch (block.type) {
      case StaticBlockType.heading:
        return Padding(
          padding: EdgeInsetsDirectional.only(top: 18.rh, bottom: 6.rh),
          child: Text(
            text,
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
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
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: colors.textPrimary),
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
            style:
                AppTextStyles.bodyLarge.copyWith(color: colors.textSecondary),
          ),
        );
    }
  }
}
