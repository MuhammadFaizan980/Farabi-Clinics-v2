import 'package:farabi_booking_app/data/constants/locale_keys.g.dart';
import 'package:farabi_booking_app/data/models/auth/login_request_model.dart';
import 'package:farabi_booking_app/data/models/auth/mobile_number.dart';
import 'package:farabi_booking_app/data/models/auth/otp_request_model.dart';
import 'package:farabi_booking_app/data/models/auth/register_request_model.dart';
import 'package:farabi_booking_app/data/models/auth/reset_password_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MobileNumber', () {
    test('normalises every form to the national one with its leading zero', () {
      expect(MobileNumber.national('0564772491'), '0564772491');
      expect(MobileNumber.national('564772491'), '0564772491');
      expect(MobileNumber.national('966564772491'), '0564772491');
      expect(MobileNumber.national('+966 56 477 2491'), '0564772491');
      expect(MobileNumber.national('056-477-2491'), '0564772491');
    });

    test('accepts valid saudi mobiles and rejects the rest', () {
      expect(MobileNumber.isValidSaudi('0564772491'), isTrue);
      expect(MobileNumber.isValidSaudi('+966564772491'), isTrue);
      expect(MobileNumber.isValidSaudi('0464772491'), isFalse);
      expect(MobileNumber.isValidSaudi('056477249'), isFalse);
      expect(MobileNumber.isValidSaudi('05647724911'), isFalse);
      expect(MobileNumber.isValidSaudi(''), isFalse);
    });
  });

  group('LoginRequestModel', () {
    test('passes with a valid pair', () {
      const model = LoginRequestModel(mobile: '0564772491', password: 'secret');
      expect(model.validate(), isNull);
    });

    test('rejects a bad mobile', () {
      const model = LoginRequestModel(mobile: '12345', password: 'secret');
      expect(model.validate(), LocaleKeys.errors_invalid_mobile);
    });

    test('rejects an empty password', () {
      const model = LoginRequestModel(mobile: '0564772491', password: '  ');
      expect(model.validate(), LocaleKeys.errors_field_required);
    });

    test('serialises the mobile in national form', () {
      const model =
          LoginRequestModel(mobile: '+966564772491', password: 'secret');
      expect(model.toJson(), {
        'mobile': '0564772491',
        'password': 'secret',
      });
    });
  });

  group('RegisterRequestModel', () {
    RegisterRequestModel build({
      String first = 'Test',
      String last = 'Agent',
      String mobile = '0552207570',
      String password = 'Test#12345',
      String? confirm,
      String id = '2464148943',
      int? type = 5,
    }) =>
        RegisterRequestModel(
          firstName: first,
          lastName: last,
          mobile: mobile,
          password: password,
          passwordConfirmation: confirm ?? password,
          citizenIdNumber: id,
          citizenIdType: type,
        );

    test('passes with the payload that really registered', () {
      expect(build().validate(), isNull);
    });

    test('rejects a short name', () {
      expect(build(first: 'A').validate(), LocaleKeys.errors_invalid_name);
    });

    test('rejects a short password', () {
      expect(build(password: 'short').validate(),
          LocaleKeys.errors_invalid_password);
    });

    test('rejects mismatched passwords', () {
      expect(build(confirm: 'Different#1').validate(),
          LocaleKeys.errors_password_mismatch);
    });

    test('rejects a short id number', () {
      expect(build(id: '123').validate(), LocaleKeys.errors_invalid_id_number);
    });

    test('requires an id type', () {
      expect(build(type: null).validate(), LocaleKeys.errors_id_type_required);
    });

    test('sends country_code alongside the national mobile', () {
      final json = build().toJson();
      expect(json['country_code'], '+966');
      expect(json['mobile'], '0552207570');
      expect(json['citizen_id_type'], 5);
      expect(json.containsKey('password_confirmation'), isTrue);
    });
  });

  group('OtpConfirmRequestModel', () {
    test('requires exactly six digits', () {
      expect(
        const OtpConfirmRequestModel(mobile: '0564772491', otp: '712633')
            .validate(),
        isNull,
      );
      expect(
        const OtpConfirmRequestModel(mobile: '0564772491', otp: '7126')
            .validate(),
        LocaleKeys.errors_invalid_otp,
      );
    });
  });

  group('ResetPasswordRequestModel', () {
    test('serialises the body the api actually accepts', () {
      const model = ResetPasswordRequestModel(
        mobile: '0552207570',
        otp: '570903',
        password: 'NewPass#123',
        passwordConfirmation: 'NewPass#123',
      );
      expect(model.validate(), isNull);
      expect(model.toJson().keys.toSet(), {
        'mobile',
        'otp',
        'password',
        'password_confirmation',
      });
    });

    test('rejects a mismatch', () {
      const model = ResetPasswordRequestModel(
        mobile: '0552207570',
        otp: '570903',
        password: 'NewPass#123',
        passwordConfirmation: 'Other#1234',
      );
      expect(model.validate(), LocaleKeys.errors_password_mismatch);
    });
  });
}
