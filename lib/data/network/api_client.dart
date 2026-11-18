import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../auth_session.dart';
import '../constants/app_constants.dart';
import 'api_response_model.dart';
import 'end_points.dart';

/// the only file in the app that knows about dio, base urls, headers,
/// interceptors or status codes.
class ApiClient {
  ApiClient({
    required AuthSession session,
    required String baseUrl,
    required bool enableLogging,
    Dio? transport,
  }) : dio = transport ?? Dio() {
    _session = session;
    _enableLogging = enableLogging;
    dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = AppConstants.connectTimeout
      ..receiveTimeout = AppConstants.receiveTimeout
      ..headers = <String, dynamic>{}
      // we normalise everything ourselves, so dio must never throw on status
      ..validateStatus = ((_) => true);
  }

  /// test seam: inject a dio whose transport is stubbed.
  factory ApiClient.withTransport({
    required AuthSession session,
    required Dio transport,
    String baseUrl = EndPoints.baseUrlDev,
  }) =>
      ApiClient(
        session: session,
        baseUrl: baseUrl,
        enableLogging: false,
        transport: transport,
      );

  final Dio dio;
  late final AuthSession _session;
  late final bool _enableLogging;

  /// fired when a request on a non-auth endpoint comes back 401. there is no
  /// refresh endpoint on this api, so the only correct response is a clean
  /// logout.
  void Function()? onUnauthorised;

  /// exactly the header set the website sends.
  Map<String, String> _headers() {
    final headers = <String, String>{
      'device': '1',
      'lang': _session.languageCode,
      'country-code': _session.countryCode.toLowerCase(),
      'Content-Type': 'application/json',
    };
    final token = _session.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<ApiResponseModel<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) =>
      _send(path, method: 'GET', query: query);

  Future<ApiResponseModel<dynamic>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) =>
      _send(path, method: 'POST', body: body, query: query);

  /// contact-us and the careers application are multipart, not json. dio sets
  /// the boundary itself, so Content-Type must be left off here.
  Future<ApiResponseModel<dynamic>> postForm(
    String path, {
    required Map<String, dynamic> fields,
  }) async {
    final headers = _headers()..remove('Content-Type');
    try {
      _log('POST(form) $path');
      final response = await dio.request<dynamic>(
        path,
        data: FormData.fromMap(fields),
        options: Options(method: 'POST', headers: headers),
      );
      return _normalise(path, response.statusCode, response.data);
    } on DioException catch (error) {
      _log('POST(form) $path failed: ${error.type}');
      return ApiResponseModel<dynamic>.failure(
        messages: [_transportMessage(error)],
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<ApiResponseModel<dynamic>> delete(
    String path, {
    Object? body,
  }) =>
      _send(path, method: 'DELETE', body: body);

  Future<ApiResponseModel<dynamic>> _send(
    String path, {
    required String method,
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    try {
      final cleanQuery = query == null
          ? null
          : (Map<String, dynamic>.from(query)
            ..removeWhere((_, value) => value == null));

      _log('$method $path ${cleanQuery ?? ''}');

      final response = await dio.request<dynamic>(
        path,
        data: body,
        queryParameters: cleanQuery,
        options: Options(method: method, headers: _headers()),
      );

      return _normalise(path, response.statusCode, response.data);
    } on DioException catch (error) {
      _log('$method $path failed: ${error.type}');
      return ApiResponseModel<dynamic>.failure(
        messages: [_transportMessage(error)],
        statusCode: error.response?.statusCode,
      );
    } catch (error) {
      _log('$method $path threw: ${error.runtimeType}');
      return ApiResponseModel<dynamic>.failure(messages: const ['unexpected']);
    }
  }

  ApiResponseModel<dynamic> _normalise(
    String path,
    int? statusCode,
    dynamic payload,
  ) {
    if (statusCode == 401 && !_isAuthPath(path)) {
      // no refresh exists on this api — validate-on-boot, hard-logout on 401
      onUnauthorised?.call();
    }

    if (payload is! Map) {
      return ApiResponseModel<dynamic>.failure(
        messages: const ['unexpected'],
        statusCode: statusCode,
      );
    }

    final map = Map<String, dynamic>.from(payload);
    final isSuccess = map['status'] == 'success';

    if (isSuccess) {
      final rawMeta = map['meta'];
      return ApiResponseModel<dynamic>(
        success: true,
        data: map['data'],
        statusCode: statusCode,
        meta: rawMeta is Map ? Map<String, dynamic>.from(rawMeta) : null,
      );
    }

    // on a 422 the `data` slot carries the field errors instead of a payload.
    final code = map['code'] is int ? map['code'] as int : statusCode;
    return ApiResponseModel<dynamic>.failure(
      messages: _messages(map['message']),
      statusCode: code,
      fieldErrors: code == 422 ? _fieldErrors(map['data']) : const {},
    );
  }

  static bool _isAuthPath(String path) =>
      EndPoints.authPaths.any((auth) => path.startsWith(auth));

  static List<String> _messages(dynamic raw) {
    if (raw is String) return [raw];
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  static Map<String, List<String>> _fieldErrors(dynamic raw) {
    if (raw is! Map) return const {};
    final result = <String, List<String>>{};
    raw.forEach((key, value) {
      if (value is List) {
        final messages = value.whereType<String>().toList(growable: false);
        if (messages.isNotEmpty) result['$key'] = messages;
      } else if (value is String) {
        result['$key'] = [value];
      }
    });
    return result;
  }

  static String _transportMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'timeout';
      case DioExceptionType.connectionError:
        return 'no_connection';
      default:
        return 'unexpected';
    }
  }

  /// never logs tokens, bodies or anything that could carry pii.
  void _log(String message) {
    if (!_enableLogging) return;
    developer.log(message, name: 'ApiClient');
  }
}
