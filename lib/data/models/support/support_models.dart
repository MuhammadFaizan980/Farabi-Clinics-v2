import '../discovery/discovery_models.dart';

class JobDataModel {
  const JobDataModel({
    required this.id,
    required this.slug,
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
  final String slug;
  final LocalisedName names;
  final String? department;
  final String? summary;
  final String? employmentType;
  final String? branchName;
  final String? cityName;
  final int? experienceMinYears;
  final int? experienceMaxYears;
  final DateTime? publishedAt;

  /// "2 months ago" style age, in whole days (the screen words it)
  int? get postedDaysAgo {
    final at = publishedAt;
    if (at == null) return null;
    final days = DateTime.now().toUtc().difference(at).inDays;
    return days < 0 ? 0 : days;
  }

  String get experienceRange {
    final min = experienceMinYears;
    final max = experienceMaxYears;
    if (min == null) return '';
    if (max == null || max <= min) return '$min';
    return '$min - $max';
  }
}

/// a job with the long-form sections the detail page shows
class JobDetailDataModel {
  const JobDetailDataModel({
    required this.job,
    this.aboutRole,
    this.responsibilities = const [],
    this.requirements = const [],
    this.offers = const [],
    this.benefits = const [],
    this.descriptionUrl,
  });

  final JobDataModel job;
  final String? aboutRole;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> offers;
  final List<String> benefits;

  /// null when no job-description file was uploaded for the post
  final String? descriptionUrl;
}

/// what the apply form submits; field names are the ones the site posts
class JobApplicationModel {
  const JobApplicationModel({
    required this.jobId,
    required this.jobTitle,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.currentPosition,
    required this.yearsOfExperience,
    required this.licenseNumber,
    required this.speciality,
    required this.highestDegree,
    required this.institution,
    required this.graduationYear,
    required this.coverLetter,
    this.referenceName = '',
    this.referenceRelationship = '',
    this.referenceContact = '',
    this.cvPath,
    this.cvName,
  });

  final int jobId;
  final String jobTitle;
  final String fullName;
  final String email;
  final String phone;

  /// "DD / MM / YYYY", exactly as the site sends it
  final String dateOfBirth;
  final String currentPosition;
  final String yearsOfExperience;
  final String licenseNumber;
  final String speciality;
  final String highestDegree;
  final String institution;
  final int graduationYear;
  final String coverLetter;
  final String referenceName;
  final String referenceRelationship;
  final String referenceContact;
  final String? cvPath;
  final String? cvName;

  Map<String, dynamic> toFields() => {
        'job_id': '$jobId',
        'job_title': jobTitle,
        'name': fullName.trim(),
        'email': email.trim(),
        'mobile_number': phone.trim(),
        'date_of_birth': dateOfBirth,
        'current_position': currentPosition.trim(),
        'years_of_experience': yearsOfExperience,
        'license_number': licenseNumber.trim(),
        'speciality': speciality,
        'highest_degree': highestDegree.trim(),
        'institution': institution.trim(),
        'graduation_year': '$graduationYear',
        'cover_letter': coverLetter.trim(),
        'reference_name': referenceName.trim(),
        'reference_relationship': referenceRelationship.trim(),
        'reference_contact': referenceContact.trim(),
      };
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

class OfferDataModel {
  const OfferDataModel({
    required this.id,
    required this.names,
    this.description,
    this.image,
    this.endsAt,
  });

  final int id;
  final LocalisedName names;
  final String? description;
  final String? image;
  final DateTime? endsAt;
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
