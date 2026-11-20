import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../common/app_button.dart';

class DoctorsFilterResult {
  const DoctorsFilterResult({
    required this.gender,
    required this.regionId,
    required this.ratings,
  });

  final String? gender;
  final int? regionId;
  final Set<int> ratings;
}

/// the site's Filter sheet: accordion sections for Doctor Gender (Male /
/// Female / Any), Location (one region, from the regions api) and Doctor
/// Rating (5 to 1 stars, several allowed), then Apply Filter. the site's
/// consultation-fee slider is deliberately absent: the site never sends it to
/// the api, so there is nothing for it to filter.
Future<DoctorsFilterResult?> showDoctorsFilterSheet(
  BuildContext context, {
  required String? gender,
  required int? regionId,
  required Set<int> ratings,
  required List<RegionDataModel> regions,
  required String language,
}) {
  return showModalBottomSheet<DoctorsFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => _FilterSheet(
      gender: gender,
      regionId: regionId,
      ratings: ratings,
      regions: regions,
      language: language,
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.gender,
    required this.regionId,
    required this.ratings,
    required this.regions,
    required this.language,
  });

  final String? gender;
  final int? regionId;
  final Set<int> ratings;
  final List<RegionDataModel> regions;
  final String language;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _gender = widget.gender;
  late int? _regionId = widget.regionId;
  late Set<int> _ratings = {...widget.ratings};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.rw, 12.rh, 16.rw, 16.rh),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.rw,
                height: 4.rh,
                decoration: BoxDecoration(
                  color: AppColors.hairline8,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 14.rh),
              Text(
                LocaleKeys.doctors_filter.tr(),
                style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: 8.rh),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _Section(
                        title: LocaleKeys.doctors_gender.tr(),
                        initiallyOpen: true,
                        children: [
                          _CheckRow(
                            label: LocaleKeys.doctors_gender_male.tr(),
                            checked: _gender == 'Male',
                            onTap: () => setState(() => _gender = 'Male'),
                          ),
                          _CheckRow(
                            label: LocaleKeys.doctors_gender_female.tr(),
                            checked: _gender == 'Female',
                            onTap: () => setState(() => _gender = 'Female'),
                          ),
                          _CheckRow(
                            label: LocaleKeys.doctors_any.tr(),
                            checked: _gender == null,
                            onTap: () => setState(() => _gender = null),
                          ),
                        ],
                      ),
                      _Section(
                        title: LocaleKeys.doctors_location.tr(),
                        children: [
                          for (final region in widget.regions)
                            _CheckRow(
                              label: region.names.display(widget.language),
                              checked: _regionId == region.id,
                              onTap: () =>
                                  setState(() => _regionId = region.id),
                            ),
                        ],
                      ),
                      _Section(
                        title: LocaleKeys.doctors_rating.tr(),
                        children: [
                          for (final stars in const [5, 4, 3, 2, 1])
                            _CheckRow(
                              checked: _ratings.contains(stars),
                              onTap: () => setState(() {
                                _ratings = {..._ratings};
                                if (!_ratings.add(stars)) {
                                  _ratings.remove(stars);
                                }
                              }),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var i = 0; i < stars; i++)
                                    Icon(
                                      Icons.star_rounded,
                                      size: 18.rw,
                                      color: const Color(0xFFF7C948),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.rh),
              AppButton(
                label: LocaleKeys.doctors_apply_filter.tr(),
                onPressed: () => Navigator.pop(
                  context,
                  DoctorsFilterResult(
                    gender: _gender,
                    regionId: _regionId,
                    ratings: _ratings,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatefulWidget {
  const _Section({
    required this.title,
    required this.children,
    this.initiallyOpen = false,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyOpen;

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: 14.rh),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.rowTitle
                        .copyWith(color: AppColors.ink),
                  ),
                ),
                Icon(
                  _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.ink,
                ),
              ],
            ),
          ),
        ),
        if (_open) ...widget.children,
        Divider(height: 1, color: AppColors.hairline8),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.checked,
    required this.onTap,
    this.label,
    this.leading,
  });

  final bool checked;
  final VoidCallback onTap;
  final String? label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 8.rh),
          child: Row(
            children: [
              Container(
                width: 22.rw,
                height: 22.rw,
                decoration: BoxDecoration(
                  color: checked ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: checked ? AppColors.primary : AppColors.hairline8,
                    width: 1.5,
                  ),
                ),
                child: checked
                    ? Icon(Icons.check, size: 15.rw, color: AppColors.white)
                    : null,
              ),
              SizedBox(width: 12.rw),
              if (leading != null) leading!,
              if (label != null)
                Text(
                  label!,
                  style: AppTextStyles.cardSubtitle
                      .copyWith(color: AppColors.ink),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
