import '../../constants/locale_keys.g.dart';

class RegisterRequestModel {
  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.mobile,
    required this.password,
    required this.citizenIdNumber,
    required this.citizenIdType,
  });

  final String firstName;
  final String lastName;

  /// "+966", from the country chosen in the phone field
  final String countryCode;

  /// the national number with its national prefix
  final String mobile;
  final String password;
  final String citizenIdNumber;
  final int? citizenIdType;

  /// the site asks for every field and checks nothing else on the device
  String? validate() {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return LocaleKeys.errors_invalid_name;
    }
    if (citizenIdType == null) return LocaleKeys.errors_id_type_required;
    if (citizenIdNumber.trim().isEmpty) {
      return LocaleKeys.errors_invalid_id_number;
    }
    if (mobile.trim().isEmpty) return LocaleKeys.errors_invalid_mobile;
    if (password.isEmpty) return LocaleKeys.errors_invalid_password;
    return null;
  }

  /// the site has no confirm field and sends the password twice
  Map<String, dynamic> toJson() => {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'country_code': countryCode,
        'mobile': mobile,
        'password': password,
        'password_confirmation': password,
        'citizen_id_number': citizenIdNumber.trim(),
        'citizen_id_type': citizenIdType,
      };
}
