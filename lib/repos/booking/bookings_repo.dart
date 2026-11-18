import '../../data/base/app_base_repo.dart';
import '../../data/models/booking/booking_models.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/booking_mapper.dart';

abstract class BookingsRepo with AppBaseRepo {
  final BookingMapper bookingMapper = const BookingMapper();

  /// [status] is an integer 1-6. omitting it returns everything.
  Future<ApiResponseModel<List<BookingDataModel>>> bookings({int? status});

  Future<ApiResponseModel<BookingDataModel>> cancel(int bookingId);

  Future<ApiResponseModel<BookingDataModel>> reschedule({
    required int bookingId,
    required String startTime,
    required String endTime,
  });
}
