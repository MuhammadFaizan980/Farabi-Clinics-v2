import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/base/app_base_model.dart';
import 'package:farabi_booking_app/data/models/booking/booking_models.dart';
import 'package:farabi_booking_app/data/models/discovery/discovery_models.dart';
import 'package:farabi_booking_app/data/network/api_response_model.dart';
import 'package:farabi_booking_app/repos/booking/checkout_repo.dart';
import 'package:farabi_booking_app/repos/booking/slots_repo.dart';
import 'package:farabi_booking_app/repos/discovery/branches_repo.dart';
import 'package:farabi_booking_app/repos/discovery/services_repo.dart';
import 'package:farabi_booking_app/screens/booking/booking_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_checkout_repo.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeCheckoutRepo checkout;

  Future<BookingVm> boot({
    bool isOff = false,
    bool loggedIn = true,
  }) async {
    await AppDi.reset();
    final session = AuthSession(FakeLocalData());
    await session.restore();
    if (loggedIn) await session.setToken('tok');
    checkout = FakeCheckoutRepo(fakeContext());
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
    vm.selectSlot(_slot);
    expect(vm.canConfirm, isTrue);
  });

  test('a service passed in from the specialities page is preselected',
      () async {
    await AppDi.reset();
    final session = AuthSession(FakeLocalData());
    await session.restore();
    AppDi.locator
      ..registerSingleton<AuthSession>(session)
      ..registerSingleton<AppBaseModel>(AppBaseModel())
      ..registerSingleton<ServicesRepo>(_FakeServicesRepo())
      ..registerSingleton<BranchesRepo>(_FakeBranchesRepo())
      ..registerSingleton<SlotsRepo>(_FakeSlotsRepo())
      ..registerSingleton<CheckoutRepo>(FakeCheckoutRepo(fakeContext()));
    final vm = BookingVm(_doctor, 19);
    await vm.onInit();
    expect(vm.serviceId, 19);
  });

  test('picking another branch keeps the chosen slot', () async {
    final vm = await boot();
    vm.selectSlot(_slot);
    await vm.selectBranch(8);
    expect(vm.slot, isNotNull);
  });
}
