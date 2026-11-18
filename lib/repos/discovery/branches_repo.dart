import '../../data/base/app_base_repo.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/discovery_mapper.dart';

abstract class BranchesRepo with AppBaseRepo {
  final DiscoveryMapper discoveryMapper = const DiscoveryMapper();

  Future<ApiResponseModel<List<BranchDataModel>>> branches({
    int? regionId,
    int? serviceId,
    int? doctorId,
    int? specialtyId,
  });

  Future<ApiResponseModel<BranchDataModel>> branchDetail(int id);

  /// regions with their branches nested, for the home screen
  Future<ApiResponseModel<List<HomeRegionBranchesDataModel>>> homeBranches();
}
