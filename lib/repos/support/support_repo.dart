import '../../data/base/app_base_repo.dart';
import '../../data/models/support/support_models.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/support_mapper.dart';

abstract class SupportRepo with AppBaseRepo {
  final SupportMapper supportMapper = const SupportMapper();

  Future<ApiResponseModel<List<JobDataModel>>> jobs({int? page});

  Future<ApiResponseModel<List<String>>> departments();

  Future<ApiResponseModel<List<BlogPostDataModel>>> posts({int? page});

  Future<ApiResponseModel<dynamic>> submitContact(ContactRequestModel request);
}
