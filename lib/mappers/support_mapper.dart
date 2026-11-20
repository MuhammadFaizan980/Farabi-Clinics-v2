import '../data/base/app_base_mapper.dart';
import '../data/models/discovery/discovery_models.dart';
import '../data/models/support/support_models.dart';

class SupportMapper extends AppBaseMapper {
  const SupportMapper();

  JobDataModel job(Map<String, dynamic> map) {
    final branch = AppBaseMapper.asMap(map['branch']);
    return JobDataModel(
          id: AppBaseMapper.asInt(map['id']) ?? 0,
          slug: AppBaseMapper.asString(map['slug']) ?? '',
          names: LocalisedName(
            name: AppBaseMapper.asString(map['title']),
            nameAr: AppBaseMapper.asString(map['title_ar']),
            nameEn: AppBaseMapper.asString(map['title_en']),
          ),
          department: AppBaseMapper.asString(map['department']),
          summary: AppBaseMapper.asString(map['summary']),
          employmentType: AppBaseMapper.asString(
              AppBaseMapper.asMap(map['employment_type'])['label']),
          branchName: AppBaseMapper.asString(branch['name']),
          cityName: AppBaseMapper.asString(branch['city']),
          experienceMinYears:
              AppBaseMapper.asInt(map['experience_min_years']),
          experienceMaxYears:
              AppBaseMapper.asInt(map['experience_max_years']),
          publishedAt: AppBaseMapper.asUtcDateTime(
              map['published_at'] ?? map['created_at']),
        );
  }

  List<JobDataModel> jobs(dynamic raw) =>
      AppBaseMapper.asList(raw).map(job).toList(growable: false);

  List<String> _strings(dynamic raw) => raw is List
      ? raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
      : const [];

  JobDetailDataModel? jobDetail(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    if (AppBaseMapper.asInt(map['id']) == null) return null;
    return JobDetailDataModel(
      job: job(map),
      aboutRole: AppBaseMapper.asString(map['about_role']),
      responsibilities: _strings(map['responsibilities']),
      requirements: _strings(map['requirements']),
      offers: _strings(map['offers']),
      benefits: _strings(map['benefits']),
      descriptionUrl: AppBaseMapper.asString(map['job_description_url']),
    );
  }

  List<String> departments(dynamic raw) => AppBaseMapper.asList(raw)
      .map((map) => AppBaseMapper.asString(map['department']))
      .whereType<String>()
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList(growable: false);

  /// the offers list is empty on the test host, so this shape is read
  /// defensively: the same title/title_ar/title_en convention as every other
  /// localisable payload, and every other field optional.
  List<OfferDataModel> offers(dynamic raw) =>
      AppBaseMapper.asList(raw).map((map) {
        return OfferDataModel(
          id: AppBaseMapper.asInt(map['id']) ?? 0,
          names: LocalisedName(
            name: AppBaseMapper.asString(map['title'] ?? map['name']),
            nameAr: AppBaseMapper.asString(map['title_ar'] ?? map['name_ar']),
            nameEn: AppBaseMapper.asString(map['title_en'] ?? map['name_en']),
          ),
          description: AppBaseMapper.asString(
              map['description'] ?? map['summary']),
          image: AppBaseMapper.asString(map['image']),
          endsAt: AppBaseMapper.asUtcDateTime(
              map['ends_at'] ?? map['end_date'] ?? map['expires_at']),
        );
      }).toList(growable: false);

  List<BlogPostDataModel> posts(dynamic raw) =>
      AppBaseMapper.asList(raw).map((map) {
        return BlogPostDataModel(
          id: AppBaseMapper.asInt(map['id']) ?? 0,
          names: LocalisedName(
            name: AppBaseMapper.asString(map['title']),
            nameAr: AppBaseMapper.asString(map['title_ar']),
            nameEn: AppBaseMapper.asString(map['title_en']),
          ),
          summary: AppBaseMapper.asString(map['summary']),
          image: AppBaseMapper.asString(map['image']),
          publishedAt: AppBaseMapper.asUtcDateTime(
              map['published_at'] ?? map['created_at']),
        );
      }).toList(growable: false);
}
