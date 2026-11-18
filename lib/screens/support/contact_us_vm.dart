import 'package:flutter/widgets.dart';

import '../../data/base/app_base_vm.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../data/models/support/support_models.dart';
import '../../repos/discovery/branches_repo.dart';
import '../../repos/discovery/services_repo.dart';
import '../../repos/support/support_repo.dart';

class ContactUsVm extends AppBaseVm {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<BranchDataModel> _branches = const [];
  List<ServiceDataModel> _services = const [];

  int? _branchId;
  int? _serviceId;
  String? _aboutUs;
  bool _sent = false;

  Future<void> onInit() async {
    setBusy(true);
    final results = await Future.wait([
      repo<BranchesRepo>().branches(),
      repo<ServicesRepo>().mainServices(),
    ]);
    setBusy(false);

    final branches = results[0];
    final services = results[1];
    if (branches.success) {
      _branches = (branches.data as List<BranchDataModel>?) ?? const [];
    }
    if (services.success) {
      _services = (services.data as List<ServiceDataModel>?) ?? const [];
    }
    notifyListeners();
  }

  ContactRequestModel get _request => ContactRequestModel(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        branchId: _branchId,
        serviceId: _serviceId,
        aboutUs: _aboutUs,
      );

  Future<void> submit() async {
    clearFailure(notify: false);
    _sent = false;

    if (!_request.isComplete) {
      setErrorMessage(LocaleKeys.errors_field_required);
      return;
    }

    setBusy(true);
    final response = await repo<SupportRepo>().submitContact(_request);
    setBusy(false);

    if (!response.success) {
      captureFailure(response);
      return;
    }

    _sent = true;
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _branchId = null;
    _serviceId = null;
    _aboutUs = null;
    notifyListeners();
  }

  void setBranch(int? id) {
    _branchId = id;
    notifyListeners();
  }

  void setService(int? id) {
    _serviceId = id;
    notifyListeners();
  }

  void setAboutUs(String? value) {
    _aboutUs = value;
    notifyListeners();
  }

  void onFieldChanged(String _) {
    if (hasFailure || _sent) {
      _sent = false;
      clearFailure(notify: false);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;
  List<BranchDataModel> get branches => _branches;
  List<ServiceDataModel> get services => _services;
  int? get branchId => _branchId;
  int? get serviceId => _serviceId;
  String? get aboutUs => _aboutUs;
  bool get sent => _sent;
  List<String> get sources => ContactSources.values;
  bool get canSubmit => _request.isComplete;
}
