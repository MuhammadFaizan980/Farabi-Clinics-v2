import '../../data/base/app_base_repo.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/discovery_mapper.dart';

abstract class ServicesRepo with AppBaseRepo {
  final DiscoveryMapper discoveryMapper = const DiscoveryMapper();

  /// top-level specialities
  Future<ApiResponseModel<List<ServiceDataModel>>> mainServices({
    int? regionId,
    int? branchId,
    int? doctorId,
  });

  /// bookable services / sub-services
  Future<ApiResponseModel<List<ServiceDataModel>>> services({
    int? regionId,
    int? branchId,
    int? doctorId,
    int? serviceId,
  });

  Future<ApiResponseModel<ServiceDataModel>> serviceDetail(int id);
}
