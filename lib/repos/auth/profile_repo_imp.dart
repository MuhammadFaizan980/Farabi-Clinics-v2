import '../../data/models/auth/patient_data_model.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'profile_repo.dart';

class ProfileRepoImp extends ProfileRepo {
  @override
  Future<ApiResponseModel<PatientDataModel>> fetchMe() async {
    final response = await apiClient.get(EndPoints.profile);
    return response.mapData(authMapper.patient);
  }
}
