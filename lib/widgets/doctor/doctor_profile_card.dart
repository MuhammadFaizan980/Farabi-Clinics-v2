import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../common/verified_badge.dart';
import '../discovery/doctor_card.dart' show DoctorRatingPill;

/// the doctor card at the top of the profile and booking frames: 382 wide, a
/// 67 avatar with the online dot, the rating chip at the top right, then the
/// name with its verified badge and the qualification.
class DoctorProfileCard extends StatelessWidget {
  const DoctorProfileCard({
    super.key,
    required this.doctor,
    required this.name,
  });

  final DoctorDataModel doctor;
  final String name;

  @override
  Widget build(BuildContext context) {
    final image = doctor.image;
    final qualification = (doctor.qualification ?? '').trim();
    final placeholder = Icon(
      Icons.person_outline,
      size: 34.rw,
      color: AppColors.primary.withValues(alpha: 0.5),
    );

    // 382 wide, 16 inset: a 67 avatar 12 from the top, the rating chip 12 from
    // the top right, then name (16 / 20 bold) and qualification (16 / 18 600)
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 12.rh, 16.rw, 20.rh),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 67.rw,
                    height: 67.rw,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x3DCC1C1C),
                      border: Border.all(color: AppColors.white, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    child: (image == null || image.isEmpty)
                        ? placeholder
                        : CachedNetworkImage(
                            imageUrl: image,
                            width: 67.rw,
                            height: 67.rw,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorWidget: (_, __, ___) => placeholder,
                          ),
                  ),
                  // static "online" dot, the same on every profile as on the site
                  PositionedDirectional(
                    top: 6.rh,
                    end: 3.rw,
                    child: Container(
                      width: 10.rw,
                      height: 10.rw,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2AC564),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (doctor.ratingCount > 0)
                DoctorRatingPill(rating: doctor.ratingAverage),
            ],
          ),
          SizedBox(height: 12.rh),
          Row(
            children: [
              Flexible(
                child: Text(
                  name,
                  style: AppTextStyles.listCardTitle.copyWith(
                    color: AppColors.ink,
                    fontSize: 16.rf,
                    height: 20 / 16,
                  ),
                ),
              ),
              SizedBox(width: 6.rw),
              const VerifiedBadge(size: 17),
            ],
          ),
          if (qualification.isNotEmpty) ...[
            SizedBox(height: 8.rh),
            Text(
              qualification,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.ink,
                fontSize: 16.rf,
                height: 18 / 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
