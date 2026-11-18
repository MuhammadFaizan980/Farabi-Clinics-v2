import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// "Book by Service": a 373-wide white card (radius 16, 1px border) laid over
/// a slightly taller grey strip that holds the expand chevron. tiles are 56 x
/// 56, radius 13.8, and the row is space-between, like the frame.
class HomeServiceGrid extends StatelessWidget {
  const HomeServiceGrid({
    super.key,
    required this.title,
    required this.services,
    required this.language,
    required this.expanded,
    required this.canExpand,
    required this.onToggle,
    required this.onServiceTap,
  });

  final String title;
  final List<ServiceDataModel> services;
  final String language;
  final bool expanded;
  final bool canExpand;
  final VoidCallback onToggle;
  final ValueChanged<ServiceDataModel> onServiceTap;

  static const int _perRow = 4;

  @override
  Widget build(BuildContext context) {
    final rows = <List<ServiceDataModel>>[];
    for (var i = 0; i < services.length; i += _perRow) {
      rows.add(services.skip(i).take(_perRow).toList(growable: false));
    }

    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: 20.rw),
      decoration: BoxDecoration(
        color: AppColors.stripFill,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.fromSTEB(14.rw, 14.rh, 14.rw, 16.rh),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 2.rw),
                  child: Text(
                    title,
                    style: AppTextStyles.sectionTitle
                        .copyWith(color: AppColors.ink),
                  ),
                ),
                SizedBox(height: 14.rh),
                for (var r = 0; r < rows.length; r++) ...[
                  if (r > 0) SizedBox(height: 14.rh),
                  _ServiceRow(
                    services: rows[r],
                    language: language,
                    onTap: onServiceTap,
                  ),
                ],
              ],
            ),
          ),
          if (canExpand)
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 28.rh,
                width: double.infinity,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: expanded ? 2 : 0,
                    child: SvgPicture.asset(
                      AppAssets.iconChevronDown,
                      width: 9.rw,
                      height: 6.rw,
                    ),
                  ),
                ),
              ),
            )
          else
            SizedBox(height: 12.rh),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.services,
    required this.language,
    required this.onTap,
  });

  final List<ServiceDataModel> services;
  final String language;
  final ValueChanged<ServiceDataModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: services.length == _fullRow
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
      children: [
        for (var i = 0; i < services.length; i++) ...[
          if (i > 0 && services.length != _fullRow) SizedBox(width: 24.rw),
          _ServiceTile(
            service: services[i],
            language: language,
            onTap: () => onTap(services[i]),
          ),
        ],
      ],
    );
  }

  static const int _fullRow = HomeServiceGrid._perRow;
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.language,
    required this.onTap,
  });

  final ServiceDataModel service;
  final String language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = service.imageUrl;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.rw,
            height: 56.rw,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tileTint,
              borderRadius: BorderRadius.circular(13.8.r),
            ),
            child: (image == null || image.isEmpty)
                ? Icon(
                    Icons.medical_services_outlined,
                    size: 24.rw,
                    color: AppColors.primary,
                  )
                : CachedNetworkImage(
                    imageUrl: image,
                    width: 24.rw,
                    height: 24.rw,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Icon(
                      Icons.medical_services_outlined,
                      size: 24.rw,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          SizedBox(height: 12.rh),
          SizedBox(
            width: 80.rw,
            child: Text(
              service.names.display(language),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.tileLabel.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
