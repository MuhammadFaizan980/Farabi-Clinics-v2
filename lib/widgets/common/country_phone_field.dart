import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/phone_country.dart';
import '../../utils/phone_field_controller.dart';
import 'app_text_field.dart';

/// the site's phone input: a country box (flag and dial code, opening a
/// searchable list that is filled from the countries api) next to the number.
/// it stays left-to-right in Arabic too, as the site's does.
class CountryPhoneField extends StatelessWidget {
  const CountryPhoneField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final PhoneFieldController controller;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final selected = controller.selected;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.auth_phone_label.tr(),
              style: AppTextStyles.fieldLabel.copyWith(color: AppColors.ink),
            ),
            SizedBox(height: 8.rh),
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Container(
                height: 52.rh,
                decoration: AppFieldDecoration.box(),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: controller.options.length > 1
                          ? () => _pick(context)
                          : null,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 12.rw),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: AppColors.hairline8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selected?.flag ?? '🌐',
                              style: TextStyle(fontSize: 20.rf),
                            ),
                            SizedBox(width: 6.rw),
                            Text(
                              selected?.dial ?? '',
                              style: AppTextStyles.fieldText
                                  .copyWith(color: AppColors.ink),
                            ),
                            if (controller.options.length > 1)
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18.rw,
                                color: AppColors.iconGrey,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller.text,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                          LengthLimitingTextInputFormatter(18),
                        ],
                        onChanged: (_) => onChanged?.call(),
                        cursorColor: AppColors.primary,
                        style: AppTextStyles.fieldText
                            .copyWith(color: AppColors.ink),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsetsDirectional.symmetric(horizontal: 12.rw),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pick(BuildContext context) async {
    final chosen = await showModalBottomSheet<PhoneCountry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _CountrySheet(
        options: controller.options,
        selected: controller.selected,
        language: context.locale.languageCode,
      ),
    );
    if (chosen != null) controller.select(chosen);
  }
}

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({
    required this.options,
    required this.selected,
    required this.language,
  });

  final List<PhoneCountry> options;
  final PhoneCountry? selected;
  final String language;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // filters by name or dial code, like the site's picker
    final q = _query.trim().toLowerCase();
    final shown = widget.options.where((c) {
      if (q.isEmpty) return true;
      return c.label(widget.language).toLowerCase().contains(q) ||
          c.dial.contains(q);
    }).toList(growable: false);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                    16.rw, 16.rh, 16.rw, 8.rh),
                child: TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: LocaleKeys.auth_search_country.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: shown.isEmpty
                    ? Padding(
                        padding: EdgeInsetsDirectional.all(24.r),
                        child: Text(
                          LocaleKeys.auth_no_countries.tr(),
                          style: AppTextStyles.cardSubtitle
                              .copyWith(color: AppColors.inkSecondary),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: shown.length,
                        itemBuilder: (context, i) {
                          final c = shown[i];
                          final selected = c.code == widget.selected?.code;
                          return ListTile(
                            selected: selected,
                            selectedTileColor: AppColors.redSelected6,
                            leading: Text(c.flag,
                                style: TextStyle(fontSize: 22.rf)),
                            title: Text(c.label(widget.language)),
                            trailing: Text(
                              c.dial,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.inkSecondary),
                            ),
                            onTap: () => Navigator.pop(context, c),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
