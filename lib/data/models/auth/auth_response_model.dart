import 'patient_data_model.dart';

/// login and otp/confirm both return this.
class AuthResponseModel {
  const AuthResponseModel({required this.token, this.patient});

  final String token;
  final PatientDataModel? patient;
}

/// register, otp/resend and forgot-password all return this. the dev api
/// includes the otp in the body; production is not guaranteed to, so [otp] is
/// nullable and is never logged.
class OtpResponseModel {
  const OtpResponseModel({this.message, this.otp});

  final String? message;
  final String? otp;
}
