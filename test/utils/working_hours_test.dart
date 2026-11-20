import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:farabi_booking_app/data/models/discovery/discovery_models.dart';
import 'package:farabi_booking_app/utils/working_hours.dart';

WorkingDayDataModel day(
  int d, [
  String start = '14:00:00',
  String end = '20:00:00',
]) => WorkingDayDataModel(
  dayOfWeek: d,
  shifts: [WorkingShiftDataModel(start: start, end: end)],
);

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  test('merges consecutive days with the same shift', () {
    final lines = summarizeWorkingHours(
      [day(1), day(2), day(3), day(4), day(5)],
      locale: 'en',
      to: 'to',
    );
    expect(lines, ['Monday to Friday, 02:00 PM to 08:00 PM']);
  });

  test('splits when the shift changes or a day is missing', () {
    final lines = summarizeWorkingHours(
      [day(0), day(1), day(3, '09:00:00', '12:00:00')],
      locale: 'en',
      to: 'to',
    );
    expect(lines, [
      'Sunday to Monday, 02:00 PM to 08:00 PM',
      'Wednesday, 09:00 AM to 12:00 PM',
    ]);
  });

  test('a day without shifts is closed and omitted', () {
    final lines = summarizeWorkingHours(
      [const WorkingDayDataModel(dayOfWeek: 2), day(3)],
      locale: 'en',
      to: 'to',
    );
    expect(lines, ['Wednesday, 02:00 PM to 08:00 PM']);
  });

  test('no hours gives no lines', () {
    expect(summarizeWorkingHours(const [], locale: 'en', to: 'to'), isEmpty);
  });
}
