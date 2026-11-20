/// every localisable object on this api carries `name` (already resolved by the
/// `lang` header) plus explicit `name_ar` / `name_en`, so a screen can render
/// either language without a refetch.
class LocalisedName {
  const LocalisedName({this.name, this.nameAr, this.nameEn});

  final String? name;
  final String? nameAr;
  final String? nameEn;

  String display(String languageCode) {
    if (languageCode == 'ar') return nameAr ?? name ?? '';
    return nameEn ?? name ?? '';
  }
}

/// one entry of `GET v1/portal/countries`. `code` is meant to be an ISO
/// alpha-2 code ("SA"); the dial code is not in the payload, it is worked out
/// from the code on the device.
class CountryDataModel {
  const CountryDataModel({
    required this.id,
    required this.code,
    required this.names,
  });

  final int id;
  final String code;
  final LocalisedName names;
}

class RegionDataModel {
  const RegionDataModel({required this.id, required this.names});

  final int id;
  final LocalisedName names;
}

class ServiceDataModel {
  const ServiceDataModel({
    required this.id,
    required this.names,
    this.imageUrl,
    this.hasOffer = false,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.price,
    this.durationMinutes,
  });

  final int id;
  final LocalisedName names;
  final String? imageUrl;
  final bool hasOffer;
  final num ratingAverage;
  final int ratingCount;

  /// arrives as a decimal string ("45.00"), never a number
  final double? price;
  final int? durationMinutes;
}

class BranchDataModel {
  const BranchDataModel({
    required this.id,
    required this.names,
    this.address,
    this.phone,
    this.image,
    this.latitude,
    this.longitude,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.region,
    this.services = const [],
  });

  final int id;
  final LocalisedName names;
  final String? address;
  final String? phone;
  final String? image;
  final double? latitude;
  final double? longitude;
  final num ratingAverage;
  final int ratingCount;
  final RegionDataModel? region;

  /// the services this branch offers (detail payload only)
  final List<ServiceDataModel> services;

  /// every branch on the test host has these null, so the map and call actions
  /// have to degrade rather than fire an empty intent.
  bool get canOpenMap => latitude != null && longitude != null;
  bool get canCall => (phone ?? '').isNotEmpty;
}

/// one opening shift, times as the api sends them ("09:00:00")
class WorkingShiftDataModel {
  const WorkingShiftDataModel({required this.start, required this.end});

  final String start;
  final String end;
}

/// opening hours of one weekday. `dayOfWeek` follows the api: 0 is Sunday.
class WorkingDayDataModel {
  const WorkingDayDataModel({required this.dayOfWeek, this.shifts = const []});

  final int dayOfWeek;
  final List<WorkingShiftDataModel> shifts;
}

class DoctorBranchDataModel {
  const DoctorBranchDataModel({
    required this.id,
    this.name,
    this.names,
    this.address,
    this.workingHours = const [],
  });

  final int id;
  final String? name;

  /// both languages, present on the doctor detail payload
  final LocalisedName? names;
  final String? address;

  /// per-branch hours, only on the doctor detail payload
  final List<WorkingDayDataModel> workingHours;

  String displayName(String languageCode) =>
      names?.display(languageCode) ?? name ?? '';
}

class DoctorDataModel {
  const DoctorDataModel({
    required this.id,
    required this.names,
    this.image,
    this.gender,
    this.qualification,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.branches = const [],
    this.specialities = const [],
    this.patientsCount,
    this.experienceYears,
    this.satisfactionPercentage,
    this.briefSummary,
  });

  final int id;
  final LocalisedName names;
  final String? image;
  final String? gender;

  /// the api returns this either as a string or as an object with `.name`
  final String? qualification;
  final num ratingAverage;
  final int ratingCount;
  final List<DoctorBranchDataModel> branches;
  final List<DoctorBranchDataModel> specialities;

  // detail-only fields; null on the list endpoint
  final int? patientsCount;
  final int? experienceYears;
  final num? satisfactionPercentage;
  final String? briefSummary;

  DoctorBranchDataModel? get primaryBranch =>
      branches.isEmpty ? null : branches.first;
}

/// what a paginated list hands back to a view model.
class PagedResult<T> {
  const PagedResult({required this.items, this.total});

  final List<T> items;
  final int? total;
}

class HomeRegionBranchesDataModel {
  const HomeRegionBranchesDataModel({
    required this.id,
    required this.names,
    this.branchesCount = 0,
    this.branches = const [],
  });

  final int id;
  final LocalisedName names;
  final int branchesCount;
  final List<BranchDataModel> branches;
}
