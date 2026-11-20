import 'package:flutter/material.dart';

import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import 'app_button.dart';

/// the fixed bar at the bottom of a screen with one primary button (Book,
/// Confirm, Apply...), above the home indicator.
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
      padding: EdgeInsetsDirectional.fromSTEB(16.rw, 12.rh, 16.rw, 12.rh + bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, SizedBox(height: 10.rh)],
          AppButton(label: label, isLoading: isLoading, onPressed: onPressed),
        ],
      ),
    );
  }
}
