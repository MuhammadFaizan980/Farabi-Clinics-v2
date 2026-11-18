import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/register_request_model.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'register_repo.dart';

class RegisterRepoImp extends RegisterRepo {
  @override
  Future<ApiResponseModel<OtpResponseModel>> register(
    RegisterRequestModel request,
  ) async {
    final response =
        await apiClient.post(EndPoints.register, body: request.toJson());
    return response.mapData(authMapper.otp);
  }
}
