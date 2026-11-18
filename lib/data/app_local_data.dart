import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// local persistence. the token lives in secure storage; everything else, which
/// is non-sensitive, lives in shared preferences.
class AppLocalData {
  AppLocalData({
    SharedPreferences? preferences,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _preferences = preferences;
  }

  static const String _keyToken = 'auth_token';
  static const String _keyLanguage = 'language_code';
  static const String _keyCountry = 'country_code';
  static const String _keyOnboarded = 'has_onboarded';

  SharedPreferences? _preferences;
  final FlutterSecureStorage _secureStorage;

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // ---- token (secure) ----

  Future<String?> readToken() async {
    try {
      return await _secureStorage.read(key: _keyToken);
    } catch (_) {
      // a corrupt keychain entry must not brick the launch
      return null;
    }
  }

  Future<void> writeToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  // ---- preferences ----

  String? get languageCode => _preferences?.getString(_keyLanguage);

  Future<void> setLanguageCode(String code) async =>
      _preferences?.setString(_keyLanguage, code);

  String? get countryCode => _preferences?.getString(_keyCountry);

  Future<void> setCountryCode(String code) async =>
      _preferences?.setString(_keyCountry, code);

  bool get hasOnboarded => _preferences?.getBool(_keyOnboarded) ?? false;

  Future<void> setOnboarded() async =>
      _preferences?.setBool(_keyOnboarded, true);
}
