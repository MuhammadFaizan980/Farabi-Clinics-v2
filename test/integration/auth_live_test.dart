@Tags(['live'])
library;

import 'dart:io';
import 'dart:math';

import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/base/app_base_model.dart';
import 'package:farabi_booking_app/data/models/auth/login_request_model.dart';
import 'package:farabi_booking_app/data/models/auth/otp_request_model.dart';
import 'package:farabi_booking_app/data/models/auth/register_request_model.dart';
import 'package:farabi_booking_app/data/models/auth/reset_password_request_model.dart';
import 'package:farabi_booking_app/data/network/api_client.dart';
import 'package:farabi_booking_app/data/network/end_points.dart';
import 'package:farabi_booking_app/repos/auth/login_repo.dart';
import 'package:farabi_booking_app/repos/auth/login_repo_imp.dart';
import 'package:farabi_booking_app/repos/auth/otp_repo.dart';
import 'package:farabi_booking_app/repos/auth/otp_repo_imp.dart';
import 'package:farabi_booking_app/repos/auth/password_repo.dart';
import 'package:farabi_booking_app/repos/auth/password_repo_imp.dart';
import 'package:farabi_booking_app/repos/auth/profile_repo.dart';
import 'package:farabi_booking_app/repos/auth/profile_repo_imp.dart';
import 'package:farabi_booking_app/repos/auth/register_repo.dart';
import 'package:farabi_booking_app/repos/auth/register_repo_imp.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/test_credentials.dart';

