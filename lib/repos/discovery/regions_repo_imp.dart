import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'regions_repo.dart';

class RegionsRepoImp extends RegionsRepo {
  @override
  Future<ApiResponseModel<List<RegionDataModel>>> regions() async {
    final response = await apiClient.get(EndPoints.regions);
    return response.mapData(discoveryMapper.regions);
  }
}
