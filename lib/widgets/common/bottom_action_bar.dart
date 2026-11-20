import 'package:flutter/material.dart';

import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import 'app_button.dart';

/// the fixed bar at the bottom of a screen with one primary button (Book,
/// Confirm, Apply...), above the home indicator: 78 tall (15 / 48 / 15), top
/// radius 16, the 374 x 48 Figma button inside.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// optional content above the button (an error banner, for instance)
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        20.rw,
        15.rh,
        20.rw,
        15.rh + bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.vertical(
          top: Radius.circular(16.r),
        ),
        border: const Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, SizedBox(height: 10.rh)],
          AppButton(
            label: label,
            isLoading: isLoading,
            onPressed: onPressed,
            figma: true,
          ),
        ],
      ),
    );
  }
}
