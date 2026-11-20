import 'package:flutter_test/flutter_test.dart';

import 'package:farabi_booking_app/data/models/booking/booking_models.dart';

void main() {
  BookingDataModel booking(DateTime? startUtc) => BookingDataModel(
        id: 1,
        bookingNumber: 'BK-1',
        statusValue: 1,
        statusLabel: 'Created',
        startTimeUtc: startUtc,
      );

  group('startClinicTime', () {
    test('shows the Riyadh wall clock (UTC+3) whatever the phone zone is', () {
      final result =
          booking(DateTime.utc(2026, 11, 20, 13, 30)).startClinicTime!;

      expect(result.hour, 16);
      expect(result.minute, 30);
      expect(result.day, 20);
    });

    test('rolls over to the next day after 21:00 UTC', () {
      final result =
          booking(DateTime.utc(2026, 11, 20, 22, 0)).startClinicTime!;

      expect(result.day, 21);
      expect(result.hour, 1);
    });

    test('is null when the booking has no start time', () {
      expect(booking(null).startClinicTime, isNull);
    });
  });
}
