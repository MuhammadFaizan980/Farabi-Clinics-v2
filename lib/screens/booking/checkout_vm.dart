import 'package:flutter/widgets.dart';

import '../../app_di.dart';
import '../../data/auth_session.dart';
import '../../data/base/app_base_vm.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/constants/payment_methods.dart';
import '../../data/models/booking/booking_models.dart';
import '../../repos/booking/checkout_repo.dart';
import '../../router/app_navigator.dart';
import '../../router/app_routes.dart';
import '../../utils/launcher.dart';

/// the "Review & Pay" page: prices the booking, applies a promo code or STC
/// Qitaf points, lists the payment methods the api offers, and places the
/// booking. the booking page hands it the doctor, service, branch, date and
/// time; nothing here is computed locally except the Qitaf deduction.
class CheckoutVm extends AppBaseVm {
  CheckoutVm(this.args);

  final CheckoutArgsModel args;

  final TextEditingController couponController = TextEditingController();
  final TextEditingController qitafMobileController = TextEditingController();
  final TextEditingController qitafOtpController = TextEditingController();
  final TextEditingController qitafAmountController = TextEditingController();

  CheckoutContextDataModel? _context;
  List<PaymentGatewayDataModel> _gateways = const [];
  String? _gatewaySlug;

  String? _coupon;
  String? _couponError;
  bool _applyingCoupon = false;

  QitafStatusModel _qitaf = const QitafStatusModel();
  QitafRedemptionModel? _redemption;
  bool _qitafCodeSent = false;
  bool _qitafBusy = false;
  String? _qitafError;

  bool _paying = false;
  PendingBookingDataModel? _pending;
  String? _payError;

  Future<void> onInit() async {
    final mobile = AppDi.locator<AuthSession>().patient?.mobile;
    if (mobile != null) qitafMobileController.text = mobile;

    setBusy(true);
    clearFailure(notify: false);

    final (context, gateways, qitaf) = await (
      _loadContext(),
      repo<CheckoutRepo>().gateways(),
      repo<CheckoutRepo>().qitafStatus(),
    ).wait;

    setBusy(false);
    if (!context) return;

    if (gateways.success) {
      _gateways = gateways.data ?? const [];
      if (_gateways.isNotEmpty) _gatewaySlug = _gateways.first.slug;
    }
    if (qitaf.success && qitaf.data != null) {
      _qitaf = qitaf.data!;
      _redemption = _qitaf.redemption;
    }
    notifyListeners();
  }

  /// prices the booking, optionally with the applied coupon; a bad coupon
  /// leaves the previous pricing in place and reports on the coupon input
  Future<bool> _loadContext({String? coupon, bool isCouponTry = false}) async {
    final response = await repo<CheckoutRepo>().context(
      doctorId: args.doctor.id,
      serviceId: args.serviceId,
      branchId: args.branchId,
      date: args.date,
      time: args.time,
      couponCode: coupon ?? _coupon,
    );

    if (!response.success || response.data == null) {
      if (isCouponTry) {
        _couponError = response.fieldErrors['coupon_code']?.first ??
            response.message ??
            LocaleKeys.errors_unexpected;
      } else {
        captureFailure(response, notify: false);
      }
      return false;
    }
    _context = response.data;
    return true;
  }

  Future<void> applyCoupon() async {
    final code = couponController.text.trim();
    if (code.isEmpty || _applyingCoupon) return;

    _applyingCoupon = true;
    _couponError = null;
    notifyListeners();

    final ok = await _loadContext(coupon: code, isCouponTry: true);
    if (ok) _coupon = code;

    _applyingCoupon = false;
    notifyListeners();
  }

  Future<void> removeCoupon() async {
    _coupon = null;
    _couponError = null;
    couponController.clear();
    notifyListeners();
    await _loadContext();
    notifyListeners();
  }

  void selectGateway(String slug) {
    _gatewaySlug = slug;
    notifyListeners();
  }

  // ---- Qitaf ---------------------------------------------------------------

  Future<void> sendQitafCode() async {
    final mobile = qitafMobileController.text.trim();
    if (mobile.isEmpty || _qitafBusy) return;

    _qitafBusy = true;
    _qitafError = null;
    notifyListeners();

    final response = await repo<CheckoutRepo>().qitafSendCode(mobile);
    _qitafBusy = false;
    if (response.success) {
      _qitafCodeSent = true;
    } else {
      _qitafError = response.message ?? LocaleKeys.errors_unexpected;
    }
    notifyListeners();
  }

  /// a whole number from 1 to the bill's whole riyals, as the api requires
  Future<void> redeemQitaf() async {
    final otp = qitafOtpController.text.trim();
    final amount = int.tryParse(qitafAmountController.text.trim());
    final max = (_context?.totalValue ?? 0).floor();
    if (_qitafBusy) return;
    if (otp.isEmpty || amount == null || amount < 1 || amount > max) {
      _qitafError = LocaleKeys.checkout_qitaf_amount_invalid;
      notifyListeners();
      return;
    }

    _qitafBusy = true;
    _qitafError = null;
    notifyListeners();

    final response = await repo<CheckoutRepo>().qitafRedeem(
      mobile: qitafMobileController.text.trim(),
      otp: otp,
      amount: amount,
    );
    _qitafBusy = false;
    if (response.success && response.data != null) {
      _redemption = QitafRedemptionModel(
        id: response.data!.id,
        amount: response.data!.amount ?? amount.toDouble(),
      );
      _qitafCodeSent = false;
      qitafOtpController.clear();
    } else {
      _qitafError = response.message ?? LocaleKeys.errors_unexpected;
    }
    notifyListeners();
  }

