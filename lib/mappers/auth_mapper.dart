import '../data/base/app_base_mapper.dart';
import '../data/models/auth/auth_response_model.dart';
import '../data/models/auth/patient_data_model.dart';

class AuthMapper extends AppBaseMapper {
  const AuthMapper();

  PatientDataModel? patient(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final id = AppBaseMapper.asInt(map['id']);
    // the website treats a profile payload without an id as "not logged in"
    if (id == null) return null;
    return PatientDataModel(
      id: id,
      patientId: AppBaseMapper.asString(map['patient_id']),
      firstName: AppBaseMapper.asString(map['first_name']),
      lastName: AppBaseMapper.asString(map['last_name']),
      email: AppBaseMapper.asString(map['email']),
      mobile: AppBaseMapper.asString(map['mobile']),
      countryCode: AppBaseMapper.asString(map['country_code']),
      citizenIdType: AppBaseMapper.asInt(map['citizen_id_type']),
      citizenIdNumber: AppBaseMapper.asString(map['citizen_id_number']),
      dateOfBirth: AppBaseMapper.asString(map['date_of_birth']),
      gender: AppBaseMapper.asString(map['gender']),
      address: AppBaseMapper.asString(map['address']),
      isPhoneVerified: AppBaseMapper.asBool(map['is_phone_verified']),
      isEmailVerified: AppBaseMapper.asBool(map['is_email_verified']),
    );
  }

  AuthResponseModel? auth(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final token = AppBaseMapper.asString(map['token']);
    if (token == null || token.isEmpty) return null;
    return AuthResponseModel(token: token, patient: patient(map['patient']));
  }

  OtpResponseModel otp(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    return OtpResponseModel(
      message: AppBaseMapper.asString(map['message']),
      otp: AppBaseMapper.asString(map['otp']),
    );
  }
}
