import 'package:flutter/widgets.dart';

import '../../../data/base/app_base_vm.dart';
import '../../../data/models/discovery/discovery_models.dart';
import '../../../repos/discovery/doctors_repo.dart';
import '../../../repos/discovery/regions_repo.dart';
import '../../../repos/discovery/services_repo.dart';

class DoctorsListVm extends AppBaseVm {
  final TextEditingController _searchController = TextEditingController();

  final List<DoctorDataModel> _doctors = [];
  List<RegionDataModel> _regions = const [];
  List<ServiceDataModel> _services = const [];

  int? _regionId;
  int? _serviceId;
  String? _gender;
  int _page = 1;
  int? _total;
  bool _isLoadingMore = false;
  bool _loadMoreFailed = false;

  Future<void> onInit() async {
    // the frame always shows a city, so the first region (Riyadh, the lowest
    // id) is selected before the first fetch
    await _loadRegions();
    _regionId ??= _regions.isEmpty ? null : _regions.first.id;
    await Future.wait([_loadServices(), load()]);
  }

  Future<void> _loadRegions() async {
    final response = await repo<RegionsRepo>().regions();
    if (response.success && response.data != null) {
      _regions = [...response.data!]..sort((a, b) => a.id.compareTo(b.id));
      notifyListeners();
    }
  }

  Future<void> _loadServices() async {
    final response = await repo<ServicesRepo>().mainServices();
    if (response.success && response.data != null) {
      _services = response.data!;
      notifyListeners();
    }
  }

  Future<void> load() async {
    setBusy(true);
    clearFailure(notify: false);
    _page = 1;
    _loadMoreFailed = false;

    final response = await _fetch(_page);

    setBusy(false);
    if (!response.success || response.data == null) {
      captureFailure(response);
      return;
    }
    _doctors
      ..clear()
      ..addAll(response.data!.items);
    _total = response.data!.total;
    notifyListeners();
  }

  /// pull-to-refresh
  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    _loadMoreFailed = false;
    notifyListeners();

    final response = await _fetch(_page + 1);

    _isLoadingMore = false;
    if (!response.success || response.data == null) {
      _loadMoreFailed = true;
      notifyListeners();
      return;
    }
    _page++;
    _doctors.addAll(response.data!.items);
    _total = response.data!.total;
    notifyListeners();
  }

  Future<dynamic> _fetch(int page) => repo<DoctorsRepo>().doctors(
        page: page,
        regionId: _regionId,
        serviceId: _serviceId,
        search: _searchController.text.trim(),
        gender: _gender,
      );

  void setRegion(int? regionId) {
    _regionId = regionId;
    load();
  }

  void setService(int? serviceId) {
    if (serviceId == _serviceId) return;
    _serviceId = serviceId;
    load();
  }

  void setGender(String? gender) {
    _gender = gender;
    load();
  }

  void onSearchSubmitted(String _) => load();

  void clearFilters() {
    _serviceId = null;
    _gender = null;
    _searchController.clear();
    load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  TextEditingController get searchController => _searchController;
  List<DoctorDataModel> get doctors => List.unmodifiable(_doctors);
  List<RegionDataModel> get regions => _regions;
  List<ServiceDataModel> get services => _services;
  int? get regionId => _regionId;
  int? get serviceId => _serviceId;
  String? get gender => _gender;
  bool get isLoadingMore => _isLoadingMore;
  bool get loadMoreFailed => _loadMoreFailed;
  bool get isEmpty => !isBusy && !hasFailure && _doctors.isEmpty;

  RegionDataModel? get selectedRegion {
    for (final region in _regions) {
      if (region.id == _regionId) return region;
    }
    return null;
  }

  /// `meta.total` is null on the test host, so "unknown total" must not be read
  /// as "no more pages" — it simply means load-more stays unavailable.
  bool get hasMore => _total != null && _doctors.length < _total!;

  bool get hasActiveFilters =>
      _serviceId != null ||
      _gender != null ||
      _searchController.text.isNotEmpty;
}
