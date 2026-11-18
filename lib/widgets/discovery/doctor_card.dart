import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/constants/app_border_radius.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_theme_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.language});

  final DoctorDataModel doctor;
  final String language;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final branch = doctor.primaryBranch?.name;

    return Container(
      padding: EdgeInsetsDirectional.all(12.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppBorderRadius.md,
        border: Border.all(color: colors.border, width: 1.r),
      ),
      child: Row(
        children: [
          _Avatar(image: doctor.image, colors: colors),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.names.display(language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySemiBold
                      .copyWith(color: colors.textPrimary),
                ),
                if ((doctor.qualification ?? '').isNotEmpty) ...[
                  SizedBox(height: 2.rh),
                  Text(
                    doctor.qualification!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
                if (branch != null) ...[
                  SizedBox(height: 4.rh),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13.r, color: colors.textMuted),
                      SizedBox(width: 4.rw),
                      Expanded(
                        child: Text(
                          branch,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption
                              .copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (doctor.ratingCount > 0)
            Row(
              children: [
                Icon(Icons.star_rounded, size: 15.r, color: colors.warning),
                SizedBox(width: 2.rw),
                Text(
                  doctor.ratingAverage.toStringAsFixed(1),
                  style: AppTextStyles.caption
                      .copyWith(color: colors.textPrimary),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.image, required this.colors});

  final String? image;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final size = 52.r;
    // image is null on every doctor on the test host, so the fallback is the
    // normal case rather than an edge case
    if (image == null || image!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, size: 26.r, color: colors.primary),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: image!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          color: colors.primarySoft,
          child: Icon(Icons.person, size: 26.r, color: colors.primary),
        ),
      ),
    );
  }
}
