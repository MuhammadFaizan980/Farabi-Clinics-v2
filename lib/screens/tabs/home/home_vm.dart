import '../../../app_di.dart';
import '../../../data/auth_session.dart';
import '../../../data/base/app_base_vm.dart';
import '../../../data/models/discovery/discovery_models.dart';
import '../../../repos/discovery/branches_repo.dart';
import '../../../repos/discovery/services_repo.dart';

class HomeVm extends AppBaseVm {
  List<ServiceDataModel> _specialities = const [];
  List<HomeRegionBranchesDataModel> _regions = const [];

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final results = await Future.wait([
      repo<ServicesRepo>().mainServices(),
      repo<BranchesRepo>().homeBranches(),
    ]);

    setBusy(false);

    final services = results[0];
    final branches = results[1];

    // the home screen is only broken if *both* rails fail; one empty rail is a
    // normal state on this data set.
    if (!services.success && !branches.success) {
      captureFailure(services);
      return;
    }

    _specialities =
        (services.data as List<ServiceDataModel>?) ?? const <ServiceDataModel>[];
    _regions = (branches.data as List<HomeRegionBranchesDataModel>?) ??
        const <HomeRegionBranchesDataModel>[];
    notifyListeners();
  }

  Future<void> refresh() => load();

  /// getters/setters below this line...

  List<ServiceDataModel> get specialities => _specialities;
  List<HomeRegionBranchesDataModel> get regions => _regions;
  String? get patientFirstName =>
      AppDi.locator<AuthSession>().patient?.firstName;
  bool get isLoggedIn => AppDi.locator<AuthSession>().isLoggedIn;
}
