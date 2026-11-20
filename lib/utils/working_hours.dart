import 'package:intl/intl.dart';

import '../data/models/discovery/discovery_models.dart';

/// turns a branch's per-day hours into short lines such as
/// "Monday to Friday, 02:00 PM to 08:00 PM": consecutive weekdays with the
/// same shifts are merged. `to` is the localised joining word. days are
/// numbered like the api (0 is Sunday) and listed in that order.
List<String> summarizeWorkingHours(
  List<WorkingDayDataModel> days, {
  required String locale,
  required String to,
}) {
  final open = days.where((d) => d.shifts.isNotEmpty).toList()
    ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
  if (open.isEmpty) return const [];

  String clock(String raw) {
    final parts = raw.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateFormat('hh:mm a', locale)
        .format(DateTime(2000, 1, 1, hour, minute));
  }

  String shiftsOf(WorkingDayDataModel d) =>
      d.shifts.map((s) => '${clock(s.start)} $to ${clock(s.end)}').join(', ');

  // 2024-01-07 is a Sunday, so dayOfWeek maps straight onto the date
  String dayName(int dayOfWeek) => DateFormat.EEEE(locale)
      .format(DateTime(2024, 1, 7 + dayOfWeek));

  final lines = <String>[];
  var start = 0;
  while (start < open.length) {
    var end = start;
    while (end + 1 < open.length &&
        open[end + 1].dayOfWeek == open[end].dayOfWeek + 1 &&
        shiftsOf(open[end + 1]) == shiftsOf(open[start])) {
      end++;
    }
    final first = dayName(open[start].dayOfWeek);
    final last = dayName(open[end].dayOfWeek);
    final days = start == end ? first : '$first $to $last';
    lines.add('$days, ${shiftsOf(open[start])}');
    start = end + 1;
  }
  return lines;
}
