import '../../data/base/app_base_vm.dart';
import '../../data/models/support/support_models.dart';
import '../../repos/support/support_repo.dart';

class BlogsVm extends AppBaseVm {
  List<BlogPostDataModel> _posts = const [];

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<SupportRepo>().posts();

    setBusy(false);
    if (!response.success) {
      captureFailure(response);
      return;
    }
    _posts = response.data ?? const [];
    notifyListeners();
  }

  Future<void> refresh() => load();

  /// getters/setters below this line...

  List<BlogPostDataModel> get posts => _posts;
  bool get isEmpty => !isBusy && !hasFailure && _posts.isEmpty;
}
