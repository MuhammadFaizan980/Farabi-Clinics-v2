import '../../data/base/app_base_repo.dart';
import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/register_request_model.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/auth_mapper.dart';

abstract class RegisterRepo with AppBaseRepo {
  final AuthMapper authMapper = const AuthMapper();

  Future<ApiResponseModel<OtpResponseModel>> register(
    RegisterRequestModel request,
  );
}
