import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/support/support_models.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// offers carousel: 373 x 169, radius 16, with the pagination dots sitting 16
/// above the bottom edge (active dot 13, inactive 6). the images are the
/// offers' own, so this renders nothing until the api returns offers.
class HomeBanner extends StatelessWidget {
  const HomeBanner({
    super.key,
    required this.offers,
    required this.index,
    required this.onIndexChanged,
  });

  final List<OfferDataModel> offers;
  final int index;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 169.rh,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: offers.length,
              onPageChanged: onIndexChanged,
              itemBuilder: (context, i) {
                final image = offers[i].image;
                if (image == null || image.isEmpty) {
                  return const ColoredBox(color: AppColors.primary);
                }
                return CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      const ColoredBox(color: AppColors.primary),
                );
              },
            ),
            if (offers.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16.rh,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < offers.length; i++)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 3.rw),
                        child: _Dot(active: i == index),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final size = (active ? 13 : 6).rw;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.white : AppColors.white.withValues(alpha: 0.5),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  offset: Offset(0, 4.rh),
                  blurRadius: 4.r,
                ),
              ]
            : null,
      ),
    );
  }
}
