import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/base/app_base_model.dart';
import 'package:farabi_booking_app/data/constants/locale_keys.g.dart';
import 'package:farabi_booking_app/data/models/booking/booking_models.dart';
import 'package:farabi_booking_app/data/models/discovery/discovery_models.dart';
import 'package:farabi_booking_app/data/network/api_response_model.dart';
import 'package:farabi_booking_app/repos/booking/checkout_repo.dart';
import 'package:farabi_booking_app/repos/booking/slots_repo.dart';
import 'package:farabi_booking_app/repos/discovery/branches_repo.dart';
import 'package:farabi_booking_app/repos/discovery/services_repo.dart';
import 'package:farabi_booking_app/screens/booking/booking_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

const _doctor = DoctorDataModel(id: 3, names: LocalisedName(name: 'Dr Test'));

const _service = ServiceDataModel(id: 19, names: LocalisedName(name: 'Creat'));
const _branch = BranchDataModel(id: 8, names: LocalisedName(name: 'Olaya'));

const _slot = SlotDataModel(
  slot: 3,
  startTime: '10:00',
  endTime: '10:30',
  isBookable: true,
);

CheckoutContextDataModel _context({
  bool available = true,
  String? reason,
}) =>
    CheckoutContextDataModel(
      appointment: AppointmentDataModel(
        date: '2026-11-19',
        startTime: '10:00:00',
        endTime: '10:30:00',
        slotAvailable: available,
        unavailableReason: reason,
      ),
      lines: const [],
      totalFormatted: '45.00 SAR',
      totalValue: 45,
    );

class _FakeServicesRepo extends ServicesRepo {
  @override
  Future<ApiResponseModel<List<ServiceDataModel>>> mainServices({
    int? regionId,
    int? branchId,
    int? doctorId,
  }) async =>
      const ApiResponseModel(success: true, data: [_service]);

  @override
  Future<ApiResponseModel<List<ServiceDataModel>>> services({
    int? regionId,
    int? branchId,
    int? doctorId,
    int? serviceId,
  }) async =>
      const ApiResponseModel(success: true, data: [_service]);

  @override
  Future<ApiResponseModel<ServiceDataModel>> serviceDetail(int id) async =>
      const ApiResponseModel(success: true, data: _service);
}

class _FakeBranchesRepo extends BranchesRepo {
  @override
  Future<ApiResponseModel<List<BranchDataModel>>> branches({
    int? regionId,
    int? serviceId,
    int? doctorId,
    int? specialtyId,
  }) async =>
      const ApiResponseModel(success: true, data: [_branch]);

  @override
  Future<ApiResponseModel<BranchDataModel>> branchDetail(int id) async =>
      const ApiResponseModel(success: true, data: _branch);

  @override
  Future<ApiResponseModel<List<HomeRegionBranchesDataModel>>>
      homeBranches() async =>
          const ApiResponseModel(success: true, data: []);
}

class _FakeSlotsRepo extends SlotsRepo {
  _FakeSlotsRepo({this.isOff = false});

  final bool isOff;

  @override
  Future<ApiResponseModel<DoctorSlotsDataModel>> slots({
    required int doctorId,
    required int serviceId,
    required String date,
  }) async =>
      ApiResponseModel(
        success: true,
        data: DoctorSlotsDataModel(
          date: date,
          isOff: isOff,
          slots: isOff
              ? const []
              : [
                  SlotDataModel(
                    slot: 3,
                    startTime: '23:00',
                    endTime: '23:30',
                    isBookable: true,
                  )
                ],
        ),
      );
}

class _FakeCheckoutRepo extends CheckoutRepo {
  _FakeCheckoutRepo(this.contextResult);

  CheckoutContextDataModel contextResult;
  int contextCalls = 0;
  int createCalls = 0;

  @override
  Future<ApiResponseModel<CheckoutContextDataModel>> context({
    required int doctorId,
    required int serviceId,
    required int branchId,
    required String date,
    required String time,
    int quantity = 1,
    String? couponCode,
  }) async {
    contextCalls++;
    return ApiResponseModel(success: true, data: contextResult);
  }

