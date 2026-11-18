import '../discovery/discovery_models.dart';

class SlotDataModel {
  const SlotDataModel({
    required this.slot,
    required this.startTime,
    required this.endTime,
    required this.isBookable,
    this.unavailableReason,
  });

  final int slot;

  /// "09:00" — the booking payloads want "09:00:00", so pad before sending
  final String startTime;
  final String endTime;
  final bool isBookable;
  final String? unavailableReason;

  String get startTimeApi => '$startTime:00';
}

class DoctorSlotsDataModel {
  const DoctorSlotsDataModel({
    required this.date,
    required this.isOff,
    required this.slots,
  });

  final String date;

  /// a distinct state from "no slots" — the doctor simply is not working
  final bool isOff;
  final List<SlotDataModel> slots;
}

class AppointmentDataModel {
  const AppointmentDataModel({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.slotAvailable,
    this.unavailableReason,
    this.durationMinutes,
  });

  /// these two are authoritative — the booking payload copies them verbatim
  /// rather than computing an end time locally.
  final String date;
  final String startTime;
  final String endTime;
  final bool slotAvailable;
  final String? unavailableReason;
  final int? durationMinutes;

  String get bookingStart => '$date $startTime';
  String get bookingEnd => '$date $endTime';
}

class PricingLineDataModel {
  const PricingLineDataModel({
    required this.title,
    required this.slug,
    required this.formatted,
  });

  final String title;
  final String slug;
  final String formatted;
}

class CheckoutContextDataModel {
  const CheckoutContextDataModel({
    required this.appointment,
    required this.lines,
    this.doctorName,
    this.serviceName,
    this.branchName,
    this.totalFormatted,
    this.totalValue,
    this.currencySymbol,
    this.couponApplied = false,
  });

  final AppointmentDataModel appointment;
  final List<PricingLineDataModel> lines;
  final String? doctorName;
  final String? serviceName;
  final String? branchName;
  final String? totalFormatted;
  final double? totalValue;
  final String? currencySymbol;
  final bool couponApplied;

  bool get isFree => (totalValue ?? 0) == 0;
}

class PaymentGatewayDataModel {
  const PaymentGatewayDataModel({
    required this.slug,
    required this.label,
    this.logo,
  });

  final String slug;

  /// the api returns `name` as an object that already carries its own
  /// localisation, so this never goes through LocaleKeys
  final String label;
  final String? logo;
}

class BookingServiceDataModel {
  const BookingServiceDataModel({this.name, this.price, this.quantity = 1});

  final String? name;
  final double? price;
  final int quantity;
}

class BookingDataModel {
  const BookingDataModel({
    required this.id,
    required this.bookingNumber,
    required this.statusValue,
    required this.statusLabel,
    this.startTimeUtc,
    this.endTimeUtc,
    this.canCancel = false,
    this.canReschedule = false,
    this.doctorId,
    this.doctorName,
    this.branchName,
    this.serviceId,
    this.services = const [],
    this.totalFormatted,
    this.paymentStatusLabel,
  });

  final int id;

  /// BK-00128 — the reference a patient can actually quote
  final String bookingNumber;
  final int statusValue;
  final String statusLabel;

  /// every timestamp the api returns is utc
  final DateTime? startTimeUtc;
  final DateTime? endTimeUtc;
  final bool canCancel;
  final bool canReschedule;
  final int? doctorId;
  final String? doctorName;
  final String? branchName;
  final int? serviceId;
  final List<BookingServiceDataModel> services;
  final String? totalFormatted;
  final String? paymentStatusLabel;

  DateTime? get startLocal => startTimeUtc?.toLocal();
}

/// returned instead of a booking when the chosen gateway needs a redirect.
class PendingBookingDataModel {
  const PendingBookingDataModel({
    required this.pendingBookingId,
    this.redirectUrl,
    this.checkoutReference,
    this.amount,
    this.currency,
    this.expiresAt,
  });

  final int pendingBookingId;
  final String? redirectUrl;
  final String? checkoutReference;
  final String? amount;
  final String? currency;
  final DateTime? expiresAt;
}

/// a create-booking call comes back as one or the other, never both.
class CreateBookingResultModel {
  const CreateBookingResultModel({this.booking, this.pending});

  final BookingDataModel? booking;
  final PendingBookingDataModel? pending;

  bool get needsGateway => pending != null;
}

class CreateBookingRequestModel {
  const CreateBookingRequestModel({
    required this.branchId,
    required this.doctorId,
    required this.bookingStartTime,
    required this.bookingEndTime,
    required this.serviceId,
    required this.paymentMethod,
    this.quantity = 1,
    this.couponCode,
  });

  final int branchId;
  final int doctorId;

  /// "YYYY-MM-DD HH:MM:SS" — read by the api as Asia/Riyadh local
  final String bookingStartTime;
  final String bookingEndTime;
  final int serviceId;
  final String paymentMethod;
  final int quantity;
  final String? couponCode;

  Map<String, dynamic> toJson() => {
        'branch_id': branchId,
        'doctor_id': doctorId,
        'booking_start_time': bookingStartTime,
        'booking_end_time': bookingEndTime,
        'items': [
          {'service_id': serviceId, 'quantity': quantity}
        ],
        'payment_method': paymentMethod,
        // omitted entirely when unused, never sent as null
        if (couponCode != null && couponCode!.isNotEmpty)
          'coupon_code': couponCode,
      };
}

class BookingArgsModel {
  const BookingArgsModel({required this.doctor});

  final DoctorDataModel doctor;
}

class BookingSuccessArgsModel {
  const BookingSuccessArgsModel({required this.booking});

  final BookingDataModel booking;
}

class RescheduleArgsModel {
  const RescheduleArgsModel({required this.booking});

  final BookingDataModel booking;
}
