import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'services_repo.dart';

class ServicesRepoImp extends ServicesRepo {
  @override
  Future<ApiResponseModel<List<ServiceDataModel>>> mainServices({
    int? regionId,
    int? branchId,
    int? doctorId,
  }) async {
    final response = await apiClient.get(
      EndPoints.mainServices,
      query: {
        'region_id': regionId,
        'branch_id': branchId,
        'doctor_id': doctorId,
      },
    );
    return response.mapData(discoveryMapper.services);
  }

  @override
  Future<ApiResponseModel<List<ServiceDataModel>>> services({
    int? regionId,
    int? branchId,
    int? doctorId,
    int? serviceId,
  }) async {
    final response = await apiClient.get(
      EndPoints.services,
      query: {
        'region_id': regionId,
        'branch_id': branchId,
        'doctor_id': doctorId,
        'service_id': serviceId,
      },
    );
    return response.mapData(discoveryMapper.services);
  }

  @override
  Future<ApiResponseModel<ServiceDataModel>> serviceDetail(int id) async {
    final response = await apiClient.get(EndPoints.serviceDetail(id));
    return response.mapData(discoveryMapper.service);
  }
}
