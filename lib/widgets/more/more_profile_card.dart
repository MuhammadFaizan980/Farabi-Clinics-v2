import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../common/verified_badge.dart';

/// profile card of the more frame: 382 x 158, radius 16, an 80px avatar with a
/// ring at the top left, the name (17 / 22 semibold) with the verified badge,
/// the patient id line and a 22px chevron on the right.
///
/// the avatar photo, the ring's progress value and the card's background art
/// are not in the profile payload, so the avatar shows initials, the ring is a
/// plain track, and the background art is the single measured circle.
class MoreProfileCard extends StatelessWidget {
  const MoreProfileCard({
    super.key,
    required this.name,
    required this.initials,
    required this.subtitle,
    required this.verified,
    required this.onTap,
    this.showPatientIcon = true,
  });

  final String name;
  final String initials;
  final String subtitle;
  final bool verified;
  final bool showPatientIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 158.rh,
        margin: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.cardBorder, width: 1),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.white, Color(0xFFF2F2F2)],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Ellipse 13 in the frame: 346 across, black at 4%, 97 in from the
              // card's left and 22 above its top
              PositionedDirectional(
                start: 97.rw,
                top: -22.rh,
                child: _Circle(size: 346.rw),
              ),
              PositionedDirectional(
                start: 15.rw,
                top: 14.rh,
                child: _Avatar(initials: initials),
              ),
              PositionedDirectional(
                start: 20.rw,
                top: 103.rh,
                end: 60.rw,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.profileName.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (verified) ...[
                      SizedBox(width: 6.rw),
                      const VerifiedBadge(),
                    ],
                  ],
                ),
              ),
              PositionedDirectional(
                start: 20.rw,
                top: 127.rh,
                end: 60.rw,
                child: Row(
                  children: [
                    if (showPatientIcon) ...[
                      SvgPicture.asset(
                        AppAssets.morePatientId,
                        width: 18.rw,
                        height: 18.rw,
                      ),
                      SizedBox(width: 2.rw),
                    ],
                    Flexible(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.profileMeta.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                end: 28.rw,
                top: 62.rh,
                child: SvgPicture.asset(
                  AppAssets.moreChevron,
                  width: 22.rw,
                  height: 22.rw,
                  matchTextDirection: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.decoration4,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.rw,
      height: 80.rw,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE6E6E6), width: 3.r),
      ),
      child: Container(
        width: 67.rw,
        height: 67.rw,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.pinkLight,
        ),
        child: Text(
          initials,
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
