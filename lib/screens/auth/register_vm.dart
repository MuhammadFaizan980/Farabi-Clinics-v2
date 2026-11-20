import 'package:flutter/widgets.dart';

import '../../data/base/app_base_vm.dart';
import '../../data/enums/citizen_id_type.dart';
import '../../data/models/auth/otp_args_model.dart';
import '../../data/models/auth/register_request_model.dart';
import '../../repos/auth/register_repo.dart';
import '../../repos/discovery/countries_repo.dart';
import '../../utils/phone_field_controller.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';

class RegisterVm extends AppBaseVm {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final PhoneFieldController phone = PhoneFieldController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  // like the site, nothing is chosen until the user picks an ID type
  CitizenIdType? _idType;
  String? _validationKey;

  RegisterRequestModel get _request => RegisterRequestModel(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        countryCode: phone.countryCode,
        mobile: phone.national,
        password: _passwordController.text,
        citizenIdNumber: _idNumberController.text,
        citizenIdType: _idType?.value,
      );

  Future<void> onInit() => phone.load(repo<CountriesRepo>());

  /// the site disables Create Account until an ID type, a phone and a
  /// password are set (and its names are required fields)
  bool get canSubmit =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _idType != null &&
      _idNumberController.text.trim().isNotEmpty &&
      !phone.isEmpty &&
      _passwordController.text.isNotEmpty;

  Future<void> submit() async {
    clearFailure(notify: false);
    _validationKey = _request.validate();
    if (_validationKey != null) {
      notifyListeners();
      return;
    }

    setBusy(true);
    final response = await repo<RegisterRepo>().register(_request);
    setBusy(false);

    if (!response.success) {
      captureFailure(response);
      return;
    }

    await AppNavigator.replaceWith(
      AppRoutes.otpVerification,
      arguments: OtpArgsModel(
        mobile: phone.national,
        purpose: OtpPurpose.registration,
        // dev convenience only; never surfaced in release builds
        prefilledOtp: response.data?.otp,
      ),
    );
  }

  void setIdType(CitizenIdType? type) {
    _idType = type;
    notifyListeners();
  }

  void onFieldChanged(String _) {
    if (_validationKey != null || hasFailure) {
      _validationKey = null;
      clearFailure(notify: false);
    }
    notifyListeners();
  }

  void goToLogin() => AppNavigator.pop();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    phone.dispose();
    _passwordController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get idNumberController => _idNumberController;
  CitizenIdType? get idType => _idType;
  String? get validationKey => _validationKey;
  List<CitizenIdType> get idTypes => CitizenIdType.values;
}
