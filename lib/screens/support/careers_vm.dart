import '../../data/base/app_base_vm.dart';
import '../../data/models/support/support_models.dart';
import '../../repos/support/support_repo.dart';

class CareersVm extends AppBaseVm {
  List<JobDataModel> _jobs = const [];
  List<String> _departments = const [];
  String? _department;

  Future<void> onInit() async {
    await Future.wait([_loadDepartments(), load()]);
  }

  Future<void> _loadDepartments() async {
    final response = await repo<SupportRepo>().departments();
    if (response.success) {
      _departments = response.data ?? const [];
      notifyListeners();
    }
  }

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<SupportRepo>().jobs();

    setBusy(false);
    if (!response.success) {
      captureFailure(response);
      return;
    }
    _jobs = response.data ?? const [];
    notifyListeners();
  }

  Future<void> refresh() => load();

  /// the api has no department filter param, so this filters what we already
  /// have rather than pretending to be a server-side query
  void setDepartment(String? department) {
    _department = department;
    notifyListeners();
  }

  /// getters/setters below this line...

  List<String> get departments => _departments;
  String? get department => _department;
  List<JobDataModel> get jobs => _department == null
      ? _jobs
      : _jobs.where((job) => job.department == _department).toList();
  bool get isEmpty => !isBusy && !hasFailure && jobs.isEmpty;
}
