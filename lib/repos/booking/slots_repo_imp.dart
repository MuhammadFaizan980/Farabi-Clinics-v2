import '../../data/models/booking/booking_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'slots_repo.dart';

class SlotsRepoImp extends SlotsRepo {
  @override
  Future<ApiResponseModel<DoctorSlotsDataModel>> slots({
    required int doctorId,
    required int serviceId,
    required String date,
  }) async {
    final response = await apiClient.get(
      EndPoints.doctorSlots(doctorId),
      query: {'date': date, 'service_id': serviceId},
    );
    return response.mapData(bookingMapper.slots);
  }
}
