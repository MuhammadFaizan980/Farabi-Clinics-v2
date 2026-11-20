import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_vm.dart';
import '../../data/enums/booking_status.dart';
import '../../data/models/booking/booking_models.dart';
import '../../repos/booking/bookings_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

/// the site's three appointment tabs
enum BookingTab { upcoming, completed, cancelled }

class BookingsVm extends AppBaseVm {
  List<BookingDataModel> _all = const [];
  BookingTab _tab = BookingTab.upcoming;
  bool _cancelling = false;
  String? _actionError;

  Future<void> onInit() => load();

  /// the api filters by an integer status, and only 1 (created) and 6
  /// (cancelled) are known (the website sends strings, gets a 422 and shows
  /// nothing). so the whole history is fetched once and split into the three
  /// tabs here: created is upcoming, cancelled is cancelled, anything else is
  /// completed.
  Future<void> load() async {
    if (!isLoggedIn) {
      notifyListeners();
      return;
    }

    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<BookingsRepo>().bookings();

    setBusy(false);
    if (!response.success) {
      captureFailure(response);
      return;
    }
    _all = response.data ?? const [];
    notifyListeners();
  }

  Future<void> refresh() => load();

  void setTab(BookingTab tab) {
    _tab = tab;
    _actionError = null;
    notifyListeners();
  }

  /// a failed cancel is reported next to the list, which stays on screen
  Future<void> cancel(BookingDataModel booking) async {
    _cancelling = true;
    _actionError = null;
    notifyListeners();

    final response = await repo<BookingsRepo>().cancel(booking.id);

    _cancelling = false;
    if (!response.success) {
      _actionError = response.message ?? 'bookings.cancel_failed';
      notifyListeners();
      return;
    }
    await load();
  }

  /// the reschedule screen answers `true` when it moved the booking
  Future<void> openReschedule(BookingDataModel booking) async {
    final moved = await AppNavigator.push<Object?>(
      AppRoutes.reschedule,
      arguments: RescheduleArgsModel(booking: booking),
    );
    if (moved == true) await load();
  }

  /// getters/setters below this line...

  BookingTab get tab => _tab;
  bool get cancelling => _cancelling;
  String? get actionError => _actionError;
  bool get isLoggedIn => AppDi.locator<AuthSession>().isLoggedIn;

  List<BookingDataModel> get bookings => _all.where((b) {
        switch (_tab) {
          case BookingTab.upcoming:
            return b.statusValue == BookingStatus.created.value;
          case BookingTab.cancelled:
            return b.statusValue == BookingStatus.cancelled.value;
          case BookingTab.completed:
            return b.statusValue != BookingStatus.created.value &&
                b.statusValue != BookingStatus.cancelled.value;
        }
      }).toList(growable: false);

  bool get isEmpty =>
      isLoggedIn && !isBusy && !hasFailure && bookings.isEmpty;
}
