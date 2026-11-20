import '../../data/base/app_base_repo.dart';
import '../../data/models/discovery/discovery_models.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/discovery_mapper.dart';

abstract class CountriesRepo with AppBaseRepo {
  final DiscoveryMapper discoveryMapper = const DiscoveryMapper();

  /// the countries offered by the phone fields on sign in, register and
  /// forgot password
  Future<ApiResponseModel<List<CountryDataModel>>> countries();
}
