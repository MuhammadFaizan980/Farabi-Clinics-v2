import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

class HomeRegionItem {
  const HomeRegionItem({
    required this.name,
    required this.doctorsLabel,
    this.imageAsset,
    this.onTap,
  });

  final String name;
  final String doctorsLabel;

  /// the regions api has no image field, so the city photos ship in the app;
  /// a region without one falls back to the tinted placeholder.
  final String? imageAsset;
  final VoidCallback? onTap;
}

/// "Location Base Appointment": 140 x 104 photos (radius 20) with the city
/// name (17 / 22) and the "N Doctors Available" line (14 / 18) under each.
class HomeRegionsRail extends StatelessWidget {
  const HomeRegionsRail({super.key, required this.items});

  final List<HomeRegionItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158.rh,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20.rw),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.rw),
        itemBuilder: (context, index) => _RegionCard(item: items[index]),
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({required this.item});

  final HomeRegionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: SizedBox(
              width: 140.rw,
              height: 104.rh,
              child: item.imageAsset == null
                  ? const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.redTint20, AppColors.tileTint],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_city_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Image.asset(item.imageAsset!, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 12.rh),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 8.rw),
            child: Text(
              item.name,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.ink,
                height: 22 / 17,
              ),
            ),
          ),
          SizedBox(height: 2.rh),
          Row(
            children: [
              SizedBox(width: 10.rw),
              Container(
                width: 5.rw,
                height: 5.rw,
                decoration: const BoxDecoration(
                  color: Color(0xFF2AC564),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.rw),
              Text(
                item.doctorsLabel,
                style: AppTextStyles.chip.copyWith(color: AppColors.inkSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
