import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_vm.dart';
import '../../data/models/booking/booking_models.dart';
import '../../data/models/auth/login_args_model.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../repos/booking/slots_repo.dart';
import '../../repos/discovery/branches_repo.dart';
import '../../repos/discovery/services_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class BookingVm extends AppBaseVm {
  BookingVm(this._doctor, [this._initialServiceId]);

  final DoctorDataModel _doctor;

  /// the service picked on the specialities page, like the site's
  /// `/book?service_id=`; falls back to the doctor's first service
  final int? _initialServiceId;

  List<ServiceDataModel> _services = const [];
  List<BranchDataModel> _branches = const [];
  List<DateTime> _dates = const [];
  List<SlotDataModel> _slots = const [];

  int? _serviceId;
  int? _branchId;
  DateTime? _date;
  SlotDataModel? _slot;

  bool _loadingBranches = false;
  bool _loadingSlots = false;
  bool _doctorOff = false;

  Future<void> onInit() async {
    _dates = List.generate(
      30,
      (i) => DateTime.now().add(Duration(days: i)),
    );
    _date = _dates.first;
    await _loadServices();
  }

  Future<void> _loadServices() async {
    setBusy(true);
    clearFailure(notify: false);

    final response =
        await repo<ServicesRepo>().services(doctorId: _doctor.id);

    setBusy(false);
    if (!response.success) {
      captureFailure(response);
      return;
    }
    _services = response.data ?? const [];
    if (_services.isNotEmpty) {
      final preferred = _services.any((s) => s.id == _initialServiceId)
          ? _initialServiceId!
          : _services.first.id;
      await selectService(preferred);
    } else {
      notifyListeners();
    }
  }

  Future<void> selectService(int serviceId) async {
    _serviceId = serviceId;
    _branchId = null;
    _slot = null;
    _loadingBranches = true;
    notifyListeners();

    final response = await repo<BranchesRepo>()
        .branches(doctorId: _doctor.id, serviceId: serviceId);

    _loadingBranches = false;
    _branches = response.success ? (response.data ?? const []) : const [];
    if (_branches.isNotEmpty) {
      _branchId = _branches.first.id;
    }
    notifyListeners();

    await _loadSlots();
  }

  Future<void> selectBranch(int branchId) async {
    _branchId = branchId;
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _date = date;
    _slot = null;
    notifyListeners();
    await _loadSlots();
  }

  Future<void> _loadSlots() async {
    final serviceId = _serviceId;
    final date = _date;
    if (serviceId == null || date == null) return;

    _loadingSlots = true;
    _slots = const [];
    _doctorOff = false;
    notifyListeners();

    final response = await repo<SlotsRepo>().slots(
      doctorId: _doctor.id,
      serviceId: serviceId,
      date: _apiDate(date),
    );

    _loadingSlots = false;
    if (!response.success || response.data == null) {
      notifyListeners();
      return;
    }

    _doctorOff = response.data!.isOff;
    // the api returns the whole day, so today's past times are filtered here
    _slots = response.data!.slots.where(_isFutureToday).toList(growable: false);
    notifyListeners();
  }

  bool _isFutureToday(SlotDataModel slot) {
    final date = _date;
    if (date == null) return true;
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    if (!isToday) return true;

    final parts = slot.startTime.split(':');
    if (parts.length < 2) return true;
    final minutes = (int.tryParse(parts[0]) ?? 0) * 60 +
        (int.tryParse(parts[1]) ?? 0);
    return minutes > now.hour * 60 + now.minute;
  }

  void selectSlot(SlotDataModel slot) {
    if (!slot.isBookable) return;
    _slot = slot;
    notifyListeners();
  }

  /// like the site: Confirm Appointment opens sign-in first when the visitor
  /// is a guest, then moves on to the Review & Pay page, which prices the
  /// booking and re-checks the slot itself.
  Future<void> confirm() async {
    if (!canConfirm) return;

    if (!AppDi.locator<AuthSession>().isLoggedIn) {
      final signedIn = await AppNavigator.push<bool>(
        AppRoutes.login,
        arguments: const LoginArgsModel(popOnSuccess: true),
      );
      if (signedIn != true) return;
    }

    await AppNavigator.push(
      AppRoutes.checkout,
      arguments: CheckoutArgsModel(
        doctor: _doctor,
        serviceId: _serviceId!,
        branchId: _branchId!,
        date: _apiDate(_date!),
        time: _slot!.startTimeApi,
      ),
    );
  }

  static String _apiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// getters/setters below this line...

  DoctorDataModel get doctor => _doctor;
  List<ServiceDataModel> get services => _services;
  List<BranchDataModel> get branches => _branches;
  List<DateTime> get dates => _dates;
  List<SlotDataModel> get slots => _slots;
  int? get serviceId => _serviceId;
  int? get branchId => _branchId;
  DateTime? get date => _date;
  SlotDataModel? get slot => _slot;
  bool get loadingBranches => _loadingBranches;
  bool get loadingSlots => _loadingSlots;
  bool get doctorOff => _doctorOff;
  bool get noBranches =>
      _serviceId != null && !_loadingBranches && _branches.isEmpty;
  bool get canConfirm =>
      _serviceId != null && _branchId != null && _date != null && _slot != null;
}
