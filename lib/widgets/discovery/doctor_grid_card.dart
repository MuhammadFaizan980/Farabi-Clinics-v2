import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// the two-column version of the doctor card used by the list's grid view: a
/// photo panel, the name and the first branch, all on the card's own width.
class DoctorGridCard extends StatelessWidget {
  const DoctorGridCard({
    super.key,
    required this.doctor,
    required this.language,
  });

  final DoctorDataModel doctor;
  final String language;

  @override
  Widget build(BuildContext context) {
    final image = doctor.image;
    final branch = doctor.primaryBranch?.name;
    final placeholder = Center(
      child: Icon(
        Icons.person_outline,
        size: 48.rw,
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: EdgeInsetsDirectional.all(8.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFE9EA), Color(0xFFFFF7F7)],
                    ),
                  ),
                  child: (image == null || image.isEmpty)
                      ? placeholder
                      : CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          errorWidget: (_, __, ___) => placeholder,
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.rh),
          Text(
            doctor.names.display(language),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.rowTitle.copyWith(color: AppColors.ink),
          ),
          if (branch != null)
            Row(
              children: [
                SvgPicture.asset(
                  AppAssets.iconLocationPin,
                  width: 16.rw,
                  height: 16.rw,
                ),
                SizedBox(width: 4.rw),
                Expanded(
                  child: Text(
                    branch,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.inkSecondary),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
