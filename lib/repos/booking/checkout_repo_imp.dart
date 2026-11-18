import '../../data/models/booking/booking_models.dart';
import '../../data/network/api_response_model.dart';
import '../../data/network/end_points.dart';
import 'checkout_repo.dart';

class CheckoutRepoImp extends CheckoutRepo {
  @override
  Future<ApiResponseModel<CheckoutContextDataModel>> context({
    required int doctorId,
    required int serviceId,
    required int branchId,
    required String date,
    required String time,
    int quantity = 1,
    String? couponCode,
  }) async {
    final response = await apiClient.get(
      EndPoints.checkoutContext,
      query: {
        'doctor_id': doctorId,
        'service_id': serviceId,
        'branch_id': branchId,
        'date': date,
        'time': time,
        'quantity': quantity,
        'coupon_code': (couponCode ?? '').isEmpty ? null : couponCode,
      },
    );
    return response.mapData(bookingMapper.checkoutContext);
  }

  @override
  Future<ApiResponseModel<List<PaymentGatewayDataModel>>> gateways() async {
    final response = await apiClient.get(EndPoints.paymentGateways);
    return response.mapData(bookingMapper.gateways);
  }

  @override
  Future<ApiResponseModel<CreateBookingResultModel>> createBooking(
    CreateBookingRequestModel request,
  ) async {
    final response =
        await apiClient.post(EndPoints.bookings, body: request.toJson());
    return response.mapData(bookingMapper.createResult);
  }
}
