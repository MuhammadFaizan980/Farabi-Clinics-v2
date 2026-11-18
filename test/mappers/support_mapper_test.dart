import 'package:farabi_booking_app/mappers/support_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = SupportMapper();

  group('jobs', () {
    final payload = [
      {
        'id': 1,
        'slug': 'specialist-dermatologist',
        'title': 'Specialist Dermatologist',
        'title_ar': 'أخصائي جلدية',
        'title_en': 'Specialist Dermatologist',
        'department': 'Dermatology Department',
        'summary': 'Provide specialized care for skin conditions.',
        'employment_type': {'value': 1, 'label': 'Full-time'},
        'experience_min_years': 4,
        'experience_max_years': 6,
        'branch': {'id': 5, 'name': 'Al-Suwaidi Branch', 'city': 'Riyadh'},
        'published_at': '2026-09-28T22:47:01+03:00',
      }
    ];

    test('maps the real captured payload', () {
      final job = mapper.jobs(payload).single;
      expect(job.id, 1);
      expect(job.names.display('ar'), 'أخصائي جلدية');
      expect(job.employmentType, 'Full-time');
      expect(job.cityName, 'Riyadh');
      expect(job.publishedAt, isNotNull);
    });

    test('formats the experience range, collapsing a degenerate one', () {
      expect(mapper.jobs(payload).single.experienceRange, '4 - 6');
      expect(
        mapper.jobs([
          {'id': 2, 'experience_min_years': 3, 'experience_max_years': 3}
        ]).single.experienceRange,
        '3',
      );
      expect(mapper.jobs([{'id': 3}]).single.experienceRange, isEmpty);
    });
  });

  group('departments', () {
    test('de-duplicates and drops blanks', () {
      final result = mapper.departments([
        {'department': 'Administration Department'},
        {'department': 'Administration Department'},
        {'department': 'Dermatology Department'},
        {'department': ''},
        {'other': 'x'},
      ]);
      expect(result.length, 2);
      expect(result, contains('Dermatology Department'));
    });
  });

  group('posts', () {
    test('returns an empty list for the empty dev dataset', () {
      expect(mapper.posts([]), isEmpty);
      expect(mapper.posts(null), isEmpty);
    });
  });
}
