import '../../data/base/app_base_vm.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../repos/discovery/branches_repo.dart';
import '../../repos/discovery/doctors_repo.dart';

class BranchDetailVm extends AppBaseVm {
  BranchDetailVm(this._branchId);

  final int _branchId;

  BranchDataModel? _branch;

  /// each service section asks for its doctors only when it is first built, so
  /// a branch with 30 services does not fire 30 requests up front
  final Map<int, Future<List<DoctorDataModel>>> _doctorsByService = {};

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);
    _doctorsByService.clear();

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

  /// doctors who offer [serviceId] at this branch
  Future<List<DoctorDataModel>> doctorsFor(int serviceId) =>
      _doctorsByService.putIfAbsent(serviceId, () async {
        final response = await repo<DoctorsRepo>().doctors(
          branchId: _branchId,
          serviceId: serviceId,
        );
        return response.data?.items ?? const <DoctorDataModel>[];
      });

  /// getters/setters below this line...

  BranchDataModel? get branch => _branch;
}
