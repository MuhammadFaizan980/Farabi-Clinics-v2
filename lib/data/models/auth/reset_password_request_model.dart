import '../../constants/app_constants.dart';
import '../../constants/locale_keys.g.dart';
import 'mobile_number.dart';

class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.mobile,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  final String mobile;
  final String otp;
  final String password;
  final String passwordConfirmation;

  String? validate() {
    if (!MobileNumber.isValidSaudi(mobile)) {
      return LocaleKeys.errors_invalid_mobile;
    }
    if (MobileNumber.digitsOnly(otp).length != AppConstants.otpLength) {
      return LocaleKeys.errors_invalid_otp;
    }
    if (password.length < 8) return LocaleKeys.errors_invalid_password;
    if (password != passwordConfirmation) {
      return LocaleKeys.errors_password_mismatch;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'mobile': MobileNumber.national(mobile),
        'otp': otp.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}
