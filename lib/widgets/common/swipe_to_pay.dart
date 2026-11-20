import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// the site's "Swipe to Pay" control: drag the knob across the track to
/// confirm. releasing early snaps it back; reaching the end fires [onSwiped]
/// once. disabled, it ignores drags. direction follows the text direction.
class SwipeToPay extends StatefulWidget {
  const SwipeToPay({
    super.key,
    required this.label,
    required this.onSwiped,
    this.enabled = true,
    this.busy = false,
  });

  final String label;
  final VoidCallback onSwiped;
  final bool enabled;
  final bool busy;

  @override
  State<SwipeToPay> createState() => _SwipeToPayState();
}

class _SwipeToPayState extends State<SwipeToPay> {
  double _drag = 0;

  @override
  Widget build(BuildContext context) {
    final knob = 48.rw;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final active = widget.enabled && !widget.busy;

    return LayoutBuilder(
      builder: (context, constraints) {
        final travel = constraints.maxWidth - knob - 8;
        final progress = travel <= 0 ? 0.0 : (_drag / travel).clamp(0.0, 1.0);

        return Semantics(
          button: true,
          enabled: active,
          label: widget.label,
          child: Container(
            height: 56.rh,
            decoration: BoxDecoration(
              color: active ? AppColors.redSelected6 : AppColors.hairline8,
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.hairline8,
              ),
            ),
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                Center(
                  child: widget.busy
                      ? SizedBox(
                          width: 22.rw,
                          height: 22.rw,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.primary,
                          ),
                        )
                      : Opacity(
                          opacity: 1 - progress,
                          child: Text(
                            widget.label,
                            style: AppTextStyles.rowTitle.copyWith(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.inkSecondary,
                            ),
                          ),
                        ),
                ),
                PositionedDirectional(
                  start: 4 + _drag,
                  child: GestureDetector(
                    onHorizontalDragUpdate: active
                        ? (details) => setState(() {
                              final dx = rtl ? -details.delta.dx : details.delta.dx;
                              _drag = (_drag + dx).clamp(0.0, travel);
                            })
                        : null,
                    onHorizontalDragEnd: active
                        ? (_) {
                            final done = travel > 0 && _drag >= travel * 0.9;
                            setState(() => _drag = 0);
                            if (done) widget.onSwiped();
                          }
                        : null,
                    child: Container(
                      width: knob,
                      height: knob,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.iconGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        rtl
                            ? Icons.keyboard_double_arrow_left
                            : Icons.keyboard_double_arrow_right,
                        color: AppColors.white,
                        size: 24.rw,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
