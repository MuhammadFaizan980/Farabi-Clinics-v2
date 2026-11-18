import '../../data/base/app_base_repo.dart';
import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/login_request_model.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/auth_mapper.dart';

abstract class LoginRepo with AppBaseRepo {
  /// a repo owns its mappers
  final AuthMapper authMapper = const AuthMapper();

  Future<ApiResponseModel<AuthResponseModel>> login(LoginRequestModel request);
}
