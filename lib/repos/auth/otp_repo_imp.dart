import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/otp_request_model.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'otp_repo.dart';

class OtpRepoImp extends OtpRepo {
  @override
  Future<ApiResponseModel<AuthResponseModel>> confirm(
    OtpConfirmRequestModel request,
  ) async {
    final response =
        await apiClient.post(EndPoints.otpConfirm, body: request.toJson());
    return response.mapData(authMapper.auth);
  }

  @override
  Future<ApiResponseModel<OtpResponseModel>> resend(
    MobileOnlyRequestModel request,
  ) async {
    final response =
        await apiClient.post(EndPoints.otpResend, body: request.toJson());
    return response.mapData(authMapper.otp);
  }
}
