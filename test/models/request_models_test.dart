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
    test('passes with a mobile and a password', () {
      const model = LoginRequestModel(mobile: '0564772491', password: 'secret');
      expect(model.validate(), isNull);
    });

    test('like the site, only an empty mobile is rejected on the device', () {
      const empty = LoginRequestModel(mobile: ' ', password: 'secret');
      expect(empty.validate(), LocaleKeys.errors_invalid_mobile);
      const odd = LoginRequestModel(mobile: '12345', password: 'secret');
      expect(odd.validate(), isNull);
    });

    test('rejects an empty password', () {
      const model = LoginRequestModel(mobile: '0564772491', password: '  ');
      expect(model.validate(), LocaleKeys.errors_field_required);
    });

    test('posts only the mobile and the password', () {
      const model = LoginRequestModel(mobile: '0564772491', password: 'secret');
      expect(model.toJson(), {'mobile': '0564772491', 'password': 'secret'});
    });
  });

  group('RegisterRequestModel', () {
    RegisterRequestModel build({
      String first = 'Test',
      String last = 'Agent',
      String countryCode = '+966',
      String mobile = '0552207570',
      String password = 'Test#12345',
      String id = '2464148943',
      int? type = 5,
    }) => RegisterRequestModel(
      firstName: first,
      lastName: last,
      countryCode: countryCode,
      mobile: mobile,
      password: password,
      citizenIdNumber: id,
      citizenIdType: type,
    );

    test('passes with the payload that really registered', () {
      expect(build().validate(), isNull);
    });

    test('asks for every field and nothing more', () {
      expect(build(first: ' ').validate(), LocaleKeys.errors_invalid_name);
      expect(
        build(password: '').validate(),
        LocaleKeys.errors_invalid_password,
      );
      expect(build(id: '').validate(), LocaleKeys.errors_invalid_id_number);
      expect(build(mobile: '').validate(), LocaleKeys.errors_invalid_mobile);
      expect(build(type: null).validate(), LocaleKeys.errors_id_type_required);
      // short passwords and ids are the server's call, as on the site
      expect(build(password: 'short', id: '123').validate(), isNull);
    });

    test('sends the chosen country code and sends the password twice', () {
      final json = build(countryCode: '+20', mobile: '01012345678').toJson();
      expect(json['country_code'], '+20');
      expect(json['mobile'], '01012345678');
      expect(json['password_confirmation'], json['password']);
      expect(json['citizen_id_type'], 5);
    });
  });

  group('OtpConfirmRequestModel', () {
    test('requires exactly six digits', () {
      expect(
        const OtpConfirmRequestModel(
          mobile: '0564772491',
          otp: '712633',
        ).validate(),
        isNull,
      );
      expect(
        const OtpConfirmRequestModel(
          mobile: '0564772491',
          otp: '7126',
        ).validate(),
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
