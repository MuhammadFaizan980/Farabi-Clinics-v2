import '../../data/base/app_base_repo.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/discovery_mapper.dart';

abstract class DoctorsRepo with AppBaseRepo {
  final DiscoveryMapper discoveryMapper = const DiscoveryMapper();

  Future<ApiResponseModel<PagedResult<DoctorDataModel>>> doctors({
    int? page,
    int? regionId,
    int? branchId,
    int? serviceId,
    int? specialtyId,
    String? search,
    String? gender,
    List<int> ratings = const [],
  });

  Future<ApiResponseModel<DoctorDataModel>> doctorDetail(int id);
}
