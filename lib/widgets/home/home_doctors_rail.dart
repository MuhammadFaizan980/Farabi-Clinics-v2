import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// "Available Doctors": 220 x 292 cards (radius 20, 1px border). photo area on
/// top, then name (17 / 26), branch line with the pin (15 / 26) and a row of
/// specialty chips (34 tall, pill, 6 / 8 padding, 8 gap).
class HomeDoctorsRail extends StatelessWidget {
  const HomeDoctorsRail({
    super.key,
    required this.doctors,
    required this.language,
    required this.onDoctorTap,
  });

  final List<DoctorDataModel> doctors;
  final String language;
  final ValueChanged<DoctorDataModel> onDoctorTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 292.rh,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20.rw),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.rw),
        itemBuilder: (context, index) => HomeDoctorCard(
          doctor: doctors[index],
          language: language,
          onTap: () => onDoctorTap(doctors[index]),
        ),
      ),
    );
  }
}

class HomeDoctorCard extends StatelessWidget {
  const HomeDoctorCard({
    super.key,
    required this.doctor,
    required this.language,
    required this.onTap,
  });

  final DoctorDataModel doctor;
  final String language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final branch = doctor.primaryBranch?.name;
    final specialities = doctor.specialities
        .map((s) => s.name)
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList(growable: false);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220.rw,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 171.rh,
              child: ClipRRect(
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(19.r),
                  topEnd: Radius.circular(19.r),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFE9EA), AppColors.white],
                        ),
                      ),
                    ),
                    if ((doctor.image ?? '').isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: doctor.image!,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorWidget: (_, __, ___) => const _PhotoPlaceholder(),
                      )
                    else
                      const _PhotoPlaceholder(),
                    if (doctor.ratingCount > 0)
                      PositionedDirectional(
                        top: 14.rh,
                        end: 12.rw,
                        child: _RatingBadge(rating: doctor.ratingAverage),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 14.rw, end: 14.rw),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.names.display(language),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTextStyles.cardTitle.copyWith(color: AppColors.ink),
                  ),
                  if (branch != null)
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.iconLocationPin,
                          width: 18.rw,
                          height: 18.rw,
                        ),
                        SizedBox(width: 6.rw),
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
                ],
              ),
            ),
            if (specialities.isNotEmpty) ...[
              SizedBox(height: 11.rh),
              SizedBox(
                height: 34.rh,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 14.rw),
                  itemCount: specialities.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.rw),
                  itemBuilder: (context, i) => _Chip(label: specialities[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person_outline,
        size: 64.rw,
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final num rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 8.rw,
        vertical: 3.rh,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12.rw, color: AppColors.warning),
          SizedBox(width: 3.rw),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.chip.copyWith(
              color: AppColors.ink,
              fontSize: 12.rf,
              height: 1,
            ),
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
