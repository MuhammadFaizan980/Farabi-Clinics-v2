import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../sheet/app_sheet.dart';

class DoctorsFilterChip {
  const DoctorsFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// fixed top block of the doctors frame. a white panel (radius 16, 170 below
/// the status bar) sits behind a red header (139 total, radius 16) that holds
/// the centred title and the grid icon; the 52px search pill straddles the two,
/// and the filter chips sit on the white part.
class DoctorsHeader extends StatelessWidget {
  const DoctorsHeader({
    super.key,
    required this.title,
    required this.searchHint,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
    required this.onToggleView,
    required this.regionLabel,
    required this.regions,
    required this.language,
    required this.onRegionSelected,
    required this.chips,
  });

  final String title;
  final String searchHint;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleView;
  final String regionLabel;
  final List<RegionDataModel> regions;
  final String language;
  final ValueChanged<int> onRegionSelected;
  final List<DoctorsFilterChip> chips;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: top + 170.rh,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(16.r),
                  bottomEnd: Radius.circular(16.r),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: top + 95.rh,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(16.r),
                  bottomEnd: Radius.circular(16.r),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: top + 20.rh,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle.copyWith(color: AppColors.white),
            ),
          ),
          PositionedDirectional(
            end: 32.rw,
            top: top + 22.rh,
            child: GestureDetector(
              onTap: onToggleView,
              behavior: HitTestBehavior.opaque,
              child: SvgPicture.asset(
                AppAssets.iconGridView,
                width: 24.rw,
                height: 24.rw,
              ),
            ),
          ),
          PositionedDirectional(
            start: 24.rw,
            end: 24.rw,
            top: top + 60.rh,
            height: 52.rh,
            child: _SearchPill(
              hint: searchHint,
              controller: searchController,
              onSubmitted: onSearchSubmitted,
              onChanged: onSearchChanged,
              regionLabel: regionLabel,
              regions: regions,
              language: language,
              onRegionSelected: onRegionSelected,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: top + 120.rh,
            height: 40.rh,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsetsDirectional.symmetric(horizontal: 24.rw),
              itemCount: chips.length,
              separatorBuilder: (_, __) => SizedBox(width: 6.rw),
              itemBuilder: (context, i) => _FilterChipView(chip: chips[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({
    required this.hint,
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    required this.regionLabel,
    required this.regions,
    required this.language,
    required this.onRegionSelected,
  });

  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final String regionLabel;
  final List<RegionDataModel> regions;
  final String language;
  final ValueChanged<int> onRegionSelected;

  /// the header only knows the label of the chosen region, so match on it
  int? _selectedRegionId() {
    for (final region in regions) {
      if (region.names.display(language) == regionLabel) return region.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.hairline8, width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              FocusScope.of(context).unfocus();
              final pick = await showSelectSheet<int>(
                context,
                title: LocaleKeys.doctors_location.tr(),
                selected: _selectedRegionId(),
                options: [
                  for (final region in regions)
                    SheetOption<int>(
                      value: region.id,
                      label: region.names.display(language),
                      leading: SvgPicture.asset(
                        AppAssets.iconLocationPin,
                        width: 22.rw,
                        height: 22.rw,
                      ),
                    ),
                ],
              );
              if (pick != null) onRegionSelected(pick.value);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppAssets.iconLocationPin,
                  width: 20.rw,
                  height: 20.rw,
                ),
                SizedBox(width: 9.rw),
                Text(
                  regionLabel,
                  style: AppTextStyles.searchHint.copyWith(color: Colors.black),
                ),
                SizedBox(width: 6.rw),
                SvgPicture.asset(
                  AppAssets.iconChevronDown,
                  width: 9.rw,
                  height: 6.rw,
                ),
              ],
            ),
          ),
          SizedBox(width: 15.rw),
          Container(width: 1, height: 24.rh, color: AppColors.hairline8),
          SizedBox(width: 14.rw),
          SvgPicture.asset(AppAssets.iconSearch, width: 18.rw, height: 18.rw),
          SizedBox(width: 8.rw),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.searchHint.copyWith(color: Colors.black),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTextStyles.searchHint.copyWith(
                  color: const Color(0xFF525252).withValues(alpha: 0.64),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipView extends StatelessWidget {
  const _FilterChipView({required this.chip});

  final DoctorsFilterChip chip;

  @override
  Widget build(BuildContext context) {
    final selected = chip.selected;
    return GestureDetector(
      onTap: chip.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40.rh,
        alignment: Alignment.center,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20.rw),
        decoration: BoxDecoration(
          color: selected ? AppColors.redSelected6 : AppColors.white,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.hairline8,
            width: 1,
          ),
        ),
        child: Text(
          chip.label,
          maxLines: 1,
          style: AppTextStyles.filterChip.copyWith(
            color: selected ? AppColors.chipInk : Colors.black,
          ),
        ),
      ),
    );
  }
}
