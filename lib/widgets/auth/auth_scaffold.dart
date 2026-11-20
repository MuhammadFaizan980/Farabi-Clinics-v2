import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// shared frame for every signed-out screen. there are no auth frames in the
/// figma file, so this carries the concept of the booking frames: the red header
/// block (bottom radius 16) with the white FARABI wordmark, and a white card
/// (radius 16, 1px border, soft shadow) that overlaps the header and holds the
/// title, fields and actions on the `#F8F8F8` canvas.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    this.title,
    required this.child,
    this.subtitle,
    this.showBack = true,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final canPop = showBack && Navigator.of(context).canPop();
    final headerHeight = top + 150.rh;

    return Scaffold(
      backgroundColor: AppColors.listBackground,
      resizeToAvoidBottomInset: true,
      body: Stack(
        // without this the stack shrinks to the header and clips the card
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: headerHeight,
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
            top: top + 38.rh,
            child: Center(
              child: SvgPicture.asset(
                AppAssets.logoWordmarkWhite,
                width: 128.rw,
                height: 26.rh,
              ),
            ),
          ),
          if (canPop)
            PositionedDirectional(
              start: 8.rw,
              top: top + 28.rh,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20.rw,
                  color: AppColors.white,
                ),
              ),
            ),
          Positioned.fill(
            top: top + 96.rh,
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(16.rw, 0, 16.rw, 24.rh),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: Container(
                width: double.infinity,
                padding: EdgeInsetsDirectional.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.statShadow,
                      offset: Offset(0, 4.rh),
                      blurRadius: 8.r,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: AppTextStyles.authTitle
                            .copyWith(color: AppColors.ink),
                      ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.rh),
                      Text(
                        subtitle!,
                        style: AppTextStyles.authSubtitle
                            .copyWith(color: AppColors.inkSecondary),
                      ),
                    ],
                    if (title != null) SizedBox(height: 20.rh),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// a red inline link, used for "forgot password", "sign up" and similar.
class AuthLink extends StatelessWidget {
  const AuthLink({
    super.key,
    required this.label,
    required this.onTap,
    this.underline = true,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final bool underline;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 6.rh),
        child: Text(
          label,
          style: AppTextStyles.link.copyWith(
            color: tint,
            decoration: underline ? TextDecoration.underline : null,
            decorationColor: tint,
          ),
        ),
      ),
    );
  }
}
