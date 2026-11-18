import '../../constants/locale_keys.g.dart';
import 'mobile_number.dart';

class RegisterRequestModel {
  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.password,
    required this.passwordConfirmation,
    required this.citizenIdNumber,
    required this.citizenIdType,
  });

  final String firstName;
  final String lastName;
  final String mobile;
  final String password;
  final String passwordConfirmation;
  final String citizenIdNumber;
  final int? citizenIdType;

  String? validate() {
    if (firstName.trim().length < 2) return LocaleKeys.errors_invalid_name;
    if (lastName.trim().length < 2) return LocaleKeys.errors_invalid_name;
    if (!MobileNumber.isValidSaudi(mobile)) {
      return LocaleKeys.errors_invalid_mobile;
    }
    if (password.length < 8) return LocaleKeys.errors_invalid_password;
    if (password != passwordConfirmation) {
      return LocaleKeys.errors_password_mismatch;
    }
    if (citizenIdNumber.trim().length < 10) {
      return LocaleKeys.errors_invalid_id_number;
    }
    if (citizenIdType == null) return LocaleKeys.errors_id_type_required;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'country_code': MobileNumber.saudiDialCode,
        'mobile': MobileNumber.national(mobile),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'citizen_id_number': citizenIdNumber.trim(),
        'citizen_id_type': citizenIdType,
      };
}
