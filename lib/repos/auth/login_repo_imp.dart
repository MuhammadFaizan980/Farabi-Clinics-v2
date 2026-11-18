import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/login_request_model.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'login_repo.dart';

class LoginRepoImp extends LoginRepo {
  @override
  Future<ApiResponseModel<AuthResponseModel>> login(
    LoginRequestModel request,
  ) async {
    final response =
        await apiClient.post(EndPoints.login, body: request.toJson());
    return response.mapData(authMapper.auth);
  }
}
