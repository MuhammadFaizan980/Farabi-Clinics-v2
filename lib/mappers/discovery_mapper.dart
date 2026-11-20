import '../data/base/app_base_mapper.dart';
import '../data/models/discovery/discovery_models.dart';

class DiscoveryMapper extends AppBaseMapper {
  const DiscoveryMapper();

  LocalisedName _names(Map<String, dynamic> map) => LocalisedName(
        name: AppBaseMapper.asString(map['name']),
        nameAr: AppBaseMapper.asString(map['name_ar']),
        nameEn: AppBaseMapper.asString(map['name_en']),
      );

  RegionDataModel? region(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final id = AppBaseMapper.asInt(map['id']);
    if (id == null) return null;
    return RegionDataModel(id: id, names: _names(map));
  }

  List<RegionDataModel> regions(dynamic raw) => AppBaseMapper.asList(raw)
      .map(region)
      .whereType<RegionDataModel>()
      .toList(growable: false);

  ServiceDataModel? service(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final id = AppBaseMapper.asInt(map['id']);
    if (id == null) return null;
    return ServiceDataModel(
      id: id,
      names: _names(map),
      imageUrl: AppBaseMapper.asString(map['image_url']) ??
          AppBaseMapper.asString(map['image']),
      hasOffer: AppBaseMapper.asBool(map['has_offer']),
      ratingAverage: AppBaseMapper.asDouble(map['rating_average']) ?? 0,
      ratingCount: AppBaseMapper.asInt(map['rating_count']) ?? 0,
      price: AppBaseMapper.asDouble(map['price']),
      durationMinutes: AppBaseMapper.asInt(map['duration_minutes']) ??
          AppBaseMapper.asInt(map['slot']),
    );
  }

  List<ServiceDataModel> services(dynamic raw) => AppBaseMapper.asList(raw)
      .map(service)
      .whereType<ServiceDataModel>()
      .toList(growable: false);

  BranchDataModel? branch(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final id = AppBaseMapper.asInt(map['id']);
    if (id == null) return null;
    return BranchDataModel(
      id: id,
      names: _names(map),
      address: AppBaseMapper.asString(map['address']),
      phone: AppBaseMapper.asString(map['phone']),
      image: AppBaseMapper.asString(map['image']),
      latitude: AppBaseMapper.asDouble(map['latitude']),
      longitude: AppBaseMapper.asDouble(map['longitude']),
      ratingAverage: AppBaseMapper.asDouble(map['rating_average']) ?? 0,
      ratingCount: AppBaseMapper.asInt(map['rating_count']) ?? 0,
      region: region(map['region']),
      services: services(map['services']),
    );
  }

  List<BranchDataModel> branches(dynamic raw) => AppBaseMapper.asList(raw)
      .map(branch)
      .whereType<BranchDataModel>()
      .toList(growable: false);

  DoctorBranchDataModel? _nested(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final id = AppBaseMapper.asInt(map['id']);
    if (id == null) return null;
    return DoctorBranchDataModel(
      id: id,
      name: AppBaseMapper.asString(map['name']),
      names: _names(map),
      address: AppBaseMapper.asString(map['address']),
      workingHours: _workingHours(map['working_hours']),
    );
  }

  /// `working_hours` is a list of days, each with its shifts; anything else
  /// (the site's own mapper expects a string) is treated as "no hours"
  List<WorkingDayDataModel> _workingHours(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final day in raw.whereType<Map>())
        if (AppBaseMapper.asInt(day['day_of_week']) != null)
          WorkingDayDataModel(
            dayOfWeek: AppBaseMapper.asInt(day['day_of_week'])!,
            shifts: [
              for (final shift in AppBaseMapper.asList(day['shifts']))
                if (AppBaseMapper.asString(shift['start_time']) != null &&
                    AppBaseMapper.asString(shift['end_time']) != null)
                  WorkingShiftDataModel(
                    start: AppBaseMapper.asString(shift['start_time'])!,
                    end: AppBaseMapper.asString(shift['end_time'])!,
                  ),
            ],
          ),
    ];
  }

  DoctorDataModel? doctor(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final id = AppBaseMapper.asInt(map['id']);
    if (id == null) return null;

    // qualification is a string on some payloads and an object on others
    final rawQualification = map['qualification'];
    final qualification = rawQualification is Map
        ? AppBaseMapper.asString(
            Map<String, dynamic>.from(rawQualification)['name'])
        : AppBaseMapper.asString(rawQualification);

    // the list endpoint spells it `specialties`; other payloads use
    // `specialities`. accept either.
    final specialities =
        map['specialities'] ?? map['specialties'] ?? const <dynamic>[];

    return DoctorDataModel(
      id: id,
      names: _names(map),
      image: AppBaseMapper.asString(map['image']),
      gender: AppBaseMapper.asString(map['gender']),
      qualification: qualification,
      ratingAverage: AppBaseMapper.asDouble(map['rating_average']) ?? 0,
      ratingCount: AppBaseMapper.asInt(map['rating_count']) ?? 0,
      branches: AppBaseMapper.asList(map['branches'])
          .map(_nested)
          .whereType<DoctorBranchDataModel>()
          .toList(growable: false),
      specialities: AppBaseMapper.asList(specialities)
          .map(_nested)
          .whereType<DoctorBranchDataModel>()
          .toList(growable: false),
      patientsCount: AppBaseMapper.asInt(map['patients_count']),
      experienceYears: AppBaseMapper.asInt(map['experience_years']),
      satisfactionPercentage:
          AppBaseMapper.asDouble(map['satisfaction_percentage']),
      briefSummary: AppBaseMapper.asString(map['brief_summary']),
    );
  }

  List<DoctorDataModel> doctors(dynamic raw) => AppBaseMapper.asList(raw)
      .map(doctor)
      .whereType<DoctorDataModel>()
      .toList(growable: false);

  /// `meta.total` drives load-more. it comes back null on the test host, which
  /// is why the paging state has to treat null as "unknown", not "zero".
  int? totalFromMeta(dynamic rawMeta) =>
      AppBaseMapper.asInt(AppBaseMapper.asMap(rawMeta)['total']);

  List<HomeRegionBranchesDataModel> homeBranches(dynamic raw) =>
      AppBaseMapper.asList(raw).map((map) {
        final id = AppBaseMapper.asInt(map['id']) ?? 0;
        return HomeRegionBranchesDataModel(
          id: id,
          names: _names(map),
          branchesCount: AppBaseMapper.asInt(map['branches_count']) ?? 0,
          branches: branches(map['branches']),
        );
      }).toList(growable: false);
}
