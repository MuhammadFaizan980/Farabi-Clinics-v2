import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';

/// the field box used across the app: 52 tall, radius 14, `#FBFBFB` fill and a
/// black 8% hairline (the doctors search pill's tokens). focus draws the brand
/// red border, an error draws the error red.
class AppFieldDecoration {
  AppFieldDecoration._();

  static BoxDecoration box({bool focused = false, bool hasError = false}) {
    final Color color = hasError
        ? AppColors.error
        : focused
            ? AppColors.primary
            : AppColors.hairline8;
    return BoxDecoration(
      color: AppColors.fieldFill,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: color, width: focused || hasError ? 1.5 : 1),
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.maxLength,
    this.digitsOnly = false,
    this.onChanged,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.letterSpacing,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;

  /// already-localised message. the view model decides when this is non-null.
  final String? errorText;

  /// a password field. it gets its own show / hide eye, starting hidden.
  final bool obscure;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool digitsOnly;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final double? letterSpacing;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focus = FocusNode();
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final textStyle = AppTextStyles.fieldText.copyWith(
      color: AppColors.ink,
      letterSpacing: widget.letterSpacing,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.fieldLabel.copyWith(color: AppColors.ink),
        ),
        SizedBox(height: 8.rh),
        Container(
          height: 52.rh,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
          decoration: AppFieldDecoration.box(
            focused: _focus.hasFocus,
            hasError: hasError,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: _hidden,
                  keyboardType: widget.keyboardType,
                  maxLength: widget.maxLength,
                  textInputAction: widget.textInputAction,
                  textAlign: widget.textAlign,
                  onChanged: widget.onChanged,
                  inputFormatters: widget.digitsOnly
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  cursorColor: AppColors.primary,
                  style: textStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.fieldText.copyWith(
                      color: AppColors.inkSecondary.withValues(alpha: 0.64),
                    ),
                  ),
                ),
              ),
              if (widget.obscure)
                GestureDetector(
                  onTap: () => setState(() => _hidden = !_hidden),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 8.rw),
                    child: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20.rw,
                      color: AppColors.iconGrey,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsetsDirectional.only(top: 6.rh, start: 2.rw),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14.rw, color: AppColors.error),
                SizedBox(width: 4.rw),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: AppTextStyles.fieldError
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
