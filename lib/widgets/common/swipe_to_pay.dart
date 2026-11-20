import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
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

        // the Figma track: 54 tall pill, red gradient, black 16% inner edge,
        // a white 48 knob 4 from the end with a red double chevron
        return Semantics(
          button: true,
          enabled: active,
          label: widget.label,
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.4,
            child: Container(
              height: 54.rh,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, Color(0xFFB30E0E)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    offset: Offset(2, -4),
                    blurRadius: 24,
                  ),
                ],
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(color: const Color(0x29000000), width: 1.5),
              ),
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  Center(
                    child: widget.busy
                        ? SizedBox(
                            width: 22.rw,
                            height: 22.rw,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.white,
                            ),
                          )
                        : Opacity(
                            opacity: 1 - progress,
                            child: _Label(widget.label),
                          ),
                  ),
                  PositionedDirectional(
                    start: 4 + _drag,
                    child: GestureDetector(
                      onHorizontalDragUpdate: active
                          ? (details) => setState(() {
                              final dx = rtl
                                  ? -details.delta.dx
                                  : details.delta.dx;
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
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Transform.flip(
                          flipX: rtl,
                          child: SizedBox(
                            width: 22.rw,
                            height: 16.rw,
                            child: Stack(
                              children: [
                                for (final dx in [0.0, 6.0])
                                  PositionedDirectional(
                                    start: dx.rw,
                                    child: SvgPicture.asset(
                                      AppAssets.iconChevronRightThick,
                                      width: 16.rw,
                                      height: 16.rw,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "Swipe to Pay ( ﷼ 2,500 )": the label is the api's own text, a riyal amount
/// inside it is shown with the Figma riyal sign
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.screenTitle.copyWith(
      fontSize: 16.rf,
      height: 20 / 16,
      color: AppColors.white,
    );
    final match = RegExp(r'^(.*?)([\d.,]+)\s*SAR(.*)$').firstMatch(text);
    if (match == null) return Text(text, style: style);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(match.group(1)!, style: style),
        SvgPicture.asset(
          AppAssets.iconSar,
          width: 13.rw,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
        SizedBox(width: 3.rw),
        Text('${match.group(2)}${match.group(3)}', style: style),
      ],
    );
  }
}
