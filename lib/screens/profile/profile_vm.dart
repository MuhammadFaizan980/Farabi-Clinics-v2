import 'package:flutter/widgets.dart';

import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_model.dart';
import '../../data/base/app_base_vm.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../repos/auth/profile_repo.dart';
import '../../repos/auth/profile_update_repo.dart';

class ProfileVm extends AppBaseVm {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  String _mobile = '';
  bool _saved = false;

  Future<void> onInit() => load();

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<ProfileRepo>().fetchMe();

    setBusy(false);
    if (!response.success || response.data == null) {
      captureFailure(response);
      return;
    }

    final patient = response.data!;
    _firstNameController.text = patient.firstName ?? '';
    _lastNameController.text = patient.lastName ?? '';
    _emailController.text = patient.email ?? '';
    _idNumberController.text = patient.citizenIdNumber ?? '';
    _mobile = patient.mobile ?? '';

    AppDi.locator<AuthSession>().setPatient(patient);
    AppDi.locator<AppBaseModel>().patient = patient;
    notifyListeners();
  }

  Future<void> save() async {
    clearFailure(notify: false);
    _saved = false;

    // the api requires all four; the save button mirrors that
    if (!canSave) {
      setErrorMessage(LocaleKeys.errors_field_required);
      return;
    }

    setBusy(true);
    final response = await repo<ProfileUpdateRepo>().update(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      citizenIdNumber: _idNumberController.text.trim(),
    );
    setBusy(false);

    if (!response.success) {
      captureFailure(response);
      return;
    }

    if (response.data != null) {
      AppDi.locator<AuthSession>().setPatient(response.data);
      AppDi.locator<AppBaseModel>().patient = response.data;
    }
    _saved = true;
    notifyListeners();
  }

  void onFieldChanged(String _) {
    if (hasFailure || _saved) {
      _saved = false;
      clearFailure(notify: false);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get idNumberController => _idNumberController;
  String get mobile => _mobile;
  bool get saved => _saved;
  bool get canSave =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _idNumberController.text.trim().isNotEmpty;
}
