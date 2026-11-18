import 'package:farabi_booking_app/mappers/discovery_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = DiscoveryMapper();

  group('localised names', () {
    test('picks the right language and falls back sensibly', () {
      final regions = mapper.regions([
        {'id': 9, 'name_ar': 'الدمام', 'name_en': 'Dammam', 'name': 'Dammam'},
      ]);
      expect(regions.single.names.display('en'), 'Dammam');
      expect(regions.single.names.display('ar'), 'الدمام');
    });

    test('falls back to name when a language variant is missing', () {
      final regions = mapper.regions([
        {'id': 1, 'name': 'Only'},
      ]);
      expect(regions.single.names.display('en'), 'Only');
      expect(regions.single.names.display('ar'), 'Only');
    });

    test('drops rows with no id instead of inventing one', () {
      expect(mapper.regions([{'name': 'x'}, {'id': 2}]).length, 1);
      expect(mapper.regions(null), isEmpty);
      expect(mapper.regions('garbage'), isEmpty);
    });
  });

  group('doctor', () {
    test('maps the real captured list payload', () {
      final doctor = mapper.doctor({
        'id': 28,
        'name': 'Alaa Ali Abo Zahraa',
        'name_ar': 'علاء ابو زهره',
        'name_en': 'Alaa Ali Abo Zahraa',
        'image': null,
        'gender': 'Male',
        'rating_average': 0,
        'rating_count': 0,
        'branches': [
          {'id': 25, 'name': 'Al-Hakeem Medical Complex Clinics'}
        ],
        'specialties': [],
      });

      expect(doctor!.id, 28);
      expect(doctor.names.display('ar'), 'علاء ابو زهره');
      expect(doctor.primaryBranch?.id, 25);
      expect(doctor.specialities, isEmpty);
      expect(doctor.image, isNull);
    });

    test('flattens qualification whether it is a string or an object', () {
      expect(
        mapper.doctor({'id': 1, 'qualification': 'MBBS'})!.qualification,
        'MBBS',
      );
      expect(
        mapper.doctor({
          'id': 1,
          'qualification': {'name': 'Consultant'}
        })!.qualification,
        'Consultant',
      );
      expect(mapper.doctor({'id': 1})!.qualification, isNull);
    });

    test('accepts specialties and specialities spellings alike', () {
      expect(
        mapper.doctor({
          'id': 1,
          'specialties': [
            {'id': 14, 'name': 'Radiology'}
          ]
        })!.specialities.single.name,
        'Radiology',
      );
      expect(
        mapper.doctor({
          'id': 1,
          'specialities': [
            {'id': 15, 'name': 'Dental'}
          ]
        })!.specialities.single.name,
        'Dental',
      );
    });
  });

  group('branch', () {
    test('maps the real payload and guards the null map/phone case', () {
      final branch = mapper.branch({
        'id': 10,
        'name': 'Al-Badeya Branch (Main)',
        'name_ar': 'فرع البديعة (الرئيسي)',
        'address': null,
        'phone': null,
        'latitude': null,
        'longitude': null,
        'region': {'id': 5, 'name': 'Riyadh'},
      });

      expect(branch!.region?.id, 5);
      // every branch on the test host looks like this, so these must be false
      expect(branch.canOpenMap, isFalse);
      expect(branch.canCall, isFalse);
    });

    test('reports map and call as available once the data exists', () {
      final branch = mapper.branch({
        'id': 8,
        'name': 'Al-Olaya',
        'phone': '0112027500',
        'latitude': 24.7,
        'longitude': 46.6,
      });
      expect(branch!.canOpenMap, isTrue);
      expect(branch.canCall, isTrue);
    });
  });

  group('service', () {
    test('parses the decimal-string price into a number', () {
      final service = mapper.service({
        'id': 19,
        'name': 'Creatinine',
        'price': '45.00',
        'slot': 0,
      });
      expect(service!.price, 45.0);
    });

    test('reads duration from either duration_minutes or slot', () {
      expect(
        mapper.service({'id': 1, 'duration_minutes': 30})!.durationMinutes,
        30,
      );
      expect(mapper.service({'id': 1, 'slot': 45})!.durationMinutes, 45);
    });
  });

  group('paging meta', () {
    test('reads total when present', () {
      expect(
        mapper.totalFromMeta({
          'per_page': 20,
          'total': 57,
          'curr_page': 1,
          'last_page': 3,
          'next_page_url': null,
        }),
        57,
      );
    });

    test('returns null for the test host where meta is null', () {
      expect(mapper.totalFromMeta(null), isNull);
      expect(mapper.totalFromMeta({}), isNull);
    });
  });

  group('home branches', () {
    test('maps regions with nested branches, empty or not', () {
      final result = mapper.homeBranches([
        {
          'id': 9,
          'name': 'Dammam',
          'name_ar': 'الدمام',
          'branches_count': 0,
          'branches': [],
        },
      ]);
      expect(result.single.branchesCount, 0);
      expect(result.single.branches, isEmpty);
      expect(result.single.names.display('ar'), 'الدمام');
    });
  });
}
