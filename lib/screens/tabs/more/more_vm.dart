import 'package:flutter/widgets.dart';

import '../../../app_di.dart';
import '../../../data/auth_session.dart';
import '../../../data/base/app_base_model.dart';
import '../../../data/base/app_base_vm.dart';
import '../../../data/enums/booking_status.dart';
import '../../../data/models/auth/patient_data_model.dart';
import '../../../data/models/booking/booking_models.dart';
import '../../../repos/booking/bookings_repo.dart';
import '../../../router/app_navigator.dart';
import '../../../router/app_routes.dart';

class MoreVm extends AppBaseVm {
  List<BookingDataModel> _bookings = const [];

  Future<void> onInit() => load();

  /// the stats strip is derived from the patient's own bookings, so it only
  /// loads for a signed-in patient.
  Future<void> load() async {
    if (!isLoggedIn) {
      notifyListeners();
      return;
    }
    final response = await repo<BookingsRepo>().bookings();
    if (response.success) {
      _bookings = response.data ?? const [];
      notifyListeners();
    }
  }

  void openProfile() => AppNavigator.push(
        isLoggedIn ? AppRoutes.profile : AppRoutes.login,
      );

  Future<void> logout() async {
    await AppDi.locator<AuthSession>().clear();
    AppDi.locator<AppBaseModel>().clear();
    await AppNavigator.resetTo(AppRoutes.login);
  }

  /// getters/setters below this line...

  AuthSession get _session => AppDi.locator<AuthSession>();
  bool get isLoggedIn => _session.isLoggedIn;
  PatientDataModel? get patient => _session.patient;

  String get displayName => patient?.fullName ?? '';

  String get initials {
    final first = (patient?.firstName ?? '').trim();
    final last = (patient?.lastName ?? '').trim();
    final letters = [first, last]
        .where((part) => part.isNotEmpty)
        .map((part) => part.characters.first.toUpperCase())
        .join();
    return letters;
  }

  bool get isVerified => patient?.isPhoneVerified ?? false;

  bool get _hasLoadedBookings => isLoggedIn;

  /// everything that has not been cancelled and starts after now
  int get upcomingCount {
    if (!_hasLoadedBookings) return 0;
    final now = DateTime.now();
    return _bookings
        .where((b) =>
            b.statusValue != BookingStatus.cancelled.value &&
            (b.startLocal?.isAfter(now) ?? false))
        .length;
  }

  /// every booking the patient has made
  int get bookedCount => _bookings.length;

  /// bookings that were not cancelled and whose time has already passed
  int get visitsCount {
    final now = DateTime.now();
    return _bookings
        .where((b) =>
            b.statusValue != BookingStatus.cancelled.value &&
            (b.startLocal?.isBefore(now) ?? false))
        .length;
  }
}
