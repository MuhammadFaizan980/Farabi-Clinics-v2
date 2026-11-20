import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../sheet/app_sheet.dart';

/// a labelled select that looks like the text fields. tapping it opens the
/// app's bottom sheet with the options, never a Material dropdown overlay.
/// the options are still given as [DropdownMenuItem]s whose child is a Text,
/// so existing screens keep their call sites.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
  });

  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  static String _labelOf(DropdownMenuItem item) {
    final child = item.child;
    if (child is Text) return child.data ?? child.textSpan?.toPlainText() ?? '';
    return '${item.value}';
  }

  @override
  Widget build(BuildContext context) {
    String? selectedLabel;
    for (final item in items) {
      if (item.value == value) selectedLabel = _labelOf(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.fieldLabel.copyWith(color: AppColors.ink),
        ),
        SizedBox(height: 8.rh),
        AppSelectBox(
          text: selectedLabel,
          hint: hint,
          onTap: () => _open(context),
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context) async {
    if (items.isEmpty) return;
    FocusScope.of(context).unfocus();

    final pick = await showSelectSheet<T?>(
      context,
      title: label.replaceAll('*', '').trim(),
      selected: value,
      searchable: items.length > 8,
      searchHint: LocaleKeys.common_search.tr(),
      options: [
        for (final item in items)
          SheetOption<T?>(value: item.value, label: _labelOf(item)),
      ],
    );
    if (pick != null) onChanged(pick.value);
  }
}
