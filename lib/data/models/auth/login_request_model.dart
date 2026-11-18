import '../../constants/locale_keys.g.dart';
import 'mobile_number.dart';

class LoginRequestModel {
  const LoginRequestModel({required this.mobile, required this.password});

  final String mobile;
  final String password;

  /// returns a locale key, or null when the model is good to send.
  String? validate() {
    if (!MobileNumber.isValidSaudi(mobile)) {
      return LocaleKeys.errors_invalid_mobile;
    }
    if (password.trim().isEmpty) return LocaleKeys.errors_field_required;
    return null;
  }

  /// the api wants the national form with its leading zero intact.
  Map<String, dynamic> toJson() => {
        'mobile': MobileNumber.national(mobile),
        'password': password,
      };
}
