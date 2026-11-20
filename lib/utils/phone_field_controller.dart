import 'package:flutter/widgets.dart';

import '../data/models/discovery/discovery_models.dart';
import '../repos/discovery/countries_repo.dart';
import 'phone_country.dart';

/// state behind a [CountryPhoneField]: the countries from the api, the chosen
/// one (Saudi Arabia first, like the site) and the typed number.
class PhoneFieldController extends ChangeNotifier {
  PhoneFieldController() : text = TextEditingController() {
    text.addListener(notifyListeners);
  }

  final TextEditingController text;

  List<PhoneCountry> _options = const [];
  PhoneCountry? _selected;

  /// loads the country list; when it cannot be loaded the field still works
  /// with Saudi Arabia alone, which is also what the site falls back to
  Future<void> load(CountriesRepo repo) async {
    final response = await repo.countries();
    final list = response.success
        ? (response.data ?? const <CountryDataModel>[])
        : const <CountryDataModel>[];
    var options = list
        .map(PhoneCountry.from)
        .whereType<PhoneCountry>()
        .toList(growable: false);
    if (options.isEmpty) {
      final saudi = PhoneCountry.from(
        const CountryDataModel(
          id: 1,
          code: 'SA',
          names: LocalisedName(
            name: 'Saudi Arabia',
            nameEn: 'Saudi Arabia',
            nameAr: 'المملكة العربية السعودية',
          ),
        ),
      );
      options = saudi == null ? const [] : [saudi];
    }
    _options = options;
    _selected = _options.firstWhere(
      (c) => c.code == 'SA',
      orElse: () => _options.first,
    );
    notifyListeners();
  }

  void select(PhoneCountry country) {
    _selected = country;
    notifyListeners();
  }

  List<PhoneCountry> get options => _options;
  PhoneCountry? get selected => _selected;

  bool get isEmpty => text.text.trim().isEmpty;

  /// "+966", sent as `country_code` on register
  String get countryCode => _selected?.dial ?? '';

  /// sent as `mobile` everywhere
  String get national => _selected?.nationalNumber(text.text) ?? '';

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }
}
