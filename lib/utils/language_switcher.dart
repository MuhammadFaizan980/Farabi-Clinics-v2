import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../app_di.dart';
import '../data/auth_session.dart';
import '../data/constants/app_locales.dart';

/// switches between English and Arabic in place, as the site's AR/EN toggle
/// does. the `lang` header is persisted first so the next request is already
/// in the new language.
Future<void> toggleAppLanguage(BuildContext context) async {
  final next = context.locale.languageCode == 'ar'
      ? AppLocales.english
      : AppLocales.arabic;
  await AppDi.locator<AuthSession>().setLanguageCode(AppLocales.apiLang(next));
  if (context.mounted) await context.setLocale(next);
}
