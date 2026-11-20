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

  @override
  Future<ApiResponseModel<QitafStatusModel>> qitafStatus() async {
    final response = await apiClient.get(EndPoints.qitaf);
    return response.mapData(bookingMapper.qitafStatus);
  }

  @override
  Future<ApiResponseModel<dynamic>> qitafSendCode(String mobile) =>
      apiClient.post(EndPoints.qitafOtp, body: {'mobile': mobile});

  @override
  Future<ApiResponseModel<QitafRedemptionModel>> qitafRedeem({
    required String mobile,
    required String otp,
    required int amount,
  }) async {
    final response = await apiClient.post(
      EndPoints.qitafRedemptions,
      body: {'mobile': mobile, 'otp': otp, 'amount': amount},
    );
    return response.mapData(bookingMapper.qitafRedemption);
  }

  @override
  Future<ApiResponseModel<dynamic>> qitafRemove(int redemptionId) =>
      apiClient.delete(EndPoints.qitafRedemptionDelete(redemptionId), body: {});

  @override
  Future<ApiResponseModel<BookingDataModel>> confirmPendingBooking(
    int pendingBookingId, {
    String? tranRef,
  }) async {
    final response = await apiClient.post(
      EndPoints.confirmPendingBooking(pendingBookingId),
      body: {if (tranRef != null && tranRef.isNotEmpty) 'tran_ref': tranRef},
    );
    return response.mapData(bookingMapper.confirmedBooking);
  }
}
