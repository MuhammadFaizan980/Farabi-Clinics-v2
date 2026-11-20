import '../../data/base/app_base_vm.dart';
import '../../data/models/support/support_models.dart';
import '../../repos/support/support_repo.dart';

class JobDetailVm extends AppBaseVm {
  JobDetailVm(this.slug);

  final String slug;

  JobDetailDataModel? _detail;

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<SupportRepo>().jobDetail(slug);

    setBusy(false);
    if (!response.success || response.data == null) {
      captureFailure(response);
      return;
    }
    _detail = response.data;
    notifyListeners();
  }

  JobDetailDataModel? get detail => _detail;
}
