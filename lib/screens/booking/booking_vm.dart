import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_vm.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/constants/payment_methods.dart';
import '../../data/models/booking/booking_models.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../repos/booking/checkout_repo.dart';
import '../../repos/booking/slots_repo.dart';
import '../../repos/discovery/branches_repo.dart';
import '../../repos/discovery/services_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class BookingVm extends AppBaseVm {
  BookingVm(this._doctor);

  final DoctorDataModel _doctor;

  List<ServiceDataModel> _services = const [];
  List<BranchDataModel> _branches = const [];
  List<DateTime> _dates = const [];
  List<SlotDataModel> _slots = const [];
  List<PaymentGatewayDataModel> _gateways = const [];

  int? _serviceId;
  int? _branchId;
  DateTime? _date;
  SlotDataModel? _slot;
  String? _gatewaySlug;

  CheckoutContextDataModel? _checkout;

  bool _loadingBranches = false;
  bool _loadingSlots = false;
  bool _loadingCheckout = false;
  bool _doctorOff = false;
  bool _submitting = false;

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
      await selectService(_services.first.id);
    } else {
      notifyListeners();
    }
  }

  Future<void> selectService(int serviceId) async {
    _serviceId = serviceId;
    _branchId = null;
    _slot = null;
    _checkout = null;
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
    _checkout = null;
    notifyListeners();
    if (_slot != null) await _loadCheckout();
  }

  Future<void> selectDate(DateTime date) async {
    _date = date;
    _slot = null;
    _checkout = null;
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

  Future<void> selectSlot(SlotDataModel slot) async {
    if (!slot.isBookable) return;
    _slot = slot;
    notifyListeners();
    await _loadCheckout();
  }

  /// prices the booking and re-checks the slot. called on selection and again
  /// right before submit, because someone else may have taken it meanwhile.
  Future<void> _loadCheckout() async {
    final serviceId = _serviceId;
    final branchId = _branchId;
    final date = _date;
    final slot = _slot;
    if (serviceId == null || branchId == null || date == null || slot == null) {
      return;
    }

    _loadingCheckout = true;
    clearFailure(notify: false);
    notifyListeners();

    final response = await repo<CheckoutRepo>().context(
      doctorId: _doctor.id,
      serviceId: serviceId,
      branchId: branchId,
      date: _apiDate(date),
      time: slot.startTimeApi,
    );

    _loadingCheckout = false;
    if (!response.success || response.data == null) {
      captureFailure(response);
      notifyListeners();
      return;
    }
    _checkout = response.data;
    notifyListeners();

    if (_gateways.isEmpty) await _loadGateways();
  }

  Future<void> _loadGateways() async {
    final response = await repo<CheckoutRepo>().gateways();
    if (response.success) {
      _gateways = response.data ?? const [];
      if (_gateways.isNotEmpty) _gatewaySlug = _gateways.first.slug;
      notifyListeners();
    }
  }

  void selectGateway(String slug) {
    _gatewaySlug = slug;
    notifyListeners();
  }

  Future<void> confirm() async {
    if (!canConfirm) return;

    if (!AppDi.locator<AuthSession>().isLoggedIn) {
      await AppNavigator.push(AppRoutes.login);
      return;
    }

    _submitting = true;
    clearFailure(notify: false);
    notifyListeners();

    // re-check the slot immediately before submitting
    await _loadCheckout();
    final checkout = _checkout;
    if (checkout == null || !checkout.appointment.slotAvailable) {
      _submitting = false;
      setErrorMessage(slotUnavailableKey);
      return;
    }

    final response = await repo<CheckoutRepo>().createBooking(
      CreateBookingRequestModel(
        branchId: _branchId!,
        doctorId: _doctor.id,
        // taken verbatim from checkout-context, never computed locally
        bookingStartTime: checkout.appointment.bookingStart,
        bookingEndTime: checkout.appointment.bookingEnd,
        serviceId: _serviceId!,
        paymentMethod: PaymentMethods.forSlug(_gatewaySlug ?? 'cash'),
      ),
    );

    _submitting = false;

    if (!response.success || response.data == null) {
      captureFailure(response);
      return;
    }

    final result = response.data!;
    if (result.needsGateway) {
      // the gateway leg (redirect / native sdk) is not wired yet
      setErrorMessage(LocaleKeys.errors_unexpected);
      return;
    }

    await AppNavigator.replaceWith(
      AppRoutes.bookingSuccess,
      arguments: BookingSuccessArgsModel(booking: result.booking!),
    );
  }

  static String _apiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// the api returns a machine code here, not display text, so it has to be
  /// mapped. unknown codes fall back to the generic message.
  String get slotUnavailableKey {
    switch (_checkout?.appointment.unavailableReason) {
      case 'outside_schedule':
        return LocaleKeys.booking_reason_outside_schedule;
      case 'past_time':
        return LocaleKeys.booking_reason_past_time;
      default:
        return LocaleKeys.booking_slot_unavailable;
    }
  }

  /// getters/setters below this line...

  DoctorDataModel get doctor => _doctor;
  List<ServiceDataModel> get services => _services;
  List<BranchDataModel> get branches => _branches;
  List<DateTime> get dates => _dates;
  List<SlotDataModel> get slots => _slots;
  List<PaymentGatewayDataModel> get gateways => _gateways;
  int? get serviceId => _serviceId;
  int? get branchId => _branchId;
  DateTime? get date => _date;
  SlotDataModel? get slot => _slot;
  String? get gatewaySlug => _gatewaySlug;
  CheckoutContextDataModel? get checkout => _checkout;
  bool get loadingBranches => _loadingBranches;
  bool get loadingSlots => _loadingSlots;
  bool get loadingCheckout => _loadingCheckout;
  bool get submitting => _submitting;
  bool get doctorOff => _doctorOff;
  bool get noBranches =>
      _serviceId != null && !_loadingBranches && _branches.isEmpty;
  bool get slotTaken =>
      _checkout != null && !_checkout!.appointment.slotAvailable;
  bool get canConfirm =>
      _serviceId != null &&
      _branchId != null &&
      _slot != null &&
      _checkout != null &&
      !_slotTakenOrBusy;
  bool get _slotTakenOrBusy => slotTaken || _submitting || _loadingCheckout;
}
