import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_model.dart';
import '../../data/base/app_base_vm.dart';
import '../../repos/auth/profile_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class SplashVm extends AppBaseVm {
  /// there is no refresh endpoint, so a stored token is only proven good by a
  /// profile call. anything else means a clean logout.
  Future<void> bootstrap() async {
    setBusy(true);

    final session = AppDi.locator<AuthSession>();

    if (!session.isLoggedIn) {
      await _goToEntry();
      return;
    }

    final response = await repo<ProfileRepo>().fetchMe();
    if (response.success && response.data != null) {
      session.setPatient(response.data);
      AppDi.locator<AppBaseModel>().patient = response.data;
      setBusy(false);
      await AppNavigator.resetTo(AppRoutes.shell);
      return;
    }

    // token rejected or unusable — drop it rather than carrying it around
    await session.clear();
    AppDi.locator<AppBaseModel>().clear();
    await _goToEntry();
  }

  Future<void> _goToEntry() async {
    setBusy(false);
    final hasChosenLanguage =
        AppDi.locator<AuthSession>().languageCode.isNotEmpty &&
            AppDi.locator<ProfileRepo>().appLocalData.languageCode != null;
    await AppNavigator.resetTo(
      hasChosenLanguage ? AppRoutes.shell : AppRoutes.languageSelection,
    );
  }
}
