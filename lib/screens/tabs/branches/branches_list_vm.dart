import '../../../data/base/app_base_vm.dart';
import '../../../data/models/discovery/discovery_models.dart';
import '../../../repos/discovery/branches_repo.dart';
import '../../../repos/discovery/regions_repo.dart';

class BranchesListVm extends AppBaseVm {
  List<BranchDataModel> _branches = const [];
  List<RegionDataModel> _regions = const [];
  int? _regionId;

  Future<void> onInit() async {
    // the frame always has a city selected, so the first region (Riyadh, the
    // lowest id) is picked before the first fetch
    await _loadRegions();
    _regionId ??= _regions.isEmpty ? null : _regions.first.id;
    await load();
  }

  Future<void> _loadRegions() async {
    final response = await repo<RegionsRepo>().regions();
    if (response.success && response.data != null) {
      _regions = [...response.data!]..sort((a, b) => a.id.compareTo(b.id));
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
    if (regionId == _regionId) return;
    _regionId = regionId;
    load();
  }

  /// getters/setters below this line...

  List<BranchDataModel> get branches => _branches;
  List<RegionDataModel> get regions => _regions;
  int? get regionId => _regionId;
  bool get isEmpty => !isBusy && !hasFailure && _branches.isEmpty;
}
