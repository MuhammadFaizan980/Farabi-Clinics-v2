import 'package:easy_localization/easy_localization.dart';

import '../data/constants/locale_keys.g.dart';

/// "Posted today / 5 days ago / 1 month ago / 2 months ago" from a day count
String postedAgo(int days) {
  if (days < 1) return LocaleKeys.careers_posted_today.tr();
  if (days < 30) return LocaleKeys.careers_posted_days.tr(args: ['$days']);
  if (days < 365) {
    final months = days ~/ 30;
    return months == 1
        ? LocaleKeys.careers_posted_month.tr()
        : LocaleKeys.careers_posted_months.tr(args: ['$months']);
  }
  final years = days ~/ 365;
  return years == 1
      ? LocaleKeys.careers_posted_year.tr()
      : LocaleKeys.careers_posted_years.tr(args: ['$years']);
}
