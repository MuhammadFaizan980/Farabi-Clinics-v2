import '../../data/base/app_base_repo.dart';
import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/otp_request_model.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/auth_mapper.dart';

abstract class OtpRepo with AppBaseRepo {
  final AuthMapper authMapper = const AuthMapper();

  Future<ApiResponseModel<AuthResponseModel>> confirm(
    OtpConfirmRequestModel request,
  );

  Future<ApiResponseModel<OtpResponseModel>> resend(
    MobileOnlyRequestModel request,
  );
}
