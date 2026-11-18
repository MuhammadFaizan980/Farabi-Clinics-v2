import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// branch card from the branches list frame: 382 wide, radius 16, a 119 tall
/// photo inset by 8, the name (17 / 26 bold), the address with a red pin and,
/// when the branch has a phone number, the red Call button.
///
/// the frame also shows a distance and a "closes at" pill; neither is in the
/// branches payload, so they are not drawn.
class BranchCard extends StatelessWidget {
  const BranchCard({
    super.key,
    required this.branch,
    required this.language,
    required this.addressFallback,
    required this.callLabel,
    required this.onTap,
  });

  final BranchDataModel branch;
  final String language;
  final String addressFallback;
  final String callLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final address = (branch.address ?? '').trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        padding: EdgeInsetsDirectional.all(8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Photo(branch: branch),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.rw, 8.rh, 8.rw, 0),
              child: Text(
                branch.names.display(language),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.listCardTitle
                    .copyWith(color: AppColors.ink),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 8.rw),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.iconLocationPin,
                    width: 18.rw,
                    height: 18.rw,
                  ),
                  SizedBox(width: 4.rw),
                  Expanded(
                    child: Text(
                      address.isEmpty ? addressFallback : address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.branchAddress
                          .copyWith(color: AppColors.inkSecondary),
                    ),
                  ),
                ],
              ),
            ),
            if (branch.canCall) ...[
              SizedBox(height: 12.rh),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 8.rw),
                child: _CallButton(label: callLabel, onTap: onTap),
              ),
            ],
            SizedBox(height: 12.rh),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.branch});

  final BranchDataModel branch;

  @override
  Widget build(BuildContext context) {
    final image = branch.image;
    Widget placeholder() => const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE9EA), Color(0xFFFFF7F7)],
            ),
          ),
          child: Center(
            child: Icon(Icons.apartment_outlined, color: AppColors.primary),
          ),
        );

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
            if (image == null || image.isEmpty)
              placeholder()
            else
              CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (_, __) => placeholder(),
                errorWidget: (_, __, ___) => placeholder(),
              ),
            if (branch.ratingCount > 0)
              PositionedDirectional(
                top: 6.rh,
                end: 6.rw,
                child: _RatingPill(rating: branch.ratingAverage),
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
            style: AppTextStyles.rating.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 136.rw,
        height: 34.rh,
        padding: EdgeInsetsDirectional.fromSTEB(8.rw, 6.rh, 12.rw, 6.rh),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: AppColors.callBorder, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppAssets.iconCall, width: 18.rw, height: 18.rw),
            SizedBox(width: 4.rw),
            Text(
              label,
              style: AppTextStyles.pillLabel.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
