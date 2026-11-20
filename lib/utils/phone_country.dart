import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../data/models/discovery/discovery_models.dart';

/// a country the phone fields offer: the api's country plus what the site
/// works out from its ISO code on the device, the dial code ("+966"), the flag
/// and the national prefix. an entry whose code is not a real ISO country (the
/// test data has one with the code "3") cannot be dialled and is left out.
class PhoneCountry {
  const PhoneCountry({
    required this.country,
    required this.iso,
    required this.dial,
    required this.nationalPrefix,
  });

  final CountryDataModel country;
  final IsoCode iso;

  /// e.g. "+966"
  final String dial;

  /// e.g. "0" for Saudi Arabia; empty when the country has none
  final String nationalPrefix;

  String get code => country.code.toUpperCase();

  /// the regional-indicator emoji for the ISO code
  String get flag => code.runes
      .map((r) => String.fromCharCode(127397 + r))
      .join();

  String label(String languageCode) => country.names.display(languageCode);

  /// null when the api's code is not a usable ISO country
  static PhoneCountry? from(CountryDataModel country) {
    final code = country.code.toUpperCase();
    for (final iso in IsoCode.values) {
      if (iso.name != code) continue;
      final metadata = metadataByIsoCode[iso];
      if (metadata == null) return null;
      return PhoneCountry(
        country: country,
        iso: iso,
        dial: '+${metadata.countryCode}',
        nationalPrefix: metadata.nationalPrefix ?? '',
      );
    }
    return null;
  }

  /// what the api takes as `mobile`: the national number, with its national
  /// prefix. typing "0564772491" or "564772491" gives the same result, like
  /// the site's phone input (it parses the number and formats it nationally).
  String nationalNumber(String typed) {
    var digits = typed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    final dialDigits = dial.substring(1);
    if (typed.trim().startsWith('+') && digits.startsWith(dialDigits)) {
      digits = digits.substring(dialDigits.length);
    }
    if (nationalPrefix.isNotEmpty && digits.startsWith(nationalPrefix)) {
      digits = digits.substring(nationalPrefix.length);
    }
    return '$nationalPrefix$digits';
  }
}
