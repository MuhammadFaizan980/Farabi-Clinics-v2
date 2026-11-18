import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/otp_request_model.dart';
import '../../data/models/auth/reset_password_request_model.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'password_repo.dart';

class PasswordRepoImp extends PasswordRepo {
  @override
  Future<ApiResponseModel<OtpResponseModel>> forgotPassword(
    MobileOnlyRequestModel request,
  ) async {
    final response =
        await apiClient.post(EndPoints.forgotPassword, body: request.toJson());
    return response.mapData(authMapper.otp);
  }

  @override
  Future<ApiResponseModel<OtpResponseModel>> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    final response =
        await apiClient.post(EndPoints.resetPassword, body: request.toJson());
    return response.mapData(authMapper.otp);
  }
}
