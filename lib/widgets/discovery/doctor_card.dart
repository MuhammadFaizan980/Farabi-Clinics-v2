import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// full-width doctor card from the doctors list frame: 366 wide, radius 16, a
/// 119 tall photo panel inset by 8 (radius 12 on top), then the name (17 / 26
/// bold), the branch line with a 24px pin, and a row of specialty chips.
class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.language});

  final DoctorDataModel doctor;
  final String language;

  @override
  Widget build(BuildContext context) {
    final branch = doctor.primaryBranch?.name;
    final specialities = doctor.specialities
        .map((s) => s.name)
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      padding: EdgeInsetsDirectional.all(8.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhotoPanel(doctor: doctor),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.rw, 8.rh, 8.rw, 0),
            child: Text(
              doctor.names.display(language),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  AppTextStyles.listCardTitle.copyWith(color: AppColors.ink),
            ),
          ),
          if (branch != null)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 8.rw),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.iconLocationPin,
                    width: 24.rw,
                    height: 24.rw,
                  ),
                  SizedBox(width: 8.rw),
                  Expanded(
                    child: Text(
                      branch,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardSubtitle
                          .copyWith(color: AppColors.inkSecondary),
                    ),
                  ),
                ],
              ),
            ),
          if (specialities.isNotEmpty) ...[
            SizedBox(height: 9.rh),
            SizedBox(
              height: 34.rh,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsetsDirectional.symmetric(horizontal: 8.rw),
                itemCount: specialities.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.rw),
                itemBuilder: (context, i) => _Chip(label: specialities[i]),
              ),
            ),
          ],
          SizedBox(height: 15.rh),
        ],
      ),
    );
  }
}

class _PhotoPanel extends StatelessWidget {
  const _PhotoPanel({required this.doctor});

  final DoctorDataModel doctor;

  @override
  Widget build(BuildContext context) {
    final image = doctor.image;

    return SizedBox(
      height: 119.rh,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(12.r),
          topEnd: Radius.circular(12.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFE9EA), Color(0xFFFFF7F7)],
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 160.rw,
                height: 119.rh,
                child: (image == null || image.isEmpty)
                    ? Icon(
                        Icons.person_outline,
                        size: 56.rw,
                        color: AppColors.primary.withValues(alpha: 0.35),
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.person_outline,
                          size: 56.rw,
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
              ),
            ),
            if (doctor.ratingCount > 0)
              PositionedDirectional(
                top: 6.rh,
                end: 6.rw,
                child: _RatingPill(rating: doctor.ratingAverage),
              ),
          ],
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final num rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 49.rw,
      height: 23.rh,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_rounded, size: 12.rw, color: AppColors.warning),
          SizedBox(width: 4.rw),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.rating.copyWith(color: AppColors.chipInk),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 8.rw,
        vertical: 6.rh,
      ),
      decoration: BoxDecoration(
        color: AppColors.chipFill,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.chipFill, width: 1),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: AppTextStyles.chip.copyWith(color: AppColors.ink),
      ),
    );
  }
}