/// drives the real dev api through the app's own repo layer. run with:
///   flutter test test/integration --tags live
///
/// these hit the network and write to the dev environment, so they are tagged
/// and excluded from the default suite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // the test binding installs an HttpOverrides that stubs every request with a
  // 400 and never hits the network. clearing it restores the real client, which
  // is the whole point of these tests.
  setUpAll(() {
    HttpOverrides.global = null;
  });

  // no account supplied -> skip rather than fail with a confusing 401
  if (!TestCredentials.available) {
    test('live tests skipped', () {}, skip: TestCredentials.missing);
    return;
  }

  final testMobile = TestCredentials.mobile;
  final testPassword = TestCredentials.password;

  late FakeLocalData localData;
  late AuthSession session;

  setUp(() async {
    await AppDi.reset();
    localData = FakeLocalData();
    session = AuthSession(localData);
    await session.restore();
    final client = ApiClient(
      session: session,
      baseUrl: EndPoints.baseUrlDev,
      enableLogging: false,
    );
    AppDi.locator
      ..registerSingleton<AuthSession>(session)
      ..registerSingleton<AppBaseModel>(AppBaseModel())
      ..registerSingleton<ApiClient>(client)
      ..registerSingleton<LoginRepo>(LoginRepoImp())
      ..registerSingleton<RegisterRepo>(RegisterRepoImp())
      ..registerSingleton<OtpRepo>(OtpRepoImp())
      ..registerSingleton<PasswordRepo>(PasswordRepoImp())
      ..registerSingleton<ProfileRepo>(ProfileRepoImp());
  });

  tearDown(() => AppDi.reset());

  test('login with the real test account returns a usable session', () async {
    final response = await AppDi.locator<LoginRepo>().login(
      LoginRequestModel(mobile: testMobile, password: testPassword),
    );

    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data, isNotNull);
    expect(response.data!.token, isNotEmpty);
    expect(response.data!.patient?.mobile, testMobile);
    expect(response.data!.patient?.countryCode, '+966');
  });

  test('a wrong password fails without destroying the stored session',
      () async {
    await session.setToken('pre-existing');
    final client = AppDi.locator<ApiClient>();
    var loggedOut = 0;
    client.onUnauthorised = () => loggedOut++;

    final response = await AppDi.locator<LoginRepo>().login(
      LoginRequestModel(mobile: testMobile, password: 'definitely-wrong'),
    );

    expect(response.success, isFalse);
    expect(response.message, isNotNull);
    // login is a token-issuing endpoint, so it must not trip the global logout
    expect(loggedOut, 0);
    expect(session.token, 'pre-existing');
  });

  test('profile round-trips the token — the validate-on-boot contract',
      () async {
    final login = await AppDi.locator<LoginRepo>().login(
      LoginRequestModel(mobile: testMobile, password: testPassword),
    );
    await session.setToken(login.data!.token);

    final me = await AppDi.locator<ProfileRepo>().fetchMe();

    expect(me.success, isTrue, reason: me.message ?? '');
    expect(me.data, isNotNull);
    expect(me.data!.mobile, testMobile);
    expect(me.data!.patientId, isNotNull);
  });

  test('a junk token is rejected and trips the hard-logout hook', () async {
    await session.setToken('not-a-real-token');
    var loggedOut = 0;
    AppDi.locator<ApiClient>().onUnauthorised = () => loggedOut++;

    final me = await AppDi.locator<ProfileRepo>().fetchMe();

    expect(me.success, isFalse);
    expect(me.isUnauthorised, isTrue);
    expect(loggedOut, 1);
  });

  test('register → otp confirm → reset password, end to end', () async {
    final suffix = Random().nextInt(90000000) + 10000000;
    final mobile = '05$suffix';
    final idNumber = '2${Random().nextInt(900000000) + 100000000}';
    const password = 'Test#12345';

    // 1. register
    final register = await AppDi.locator<RegisterRepo>().register(
      RegisterRequestModel(
        firstName: 'Agent',
        lastName: 'Verify',
        mobile: mobile,
        password: password,
        passwordConfirmation: password,
        citizenIdNumber: idNumber,
        citizenIdType: 5,
      ),
    );
    expect(register.success, isTrue, reason: register.message ?? '');
    final otp = register.data?.otp;
    expect(otp, isNotNull, reason: 'dev api returns the otp in the body');

    // 2. confirm the otp — this is what mints the token
    final confirm = await AppDi.locator<OtpRepo>().confirm(
      OtpConfirmRequestModel(mobile: mobile, otp: otp!),
    );
    expect(confirm.success, isTrue, reason: confirm.message ?? '');
    expect(confirm.data!.token, isNotEmpty);
    expect(confirm.data!.patient?.isPhoneVerified, isTrue);

    // 3. resend issues a fresh code
    final resend = await AppDi.locator<OtpRepo>()
        .resend(MobileOnlyRequestModel(mobile: mobile));
    expect(resend.success, isTrue, reason: resend.message ?? '');

    // 4. forgot-password issues a reset code
    final forgot = await AppDi.locator<PasswordRepo>()
        .forgotPassword(MobileOnlyRequestModel(mobile: mobile));
    expect(forgot.success, isTrue, reason: forgot.message ?? '');
    final resetOtp = forgot.data?.otp;
    expect(resetOtp, isNotNull);

    // 5. reset, then prove the new password actually works
    const newPassword = 'Reset#12345';
    final reset = await AppDi.locator<PasswordRepo>().resetPassword(
      ResetPasswordRequestModel(
        mobile: mobile,
        otp: resetOtp!,
        password: newPassword,
        passwordConfirmation: newPassword,
      ),
    );
    expect(reset.success, isTrue, reason: reset.message ?? '');

    final reLogin = await AppDi.locator<LoginRepo>().login(
      LoginRequestModel(mobile: mobile, password: newPassword),
    );
    expect(reLogin.success, isTrue, reason: reLogin.message ?? '');
    expect(reLogin.data!.token, isNotEmpty);
  });

  test('a 422 from the api lands in fieldErrors', () async {
    // mobile already registered → the api rejects it with a field error
    final register = await AppDi.locator<RegisterRepo>().register(
      RegisterRequestModel(
        firstName: 'Agent',
        lastName: 'Duplicate',
        mobile: testMobile,
        password: 'Test#12345',
        passwordConfirmation: 'Test#12345',
        citizenIdNumber: '2563356050',
        citizenIdType: 5,
      ),
    );

    expect(register.success, isFalse);
    expect(register.isValidationError, isTrue);
    expect(register.fieldErrors, isNotEmpty);
  });
}
