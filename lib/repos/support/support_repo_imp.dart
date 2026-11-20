import 'package:dio/dio.dart';

import '../../data/models/support/support_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'support_repo.dart';

class SupportRepoImp extends SupportRepo {
  @override
  Future<ApiResponseModel<List<JobDataModel>>> jobs({
    int? page,
    String? department,
    String? search,
  }) async {
    final response = await apiClient.get(
      EndPoints.careers,
      query: {
        'page': page ?? 1,
        'per_page': 50,
        'department': (department ?? '').isEmpty ? null : department,
        'search': (search ?? '').isEmpty ? null : search,
      },
    );
    return response.mapData(supportMapper.jobs);
  }

  @override
  Future<ApiResponseModel<JobDetailDataModel>> jobDetail(String slug) async {
    final response = await apiClient.get(EndPoints.careerDetail(slug));
    return response.mapData(supportMapper.jobDetail);
  }

  @override
  Future<ApiResponseModel<dynamic>> applyToJob(
    String slug,
    JobApplicationModel application,
  ) {
    final fields = application.toFields();
    final path = application.cvPath;
    if (path != null) {
      // the cv travels as the multipart part named `file`
      fields['file'] = MultipartFile.fromFileSync(
        path,
        filename: application.cvName,
      );
    }
    return apiClient.postForm(EndPoints.careerApply(slug), fields: fields);
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
  Future<ApiResponseModel<List<OfferDataModel>>> offers({int? page}) async {
    final response =
        await apiClient.get(EndPoints.offers, query: {'page': page});
    return response.mapData(supportMapper.offers);
  }

  @override
  Future<ApiResponseModel<dynamic>> submitContact(
    ContactRequestModel request,
  ) =>
      // multipart, not json
      apiClient.postForm(EndPoints.contactUs, fields: request.toFields());
}
