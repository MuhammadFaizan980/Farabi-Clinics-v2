import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_model.dart';
import '../../data/base/app_base_vm.dart';
import '../../data/constants/app_constants.dart';
import '../../data/models/auth/otp_args_model.dart';
import '../../data/models/auth/otp_request_model.dart';
import '../../repos/auth/otp_repo.dart';
import '../../repos/auth/password_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class OtpVerificationVm extends AppBaseVm {
  OtpVerificationVm(this._args);

  final OtpArgsModel _args;

  final TextEditingController _otpController = TextEditingController();

  Timer? _timer;
  int _secondsRemaining = 0;
  String? _validationKey;
  bool _isResending = false;

  void onInit() {
    final prefilled = _args.prefilledOtp;
    if (prefilled != null && prefilled.isNotEmpty) {
      _otpController.text = prefilled;
    }
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsRemaining = AppConstants.otpResendSeconds;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _secondsRemaining = 0;
      } else {
        _secondsRemaining--;
      }
      notifyListeners();
    });
  }

  Future<void> verify() async {
    clearFailure(notify: false);
    final request = OtpConfirmRequestModel(
      mobile: _args.mobile,
      otp: _otpController.text,
    );
    _validationKey = request.validate();
    if (_validationKey != null) {
      notifyListeners();
      return;
    }

    // a password reset only needs the code carried forward; the token comes
    // after the new password is set.
    if (_args.purpose == OtpPurpose.passwordReset) {
      await AppNavigator.replaceWith(
        AppRoutes.resetPassword,
        arguments: ResetPasswordArgsModel(
          mobile: _args.mobile,
          otp: _otpController.text.trim(),
        ),
      );
      return;
    }

    setBusy(true);
    final response = await repo<OtpRepo>().confirm(request);
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

  Future<void> resend() async {
    if (_secondsRemaining > 0 || _isResending) return;

    clearFailure(notify: false);
    _isResending = true;
    notifyListeners();

    final request = MobileOnlyRequestModel(mobile: _args.mobile);
    final response = _args.purpose == OtpPurpose.passwordReset
        ? await repo<PasswordRepo>().forgotPassword(request)
        : await repo<OtpRepo>().resend(request);

    _isResending = false;

    if (!response.success) {
      captureFailure(response);
      return;
    }

    final otp = response.data?.otp;
    if (otp != null && otp.isNotEmpty) _otpController.text = otp;

    _startCountdown();
  }

  void onOtpChanged(String _) {
    if (_validationKey != null || hasFailure) {
      _validationKey = null;
      clearFailure(notify: false);
    }
    notifyListeners();
  }

  void changeNumber() => AppNavigator.pop();

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  TextEditingController get otpController => _otpController;
  int get secondsRemaining => _secondsRemaining;
  bool get canResend => _secondsRemaining == 0 && !_isResending;
  bool get isResending => _isResending;
  String? get validationKey => _validationKey;
  String get mobile => _args.mobile;
  bool get canSubmit =>
      _otpController.text.trim().length == AppConstants.otpLength;
}
