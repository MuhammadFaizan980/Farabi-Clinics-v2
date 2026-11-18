import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'branches_repo.dart';

class BranchesRepoImp extends BranchesRepo {
  @override
  Future<ApiResponseModel<List<BranchDataModel>>> branches({
    int? regionId,
    int? serviceId,
    int? doctorId,
    int? specialtyId,
  }) async {
    final response = await apiClient.get(
      EndPoints.branches,
      query: {
        'region_id': regionId,
        'service_id': serviceId,
        'doctor_id': doctorId,
        // american spelling, verified against the api
        'specialty_id': specialtyId,
      },
    );
    return response.mapData(discoveryMapper.branches);
  }

  @override
  Future<ApiResponseModel<BranchDataModel>> branchDetail(int id) async {
    final response = await apiClient.get(EndPoints.branchDetail(id));
    return response.mapData(discoveryMapper.branch);
  }

  @override
  Future<ApiResponseModel<List<HomeRegionBranchesDataModel>>>
      homeBranches() async {
    final response = await apiClient.get(EndPoints.homeBranches);
    return response.mapData(discoveryMapper.homeBranches);
  }
}
