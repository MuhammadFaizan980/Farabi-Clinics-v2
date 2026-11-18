/// captured from the website's own constant, both labels included.
enum CitizenIdType {
  passport(1, 'Passport ID', 'جواز سفر'),
  withoutId(2, 'Without ID', 'بدون هوية'),
  birthCertificate(3, 'Birth Certificate', 'شهادة ميلاد'),
  notSpecific(4, 'Not Specific', 'غير محدد'),
  iqama(5, 'Iqama', 'إقامة'),
  saudiCitizenId(6, 'Saudi Citizen ID', 'هوية مواطن سعودي');

  const CitizenIdType(this.value, this.labelEn, this.labelAr);

  final int value;
  final String labelEn;
  final String labelAr;

  String label(String languageCode) =>
      languageCode == 'ar' ? labelAr : labelEn;

  static CitizenIdType? fromValue(int? value) {
    if (value == null) return null;
    for (final type in CitizenIdType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}
