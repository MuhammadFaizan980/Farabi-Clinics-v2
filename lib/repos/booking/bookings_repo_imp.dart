import '../../data/models/booking/booking_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'bookings_repo.dart';

class BookingsRepoImp extends BookingsRepo {
  @override
  Future<ApiResponseModel<List<BookingDataModel>>> bookings({
    int? status,
  }) async {
    final response = await apiClient.get(
      EndPoints.bookings,
      // the api rejects a string here with a 422; it wants an integer
      query: {'status': status},
    );
    return response.mapData(bookingMapper.bookings);
  }

  @override
  Future<ApiResponseModel<BookingDataModel>> cancel(int bookingId) async {
    final response = await apiClient.post(
      EndPoints.cancelBooking(bookingId),
      body: const <String, dynamic>{},
    );
    return response.mapData(bookingMapper.booking);
  }

  @override
  Future<ApiResponseModel<BookingDataModel>> reschedule({
    required int bookingId,
    required String startTime,
    required String endTime,
  }) async {
    final response = await apiClient.post(
      EndPoints.rescheduleBooking(bookingId),
      body: {
        'booking_start_time': startTime,
        'booking_end_time': endTime,
      },
    );
    return response.mapData(bookingMapper.booking);
  }
}
