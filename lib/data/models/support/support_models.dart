import '../discovery/discovery_models.dart';

class JobDataModel {
  const JobDataModel({
    required this.id,
    required this.names,
    this.department,
    this.summary,
    this.employmentType,
    this.branchName,
    this.cityName,
    this.experienceMinYears,
    this.experienceMaxYears,
    this.publishedAt,
  });

  final int id;
  final LocalisedName names;
  final String? department;
  final String? summary;
  final String? employmentType;
  final String? branchName;
  final String? cityName;
  final int? experienceMinYears;
  final int? experienceMaxYears;
  final DateTime? publishedAt;

  String get experienceRange {
    final min = experienceMinYears;
    final max = experienceMaxYears;
    if (min == null) return '';
    if (max == null || max <= min) return '$min';
    return '$min - $max';
  }
}

class BlogPostDataModel {
  const BlogPostDataModel({
    required this.id,
    required this.names,
    this.summary,
    this.image,
    this.publishedAt,
  });

  final int id;
  final LocalisedName names;
  final String? summary;
  final String? image;
  final DateTime? publishedAt;
}

class ContactRequestModel {
  const ContactRequestModel({
    required this.name,
    required this.phone,
    required this.branchId,
    required this.serviceId,
    required this.aboutUs,
    this.email = '',
  });

  final String name;
  final String phone;
  final int? branchId;
  final int? serviceId;
  final String? aboutUs;
  final String email;

  /// mirrors the website's own required set
  bool get isComplete =>
      name.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      branchId != null &&
      serviceId != null &&
      (aboutUs ?? '').isNotEmpty;

  /// sent as multipart, not json
  Map<String, dynamic> toFields() => {
        'name': name.trim(),
        'email': email.trim(),
        'phone_number': phone.trim(),
        'service_id': '$serviceId',
        'branch_id': '$branchId',
        'about_us': aboutUs ?? '',
      };
}

/// the exact option set the website offers
class ContactSources {
  ContactSources._();

  static const List<String> values = [
    'instagram',
    'snapchat',
    'tiktok',
    'twitter',
    'youtube',
    'facebook',
    'news',
    'friend',
    'other',
  ];
}
