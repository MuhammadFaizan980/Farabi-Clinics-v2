import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/base/app_base_model.dart';
import 'package:farabi_booking_app/data/constants/locale_keys.g.dart';
import 'package:farabi_booking_app/data/models/booking/booking_models.dart';
import 'package:farabi_booking_app/data/models/discovery/discovery_models.dart';
import 'package:farabi_booking_app/repos/booking/checkout_repo.dart';
import 'package:farabi_booking_app/screens/booking/checkout_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_checkout_repo.dart';
import '../helpers/fakes.dart';

const _args = CheckoutArgsModel(
  doctor: DoctorDataModel(id: 3, names: LocalisedName(name: 'Dr Test')),
  serviceId: 19,
  branchId: 8,
  date: '2026-11-19',
  time: '10:00:00',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeCheckoutRepo repo;

  Future<CheckoutVm> boot({
    bool available = true,
    String? reason,
    double total = 45,
    bool qitaf = false,
  }) async {
    await AppDi.reset();
    final session = AuthSession(FakeLocalData());
    await session.restore();
    await session.setToken('tok');
    repo = FakeCheckoutRepo(
      fakeContext(available: available, reason: reason, total: total),
    )..qitafOn = qitaf;
    AppDi.locator
      ..registerSingleton<AuthSession>(session)
      ..registerSingleton<AppBaseModel>(AppBaseModel())
      ..registerSingleton<CheckoutRepo>(repo);
    final vm = CheckoutVm(_args);
    await vm.onInit();
    return vm;
  }

  tearDown(() => AppDi.reset());

  test('loads the price, the payment methods and the first one is chosen',
      () async {
    final vm = await boot();
    expect(vm.checkout?.totalValue, 45);
    expect(vm.gateways, hasLength(2));
    expect(vm.gatewaySlug, 'cash');
  });

  test('pay re-checks the slot, then books with the context window', () async {
    final vm = await boot();
    final before = repo.contextCalls;

    await vm.pay();

    expect(repo.contextCalls, before + 1);
    expect(repo.createCalls, 1);
    expect(repo.lastRequest?.bookingStartTime, '2026-11-19 10:00:00');
    expect(repo.lastRequest?.paymentMethod, 'cash');
  });

  test('a slot lost before paying stops the booking with its reason',
      () async {
    final vm = await boot();
    repo.contextResult = fakeContext(available: false, reason: 'past_time');

    await vm.pay();

    expect(repo.createCalls, 0);
    expect(vm.payError, LocaleKeys.booking_reason_past_time);
  });

  test('an unknown unavailable reason falls back to the generic message',
      () async {
    final vm = await boot();
    repo.contextResult = fakeContext(available: false, reason: 'something');
    await vm.pay();
    expect(vm.payError, LocaleKeys.booking_slot_unavailable);
  });

  test('a free booking is sent as free', () async {
    final vm = await boot(total: 0);
    await vm.pay();
    expect(repo.lastRequest?.paymentMethod, 'free');
  });

  test('a bad promo code reports on the coupon field and keeps the price',
      () async {
    final vm = await boot();
    repo.badCoupon = 'BOGUS';
    vm.couponController.text = 'BOGUS';

    await vm.applyCoupon();

    expect(vm.couponError, 'This coupon code is not valid.');
    expect(vm.appliedCoupon, isNull);
    expect(vm.checkout?.totalValue, 45);
  });

  test('a good promo code is applied and sent with the booking', () async {
    final vm = await boot();
    vm.couponController.text = 'SAVE10';

    await vm.applyCoupon();
    expect(vm.appliedCoupon, 'SAVE10');

    await vm.pay();
    expect(repo.lastRequest?.couponCode, 'SAVE10');
  });

  test('qitaf only shows when the api turns it on', () async {
    expect((await boot()).qitafEnabled, isFalse);
    expect((await boot(qitaf: true)).qitafEnabled, isTrue);
  });

  test('qitaf points reduce what is payable and ride along with the booking',
      () async {
    final vm = await boot(qitaf: true);
    vm.qitafOtpController.text = '123456';
    vm.qitafAmountController.text = '20';

    await vm.redeemQitaf();

    expect(vm.redemption?.id, 77);
    expect(vm.payable, 25);

    await vm.pay();
    expect(repo.lastRequest?.qitafRedemptionId, 77);
    expect(repo.lastRequest?.paymentMethod, 'cash');
  });

  test('qitaf covering the whole bill is paid as cash', () async {
    final vm = await boot(qitaf: true);
    await vm.selectGatewayForTest('paytabs');
    vm.qitafOtpController.text = '123456';
    vm.qitafAmountController.text = '45';
    await vm.redeemQitaf();

    await vm.pay();
    expect(repo.lastRequest?.paymentMethod, 'cash');
  });

  test('a qitaf amount above the bill is rejected before any request',
      () async {
    final vm = await boot(qitaf: true);
    vm.qitafOtpController.text = '123456';
    vm.qitafAmountController.text = '999';

    await vm.redeemQitaf();

    expect(vm.redemption, isNull);
    expect(vm.qitafError, LocaleKeys.checkout_qitaf_amount_invalid);
  });
}

extension on CheckoutVm {
  Future<void> selectGatewayForTest(String slug) async => selectGateway(slug);
}
