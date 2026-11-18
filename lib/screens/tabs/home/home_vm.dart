import '../../../app_di.dart';
import '../../../data/auth_session.dart';
import '../../../data/base/app_base_vm.dart';
import '../../../data/models/discovery/discovery_models.dart';
import '../../../data/models/support/support_models.dart';
import '../../../repos/discovery/branches_repo.dart';
import '../../../repos/discovery/doctors_repo.dart';
import '../../../repos/discovery/services_repo.dart';
import '../../../repos/support/support_repo.dart';

class HomeVm extends AppBaseVm {
  /// the design shows one row of four specialities, expandable to two
  static const int collapsedServiceCount = 4;
  static const int expandedServiceCount = 8;
  static const int availableDoctorsCount = 6;

  List<ServiceDataModel> _specialities = const [];
  List<HomeRegionBranchesDataModel> _regions = const [];
  List<OfferDataModel> _offers = const [];
  List<DoctorDataModel> _doctors = const [];
  Map<int, int> _doctorTotalsByRegion = const {};
  bool _servicesExpanded = false;
  int _bannerIndex = 0;

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final results = await Future.wait([
      repo<ServicesRepo>().mainServices(),
      repo<BranchesRepo>().homeBranches(),
      repo<SupportRepo>().offers(),
      repo<DoctorsRepo>().doctors(page: 1),
    ]);

    setBusy(false);

    final services = results[0];
    final branches = results[1];

    // the home screen is only broken if *both* main rails fail; one empty rail
    // is a normal state on this data set.
    if (!services.success && !branches.success) {
      captureFailure(services);
      return;
    }

    _specialities =
        (services.data as List<ServiceDataModel>?) ?? const <ServiceDataModel>[];
    _regions = (branches.data as List<HomeRegionBranchesDataModel>?) ??
        const <HomeRegionBranchesDataModel>[];
    _offers = (results[2].data as List<OfferDataModel>?) ??
        const <OfferDataModel>[];
    final doctorPage = results[3].data as PagedResult<DoctorDataModel>?;
    _doctors = (doctorPage?.items ?? const <DoctorDataModel>[])
        .take(availableDoctorsCount)
        .toList(growable: false);
    notifyListeners();

    // the "N doctors available" line under each city is the doctors endpoint's
    // own total for that region, so it is fetched after the first paint.
    await _loadDoctorTotals();
  }

  Future<void> _loadDoctorTotals() async {
    final totals = await Future.wait(
      _regions.map((region) async {
        final response =
            await repo<DoctorsRepo>().doctors(page: 1, regionId: region.id);
        // `meta` is null when everything fits on one page, so the item count
        // is the total in that case
        final page = response.data;
        return MapEntry(region.id, page?.total ?? page?.items.length ?? 0);
      }),
    );
    _doctorTotalsByRegion = Map<int, int>.fromEntries(totals);
    notifyListeners();
  }

  Future<void> refresh() => load();

  void toggleServicesExpanded() {
    _servicesExpanded = !_servicesExpanded;
    notifyListeners();
  }

  void setBannerIndex(int index) {
    if (index == _bannerIndex) return;
    _bannerIndex = index;
    notifyListeners();
  }

  int doctorsIn(int regionId) => _doctorTotalsByRegion[regionId] ?? 0;

  /// getters/setters below this line...

  List<ServiceDataModel> get specialities => _specialities;
  List<ServiceDataModel> get visibleSpecialities => _specialities
      .take(_servicesExpanded ? expandedServiceCount : collapsedServiceCount)
      .toList(growable: false);
  bool get canExpandServices => _specialities.length > collapsedServiceCount;
  bool get servicesExpanded => _servicesExpanded;
  List<HomeRegionBranchesDataModel> get regions => _regions;

  /// the frame leads with the cities that have the most doctors; the api
  /// returns regions alphabetically, so the rail is ordered here instead.
  List<HomeRegionBranchesDataModel> get regionsByDoctors {
    final sorted = [..._regions];
    sorted.sort((a, b) {
      final byDoctors = doctorsIn(b.id).compareTo(doctorsIn(a.id));
      return byDoctors != 0 ? byDoctors : a.id.compareTo(b.id);
    });
    return sorted;
  }

  List<OfferDataModel> get offers => _offers;
  List<DoctorDataModel> get doctors => _doctors;
  int get bannerIndex => _bannerIndex;
  String? get patientFirstName =>
      AppDi.locator<AuthSession>().patient?.firstName;
  bool get isLoggedIn => AppDi.locator<AuthSession>().isLoggedIn;
}
