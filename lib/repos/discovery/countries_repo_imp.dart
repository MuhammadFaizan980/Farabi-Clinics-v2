import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'countries_repo.dart';

class CountriesRepoImp extends CountriesRepo {
  @override
  Future<ApiResponseModel<List<CountryDataModel>>> countries() async {
    final response = await apiClient.get(EndPoints.countries);
    return response.mapData(discoveryMapper.countries);
  }
}
