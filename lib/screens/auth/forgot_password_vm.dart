import 'package:flutter/widgets.dart';

import '../../data/base/app_base_vm.dart';
import '../../data/models/auth/otp_args_model.dart';
import '../../data/models/auth/otp_request_model.dart';
import '../../repos/auth/password_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class ForgotPasswordVm extends AppBaseVm {
  final TextEditingController _mobileController = TextEditingController();

  String? _validationKey;

  bool get canSubmit => _mobileController.text.trim().isNotEmpty;

  Future<void> submit() async {
    clearFailure(notify: false);
    final request = MobileOnlyRequestModel(mobile: _mobileController.text);
    _validationKey = request.validate();
    if (_validationKey != null) {
      notifyListeners();
      return;
    }

    setBusy(true);
    final response = await repo<PasswordRepo>().forgotPassword(request);
    setBusy(false);

    if (!response.success) {
      captureFailure(response);
      return;
    }

    await AppNavigator.replaceWith(
      AppRoutes.otpVerification,
      arguments: OtpArgsModel(
        mobile: _mobileController.text,
        purpose: OtpPurpose.passwordReset,
        prefilledOtp: response.data?.otp,
      ),
    );
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
    _mobileController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  TextEditingController get mobileController => _mobileController;
  String? get validationKey => _validationKey;
}
