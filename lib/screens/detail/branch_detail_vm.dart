import '../../data/base/app_base_vm.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../repos/discovery/branches_repo.dart';

class BranchDetailVm extends AppBaseVm {
  BranchDetailVm(this._branchId);

  final int _branchId;

  BranchDataModel? _branch;

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<BranchesRepo>().branchDetail(_branchId);

    setBusy(false);
    if (!response.success || response.data == null) {
      captureFailure(response);
      return;
    }
    _branch = response.data;
    notifyListeners();
  }

  Future<void> refresh() => load();

  /// getters/setters below this line...

  BranchDataModel? get branch => _branch;

  /// both are null on every branch in the dev data, so the buttons have to
  /// disable rather than fire an empty intent
  bool get canCall => _branch?.canCall ?? false;
  bool get canOpenMap => _branch?.canOpenMap ?? false;
}
