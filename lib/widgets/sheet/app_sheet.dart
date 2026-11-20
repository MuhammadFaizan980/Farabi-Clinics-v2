import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/constants/app_assets.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';

/// the app's one bottom sheet. every choice, confirmation and picker that used
/// to be a Material dialog, popup menu or dropdown opens through here, so they
/// all read as a continuation of the screens, like the Figma sheets: a white
/// card floating 8 in from the edges with a 40 radius over a soft dim, a grab
/// handle, a centred 18 bold title, 12 radius option rows (the chosen one
/// tinted red with a red border and check), and the red 48 button at the
/// bottom.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x73000000),
    elevation: 0,
    builder: (sheetContext) => Padding(
      // the Figma sheets float: 8 in from each side and 8 above the bottom
      padding: EdgeInsetsDirectional.fromSTEB(8.rw, 0, 8.rw, 8.rh),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(40.r),
          border: Border.all(color: const Color(0x1F000000)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.r),
          child: builder(sheetContext),
        ),
      ),
    ),
  );
}

/// the body of a sheet: handle, title, optional subtitle, scrolling content and
/// a fixed actions area. it lifts above the keyboard and the home indicator.
class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.actions = const [],
    this.header,
    this.maxHeightFactor = 0.85,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;

  /// extra widget between the title block and the content (a search field)
  final Widget? header;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * maxHeightFactor,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 14.rh),
              Center(
                child: Container(
                  width: 34.rw,
                  height: 3.rh,
                  decoration: BoxDecoration(
                    color: const Color(0x33211722),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              if (title != null) ...[
                SizedBox(height: 14.rh),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 24.rw),
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.listCardTitle.copyWith(
                      color: AppColors.ink,
                      fontSize: 18.rf,
                      height: 24 / 18,
                    ),
                  ),
                ),
              ],
              if (subtitle != null) ...[
                SizedBox(height: 4.rh),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 24.rw),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.profileBody.copyWith(
                      color: AppColors.inkSecondary,
                      fontSize: 14.rf,
                      height: 20 / 14,
                    ),
                  ),
                ),
              ],
              if (header != null) ...[
                SizedBox(height: 12.rh),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 22.rw),
                  child: header!,
                ),
              ],
              SizedBox(height: 14.rh),
              Flexible(child: child),
              if (actions.isNotEmpty)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    22.rw,
                    12.rh,
                    22.rw,
                    18.rh,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0) SizedBox(height: 8.rh),
                        actions[i],
                      ],
                    ],
                  ),
                )
              else
                SizedBox(height: 12.rh),
            ],
          ),
        ),
      ),
    );
  }
}

/// one selectable row of a sheet: radius 12, 62 tall, a light hairline, an optional leading
/// widget (icon tile, flag), a semibold title with an optional grey subtitle,
/// and a red check when chosen. the chosen row is tinted red with a red border.
class AppSheetOption extends StatelessWidget {
  const AppSheetOption({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  /// shown instead of the check badge when the row is not chosen
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: BoxConstraints(minHeight: 62.rh),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 16.rw,
            vertical: 10.rh,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.redSelected6 : AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0x14211722),
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, SizedBox(width: 12.rw)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.rowTitle.copyWith(
                        color: AppColors.ink,
                        height: 20 / 15,
                      ),
                    ),
                    if ((subtitle ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.rh),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.branchAddress.copyWith(
                          color: AppColors.inkSecondary,
                          fontWeight: FontWeight.w400,
                          height: 18 / 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected) ...[
                SizedBox(width: 12.rw),
                Icon(Icons.check, size: 20.rw, color: AppColors.primary),
              ] else if (trailing != null) ...[
                SizedBox(width: 12.rw),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// the outlined secondary button of a sheet (Cancel, Keep it): white, radius
/// 10, 4% hairline, grey semibold label, 48 tall like the red one.
class AppSheetSecondaryButton extends StatelessWidget {
  const AppSheetSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 48.rh,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0x14211722)),
          ),
          child: Text(
            label,
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: 16.rf,
              height: 20 / 16,
              color: AppColors.inkSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// one entry of a select sheet. [value] may be null ("All departments").
class SheetOption<T> {
  const SheetOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.leading,
  });

  final T value;
  final String label;
  final String? subtitle;
  final Widget? leading;
}

/// what a select sheet answers, so choosing a null value is told apart from
/// closing the sheet (which answers nothing at all).
class SheetPick<T> {
  const SheetPick(this.value);

  final T value;
}

