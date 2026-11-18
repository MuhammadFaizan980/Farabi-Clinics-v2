import '../../data/base/app_base_vm.dart';
import '../../data/models/booking/booking_models.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../repos/discovery/doctors_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class DoctorDetailVm extends AppBaseVm {
  DoctorDetailVm(this._doctorId);

  final int _doctorId;

  DoctorDataModel? _doctor;

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<DoctorsRepo>().doctorDetail(_doctorId);

    setBusy(false);
    if (!response.success || response.data == null) {
      captureFailure(response);
      return;
    }
    _doctor = response.data;
    notifyListeners();
  }

  Future<void> refresh() => load();

  void bookAppointment() {
    final doctor = _doctor;
    if (doctor == null) return;
    AppNavigator.push(
      AppRoutes.booking,
      arguments: BookingArgsModel(doctor: doctor),
    );
  }

  /// getters/setters below this line...

  DoctorDataModel? get doctor => _doctor;
}
