import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/language_switcher.dart';
import 'app_sheet.dart';

/// the Figma "Change Language" sheet: English and العربية rows, the current one
/// tinted red with a check. choosing the other one switches the app in place,
/// exactly like the AR / EN toggle.
Future<void> showLanguageSheet(BuildContext context) {
  final current = context.locale.languageCode;

  return showAppSheet<void>(
    context,
    builder: (sheetContext) {
      Widget flag(String emoji) => Container(
            width: 32.rw,
            height: 32.rw,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.listBackground,
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: TextStyle(fontSize: 18.rf)),
          );

      Future<void> choose(String code) async {
        Navigator.of(sheetContext).pop();
        if (code != current) await toggleAppLanguage(context);
      }

      return AppSheet(
        title: LocaleKeys.more_language_sheet_title.tr(),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsetsDirectional.fromSTEB(22.rw, 0, 22.rw, 18.rh),
          children: [
            AppSheetOption(
              title: LocaleKeys.more_language_english.tr(),
              subtitle: LocaleKeys.more_language_english_sub.tr(),
              leading: flag('🇺🇸'),
              selected: current == 'en',
              onTap: () => choose('en'),
            ),
            SizedBox(height: 8.rh),
            AppSheetOption(
              title: LocaleKeys.more_language_arabic.tr(),
              subtitle: LocaleKeys.more_language_arabic_sub.tr(),
              leading: flag('🇸🇦'),
              selected: current == 'ar',
              onTap: () => choose('ar'),
            ),
          ],
        ),
      );
    },
  );
}
