import 'app_local_data.dart';
import 'constants/app_constants.dart';
import 'models/auth/patient_data_model.dart';

/// the live request context: token, language and country. the api client reads
/// this on every call, so it has to be populated before any screen can fire a
/// request.
class AuthSession {
  AuthSession(this._localData);

  final AppLocalData _localData;

  String? _token;
  PatientDataModel? _patient;
  String _languageCode = 'en';
  String _countryCode = AppConstants.defaultCountryCode;

  String? get token => _token;
  PatientDataModel? get patient => _patient;
  String get languageCode => _languageCode;
  String get countryCode => _countryCode;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// restores whatever was persisted. does not validate the token — that is the
  /// splash view model's job, via a profile call.
  Future<void> restore() async {
    _token = await _localData.readToken();
    _languageCode = _localData.languageCode ?? 'en';
    _countryCode = _localData.countryCode ?? AppConstants.defaultCountryCode;
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _localData.writeToken(token);
  }

  void setPatient(PatientDataModel? patient) => _patient = patient;

  Future<void> setLanguageCode(String code) async {
    _languageCode = code;
    await _localData.setLanguageCode(code);
  }

  Future<void> setCountryCode(String code) async {
    _countryCode = code;
    await _localData.setCountryCode(code);
  }

  /// there is no refresh endpoint, so an expired token has exactly one outcome.
  Future<void> clear() async {
    _token = null;
    _patient = null;
    await _localData.clearToken();
  }
}
