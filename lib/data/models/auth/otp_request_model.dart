import '../../constants/app_constants.dart';
import '../../constants/locale_keys.g.dart';
import 'mobile_number.dart';

class OtpConfirmRequestModel {
  const OtpConfirmRequestModel({required this.mobile, required this.otp});

  final String mobile;
  final String otp;

  String? validate() {
    if (!MobileNumber.isValidSaudi(mobile)) {
      return LocaleKeys.errors_invalid_mobile;
    }
    if (MobileNumber.digitsOnly(otp).length != AppConstants.otpLength) {
      return LocaleKeys.errors_invalid_otp;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'mobile': MobileNumber.national(mobile),
        'otp': otp.trim(),
      };
}

class MobileOnlyRequestModel {
  const MobileOnlyRequestModel({required this.mobile});

  final String mobile;

  String? validate() => MobileNumber.isValidSaudi(mobile)
      ? null
      : LocaleKeys.errors_invalid_mobile;

  Map<String, dynamic> toJson() => {'mobile': MobileNumber.national(mobile)};
}
