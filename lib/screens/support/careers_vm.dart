import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/base/app_base_vm.dart';
import '../../data/models/support/support_models.dart';
import '../../repos/support/support_repo.dart';

/// the jobs list. department and search are sent to the api (it filters
/// server-side, up to 50 jobs a page), like the site.
class CareersVm extends AppBaseVm {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<JobDataModel> _jobs = const [];
  List<String> _departments = const [];
  String? _department;

  Future<void> onInit() async {
    await Future.wait([_loadDepartments(), load()]);
  }

  Future<void> _loadDepartments() async {
    final response = await repo<SupportRepo>().departments();
    if (response.success) {
      _departments = response.data ?? const [];
      notifyListeners();
    }
  }

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);

    final response = await repo<SupportRepo>().jobs(
      department: _department,
      search: _searchController.text.trim(),
    );

    setBusy(false);
    if (!response.success) {
      captureFailure(response);
      return;
    }
    _jobs = response.data ?? const [];
    notifyListeners();
  }

  Future<void> refresh() => load();

  void setDepartment(String? department) {
    if (department == _department) return;
    _department = department;
    load();
  }

  void onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), load);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  TextEditingController get searchController => _searchController;
  List<String> get departments => _departments;
  String? get department => _department;
  List<JobDataModel> get jobs => _jobs;
  bool get isEmpty => !isBusy && !hasFailure && _jobs.isEmpty;
}
