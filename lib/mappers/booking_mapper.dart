import '../data/base/app_base_mapper.dart';
import '../data/models/booking/booking_models.dart';

class BookingMapper extends AppBaseMapper {
  const BookingMapper();

  DoctorSlotsDataModel slots(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final doctors = AppBaseMapper.asList(map['doctors']);
    // single-doctor response wrapped in an array; an empty array just means
    // no slots, not an error
    final first = doctors.isEmpty ? const <String, dynamic>{} : doctors.first;
    return DoctorSlotsDataModel(
      date: AppBaseMapper.asString(map['date']) ?? '',
      isOff: AppBaseMapper.asBool(first['is_off']),
      slots: AppBaseMapper.asList(first['slots']).map((slot) {
        return SlotDataModel(
          slot: AppBaseMapper.asInt(slot['slot']) ?? 0,
          startTime: AppBaseMapper.asString(slot['start_time']) ?? '',
          endTime: AppBaseMapper.asString(slot['end_time']) ?? '',
          isBookable: AppBaseMapper.asBool(slot['is_bookable']),
          unavailableReason:
              AppBaseMapper.asString(slot['unavailable_reason']),
        );
      }).toList(growable: false),
    );
  }

  CheckoutContextDataModel? checkoutContext(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final appointmentMap = AppBaseMapper.asMap(map['appointment']);
    if (appointmentMap.isEmpty) return null;

    final pricing = AppBaseMapper.asMap(map['pricing']);
    final total = AppBaseMapper.asMap(map['total']);

    return CheckoutContextDataModel(
      appointment: AppointmentDataModel(
        date: AppBaseMapper.asString(appointmentMap['date']) ?? '',
        startTime: AppBaseMapper.asString(appointmentMap['start_time']) ?? '',
        endTime: AppBaseMapper.asString(appointmentMap['end_time']) ?? '',
        slotAvailable: AppBaseMapper.asBool(
          appointmentMap['slot_available'],
          fallback: true,
        ),
        unavailableReason:
            AppBaseMapper.asString(appointmentMap['unavailable_reason']),
        durationMinutes:
            AppBaseMapper.asInt(appointmentMap['duration_minutes']),
      ),
      lines: AppBaseMapper.asList(map['checkout_total']).map((line) {
        final value = AppBaseMapper.asMap(line['value']);
        return PricingLineDataModel(
          title: AppBaseMapper.asString(line['title']) ?? '',
          slug: AppBaseMapper.asString(line['slug']) ?? '',
          formatted: AppBaseMapper.asString(value['formatted']) ?? '',
        );
      }).toList(growable: false),
      doctorName:
          AppBaseMapper.asString(AppBaseMapper.asMap(map['doctor'])['name']),
      serviceName:
          AppBaseMapper.asString(AppBaseMapper.asMap(map['service'])['name']),
      branchName:
          AppBaseMapper.asString(AppBaseMapper.asMap(map['branch'])['name']),
      totalFormatted: AppBaseMapper.asString(total['formatted']),
      totalValue: AppBaseMapper.asDouble(total['value']),
      currencySymbol: AppBaseMapper.asString(pricing['currency_symbol']),
      couponApplied: AppBaseMapper.asBool(map['is_coupon']),
    );
  }

  /// the qitaf payloads are only contract-verified, so every field is read
  /// defensively
  QitafRedemptionModel? qitafRedemption(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final id = AppBaseMapper.asInt(map['id']);
    if (id == null) return null;
    return QitafRedemptionModel(
      id: id,
      amount: AppBaseMapper.asDouble(map['amount']),
    );
  }

  QitafStatusModel qitafStatus(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    return QitafStatusModel(
      enabled: AppBaseMapper.asBool(map['enabled']),
      redemption: qitafRedemption(map['redemption']),
    );
  }

