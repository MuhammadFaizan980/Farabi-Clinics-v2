import '../../../data/base/app_base_vm.dart';
import '../../../data/models/discovery/discovery_models.dart';
import '../../../repos/discovery/branches_repo.dart';
import '../../../repos/discovery/regions_repo.dart';

class BranchesListVm extends AppBaseVm {
  List<BranchDataModel> _branches = const [];
  List<RegionDataModel> _regions = const [];
  int? _regionId;

  Future<void> onInit() async {
    await Future.wait([_loadRegions(), load()]);
  }

  Future<void> _loadRegions() async {
    final response = await repo<RegionsRepo>().regions();
    if (response.success && response.data != null) {
      _regions = response.data!;
      notifyListeners();
    }
  }

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<BranchesRepo>().branches(regionId: _regionId);

    setBusy(false);
    if (!response.success || response.data == null) {
      captureFailure(response);
      return;
    }
    _branches = response.data!;
    notifyListeners();
  }

  Future<void> refresh() => load();

  void setRegion(int? regionId) {
    _regionId = regionId;
    load();
  }

  /// getters/setters below this line...

  List<BranchDataModel> get branches => _branches;
  List<RegionDataModel> get regions => _regions;
  int? get regionId => _regionId;
  bool get isEmpty => !isBusy && !hasFailure && _branches.isEmpty;
}