  @override
  Future<ApiResponseModel<List<PaymentGatewayDataModel>>> gateways() async =>
      const ApiResponseModel(
        success: true,
        data: [PaymentGatewayDataModel(slug: 'cash', label: 'Cash')],
      );

  @override
  Future<ApiResponseModel<CreateBookingResultModel>> createBooking(
    CreateBookingRequestModel request,
  ) async {
    createCalls++;
    return ApiResponseModel(
      success: true,
      data: CreateBookingResultModel(
        booking: BookingDataModel(
          id: 1,
          bookingNumber: 'BK-00001',
          statusValue: 1,
          statusLabel: 'Created',
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeCheckoutRepo checkout;

  Future<BookingVm> boot({
    bool available = true,
    String? reason,
    bool isOff = false,
    bool loggedIn = true,
  }) async {
    await AppDi.reset();
    final session = AuthSession(FakeLocalData());
    await session.restore();
    if (loggedIn) await session.setToken('tok');
    checkout = _FakeCheckoutRepo(_context(available: available, reason: reason));
    AppDi.locator
      ..registerSingleton<AuthSession>(session)
      ..registerSingleton<AppBaseModel>(AppBaseModel())
      ..registerSingleton<ServicesRepo>(_FakeServicesRepo())
      ..registerSingleton<BranchesRepo>(_FakeBranchesRepo())
      ..registerSingleton<SlotsRepo>(_FakeSlotsRepo(isOff: isOff))
      ..registerSingleton<CheckoutRepo>(checkout);
    final vm = BookingVm(_doctor);
    await vm.onInit();
    return vm;
  }

  tearDown(() => AppDi.reset());

  test('picking a service auto-selects its only branch and loads slots',
      () async {
    final vm = await boot();
    expect(vm.serviceId, 19);
    expect(vm.branchId, 8);
    expect(vm.slots, isNotEmpty);
  });

  test('a day off is its own state, distinct from having no slots', () async {
    final vm = await boot(isOff: true);
    expect(vm.doctorOff, isTrue);
    expect(vm.slots, isEmpty);
  });

  test('confirm is blocked until a slot is chosen', () async {
    final vm = await boot();
    expect(vm.canConfirm, isFalse);
    await vm.selectSlot(_slot);
    expect(vm.canConfirm, isTrue);
  });

  test('a taken slot blocks confirm and maps its reason to a locale key',
      () async {
    final vm = await boot(available: false, reason: 'outside_schedule');
    await vm.selectSlot(_slot);

    expect(vm.slotTaken, isTrue);
    expect(vm.canConfirm, isFalse);
    // the api sends a machine code, never display text
    expect(vm.slotUnavailableKey,
        LocaleKeys.booking_reason_outside_schedule);
  });

  test('a past-time reason maps to its own message', () async {
    final vm = await boot(available: false, reason: 'past_time');
    await vm.selectSlot(_slot);
    expect(vm.slotUnavailableKey, LocaleKeys.booking_reason_past_time);
  });

  test('an unknown reason falls back to the generic message', () async {
    final vm = await boot(available: false, reason: 'something_new');
    await vm.selectSlot(_slot);
    expect(vm.slotUnavailableKey, LocaleKeys.booking_slot_unavailable);
  });

  test('confirm re-checks the slot before creating the booking', () async {
    final vm = await boot();
    await vm.selectSlot(_slot);
    final before = checkout.contextCalls;

    await vm.confirm();

    // one extra context call guards against someone taking the slot meanwhile
    expect(checkout.contextCalls, before + 1);
    expect(checkout.createCalls, 1);
  });

  test('a slot lost between selection and submit stops the booking', () async {
    final vm = await boot();
    await vm.selectSlot(_slot);

    // someone else takes it in the gap
    checkout.contextResult = _context(available: false, reason: 'past_time');
    await vm.confirm();

    expect(checkout.createCalls, 0);
    expect(vm.errorMessage, LocaleKeys.booking_reason_past_time);
  });

  test('a signed-out user is sent to login instead of booking', () async {
    final vm = await boot(loggedIn: false);
    await vm.selectSlot(_slot);
    await vm.confirm();
    expect(checkout.createCalls, 0);
  });
}
