import '../../data/base/app_base_vm.dart';
import '../../data/models/booking/booking_models.dart';
import '../../repos/booking/bookings_repo.dart';
import '../../repos/booking/slots_repo.dart';
import '../../router/app_navigator.dart';

class RescheduleVm extends AppBaseVm {
  RescheduleVm(this._booking);

  final BookingDataModel _booking;

  List<DateTime> _dates = const [];
  List<SlotDataModel> _slots = const [];
  DateTime? _date;
  SlotDataModel? _slot;
  bool _loadingSlots = false;
  bool _doctorOff = false;

  Future<void> onInit() async {
    _dates = List.generate(30, (i) => DateTime.now().add(Duration(days: i)));
    _date = _dates.first;
    await _loadSlots();
  }

  Future<void> selectDate(DateTime date) async {
    _date = date;
    _slot = null;
    notifyListeners();
    await _loadSlots();
  }

  void selectSlot(SlotDataModel slot) {
    if (!slot.isBookable) return;
    _slot = slot;
    notifyListeners();
  }

  Future<void> _loadSlots() async {
    final doctorId = _booking.doctorId;
    final serviceId = _booking.serviceId;
    final date = _date;
    if (doctorId == null || serviceId == null || date == null) return;

    _loadingSlots = true;
    _slots = const [];
    notifyListeners();

    final response = await repo<SlotsRepo>().slots(
      doctorId: doctorId,
      serviceId: serviceId,
      date: _apiDate(date),
    );

    _loadingSlots = false;
    if (response.success && response.data != null) {
      _doctorOff = response.data!.isOff;
      // the api returns the whole day, so today's past times are dropped,
      // as on the booking page
      _slots = response.data!.slots.where(_isFutureToday).toList(growable: false);
    }
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
    final minutes =
        (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
    return minutes > now.hour * 60 + now.minute;
  }

  Future<void> confirm() async {
    final date = _date;
    final slot = _slot;
    if (date == null || slot == null) return;

    setBusy(true);
    clearFailure(notify: false);

    // send the naked local form, matching how the booking was created
    final day = _apiDate(date);
    final response = await repo<BookingsRepo>().reschedule(
      bookingId: _booking.id,
      startTime: '$day ${slot.startTime}:00',
      endTime: '$day ${slot.endTime}:00',
    );

    setBusy(false);
    if (!response.success) {
      captureFailure(response);
      return;
    }
    AppNavigator.pop(true);
  }

  static String _apiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// getters/setters below this line...

  BookingDataModel get booking => _booking;
  List<DateTime> get dates => _dates;
  List<SlotDataModel> get slots => _slots;
  DateTime? get date => _date;
  SlotDataModel? get slot => _slot;
  bool get loadingSlots => _loadingSlots;
  bool get doctorOff => _doctorOff;
  bool get canConfirm => _slot != null && !isBusy;
}
