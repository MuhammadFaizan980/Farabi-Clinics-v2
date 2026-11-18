import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// guards the two things that silently rot: a key added to one language but
/// not the other, and a LocaleKeys entry that no longer resolves.
void main() {
  Map<String, dynamic> load(String path) =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

  Set<String> flatten(Map<String, dynamic> map, [String prefix = '']) {
    final keys = <String>{};
    map.forEach((key, value) {
      final full = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        keys.addAll(flatten(value, full));
      } else {
        keys.add(full);
      }
    });
    return keys;
  }

  late Set<String> en;
  late Set<String> ar;

  setUpAll(() {
    en = flatten(load('assets/translations/en-US.json'));
    ar = flatten(load('assets/translations/ar-SA.json'));
  });

  test('en-US and ar-SA have identical key sets', () {
    expect(en.difference(ar), isEmpty, reason: 'missing from ar-SA');
    expect(ar.difference(en), isEmpty, reason: 'missing from en-US');
  });

  test('no translation value is left blank', () {
    for (final path in [
      'assets/translations/en-US.json',
      'assets/translations/ar-SA.json',
    ]) {
      final raw = File(path).readAsStringSync();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      void walk(Map<String, dynamic> map, String prefix) {
        map.forEach((key, value) {
          final full = prefix.isEmpty ? key : '$prefix.$key';
          if (value is Map<String, dynamic>) {
            walk(value, full);
          } else {
            expect(
              '$value'.trim(),
              isNotEmpty,
              reason: '$path -> $full is blank',
            );
          }
        });
      }

      walk(decoded, '');
    }
  });

  test('every generated LocaleKeys entry exists in both bundles', () {
    final generated = File('lib/data/constants/locale_keys.g.dart')
        .readAsStringSync();
    final matches = RegExp(r"static const \w+ = '([^']+)';")
        .allMatches(generated)
        .map((m) => m.group(1)!)
        .where((key) => !key.endsWith('.'))
        .toSet();

    expect(matches, isNotEmpty);
    for (final key in matches) {
      // skip the group prefixes easy_localization emits for nested maps
      if (en.any((k) => k.startsWith('$key.'))) continue;
      expect(en, contains(key), reason: '$key missing from en-US');
      expect(ar, contains(key), reason: '$key missing from ar-SA');
    }
  });

  test('arabic bundle actually contains arabic script', () {
    final raw = File('assets/translations/ar-SA.json').readAsStringSync();
    final arabic = RegExp(r'[؀-ۿ]');
    expect(arabic.hasMatch(raw), isTrue);
  });
}
