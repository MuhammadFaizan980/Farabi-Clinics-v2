import 'package:farabi_booking_app/utils/phone_country.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_countries_repo.dart';

PhoneCountry country(String code) =>
    PhoneCountry.from(fakeCountries.firstWhere((c) => c.code == code))!;

void main() {
  test('dial code and flag are worked out from the ISO code', () {
    expect(country('SA').dial, '+966');
    expect(country('SA').flag, '🇸🇦');
    expect(country('EG').dial, '+20');
    expect(country('AE').dial, '+971');
  });

  test('an api code that is not a real country is skipped', () {
    final pakistan = fakeCountries.firstWhere((c) => c.code == '3');
    expect(PhoneCountry.from(pakistan), isNull);
  });

  group('nationalNumber', () {
    test('typing with or without the leading zero gives the same number', () {
      final sa = country('SA');
      expect(sa.nationalNumber('0564772491'), '0564772491');
      expect(sa.nationalNumber('564772491'), '0564772491');
      expect(sa.nationalNumber('056 477 2491'), '0564772491');
    });

    test('a pasted international number is trimmed to the national one', () {
      expect(country('SA').nationalNumber('+966564772491'), '0564772491');
    });

    test('other countries keep their own prefix', () {
      expect(country('EG').nationalNumber('1012345678'), '01012345678');
    });

    test('nothing typed gives nothing', () {
      expect(country('SA').nationalNumber('  '), '');
    });
  });

  test('the name follows the app language', () {
    expect(country('EG').label('en'), 'Egypt');
    expect(country('EG').label('ar'), 'مصر');
  });
}
