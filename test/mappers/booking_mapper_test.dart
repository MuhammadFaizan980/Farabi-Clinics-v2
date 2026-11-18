import 'package:farabi_booking_app/mappers/booking_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = BookingMapper();

  group('slots', () {
    test('reads the single-doctor array wrapper', () {
      final result = mapper.slots({
        'date': '2026-11-19',
        'doctors': [
          {
            'doctor_id': 3,
            'is_off': false,
            'slots': [
              {
                'slot': 1,
                'start_time': '09:00',
                'end_time': '09:30',
                'is_bookable': true,
                'unavailable_reason': null,
              }
            ]
          }
        ]
      });

      expect(result.date, '2026-11-19');
      expect(result.isOff, isFalse);
      expect(result.slots.single.startTime, '09:00');
      // the booking payload wants HH:MM:SS
      expect(result.slots.single.startTimeApi, '09:00:00');
    });

    test('surfaces a day off as its own state, not just an empty list', () {
      final result = mapper.slots({
        'date': '2026-11-20',
        'doctors': [
          {'doctor_id': 28, 'is_off': true, 'slots': []}
        ]
      });
      expect(result.isOff, isTrue);
      expect(result.slots, isEmpty);
    });

    test('an empty doctors array is no slots, not a crash', () {
      final result = mapper.slots({'date': '2026-11-20', 'doctors': []});
      expect(result.slots, isEmpty);
      expect(result.isOff, isFalse);
    });
  });

  group('checkout context', () {
    final payload = {
      'doctor': {'id': 3, 'name': 'Dr. Ahmed Hassan'},
      'service': {'id': 19, 'name': 'Creatinine'},
      'branch': {'id': 8, 'name': 'Al-Olaya Medical Center'},
      'appointment': {
        'date': '2026-11-19',
        'start_time': '10:00:00',
        'end_time': '10:30:00',
        'duration_minutes': 30,
        'slot_available': true,
        'unavailable_reason': null,
      },
      'pricing': {'currency_symbol': 'ر.س'},
      'checkout_total': [
        {
          'title': 'Service fee',
          'slug': 'service_fee',
          'value': {'value': 45, 'formatted': '45.00 SAR'}
        }
      ],
      'total': {'value': 45, 'formatted': '45.00 SAR'},
      'is_coupon': false,
    };

    test('maps the real captured payload', () {
      final context = mapper.checkoutContext(payload)!;
      expect(context.serviceName, 'Creatinine');
      expect(context.totalFormatted, '45.00 SAR');
      expect(context.lines.single.slug, 'service_fee');
      expect(context.appointment.slotAvailable, isTrue);
    });

    test('builds the booking window verbatim from appointment', () {
      final context = mapper.checkoutContext(payload)!;
      // never computed locally — copied from the api
      expect(context.appointment.bookingStart, '2026-11-19 10:00:00');
      expect(context.appointment.bookingEnd, '2026-11-19 10:30:00');
    });

    test('carries the unavailable reason as a machine code', () {
      final context = mapper.checkoutContext({
        ...payload,
        'appointment': {
          'date': '2026-11-19',
          'start_time': '23:00:00',
          'end_time': '23:30:00',
          'slot_available': false,
          'unavailable_reason': 'outside_schedule',
        },
      })!;
      expect(context.appointment.slotAvailable, isFalse);
      expect(context.appointment.unavailableReason, 'outside_schedule');
    });
  });

  group('payment gateways', () {
    test('reads the label out of the name object', () {
      final gateways = mapper.gateways([
        {
          'slug': 'cash',
          'name': {'value': 1, 'label': 'Cash', 'label_ar': 'نقدي'},
          'logo': 'http://example/cash.svg',
        }
      ]);
      expect(gateways.single.slug, 'cash');
      // `name` is an object, not a string
      expect(gateways.single.label, 'Cash');
    });
  });

  group('create booking result', () {
    test('maps the completed-booking shape', () {
      final result = mapper.createResult({
        'id': 128,
        'booking_number': 'BK-00128',
        'status': {'value': 1, 'label': 'Created'},
        'booking_start_time': '2026-11-19T07:00:00.000000Z',
        'can_cancel': true,
        'can_reschedule': true,
        'services': [
          {
            'service': {'id': 19, 'name': 'Creatinine'},
            'quantity': 1,
            'price': '45.00'
          }
        ],
        'branch': {'name': 'Al-Olaya'},
        'doctor': {'id': 3, 'name': 'Dr. Ahmed Hassan'},
      })!;

      expect(result.needsGateway, isFalse);
      expect(result.booking!.bookingNumber, 'BK-00128');
      expect(result.booking!.serviceId, 19);
      expect(result.booking!.services.single.price, 45.0);
      // the api returns utc
      expect(result.booking!.startTimeUtc!.isUtc, isTrue);
      expect(result.booking!.startTimeUtc!.hour, 7);
    });

    test('maps the gateway shape, which carries no id', () {
      final result = mapper.createResult({
        'pending_booking_id': 64,
        'amount': '45.00',
        'currency': 'SAR',
        'checkout_reference': 'PGB-64',
        'redirect_url': 'https://secure.paytabs.sa/payment/page/abc',
        'expires_at': '2026-11-18T10:08:04.000000Z',
      })!;

      expect(result.needsGateway, isTrue);
      expect(result.pending!.pendingBookingId, 64);
      expect(result.pending!.checkoutReference, 'PGB-64');
      expect(result.pending!.expiresAt, isNotNull);
      expect(result.booking, isNull);
    });
  });

  group('booking list item', () {
    test('prefers booking_number and respects the server action flags', () {
      final booking = mapper.booking({
        'id': 128,
        'booking_number': 'BK-00128',
        'status': {'value': 6, 'label': 'Cancelled'},
        'can_cancel': false,
        'can_reschedule': false,
      })!;
      expect(booking.bookingNumber, 'BK-00128');
      expect(booking.statusValue, 6);
      expect(booking.canCancel, isFalse);
      expect(booking.canReschedule, isFalse);
    });

    test('falls back to the id when booking_number is missing', () {
      expect(mapper.booking({'id': 7})!.bookingNumber, '7');
    });
  });
}
