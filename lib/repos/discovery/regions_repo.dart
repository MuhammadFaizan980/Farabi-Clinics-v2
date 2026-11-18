import '../../data/base/app_base_repo.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/discovery_mapper.dart';

abstract class RegionsRepo with AppBaseRepo {
  final DiscoveryMapper discoveryMapper = const DiscoveryMapper();

  Future<ApiResponseModel<List<RegionDataModel>>> regions();
}
