import '../../../data/base/app_base_vm.dart';
import '../../../data/models/discovery/discovery_models.dart';
import '../../../repos/discovery/services_repo.dart';

class SpecialitiesVm extends AppBaseVm {
  List<ServiceDataModel> _specialities = const [];

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<ServicesRepo>().mainServices();

    setBusy(false);
    if (!response.success || response.data == null) {
      captureFailure(response);
      return;
    }
    _specialities = response.data!;
    notifyListeners();
  }

  Future<void> refresh() => load();

  /// getters/setters below this line...

  List<ServiceDataModel> get specialities => _specialities;
  bool get isEmpty => !isBusy && !hasFailure && _specialities.isEmpty;
}
