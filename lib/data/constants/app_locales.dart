import 'dart:ui';

class AppLocales {
  AppLocales._();

  static const Locale english = Locale('en', 'US');
  static const Locale arabic = Locale('ar', 'SA');

  static const List<Locale> supported = [english, arabic];

  static const String path = 'assets/translations';

  /// the api takes a bare language code in its `lang` header
  static String apiLang(Locale locale) => locale.languageCode;
}
