import 'dart:io';

/// the live tests need a real patient account. it comes from the environment
/// so no credential is ever committed:
///
///   FARABI_TEST_MOBILE=05XXXXXXXX FARABI_TEST_PASSWORD=... \
///     flutter test --tags live --run-skipped
class TestCredentials {
  TestCredentials._();

  static String get mobile => Platform.environment['FARABI_TEST_MOBILE'] ?? '';

  static String get password =>
      Platform.environment['FARABI_TEST_PASSWORD'] ?? '';

  static bool get available => mobile.isNotEmpty && password.isNotEmpty;

  static const String missing =
      'set FARABI_TEST_MOBILE and FARABI_TEST_PASSWORD to run the live tests';
}
