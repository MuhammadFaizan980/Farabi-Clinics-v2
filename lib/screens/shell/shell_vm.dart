import '../../data/base/app_base_vm.dart';

class ShellVm extends AppBaseVm {
  int _index = 0;

  void setIndex(int index) {
    if (index == _index) return;
    _index = index;
    notifyListeners();
  }

  /// getters/setters below this line...

  int get index => _index;
}
