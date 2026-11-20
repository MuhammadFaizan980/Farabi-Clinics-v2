import '../../../data/base/app_base_vm.dart';
import '../../../data/models/discovery/discovery_models.dart';
import '../../../repos/discovery/doctors_repo.dart';
import '../../../repos/discovery/regions_repo.dart';
import '../../../repos/discovery/services_repo.dart';

/// one bookable service with the doctors who offer it in the chosen region
class ServiceWithDoctors {
  const ServiceWithDoctors({
    required this.service,
    required this.doctors,
    required this.doctorCount,
  });

  final ServiceDataModel service;
  final List<DoctorDataModel> doctors;
  final int doctorCount;
}

/// the site's specialities page: region chips, speciality chips, then the
/// services of that selection, each with its available doctors. every list on
/// it comes from the api (regions, services/main, services, doctors).
class SpecialitiesVm extends AppBaseVm {
  SpecialitiesVm({int? initialMainServiceId})
      : _mainServiceId = initialMainServiceId;

  List<RegionDataModel> _regions = const [];
  List<ServiceDataModel> _mainServices = const [];
  List<ServiceWithDoctors> _services = const [];

  int? _regionId;
  int? _mainServiceId;

  Future<void> onInit() async {
    setBusy(true);
    clearFailure(notify: false);

    final (regions, mains) = await (
      repo<RegionsRepo>().regions(),
      repo<ServicesRepo>().mainServices(),
    ).wait;

    if (mains.success && mains.data != null) {
      _mainServices = mains.data!;
    }
    if (regions.success && regions.data != null) {
      _regions = [...regions.data!]..sort((a, b) => a.id.compareTo(b.id));
      _regionId ??= _regions.isEmpty ? null : _regions.first.id;
    }
    if (!mains.success && !regions.success) {
      setBusy(false);
      captureFailure(mains);
      return;
    }
    await _loadServices();
  }

  Future<void> _loadServices() async {
    // nothing is listed until a speciality is chosen, as on the site
    if (_mainServiceId == null) {
      _services = const [];
      setBusy(false);
      notifyListeners();
      return;
    }
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<ServicesRepo>().services(
      regionId: _regionId,
      serviceId: _mainServiceId,
    );
    if (!response.success || response.data == null) {
      setBusy(false);
      captureFailure(response);
      return;
    }

    // one doctors query per service gives both the count and the rows
    final services = response.data!;
    final doctorPages = await Future.wait(
      services.map(
        (service) => repo<DoctorsRepo>().doctors(
          regionId: _regionId,
          serviceId: service.id,
        ),
      ),
    );

    _services = [
      for (var i = 0; i < services.length; i++)
        ServiceWithDoctors(
          service: services[i],
          doctors: doctorPages[i].data?.items ?? const [],
          doctorCount: doctorPages[i].data?.total ??
              doctorPages[i].data?.items.length ??
              0,
        ),
    ];
    setBusy(false);
    notifyListeners();
  }

  Future<void> load() => _loadServices();

  Future<void> refresh() => _loadServices();

  Future<void> selectRegion(int regionId) async {
    if (_regionId == regionId) return;
    _regionId = regionId;
    await _loadServices();
  }

  Future<void> selectMainService(int? serviceId) async {
    if (_mainServiceId == serviceId) return;
    _mainServiceId = serviceId;
    await _loadServices();
  }

  /// getters/setters below this line...

  List<RegionDataModel> get regions => _regions;
  List<ServiceDataModel> get mainServices => _mainServices;
  List<ServiceWithDoctors> get services => _services;
  int? get regionId => _regionId;
  int? get mainServiceId => _mainServiceId;
  bool get hasSelection => _mainServiceId != null;
  bool get isEmpty =>
      !isBusy && !hasFailure && hasSelection && _services.isEmpty;
}
