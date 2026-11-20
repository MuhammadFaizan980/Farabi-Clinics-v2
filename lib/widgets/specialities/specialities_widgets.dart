import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
      padding: EdgeInsetsDirectional.all(16.r),
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
          SizedBox(height: 14.rh),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final service in services) ...[
                  _Tile(
                    service: service,
                    selected: service.id == selectedId,
                    language: language,
                    onTap: () => onSelected(service),
                  ),
                  SizedBox(width: 14.rw),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
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
        child: SizedBox(
          width: 76.rw,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64.rw,
                    height: 64.rw,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.redSelected6
                          : AppColors.listBackground,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color:
                            selected ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: (image == null || image.isEmpty)
                        ? fallback
                        : CachedNetworkImage(
                            imageUrl: image,
                            width: 36.rw,
                            height: 36.rw,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => fallback,
                          ),
                  ),
                  if (selected)
                    PositionedDirectional(
                      top: -6.rh,
                      end: -6.rw,
                      child: Container(
                        width: 20.rw,
                        height: 20.rw,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 13.rw,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.rh),
              Text(
                service.names.display(language),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.rowTitle.copyWith(color: AppColors.ink),
              ),
            ],
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
  });

  final ServiceWithDoctors entry;
  final String language;
  final void Function(DoctorDataModel doctor) onDoctorTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.service.names.display(language),
            style: AppTextStyles.listCardTitle.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: 4.rh),
          Row(
            children: [
              Container(
                width: 6.rw,
                height: 6.rw,
                decoration: const BoxDecoration(
                  color: Color(0xFF3DB26B),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.rw),
              Text(
                LocaleKeys.specialities_doctors_available
                    .tr(args: ['${entry.doctorCount}']),
                style: AppTextStyles.cardSubtitle
                    .copyWith(color: AppColors.inkSecondary),
              ),
            ],
          ),
          if (entry.doctors.isNotEmpty) ...[
            SizedBox(height: 12.rh),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final doctor in entry.doctors) ...[
                      GestureDetector(
                        onTap: () => onDoctorTap(doctor),
                        child: SizedBox(
                          width: 190.rw,
                          child: DoctorCard(
                            doctor: doctor,
                            language: language,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.rw),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