  Future<void> removeQitaf() async {
    final redemption = _redemption;
    if (redemption == null || _qitafBusy) return;

    _qitafBusy = true;
    notifyListeners();
    final response = await repo<CheckoutRepo>().qitafRemove(redemption.id);
    _qitafBusy = false;
    if (response.success) {
      _redemption = null;
    } else {
      _qitafError = response.message ?? LocaleKeys.errors_unexpected;
    }
    notifyListeners();
  }

  // ---- pay -----------------------------------------------------------------

  /// the website's rule: a free booking is `free`, a bill fully covered by
  /// Qitaf is `cash`, otherwise the chosen method
  String get _paymentMethod {
    final total = _context?.totalValue ?? 0;
    if (total == 0) return 'free';
    if (_redeemed >= total) return 'cash';
    return PaymentMethods.forSlug(_gatewaySlug ?? 'cash');
  }

  Future<void> pay() async {
    final checkout = _context;
    if (checkout == null || _paying) return;

    _paying = true;
    _payError = null;
    notifyListeners();

    // re-check the slot right before paying, someone may have taken it
    final stillOk = await _loadContext();
    final fresh = _context;
    if (!stillOk || fresh == null || !fresh.appointment.slotAvailable) {
      _paying = false;
      _payError = _slotKey(fresh);
      notifyListeners();
      return;
    }

    final response = await repo<CheckoutRepo>().createBooking(
      CreateBookingRequestModel(
        branchId: args.branchId,
        doctorId: args.doctor.id,
        // taken verbatim from checkout-context, never computed locally
        bookingStartTime: fresh.appointment.bookingStart,
        bookingEndTime: fresh.appointment.bookingEnd,
        serviceId: args.serviceId,
        paymentMethod: _paymentMethod,
        couponCode: _coupon,
        qitafRedemptionId: _redemption?.id,
      ),
    );

    _paying = false;
    if (!response.success || response.data == null) {
      _payError = response.message ?? LocaleKeys.errors_unexpected;
      notifyListeners();
      return;
    }

    final result = response.data!;
    if (result.needsGateway) {
      // card / BNPL: the payment page opens outside the app, and the booking
      // is confirmed once the user comes back
      _pending = result.pending;
      notifyListeners();
      final url = result.pending!.redirectUrl;
      if (url != null && url.isNotEmpty) await openUrl(url);
      return;
    }

    await AppNavigator.replaceWith(
      AppRoutes.bookingSuccess,
      arguments: BookingSuccessArgsModel(booking: result.booking!),
    );
  }

  /// after the payment page: ask the api to confirm, up to five times like
  /// the website does
  Future<void> confirmPendingPayment() async {
    final pending = _pending;
    if (pending == null || _paying) return;

    _paying = true;
    _payError = null;
    notifyListeners();

    for (var attempt = 0; attempt < 5; attempt++) {
      final response = await repo<CheckoutRepo>()
          .confirmPendingBooking(pending.pendingBookingId);
      if (response.success && response.data != null) {
        _paying = false;
        await AppNavigator.replaceWith(
          AppRoutes.bookingSuccess,
          arguments: BookingSuccessArgsModel(booking: response.data!),
        );
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }

    _paying = false;
    _payError = LocaleKeys.checkout_payment_not_confirmed;
    notifyListeners();
  }

  String _slotKey(CheckoutContextDataModel? checkout) {
    switch (checkout?.appointment.unavailableReason) {
      case 'outside_schedule':
        return LocaleKeys.booking_reason_outside_schedule;
      case 'past_time':
        return LocaleKeys.booking_reason_past_time;
      default:
        return LocaleKeys.booking_slot_unavailable;
    }
  }

  @override
  void dispose() {
    couponController.dispose();
    qitafMobileController.dispose();
    qitafOtpController.dispose();
    qitafAmountController.dispose();
    super.dispose();
  }

  /// getters/setters below this line...

  CheckoutContextDataModel? get checkout => _context;
  List<PaymentGatewayDataModel> get gateways => _gateways;
  String? get gatewaySlug => _gatewaySlug;
  String? get appliedCoupon => _coupon;
  String? get couponError => _couponError;
  bool get applyingCoupon => _applyingCoupon;
  bool get qitafEnabled => _qitaf.enabled;
  QitafRedemptionModel? get redemption => _redemption;
  bool get qitafCodeSent => _qitafCodeSent;
  bool get qitafBusy => _qitafBusy;
  String? get qitafError => _qitafError;
  bool get paying => _paying;
  PendingBookingDataModel? get pending => _pending;
  String? get payError => _payError;

  double get _redeemed => _redemption?.amount ?? 0;

  /// what is left to pay after Qitaf points
  double get payable {
    final total = _context?.totalValue ?? 0;
    final left = total - _redeemed;
    return left < 0 ? 0 : left;
  }

  bool get canPay => _context != null && !_paying && _pending == null;
}
