import '../../data/base/app_base_repo.dart';
import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/otp_request_model.dart';
import '../../data/models/auth/reset_password_request_model.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/auth_mapper.dart';

abstract class PasswordRepo with AppBaseRepo {
  final AuthMapper authMapper = const AuthMapper();

  Future<ApiResponseModel<OtpResponseModel>> forgotPassword(
    MobileOnlyRequestModel request,
  );

  Future<ApiResponseModel<OtpResponseModel>> resetPassword(
    ResetPasswordRequestModel request,
  );
}
