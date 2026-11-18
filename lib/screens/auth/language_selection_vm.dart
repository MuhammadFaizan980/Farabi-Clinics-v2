import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_vm.dart';
import '../../data/constants/app_locales.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import 'dart:ui';

class LanguageSelectionVm extends AppBaseVm {
  Locale _selected = AppLocales.english;

  void select(Locale locale) {
    _selected = locale;
    notifyListeners();
  }

  /// persisting the language also updates the `lang` header the api reads, so
  /// it must land before the next request.
  Future<Locale> confirm() async {
    setBusy(true);
    await AppDi.locator<AuthSession>()
        .setLanguageCode(AppLocales.apiLang(_selected));
    setBusy(false);
    await AppNavigator.resetTo(AppRoutes.shell);
    return _selected;
  }

  /// getters/setters below this line...

  Locale get selected => _selected;
  bool isSelected(Locale locale) =>
      locale.languageCode == _selected.languageCode;
}
