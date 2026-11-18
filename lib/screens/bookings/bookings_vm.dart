import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_vm.dart';
import '../../data/enums/booking_status.dart';
import '../../data/models/booking/booking_models.dart';
import '../../repos/booking/bookings_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class BookingsVm extends AppBaseVm {
  List<BookingDataModel> _bookings = const [];

  /// null = all. only 1 (Created) and 6 (Cancelled) are confirmed labels, so
  /// those are the only filters offered; 2-5 exist but are unnamed.
  int? _statusFilter;

  bool _cancelling = false;

  Future<void> onInit() => load();

  Future<void> load() async {
    if (!isLoggedIn) {
      notifyListeners();
      return;
    }

    setBusy(true);
    clearFailure(notify: false);

    final response =
        await repo<BookingsRepo>().bookings(status: _statusFilter);

    setBusy(false);
    if (!response.success) {
      captureFailure(response);
      return;
    }
    _bookings = response.data ?? const [];
    notifyListeners();
  }

  Future<void> refresh() => load();

  void setFilter(int? status) {
    _statusFilter = status;
    load();
  }

  Future<void> cancel(BookingDataModel booking) async {
    _cancelling = true;
    notifyListeners();

    final response = await repo<BookingsRepo>().cancel(booking.id);

    _cancelling = false;
    if (!response.success) {
      captureFailure(response);
      return;
    }
    await load();
  }

  void openReschedule(BookingDataModel booking) {
    AppNavigator.push(
      AppRoutes.reschedule,
      arguments: RescheduleArgsModel(booking: booking),
    );
  }

  /// getters/setters below this line...

  List<BookingDataModel> get bookings => _bookings;
  int? get statusFilter => _statusFilter;
  bool get cancelling => _cancelling;
  bool get isLoggedIn => AppDi.locator<AuthSession>().isLoggedIn;
  bool get isEmpty =>
      isLoggedIn && !isBusy && !hasFailure && _bookings.isEmpty;

  int get createdStatus => BookingStatus.created.value;
  int get cancelledStatus => BookingStatus.cancelled.value;
}
