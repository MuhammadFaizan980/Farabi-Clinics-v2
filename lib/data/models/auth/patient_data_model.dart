class PatientDataModel {
  const PatientDataModel({
    required this.id,
    this.patientId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.countryCode,
    this.citizenIdType,
    this.citizenIdNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
  });

  final int id;

  /// human-facing reference, e.g. PAT-DD81212C
  final String? patientId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;
  final String? countryCode;
  final int? citizenIdType;
  final String? citizenIdNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final bool isPhoneVerified;
  final bool isEmailVerified;

  String get fullName => [firstName, lastName]
      .whereType<String>()
      .where((part) => part.isNotEmpty)
      .join(' ');

  /// the booking flow refuses to proceed without this
  bool get hasCitizenId => (citizenIdNumber ?? '').isNotEmpty;
}
