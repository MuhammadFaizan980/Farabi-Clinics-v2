import '../../data/base/app_base_vm.dart';
import '../../data/models/auth/otp_request_model.dart';
import '../../repos/auth/password_repo.dart';
import '../../repos/discovery/countries_repo.dart';
import '../../router/app_navigator.dart';
import '../../utils/phone_field_controller.dart';

/// forgot password, as on the site: send the national number, then show
/// "Check your messages". the reset itself happens from the link the patient
/// receives, so there is no code entry here.
class ForgotPasswordVm extends AppBaseVm {
  final PhoneFieldController phone = PhoneFieldController();

  String? _validationKey;
  bool _sent = false;

  Future<void> onInit() => phone.load(repo<CountriesRepo>());

  bool get canSubmit => !phone.isEmpty;

  Future<void> submit() async {
    clearFailure(notify: false);
    final request = MobileOnlyRequestModel(mobile: phone.national);
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
    _sent = true;
    notifyListeners();
  }

  void onFieldChanged(String _) {
    if (_validationKey != null || hasFailure) {
      _validationKey = null;
      clearFailure(notify: false);
    }
    notifyListeners();
  }

  void goBackToSignIn() => AppNavigator.pop();

  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  String? get validationKey => _validationKey;
  bool get sent => _sent;
}