  List<PaymentGatewayDataModel> gateways(dynamic raw) =>
      AppBaseMapper.asList(raw).map((map) {
        final name = AppBaseMapper.asMap(map['name']);
        return PaymentGatewayDataModel(
          slug: AppBaseMapper.asString(map['slug']) ?? '',
          // `name` is an object carrying its own localisation
          label: AppBaseMapper.asString(name['label']) ??
              AppBaseMapper.asString(map['slug']) ??
              '',
          logo: AppBaseMapper.asString(map['logo']),
        );
      }).toList(growable: false);

  BookingDataModel? booking(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final id = AppBaseMapper.asInt(map['id']);
    if (id == null) return null;

    final status = AppBaseMapper.asMap(map['status']);
    final services = AppBaseMapper.asList(map['services']);
    final invoices = AppBaseMapper.asList(map['invoices']);
    final payment = AppBaseMapper.asMap(map['payment']);

    return BookingDataModel(
      id: id,
      bookingNumber: AppBaseMapper.asString(map['booking_number']) ?? '$id',
      statusValue: AppBaseMapper.asInt(status['value']) ?? 0,
      statusLabel: AppBaseMapper.asString(status['label']) ?? '',
      startTimeUtc: AppBaseMapper.asUtcDateTime(map['booking_start_time']),
      endTimeUtc: AppBaseMapper.asUtcDateTime(map['booking_end_time']),
      canCancel: AppBaseMapper.asBool(map['can_cancel']),
      canReschedule: AppBaseMapper.asBool(map['can_reschedule']),
      doctorId:
          AppBaseMapper.asInt(AppBaseMapper.asMap(map['doctor'])['id']),
      doctorName:
          AppBaseMapper.asString(AppBaseMapper.asMap(map['doctor'])['name']),
      branchName:
          AppBaseMapper.asString(AppBaseMapper.asMap(map['branch'])['name']),
      serviceId: services.isEmpty
          ? null
          : AppBaseMapper.asInt(
              AppBaseMapper.asMap(services.first['service'])['id']),
      services: services.map((item) {
        final service = AppBaseMapper.asMap(item['service']);
        return BookingServiceDataModel(
          name: AppBaseMapper.asString(service['name']),
          price: AppBaseMapper.asDouble(item['price']),
          quantity: AppBaseMapper.asInt(item['quantity']) ?? 1,
        );
      }).toList(growable: false),
      totalFormatted: invoices.isEmpty
          ? null
          : AppBaseMapper.asString(invoices.first['total']),
      paymentStatusLabel: AppBaseMapper.asString(
          AppBaseMapper.asMap(payment['status'])['label']),
    );
  }

  List<BookingDataModel> bookings(dynamic raw) => AppBaseMapper.asList(raw)
      .map(booking)
      .whereType<BookingDataModel>()
      .toList(growable: false);

  /// the confirm call answers `{ status: {key}, booking: {...} }`; only a
  /// `completed` status with a booking counts as confirmed
  BookingDataModel? confirmedBooking(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    final status = AppBaseMapper.asString(
        AppBaseMapper.asMap(map['status'])['key']);
    if (status != 'completed') return null;
    return booking(map['booking']);
  }

  /// create-booking returns either a full booking or a pending gateway stub.
  /// the pending shape has no `id`, so that is what we branch on.
  CreateBookingResultModel? createResult(dynamic raw) {
    final map = AppBaseMapper.asMap(raw);
    if (map.isEmpty) return null;

    final pendingId = AppBaseMapper.asInt(map['pending_booking_id']);
    if (pendingId != null) {
      return CreateBookingResultModel(
        pending: PendingBookingDataModel(
          pendingBookingId: pendingId,
          redirectUrl: AppBaseMapper.asString(map['redirect_url']),
          checkoutReference: AppBaseMapper.asString(map['checkout_reference']),
          amount: AppBaseMapper.asString(map['amount']),
          currency: AppBaseMapper.asString(map['currency']),
          expiresAt: AppBaseMapper.asUtcDateTime(map['expires_at']),
        ),
      );
    }

    final result = booking(map);
    return result == null ? null : CreateBookingResultModel(booking: result);
  }
}
