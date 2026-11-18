import '../data/base/app_base_mapper.dart';
import '../data/models/discovery/discovery_models.dart';
import '../data/models/support/support_models.dart';

class SupportMapper extends AppBaseMapper {
  const SupportMapper();

  List<JobDataModel> jobs(dynamic raw) =>
      AppBaseMapper.asList(raw).map((map) {
        final branch = AppBaseMapper.asMap(map['branch']);
        return JobDataModel(
          id: AppBaseMapper.asInt(map['id']) ?? 0,
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
      }).toList(growable: false);

  List<String> departments(dynamic raw) => AppBaseMapper.asList(raw)
      .map((map) => AppBaseMapper.asString(map['department']))
      .whereType<String>()
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList(growable: false);

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
