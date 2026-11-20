import '../../data/base/app_base_repo.dart';
import '../../data/models/booking/booking_models.dart';
import '../../data/network/api_response_model.dart';
import '../../mappers/booking_mapper.dart';

abstract class CheckoutRepo with AppBaseRepo {
  final BookingMapper bookingMapper = const BookingMapper();

  /// prices the booking and re-checks the slot in one call
  Future<ApiResponseModel<CheckoutContextDataModel>> context({
    required int doctorId,
    required int serviceId,
    required int branchId,
    required String date,
    required String time,
    int quantity = 1,
    String? couponCode,
  });

  Future<ApiResponseModel<List<PaymentGatewayDataModel>>> gateways();

  Future<ApiResponseModel<CreateBookingResultModel>> createBooking(
    CreateBookingRequestModel request,
  );

  /// STC Qitaf points: status, send code, redeem, undo
  Future<ApiResponseModel<QitafStatusModel>> qitafStatus();

  Future<ApiResponseModel<dynamic>> qitafSendCode(String mobile);

  Future<ApiResponseModel<QitafRedemptionModel>> qitafRedeem({
    required String mobile,
    required String otp,
    required int amount,
  });

  Future<ApiResponseModel<dynamic>> qitafRemove(int redemptionId);

  /// confirms a gateway booking after the payment page; `tranRef` is omitted
  /// when the gateway returned none
  Future<ApiResponseModel<BookingDataModel>> confirmPendingBooking(
    int pendingBookingId, {
    String? tranRef,
  });
}
