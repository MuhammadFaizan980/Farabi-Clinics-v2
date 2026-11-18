import '../../data/models/support/support_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'support_repo.dart';

class SupportRepoImp extends SupportRepo {
  @override
  Future<ApiResponseModel<List<JobDataModel>>> jobs({int? page}) async {
    final response =
        await apiClient.get(EndPoints.careers, query: {'page': page});
    return response.mapData(supportMapper.jobs);
  }

  @override
  Future<ApiResponseModel<List<String>>> departments() async {
    final response = await apiClient.get(EndPoints.careerDepartments);
    return response.mapData(supportMapper.departments);
  }

  @override
  Future<ApiResponseModel<List<BlogPostDataModel>>> posts({int? page}) async {
    final response =
        await apiClient.get(EndPoints.blog, query: {'page': page});
    return response.mapData(supportMapper.posts);
  }

  @override
  Future<ApiResponseModel<dynamic>> submitContact(
    ContactRequestModel request,
  ) =>
      // multipart, not json
      apiClient.postForm(EndPoints.contactUs, fields: request.toFields());
}
