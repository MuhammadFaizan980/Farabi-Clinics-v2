import '../../constants/locale_keys.g.dart';

class LoginRequestModel {
  const LoginRequestModel({required this.mobile, required this.password});

  /// the national number with its national prefix ("0564772491"), exactly what
  /// the site posts. the country is not sent on sign in.
  final String mobile;
  final String password;

  /// returns a locale key, or null when the model is good to send. like the
  /// site, only emptiness is checked here; the server judges the rest.
  String? validate() {
    if (mobile.trim().isEmpty) return LocaleKeys.errors_invalid_mobile;
    if (password.trim().isEmpty) return LocaleKeys.errors_field_required;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'password': password,
      };
}
