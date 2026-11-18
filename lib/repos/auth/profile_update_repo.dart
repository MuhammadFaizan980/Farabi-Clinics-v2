import '../../data/base/app_base_repo.dart';
import '../../data/models/auth/patient_data_model.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/auth_mapper.dart';

abstract class ProfileUpdateRepo with AppBaseRepo {
  final AuthMapper authMapper = const AuthMapper();

  Future<ApiResponseModel<PatientDataModel>> update({
    required String firstName,
    required String lastName,
    required String email,
    required String citizenIdNumber,
  });
}
