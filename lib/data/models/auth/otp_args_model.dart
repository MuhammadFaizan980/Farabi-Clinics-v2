/// route arguments are always typed, never raw maps.
enum OtpPurpose { registration, passwordReset }

class OtpArgsModel {
  const OtpArgsModel({
    required this.mobile,
    required this.purpose,
    this.prefilledOtp,
  });

  final String mobile;
  final OtpPurpose purpose;

  /// the dev api returns the otp in the register/forgot response. carried here
  /// purely so testing on dev does not need a real sms.
  final String? prefilledOtp;
}

class ResetPasswordArgsModel {
  const ResetPasswordArgsModel({required this.mobile, required this.otp});

  final String mobile;
  final String otp;
}
