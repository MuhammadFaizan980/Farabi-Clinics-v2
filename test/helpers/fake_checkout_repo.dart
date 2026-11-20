import 'package:farabi_booking_app/data/models/booking/booking_models.dart';
import 'package:farabi_booking_app/data/network/api_response_model.dart';
import 'package:farabi_booking_app/repos/booking/checkout_repo.dart';

CheckoutContextDataModel fakeContext({
  bool available = true,
  String? reason,
  double total = 45,
}) =>
    CheckoutContextDataModel(
      appointment: AppointmentDataModel(
        date: '2026-11-19',
        startTime: '10:00:00',
        endTime: '10:30:00',
        slotAvailable: available,
        unavailableReason: reason,
      ),
      lines: const [],
      totalFormatted: '${total.toStringAsFixed(2)} SAR',
      totalValue: total,
    );

/// records what the checkout page sends; every call succeeds unless told not to
class FakeCheckoutRepo extends CheckoutRepo {
  FakeCheckoutRepo(this.contextResult);

  CheckoutContextDataModel contextResult;
  bool qitafOn = false;
  String? badCoupon;
  int contextCalls = 0;
  int createCalls = 0;
  CreateBookingRequestModel? lastRequest;
  String? lastCoupon;

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
    contextCalls++;
    lastCoupon = couponCode;
    if (couponCode != null && couponCode == badCoupon) {
      return const ApiResponseModel(
        success: false,
        messages: ['This coupon code is not valid.'],
        fieldErrors: {
          'coupon_code': ['This coupon code is not valid.'],
        },
      );
    }
    return ApiResponseModel(success: true, data: contextResult);
  }

  @override
  Future<ApiResponseModel<List<PaymentGatewayDataModel>>> gateways() async =>
      const ApiResponseModel(
        success: true,
        data: [
          PaymentGatewayDataModel(slug: 'cash', label: 'Cash'),
          PaymentGatewayDataModel(slug: 'paytabs', label: 'PayTabs'),
        ],
      );

  @override
  Future<ApiResponseModel<CreateBookingResultModel>> createBooking(
    CreateBookingRequestModel request,
  ) async {
    createCalls++;
    lastRequest = request;
    return ApiResponseModel(
      success: true,
      data: CreateBookingResultModel(
        booking: BookingDataModel(
          id: 1,
          bookingNumber: 'BK-00001',
          statusValue: 1,
          statusLabel: 'Created',
        ),
      ),
    );
  }

  @override
  Future<ApiResponseModel<QitafStatusModel>> qitafStatus() async =>
      ApiResponseModel(
        success: true,
        data: QitafStatusModel(enabled: qitafOn),
      );

  @override
  Future<ApiResponseModel<dynamic>> qitafSendCode(String mobile) async =>
      const ApiResponseModel(success: true, data: {});

  @override
  Future<ApiResponseModel<QitafRedemptionModel>> qitafRedeem({
    required String mobile,
    required String otp,
    required int amount,
  }) async =>
      ApiResponseModel(
        success: true,
        data: QitafRedemptionModel(id: 77, amount: amount.toDouble()),
      );

  @override
  Future<ApiResponseModel<dynamic>> qitafRemove(int redemptionId) async =>
      const ApiResponseModel(success: true, data: {});

  @override
  Future<ApiResponseModel<BookingDataModel>> confirmPendingBooking(
    int pendingBookingId, {
    String? tranRef,
  }) async =>
      const ApiResponseModel(success: false, messages: ['pending']);
}
