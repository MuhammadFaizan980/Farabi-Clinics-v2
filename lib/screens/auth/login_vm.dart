import 'package:flutter/widgets.dart';

import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_model.dart';
import '../../data/base/app_base_vm.dart';
import '../../data/models/auth/login_request_model.dart';
import '../../repos/auth/login_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class LoginVm extends AppBaseVm {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _validationKey;
  bool _obscurePassword = true;

  LoginRequestModel get _request => LoginRequestModel(
        mobile: _mobileController.text,
        password: _passwordController.text,
      );

  bool get canSubmit =>
      _mobileController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  Future<void> submit() async {
    clearFailure(notify: false);
    _validationKey = _request.validate();
    if (_validationKey != null) {
      notifyListeners();
      return;
    }

    setBusy(true);
    final response = await repo<LoginRepo>().login(_request);
    setBusy(false);

    if (!response.success || response.data == null) {
      captureFailure(response);
      return;
    }

    final auth = response.data!;
    final session = AppDi.locator<AuthSession>();
    await session.setToken(auth.token);
    session.setPatient(auth.patient);
    AppDi.locator<AppBaseModel>().patient = auth.patient;

    await AppNavigator.resetTo(AppRoutes.shell);
  }

  void toggleObscure() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void onFieldChanged(String _) {
    if (_validationKey != null || hasFailure) {
      _validationKey = null;
      clearFailure(notify: false);
    }
    notifyListeners();
  }

  void goToRegister() => AppNavigator.push(AppRoutes.register);

  void goToForgotPassword() => AppNavigator.push(AppRoutes.forgotPassword);

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  TextEditingController get mobileController => _mobileController;
  TextEditingController get passwordController => _passwordController;
  String? get validationKey => _validationKey;
  bool get obscurePassword => _obscurePassword;
}
