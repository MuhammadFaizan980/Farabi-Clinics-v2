import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../screens/tabs/specialities/specialities_vm.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../discovery/doctor_card.dart';

/// the "Choose Speciality" card: one selectable icon tile per main service.
/// the icon is the service's own `image_url`; a service without one gets a
/// plain medical glyph. the selected tile has a red border and a check badge.
class SpecialityPicker extends StatelessWidget {
  const SpecialityPicker({
    super.key,
    required this.title,
    required this.services,
    required this.selectedId,
    required this.language,
    required this.onSelected,
  });

  final String title;
  final List<ServiceDataModel> services;
  final int? selectedId;
  final String language;
  final ValueChanged<ServiceDataModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 14.rh, 16.rw, 18.rh),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: 5.rh),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < services.length; i++) ...[
                  if (i > 0) SizedBox(width: 16.rw),
                  SpecialityTile(
                    service: services[i],
                    selected: services[i].id == selectedId,
                    language: language,
                    onTap: () => onSelected(services[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// one speciality tile; also used by the branch page's "Choose Speciality" card
class SpecialityTile extends StatelessWidget {
  const SpecialityTile({
    super.key,
    required this.service,
    required this.selected,
    required this.language,
    required this.onTap,
  });

  final ServiceDataModel service;
  final bool selected;
  final String language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = service.imageUrl;
    final fallback = Icon(
      Icons.medical_services_outlined,
      size: 28.rw,
      color: AppColors.primary,
    );

    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 56.rw, maxWidth: 96.rw),
          child: IntrinsicWidth(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56.rw,
                      height: 56.rw,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.redSelected6
                            : const Color(0x051D1D24),
                        borderRadius: BorderRadius.circular(14.r),
                        border: selected
                            ? Border.all(color: AppColors.primary, width: 1.25)
                            : null,
                      ),
                      child: (image == null || image.isEmpty)
                          ? fallback
                          : CachedNetworkImage(
                              imageUrl: image,
                              width: 30.rw,
                              height: 30.rw,
                              fit: BoxFit.contain,
                              errorWidget: (_, __, ___) => fallback,
                            ),
                    ),
                    if (selected)
                      PositionedDirectional(
                        top: -4.rh,
                        end: -4.rw,
                        child: Container(
                          width: 16.rw,
                          height: 16.rw,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 11.rw,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.rh),
                Text(
                  service.names.display(language),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tileLabel.copyWith(
                    color: AppColors.ink,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// a service with its "N Doctors Available" line and a horizontal rail of
/// doctor cards; tapping a card opens the doctor's profile. a service with no
/// doctors is just the title and the count, like the site.
class SpecialityServiceCard extends StatelessWidget {
  const SpecialityServiceCard({
    super.key,
    required this.entry,
    required this.language,
    required this.onDoctorTap,
    this.emptyChild,
    this.loading = false,
  });

  /// shows an ellipsis instead of the doctor count while the doctors load
  final bool loading;

  /// shown under the count when the service has no doctors
  final Widget? emptyChild;

  final ServiceWithDoctors entry;
  final String language;
  final void Function(DoctorDataModel doctor) onDoctorTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.only(top: 12.rh, bottom: 16.rh),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 18.rw, end: 12.rw),
            child: Text(
              entry.service.names.display(language),
              style: AppTextStyles.listCardTitle.copyWith(color: AppColors.ink),
            ),
          ),
          SizedBox(height: 2.rh),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 22.rw),
            child: Row(
              children: [
                _AvailableDot(),
                SizedBox(width: 10.rw),
                Text(
                  LocaleKeys.specialities_doctors_available.tr(
                    args: ['${entry.doctorCount}'],
                  ),
                  style: AppTextStyles.doctorsAvailable.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (entry.doctors.isEmpty && emptyChild != null) ...[
            SizedBox(height: 12.rh),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 12.rw),
              child: emptyChild!,
            ),
          ],
          if (entry.doctors.isNotEmpty) ...[
            SizedBox(height: 12.rh),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsetsDirectional.symmetric(horizontal: 12.rw),
              child: Row(
                children: [
                  for (var i = 0; i < entry.doctors.length; i++) ...[
                    if (i > 0) SizedBox(width: 8.rw),
                    GestureDetector(
                      onTap: () => onDoctorTap(entry.doctors[i]),
                      child: _RailDoctorCard(
                        doctor: entry.doctors[i],
                        language: language,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// the green "available" dot: a 5px dot with a soft 12px halo
class _AvailableDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11.rw,
      height: 11.rw,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFCEF0DA),
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 5.rw,
        height: 5.rw,
        decoration: const BoxDecoration(
          color: Color(0xFF2AC564),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// the 220 x 248 card of the specialities rail: a 208 x 154 photo panel inset
/// by 6, the rating chip 12 from the top right, the name (17 / 26 bold) and a
/// branch line (15 / 26) with a pin.
class _RailDoctorCard extends StatelessWidget {
  const _RailDoctorCard({required this.doctor, required this.language});

  final DoctorDataModel doctor;
  final String language;

  @override
  Widget build(BuildContext context) {
    final image = doctor.image;
    final branch = doctor.primaryBranch?.name;
    final placeholder = Icon(
      Icons.person_outline,
      size: 56.rw,
      color: AppColors.primary.withValues(alpha: 0.35),
    );

    return Container(
      width: 220.rw,
      height: 248.rh,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: 6.rh,
            start: 6.rw,
            end: 6.rw,
            height: 154.rh,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
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
                    child: (image == null || image.isEmpty)
                        ? placeholder
                        : CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            errorWidget: (_, __, ___) => placeholder,
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (doctor.ratingCount > 0)
            PositionedDirectional(
              top: 12.rh,
              end: 12.rw,
              child: DoctorRatingPill(rating: doctor.ratingAverage),
            ),
          PositionedDirectional(
            top: 177.5.rh,
            start: 14.rw,
            end: 8.rw,
            child: Text(
              doctor.names.display(language),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.listCardTitle.copyWith(color: AppColors.ink),
            ),
          ),
          if (branch != null)
            PositionedDirectional(
              top: 203.5.rh,
              start: 12.rw,
              end: 8.rw,
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.iconLocationPin,
                    width: 20.rw,
                    height: 20.rw,
                  ),
                  SizedBox(width: 6.rw),
                  Expanded(
                    child: Text(
                      branch,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
