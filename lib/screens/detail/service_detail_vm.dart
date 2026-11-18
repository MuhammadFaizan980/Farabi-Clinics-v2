import '../../data/base/app_base_vm.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../repos/discovery/services_repo.dart';

class ServiceDetailVm extends AppBaseVm {
  ServiceDetailVm(this._serviceId);

  final int _serviceId;

  ServiceDataModel? _service;
  List<ServiceDataModel> _subServices = const [];

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final detail = await repo<ServicesRepo>().serviceDetail(_serviceId);
    if (!detail.success || detail.data == null) {
      setBusy(false);
      captureFailure(detail);
      return;
    }
    _service = detail.data;

    // sub-services come from the list endpoint filtered by parent
    final subs = await repo<ServicesRepo>().services(serviceId: _serviceId);
    _subServices = subs.success ? (subs.data ?? const []) : const [];

    setBusy(false);
    notifyListeners();
  }

  Future<void> refresh() => load();

  /// getters/setters below this line...

  ServiceDataModel? get service => _service;
  List<ServiceDataModel> get subServices => _subServices;
}
