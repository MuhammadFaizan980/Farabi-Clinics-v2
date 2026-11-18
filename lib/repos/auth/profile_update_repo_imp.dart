import '../../data/models/auth/patient_data_model.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'profile_update_repo.dart';

class ProfileUpdateRepoImp extends ProfileUpdateRepo {
  @override
  Future<ApiResponseModel<PatientDataModel>> update({
    required String firstName,
    required String lastName,
    required String email,
    required String citizenIdNumber,
  }) async {
    // note: this path has no /portal segment, unlike every other endpoint
    final response = await apiClient.post(
      EndPoints.profileUpdate,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'citizen_id_number': citizenIdNumber,
      },
    );
    return response.mapData(authMapper.patient);
  }
}
