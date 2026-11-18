/// the only place in the app that knows an endpoint string. nothing outside
/// this class may contain a url literal.
class EndPoints {
  EndPoints._();

  static const String baseUrlDev = 'https://erpapi-test.doctorstation.com/api/';

  /// the website injects this at deploy time from NEXT_PUBLIC_API_BASE_URL and
  /// it is not present in any shipped bundle, so it is still unknown. the dev
  /// host is used until the real value is supplied.
  static const String baseUrlProd = baseUrlDev;

  // ---- auth ----
  static const String login = 'v1/portal/auth/login';
  static const String register = 'v1/portal/auth/register';
  static const String otpConfirm = 'v1/portal/auth/otp/confirm';
  static const String otpResend = 'v1/portal/auth/otp/resend';
  static const String forgotPassword = 'v1/portal/auth/forgot-password';
  static const String resetPassword = 'v1/portal/auth/reset-password';

  /// endpoints that issue or revoke a token. a 401 from one of these is a
  /// credential problem, not an expired session, so it must never trigger the
  /// global logout.
  static const Set<String> authPaths = {
    login,
    register,
    otpConfirm,
    otpResend,
    forgotPassword,
    resetPassword,
  };

  // ---- profile ----
  static const String profile = 'v1/portal/profile';

  /// note: no `/portal` segment on this one. verified against the live api.
  static const String profileUpdate = 'v1/profile/update';

  // ---- geography / taxonomy ----
  static const String countries = 'v1/portal/countries';
  static const String regions = 'v1/portal/regions';
  static const String mainServices = 'v1/portal/services/main';
  static const String services = 'v1/portal/services';
  static String serviceDetail(int id) => 'v1/portal/services/$id';

  // ---- branches ----
  static const String branches = 'v1/portal/branches';
  static String branchDetail(int id) => 'v1/portal/branches/$id';
  static const String homeBranches = 'v1/portal/home/branches';

  // ---- doctors ----
  static const String doctors = 'v1/portal/doctors';
  static String doctorDetail(int id) => 'v1/portal/doctors/$id';
  static String doctorSlots(int id) => 'v1/portal/doctors/$id/slots';

  // ---- booking ----
  static const String checkoutContext = 'v1/portal/checkout-context';
  static const String bookings = 'v1/portal/bookings';
  static String cancelBooking(int id) => 'v1/portal/bookings/$id/cancel';
  static String rescheduleBooking(int id) => 'v1/portal/bookings/$id/reschedule';
  static String confirmPendingBooking(int id) =>
      'v1/portal/pending-bookings/$id/confirm';
  static const String paymentGateways = 'v1/portal/payment-gateways';

  // ---- qitaf loyalty ----
  static const String qitaf = 'v1/portal/qitaf';
  static const String qitafOtp = 'v1/portal/qitaf/otp';
  static const String qitafRedemptions = 'v1/portal/qitaf/redemptions';
  static String qitafRedemptionDelete(int id) =>
      'v1/portal/qitaf/redemptions/$id';

  // ---- content / support ----
  static const String offers = 'v1/portal/offers';
  static const String blog = 'v1/portal/blog';
  static String blogComments(int id) => 'v1/portal/blog/$id/comments';
  static const String contactUs = 'v1/portal/contact-us';
  static const String careers = 'v1/portal/careers';
  static const String careerDepartments = 'v1/portal/careers/departments';
  static String careerApply(int id) => 'v1/portal/careers/$id/applications';
}
