import '../../../data/base/app_base_vm.dart';
import '../../../data/models/support/support_models.dart';
import '../../../repos/support/support_repo.dart';

class OffersVm extends AppBaseVm {
  List<OfferDataModel> _offers = const [];

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<SupportRepo>().offers();

    setBusy(false);
    if (!response.success) {
      captureFailure(response);
      return;
    }
    _offers = response.data ?? const [];
    notifyListeners();
  }

  Future<void> refresh() => load();

  /// getters/setters below this line...

  List<OfferDataModel> get offers => _offers;
  bool get isEmpty => !isBusy && !hasFailure && _offers.isEmpty;
}
