import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'doctors_repo.dart';

class DoctorsRepoImp extends DoctorsRepo {
  @override
  Future<ApiResponseModel<PagedResult<DoctorDataModel>>> doctors({
    int? page,
    int? regionId,
    int? branchId,
    int? serviceId,
    int? specialtyId,
    String? search,
    String? gender,
    List<int> ratings = const [],
  }) async {
    final response = await apiClient.get(
      EndPoints.doctors,
      query: {
        'page': page,
        'region_id': regionId,
        'branch_id': branchId,
        'service_id': serviceId,
        'specialty_id': specialtyId,
        'search': (search ?? '').isEmpty ? null : search,
        'gender': gender,
        // the api takes a comma-joined list here
        'ratings': ratings.isEmpty ? null : ratings.join(','),
      },
    );

    return ApiResponseModel<PagedResult<DoctorDataModel>>(
      success: response.success,
      data: response.success
          ? PagedResult<DoctorDataModel>(
              items: discoveryMapper.doctors(response.data),
              total: discoveryMapper.totalFromMeta(response.meta),
            )
          : null,
      messages: response.messages,
      fieldErrors: response.fieldErrors,
      statusCode: response.statusCode,
      meta: response.meta,
    );
  }

  @override
  Future<ApiResponseModel<DoctorDataModel>> doctorDetail(int id) async {
    final response = await apiClient.get(EndPoints.doctorDetail(id));
    return response.mapData(discoveryMapper.doctor);
  }
}