/// a single-choice sheet: the replacement for dropdowns and popup menus.
/// a long list (or [searchable]) gets a search field. returns null when the
/// sheet is dismissed.
Future<SheetPick<T>?> showSelectSheet<T>(
  BuildContext context, {
  required String title,
  required List<SheetOption<T>> options,
  required T? selected,
  String? subtitle,
  bool? searchable,
  String? searchHint,
  String? emptyLabel,
}) {
  return showAppSheet<SheetPick<T>>(
    context,
    builder: (_) => _SelectSheet<T>(
      title: title,
      subtitle: subtitle,
      options: options,
      selected: selected,
      searchable: searchable ?? options.length > 8,
      searchHint: searchHint,
      emptyLabel: emptyLabel,
    ),
  );
}

class _SelectSheet<T> extends StatefulWidget {
  const _SelectSheet({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.searchable,
    required this.searchHint,
    required this.emptyLabel,
  });

  final String title;
  final String? subtitle;
  final List<SheetOption<T>> options;
  final T? selected;
  final bool searchable;
  final String? searchHint;
  final String? emptyLabel;

  @override
  State<_SelectSheet<T>> createState() => _SelectSheetState<T>();
}

class _SelectSheetState<T> extends State<_SelectSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = widget.options
        .where((o) => q.isEmpty || o.label.toLowerCase().contains(q))
        .toList(growable: false);

    return AppSheet(
      title: widget.title,
      subtitle: widget.subtitle,
      header: widget.searchable
          ? AppSheetSearchField(
              hint: widget.searchHint ?? '',
              onChanged: (v) => setState(() => _query = v),
            )
          : null,
      child: shown.isEmpty
          ? Padding(
              padding: EdgeInsetsDirectional.all(24.r),
              child: Text(
                widget.emptyLabel ?? '',
                textAlign: TextAlign.center,
                style: AppTextStyles.profileBody.copyWith(
                  color: AppColors.inkSecondary,
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsetsDirectional.fromSTEB(16.rw, 0, 16.rw, 8.rh),
              itemCount: shown.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.rh),
              itemBuilder: (context, i) {
                final option = shown[i];
                return AppSheetOption(
                  title: option.label,
                  subtitle: option.subtitle,
                  leading: option.leading,
                  selected: option.value == widget.selected,
                  onTap: () =>
                      Navigator.of(context).pop(SheetPick<T>(option.value)),
                );
              },
            ),
    );
  }
}

/// the search field used inside sheets: the app's pill search look (light fill,
/// 8% hairline, grey magnifier)
class AppSheetSearchField extends StatelessWidget {
  const AppSheetSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.rh,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.hairline8),
      ),
      child: Row(
        children: [
          SvgPicture.asset(AppAssets.iconSearch, width: 18.rw, height: 18.rw),
          SizedBox(width: 8.rw),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              cursorColor: AppColors.primary,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.searchHint.copyWith(color: Colors.black),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTextStyles.searchHint.copyWith(
                  color: const Color(0xFF525252).withValues(alpha: 0.64),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// a yes / no sheet: the replacement for AlertDialog. a tinted round icon, a
/// centred title and message, the red confirm button over an outlined cancel.
/// answers true only when the confirm button is pressed.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  IconData icon = Icons.help_outline,
}) async {
  final result = await showAppSheet<bool>(
    context,
    builder: (sheetContext) => AppSheet(
      actions: [
        AppButton(
          label: confirmLabel,
          figma: true,
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        AppSheetSecondaryButton(
          label: cancelLabel,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 24.rw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 2.rh),
            Container(
              width: 56.rw,
              height: 56.rw,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0x3DCC1C1C),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26.rw, color: AppColors.primary),
            ),
            SizedBox(height: 16.rh),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.listCardTitle.copyWith(
                color: AppColors.ink,
                fontSize: 18.rf,
                height: 24 / 18,
              ),
            ),
            SizedBox(height: 6.rh),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.profileBody.copyWith(
                color: AppColors.inkSecondary,
                fontSize: 14.rf,
                height: 20 / 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// the tappable field that opens a select sheet: the same box as the text
/// fields (14 radius, light fill, hairline) with the value or hint and the
/// app's chevron.
class AppSelectBox extends StatelessWidget {
  const AppSelectBox({
    super.key,
    required this.onTap,
    this.text,
    this.hint,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final String? text;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasText = (text ?? '').isNotEmpty;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52.rh,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
        decoration: AppFieldDecoration.box(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasText ? text! : (hint ?? ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.fieldText.copyWith(
                  color: hasText
                      ? AppColors.ink
                      : AppColors.inkSecondary.withValues(alpha: 0.64),
                ),
              ),
            ),
            SizedBox(width: 8.rw),
            SvgPicture.asset(
              AppAssets.iconChevronDown,
              width: 11.rw,
              height: 7.rw,
            ),
          ],
        ),
      ),
    );
  }
}
