class AppConstants {
  AppConstants._();

  /// the api scopes almost every list by country; getting this wrong returns
  /// empty screens rather than an error, so it has a hard default.
  static const String defaultCountryCode = 'SA';

  /// the api reads a naked datetime as asia/riyadh local time.
  static const Duration apiTimeZoneOffset = Duration(hours: 3);

  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  static const int defaultPageSize = 20;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
