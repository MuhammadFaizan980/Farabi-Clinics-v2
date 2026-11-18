import 'package:farabi_booking_app/mappers/auth_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = AuthMapper();

  group('AuthMapper.patient', () {
    test('maps the real captured payload', () {
      final patient = mapper.patient({
        'id': 17,
        'patient_id': 'PAT-DD81212C',
        'first_name': 'Faizan',
        'last_name': 'Awan',
        'email': null,
        'mobile': '0564772491',
        'country_code': '+966',
        'citizen_id_type': 5,
        'citizen_id_number': '2563356050',
        'is_phone_verified': true,
        'is_email_verified': false,
      });

      expect(patient, isNotNull);
      expect(patient!.id, 17);
      expect(patient.patientId, 'PAT-DD81212C');
      expect(patient.fullName, 'Faizan Awan');
      expect(patient.email, isNull);
      expect(patient.isPhoneVerified, isTrue);
      expect(patient.isEmailVerified, isFalse);
      expect(patient.hasCitizenId, isTrue);
    });

    test('returns null when id is absent — the "not logged in" signal', () {
      expect(mapper.patient({'first_name': 'No'}), isNull);
      expect(mapper.patient(null), isNull);
      expect(mapper.patient('garbage'), isNull);
    });

    test('tolerates missing and null optional fields', () {
      final patient = mapper.patient({'id': 1});
      expect(patient, isNotNull);
      expect(patient!.firstName, isNull);
      expect(patient.fullName, isEmpty);
      expect(patient.hasCitizenId, isFalse);
      expect(patient.isPhoneVerified, isFalse);
    });

    test('coerces a stringified id', () {
      expect(mapper.patient({'id': '42'})?.id, 42);
    });
  });

  group('AuthMapper.auth', () {
    test('maps token and nested patient', () {
      final auth = mapper.auth({
        'token': 'a' * 52,
        'patient': {'id': 17, 'first_name': 'Faizan'},
      });
      expect(auth, isNotNull);
      expect(auth!.token.length, 52);
      expect(auth.patient?.id, 17);
    });

    test('returns null without a usable token', () {
      expect(mapper.auth({'patient': {'id': 1}}), isNull);
      expect(mapper.auth({'token': ''}), isNull);
      expect(mapper.auth(null), isNull);
    });

    test('survives a token with no patient', () {
      final auth = mapper.auth({'token': 'tok'});
      expect(auth?.patient, isNull);
    });
  });

  group('AuthMapper.otp', () {
    test('maps the dev payload that carries the otp', () {
      final otp = mapper.otp({'message': 'OTP sent successfully.', 'otp': '712633'});
      expect(otp.message, 'OTP sent successfully.');
      expect(otp.otp, '712633');
    });

    test('maps a production payload with no otp', () {
      final otp = mapper.otp({'message': 'OTP sent successfully.'});
      expect(otp.otp, isNull);
    });

    test('coerces a numeric otp to string', () {
      expect(mapper.otp({'otp': 712633}).otp, '712633');
    });
  });
}
