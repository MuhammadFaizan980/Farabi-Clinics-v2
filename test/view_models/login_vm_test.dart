import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/base/app_base_model.dart';
import 'package:farabi_booking_app/data/constants/locale_keys.g.dart';
import 'package:farabi_booking_app/data/models/auth/auth_response_model.dart';
import 'package:farabi_booking_app/data/models/auth/login_request_model.dart';
import 'package:farabi_booking_app/data/models/auth/patient_data_model.dart';
import 'package:farabi_booking_app/data/network/api_response_model.dart';
import 'package:farabi_booking_app/repos/auth/login_repo.dart';
import 'package:farabi_booking_app/repos/discovery/countries_repo.dart';
import 'package:farabi_booking_app/screens/auth/login_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_countries_repo.dart';
import '../helpers/fakes.dart';

class _FakeLoginRepo extends LoginRepo {
  _FakeLoginRepo(this.response);

  final ApiResponseModel<AuthResponseModel> response;
  LoginRequestModel? received;

  @override
  Future<ApiResponseModel<AuthResponseModel>> login(
    LoginRequestModel request,
  ) async {
    received = request;
    return response;
  }
}

void main() {
  // AppNavigator reads a GlobalKey's currentState, which needs the binding
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeLocalData localData;
  late AuthSession session;

  Future<_FakeLoginRepo> setUpWith(
    ApiResponseModel<AuthResponseModel> response,
  ) async {
    await AppDi.reset();
    localData = FakeLocalData();
    session = AuthSession(localData);
    await session.restore();
    final repo = _FakeLoginRepo(response);
    AppDi.locator
      ..registerSingleton<AuthSession>(session)
      ..registerSingleton<AppBaseModel>(AppBaseModel())
      ..registerSingleton<CountriesRepo>(FakeCountriesRepo())
      ..registerSingleton<LoginRepo>(repo);
    return repo;
  }

  tearDown(() => AppDi.reset());

  Future<LoginVm> vmWith(String mobile, String password) async {
    final vm = LoginVm();
    await vm.onInit();
    vm.phone.text.text = mobile;
    vm.passwordController.text = password;
    return vm;
  }

  test(
    'blocks submit and surfaces a locale key when the mobile is empty',
    () async {
      final repo = await setUpWith(
        const ApiResponseModel<AuthResponseModel>(success: true),
      );
      final vm = await vmWith('', 'secret');

      await vm.submit();

      expect(vm.validationKey, LocaleKeys.errors_invalid_mobile);
      // never reached the repo
      expect(repo.received, isNull);
      expect(session.isLoggedIn, isFalse);
    },
  );

  test('stores the token and patient on success', () async {
    const patient = PatientDataModel(id: 17, firstName: 'Faizan');
    await setUpWith(
      const ApiResponseModel<AuthResponseModel>(
        success: true,
        data: AuthResponseModel(token: 'tok-abc', patient: patient),
      ),
    );
    final vm = await vmWith('0564772491', 'secret123');

    await vm.submit();

    expect(session.token, 'tok-abc');
    expect(localData.storedToken, 'tok-abc');
    expect(session.patient?.id, 17);
    expect(AppDi.locator<AppBaseModel>().patient?.id, 17);
    expect(vm.isBusy, isFalse);
    expect(vm.hasFailure, isFalse);
  });

  test('sends the normalised national mobile to the repo', () async {
    final repo = await setUpWith(
      const ApiResponseModel<AuthResponseModel>(
        success: true,
        data: AuthResponseModel(token: 'tok'),
      ),
    );
    final vm = await vmWith('+966564772491', 'secret123');

    await vm.submit();

    expect(repo.received!.toJson()['mobile'], '0564772491');
  });

  test(
    'surfaces the server message and leaves the session alone on failure',
    () async {
      await setUpWith(
        ApiResponseModel<AuthResponseModel>.failure(
          messages: const ['Invalid credentials.'],
          statusCode: 401,
        ),
      );
      final vm = await vmWith('0564772491', 'wrong');

      await vm.submit();

      expect(vm.errorMessage, 'Invalid credentials.');
      expect(session.isLoggedIn, isFalse);
      expect(vm.isBusy, isFalse);
    },
  );

  test('maps 422 field errors back onto the right input', () async {
    await setUpWith(
      ApiResponseModel<AuthResponseModel>.failure(
        messages: const ['The mobile field is required.'],
        statusCode: 422,
        fieldErrors: const {
          'mobile': ['The mobile field is required.'],
        },
      ),
    );
    final vm = await vmWith('0564772491', 'secret123');

    await vm.submit();

    expect(vm.fieldError('mobile'), 'The mobile field is required.');
    expect(vm.fieldError('password'), isNull);
  });

  test('clears a previous error as soon as the user edits a field', () async {
    await setUpWith(
      ApiResponseModel<AuthResponseModel>.failure(
        messages: const ['Invalid credentials.'],
        statusCode: 401,
      ),
    );
    final vm = await vmWith('0564772491', 'wrong');

    await vm.submit();
    expect(vm.hasFailure, isTrue);

    vm.onFieldChanged('x');
    expect(vm.hasFailure, isFalse);
    expect(vm.validationKey, isNull);
  });

  test('canSubmit guards the button', () async {
    await setUpWith(const ApiResponseModel<AuthResponseModel>(success: true));
    final vm = LoginVm();
    await vm.onInit();
    expect(vm.canSubmit, isFalse);
    vm.phone.text.text = '0564772491';
    expect(vm.canSubmit, isFalse);
    vm.passwordController.text = 'x';
    expect(vm.canSubmit, isTrue);
  });

  test(
    'the country list comes from the api and starts on Saudi Arabia',
    () async {
      await setUpWith(const ApiResponseModel<AuthResponseModel>(success: true));
      final vm = LoginVm();
      await vm.onInit();

      expect(vm.phone.selected?.code, 'SA');
      expect(vm.phone.countryCode, '+966');
      // Pakistan's code in the test data is "3", which has no dial code
      expect(vm.phone.options.map((c) => c.code), ['EG', 'SA', 'AE']);
    },
  );

  test('another country sends its own national prefix', () async {
    final repo = await setUpWith(
      const ApiResponseModel<AuthResponseModel>(
        success: true,
        data: AuthResponseModel(token: 'tok'),
      ),
    );
    final vm = await vmWith('1012345678', 'secret123');
    vm.phone.select(vm.phone.options.firstWhere((c) => c.code == 'EG'));

    await vm.submit();

    expect(repo.received!.toJson()['mobile'], '01012345678');
  });

  test(
    'without the country list the field still works with Saudi Arabia',
    () async {
      await AppDi.reset();
      final session = AuthSession(FakeLocalData());
      await session.restore();
      AppDi.locator
        ..registerSingleton<AuthSession>(session)
        ..registerSingleton<AppBaseModel>(AppBaseModel())
        ..registerSingleton<CountriesRepo>(FakeCountriesRepo(fail: true))
        ..registerSingleton<LoginRepo>(
          _FakeLoginRepo(
            const ApiResponseModel<AuthResponseModel>(success: true),
          ),
        );
      final vm = LoginVm();
      await vm.onInit();

      expect(vm.phone.options.map((c) => c.code), ['SA']);
      expect(vm.phone.countryCode, '+966');
    },
  );
}
