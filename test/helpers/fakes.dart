import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:farabi_booking_app/data/app_local_data.dart';

/// in-memory stand-in so tests never touch the keychain or shared prefs.
class FakeLocalData extends AppLocalData {
  FakeLocalData({this.storedToken});

  String? storedToken;
  String? storedLanguage;
  String? storedCountry;

  @override
  Future<void> init() async {}

  @override
  Future<String?> readToken() async => storedToken;

  @override
  Future<void> writeToken(String token) async => storedToken = token;

  @override
  Future<void> clearToken() async => storedToken = null;

  @override
  String? get languageCode => storedLanguage;

  @override
  Future<void> setLanguageCode(String code) async => storedLanguage = code;

  @override
  String? get countryCode => storedCountry;

  @override
  Future<void> setCountryCode(String code) async => storedCountry = code;
}

/// records the request it was handed and replays a canned response, so the
/// api client's contract can be asserted without a network.
class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter({required this.statusCode, required this.body});

  int statusCode;
  Map<String, dynamic> body;

  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
