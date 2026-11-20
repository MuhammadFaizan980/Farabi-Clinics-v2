import '../../data/base/app_base_vm.dart';
import '../../data/models/booking/booking_models.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../repos/discovery/doctors_repo.dart';
import '../../repos/discovery/services_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class DoctorDetailVm extends AppBaseVm {
  DoctorDetailVm(this._doctorId);

  final int _doctorId;

  DoctorDataModel? _doctor;
  List<ServiceDataModel> _services = const [];

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    // the profile and the services this doctor can be booked for are two
    // separate endpoints, fetched together
    final (detail, services) = await (
      repo<DoctorsRepo>().doctorDetail(_doctorId),
      repo<ServicesRepo>().services(doctorId: _doctorId),
    ).wait;

    setBusy(false);
    if (!detail.success || detail.data == null) {
      captureFailure(detail);
      return;
    }
    _doctor = detail.data;
    _services = services.success ? (services.data ?? const []) : const [];
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
  List<ServiceDataModel> get services => _services;
}
