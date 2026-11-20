import 'package:farabi_booking_app/data/models/discovery/discovery_models.dart';
import 'package:farabi_booking_app/data/network/api_response_model.dart';
import 'package:farabi_booking_app/repos/discovery/countries_repo.dart';

/// the countries the test api returns, including its one bad entry (Pakistan
/// with the code "3"), which has no dial code
const fakeCountries = [
  CountryDataModel(
    id: 2,
    code: 'EG',
    names: LocalisedName(name: 'Egypt', nameEn: 'Egypt', nameAr: 'مصر'),
  ),
  CountryDataModel(
    id: 6,
    code: '3',
    names: LocalisedName(name: 'PAKISTAN', nameEn: 'PAKISTAN'),
  ),
  CountryDataModel(
    id: 1,
    code: 'SA',
    names: LocalisedName(
      name: 'Saudi Arabia',
      nameEn: 'Saudi Arabia',
      nameAr: 'المملكة العربية السعودية',
    ),
  ),
  CountryDataModel(
    id: 3,
    code: 'AE',
    names: LocalisedName(
      name: 'United Arab Emirates',
      nameEn: 'United Arab Emirates',
    ),
  ),
];

class FakeCountriesRepo extends CountriesRepo {
  FakeCountriesRepo({this.fail = false});

  final bool fail;

  @override
  Future<ApiResponseModel<List<CountryDataModel>>> countries() async => fail
      ? const ApiResponseModel(success: false, messages: ['down'])
      : const ApiResponseModel(success: true, data: fakeCountries);
}
