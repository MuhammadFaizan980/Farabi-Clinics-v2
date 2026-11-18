@Tags(['live'])
library;

import 'dart:io';

import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/enums/booking_status.dart';
import 'package:farabi_booking_app/data/models/auth/login_request_model.dart';
import 'package:farabi_booking_app/data/models/booking/booking_models.dart';
import 'package:farabi_booking_app/data/network/api_client.dart';
import 'package:farabi_booking_app/data/network/end_points.dart';
import 'package:farabi_booking_app/repos/auth/login_repo.dart';
import 'package:farabi_booking_app/repos/auth/login_repo_imp.dart';
import 'package:farabi_booking_app/repos/booking/bookings_repo.dart';
import 'package:farabi_booking_app/repos/booking/bookings_repo_imp.dart';
import 'package:farabi_booking_app/repos/booking/checkout_repo.dart';
import 'package:farabi_booking_app/repos/booking/checkout_repo_imp.dart';
import 'package:farabi_booking_app/repos/booking/slots_repo.dart';
import 'package:farabi_booking_app/repos/booking/slots_repo_imp.dart';
import 'package:farabi_booking_app/repos/discovery/branches_repo.dart';
import 'package:farabi_booking_app/repos/discovery/branches_repo_imp.dart';
import 'package:farabi_booking_app/repos/discovery/services_repo.dart';
import 'package:farabi_booking_app/repos/discovery/services_repo_imp.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/test_credentials.dart';

/// the whole booking chain against the real dev api, through the app's repos.
/// it creates a real booking and cancels it again at the end.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    HttpOverrides.global = null;
  });

  // no account supplied -> skip rather than fail with a confusing 401
  if (!TestCredentials.available) {
    test('live tests skipped', () {}, skip: TestCredentials.missing);
    return;
  }

  final testMobile = TestCredentials.mobile;
  final testPassword = TestCredentials.password;

  late AuthSession session;

  setUp(() async {
    await AppDi.reset();
    session = AuthSession(FakeLocalData());
    await session.restore();
    AppDi.locator
      ..registerSingleton<AuthSession>(session)
      ..registerSingleton<ApiClient>(
        ApiClient(
          session: session,
          baseUrl: EndPoints.baseUrlDev,
          enableLogging: false,
        ),
      )
      ..registerSingleton<LoginRepo>(LoginRepoImp())
      ..registerSingleton<ServicesRepo>(ServicesRepoImp())
      ..registerSingleton<BranchesRepo>(BranchesRepoImp())
      ..registerSingleton<SlotsRepo>(SlotsRepoImp())
      ..registerSingleton<CheckoutRepo>(CheckoutRepoImp())
      ..registerSingleton<BookingsRepo>(BookingsRepoImp());

    final login = await AppDi.locator<LoginRepo>().login(
      LoginRequestModel(mobile: testMobile, password: testPassword),
    );
    await session.setToken(login.data!.token);
  });

  tearDown(() => AppDi.reset());

  String apiDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  test('payment gateways load once authenticated', () async {
    final response = await AppDi.locator<CheckoutRepo>().gateways();
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data!.map((g) => g.slug), contains('cash'));
    // name is an object; the mapper must have pulled a real label out
    expect(response.data!.first.label, isNotEmpty);
  });

  test('bookings list rejects a string status and accepts an integer',
      () async {
    // the api wants an int here; this is the call the website gets wrong
    final ok = await AppDi.locator<BookingsRepo>()
        .bookings(status: BookingStatus.created.value);
    expect(ok.success, isTrue, reason: ok.message ?? '');

    final all = await AppDi.locator<BookingsRepo>().bookings();
    expect(all.success, isTrue);
  });

  test('checkout-context reports a lost slot instead of failing', () async {
    // a time well outside the doctor's shift
    final response = await AppDi.locator<CheckoutRepo>().context(
      doctorId: 3,
      serviceId: 19,
      branchId: 8,
      date: apiDate(DateTime.now().add(const Duration(days: 1))),
      time: '23:00:00',
    );

    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data!.appointment.slotAvailable, isFalse);
    expect(
      response.data!.appointment.unavailableReason,
      'outside_schedule',
    );
  });

  test('an invalid coupon comes back as a field error', () async {
    final response = await AppDi.locator<CheckoutRepo>().context(
      doctorId: 3,
      serviceId: 19,
      branchId: 8,
      date: apiDate(DateTime.now().add(const Duration(days: 1))),
      time: '10:00:00',
      couponCode: 'BOGUS123',
    );

    expect(response.success, isFalse);
    expect(response.isValidationError, isTrue);
    expect(response.fieldErrors['coupon_code'], isNotEmpty);
  });

  test('full chain: services → branches → slots → context → book → cancel',
      () async {
    // 1. bookable services for the doctor
    final services =
        await AppDi.locator<ServicesRepo>().services(doctorId: 3);
    expect(services.success, isTrue);
    final serviceId = services.data!.first.id;

    // 2. branches that offer it
    final branches = await AppDi.locator<BranchesRepo>()
        .branches(doctorId: 3, serviceId: serviceId);
    expect(branches.success, isTrue);
    expect(branches.data, isNotEmpty);
    final branchId = branches.data!.first.id;

    // 3. find a day with a bookable slot
    SlotDataModel? slot;
    String? day;
    for (var offset = 1; offset <= 7 && slot == null; offset++) {
      final date = apiDate(DateTime.now().add(Duration(days: offset)));
      final slots = await AppDi.locator<SlotsRepo>()
          .slots(doctorId: 3, serviceId: serviceId, date: date);
      if (!slots.success || slots.data!.isOff) continue;
      final free = slots.data!.slots.where((s) => s.isBookable).toList();
      if (free.isNotEmpty) {
        slot = free[free.length ~/ 2];
        day = date;
      }
    }
    expect(slot, isNotNull, reason: 'no bookable slot in the next week');

    // 4. price it and confirm the slot is live
    final context = await AppDi.locator<CheckoutRepo>().context(
      doctorId: 3,
      serviceId: serviceId,
      branchId: branchId,
      date: day!,
      time: slot!.startTimeApi,
    );
    expect(context.success, isTrue, reason: context.message ?? '');
    expect(context.data!.appointment.slotAvailable, isTrue);

    // 5. book it, using the window the api handed back
    final created = await AppDi.locator<CheckoutRepo>().createBooking(
      CreateBookingRequestModel(
        branchId: branchId,
        doctorId: 3,
        bookingStartTime: context.data!.appointment.bookingStart,
        bookingEndTime: context.data!.appointment.bookingEnd,
        serviceId: serviceId,
        paymentMethod: 'cash',
      ),
    );
    expect(created.success, isTrue, reason: created.message ?? '');
    expect(created.data!.needsGateway, isFalse);

    final booking = created.data!.booking!;
    expect(booking.bookingNumber, startsWith('BK-'));
    expect(booking.statusValue, BookingStatus.created.value);
    expect(booking.canCancel, isTrue);

    // 6. it shows up under status 1
    final listed = await AppDi.locator<BookingsRepo>()
        .bookings(status: BookingStatus.created.value);
    expect(
      listed.data!.map((b) => b.id),
      contains(booking.id),
    );

    // 7. clean up after ourselves
    final cancelled =
        await AppDi.locator<BookingsRepo>().cancel(booking.id);
    expect(cancelled.success, isTrue, reason: cancelled.message ?? '');
    expect(cancelled.data!.statusValue, BookingStatus.cancelled.value);
    expect(cancelled.data!.canCancel, isFalse);
  });
}
