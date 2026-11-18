import 'package:flutter/widgets.dart';

import '../../data/base/app_base_vm.dart';
import '../../data/models/auth/otp_args_model.dart';
import '../../data/models/auth/reset_password_request_model.dart';
import '../../repos/auth/password_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class ResetPasswordVm extends AppBaseVm {
  ResetPasswordVm(this._args);

  final ResetPasswordArgsModel _args;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _validationKey;
  bool _isDone = false;

  bool get canSubmit =>
      _passwordController.text.isNotEmpty && _confirmController.text.isNotEmpty;

  Future<void> submit() async {
    clearFailure(notify: false);
    final request = ResetPasswordRequestModel(
      mobile: _args.mobile,
      otp: _args.otp,
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );
    _validationKey = request.validate();
    if (_validationKey != null) {
      notifyListeners();
      return;
    }

    setBusy(true);
    final response = await repo<PasswordRepo>().resetPassword(request);
    setBusy(false);

    if (!response.success) {
      captureFailure(response);
      return;
    }

    _isDone = true;
    notifyListeners();
    await AppNavigator.resetTo(AppRoutes.login);
  }

  void onFieldChanged(String _) {
    if (_validationKey != null || hasFailure) {
      _validationKey = null;
      clearFailure(notify: false);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmController => _confirmController;
  String? get validationKey => _validationKey;
  bool get isDone => _isDone;
}
