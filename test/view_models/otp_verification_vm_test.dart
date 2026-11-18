import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/base/app_base_model.dart';
import 'package:farabi_booking_app/data/constants/locale_keys.g.dart';
import 'package:farabi_booking_app/data/models/auth/auth_response_model.dart';
import 'package:farabi_booking_app/data/models/auth/otp_args_model.dart';
import 'package:farabi_booking_app/data/models/auth/otp_request_model.dart';
import 'package:farabi_booking_app/data/models/auth/patient_data_model.dart';
import 'package:farabi_booking_app/data/network/api_response_model.dart';
import 'package:farabi_booking_app/repos/auth/otp_repo.dart';
import 'package:farabi_booking_app/repos/auth/password_repo.dart';
import 'package:farabi_booking_app/data/models/auth/reset_password_request_model.dart';
import 'package:farabi_booking_app/screens/auth/otp_verification_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

class _FakeOtpRepo extends OtpRepo {
  _FakeOtpRepo({required this.confirmResponse, required this.resendResponse});

  ApiResponseModel<AuthResponseModel> confirmResponse;
  ApiResponseModel<OtpResponseModel> resendResponse;
  int confirmCalls = 0;
  int resendCalls = 0;

  @override
  Future<ApiResponseModel<AuthResponseModel>> confirm(
    OtpConfirmRequestModel request,
  ) async {
    confirmCalls++;
    return confirmResponse;
  }

  @override
  Future<ApiResponseModel<OtpResponseModel>> resend(
    MobileOnlyRequestModel request,
  ) async {
    resendCalls++;
    return resendResponse;
  }
}

class _FakePasswordRepo extends PasswordRepo {
  int forgotCalls = 0;

  @override
  Future<ApiResponseModel<OtpResponseModel>> forgotPassword(
    MobileOnlyRequestModel request,
  ) async {
    forgotCalls++;
    return const ApiResponseModel<OtpResponseModel>(
      success: true,
      data: OtpResponseModel(otp: '111111'),
    );
  }

  @override
  Future<ApiResponseModel<OtpResponseModel>> resetPassword(
    ResetPasswordRequestModel request,
  ) async =>
      const ApiResponseModel<OtpResponseModel>(success: true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthSession session;
  late _FakeOtpRepo otpRepo;
  late _FakePasswordRepo passwordRepo;

  Future<void> boot({
    ApiResponseModel<AuthResponseModel>? confirm,
  }) async {
    await AppDi.reset();
    session = AuthSession(FakeLocalData());
    await session.restore();
    otpRepo = _FakeOtpRepo(
      confirmResponse: confirm ??
          const ApiResponseModel<AuthResponseModel>(
            success: true,
            data: AuthResponseModel(
              token: 'tok-otp',
              patient: PatientDataModel(id: 18),
            ),
          ),
      resendResponse: const ApiResponseModel<OtpResponseModel>(
        success: true,
        data: OtpResponseModel(otp: '294712'),
      ),
    );
    passwordRepo = _FakePasswordRepo();
    AppDi.locator
      ..registerSingleton<AuthSession>(session)
      ..registerSingleton<AppBaseModel>(AppBaseModel())
      ..registerSingleton<OtpRepo>(otpRepo)
      ..registerSingleton<PasswordRepo>(passwordRepo);
  }

  tearDown(() => AppDi.reset());

  const registrationArgs = OtpArgsModel(
    mobile: '0552207570',
    purpose: OtpPurpose.registration,
  );

  test('prefills the otp the dev api handed back', () async {
    await boot();
    final vm = OtpVerificationVm(
      const OtpArgsModel(
        mobile: '0552207570',
        purpose: OtpPurpose.registration,
        prefilledOtp: '712633',
      ),
    )..onInit();

    expect(vm.otpController.text, '712633');
    expect(vm.canSubmit, isTrue);
    vm.dispose();
  });

  test('starts a 60 second countdown and blocks resend until it ends',
      () async {
    await boot();
    final vm = OtpVerificationVm(registrationArgs)..onInit();

    expect(vm.secondsRemaining, 60);
    expect(vm.canResend, isFalse);

    await vm.resend();
    expect(otpRepo.resendCalls, 0, reason: 'resend must be blocked while counting');

    vm.dispose();
  });

  test('rejects an otp that is not six digits', () async {
    await boot();
    final vm = OtpVerificationVm(registrationArgs)..onInit();
    vm.otpController.text = '123';

    await vm.verify();

    expect(vm.validationKey, LocaleKeys.errors_invalid_otp);
    expect(otpRepo.confirmCalls, 0);
    vm.dispose();
  });

  test('stores the session on a successful confirm', () async {
    await boot();
    final vm = OtpVerificationVm(registrationArgs)..onInit();
    vm.otpController.text = '712633';

    await vm.verify();

    expect(otpRepo.confirmCalls, 1);
    expect(session.token, 'tok-otp');
    expect(session.patient?.id, 18);
    vm.dispose();
  });

  test('surfaces a rejected otp without touching the session', () async {
    await boot(
      confirm: ApiResponseModel<AuthResponseModel>.failure(
        messages: const ['The otp is invalid.'],
        statusCode: 422,
        fieldErrors: const {
          'otp': ['The otp is invalid.']
        },
      ),
    );
    final vm = OtpVerificationVm(registrationArgs)..onInit();
    vm.otpController.text = '000000';

    await vm.verify();

    expect(vm.fieldError('otp'), 'The otp is invalid.');
    expect(session.isLoggedIn, isFalse);
    vm.dispose();
  });

  test('a password-reset code never calls confirm — it carries the code on',
      () async {
    await boot();
    final vm = OtpVerificationVm(
      const OtpArgsModel(
        mobile: '0552207570',
        purpose: OtpPurpose.passwordReset,
      ),
    )..onInit();
    vm.otpController.text = '570903';

    await vm.verify();

    // confirming a reset code here would burn it before the new password lands
    expect(otpRepo.confirmCalls, 0);
    expect(session.isLoggedIn, isFalse);
    vm.dispose();
  });

  test('resend for a reset goes to forgot-password, not otp/resend', () async {
    await boot();
    final vm = OtpVerificationVm(
      const OtpArgsModel(
        mobile: '0552207570',
        purpose: OtpPurpose.passwordReset,
      ),
    );
    // deliberately not calling onInit, so no countdown blocks the resend
    await vm.resend();

    expect(passwordRepo.forgotCalls, 1);
    expect(otpRepo.resendCalls, 0);
    expect(vm.otpController.text, '111111');
    vm.dispose();
  });
}
