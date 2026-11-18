import '../../data/base/app_base_repo.dart';
import '../../data/models/booking/booking_models.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/booking_mapper.dart';

abstract class SlotsRepo with AppBaseRepo {
  final BookingMapper bookingMapper = const BookingMapper();

  Future<ApiResponseModel<DoctorSlotsDataModel>> slots({
    required int doctorId,
    required int serviceId,
    required String date,
  });
}
