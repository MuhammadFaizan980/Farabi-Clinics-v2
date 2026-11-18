import 'package:dio/dio.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/network/api_client.dart';
import 'package:farabi_booking_app/data/network/end_points.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeLocalData localData;
  late AuthSession session;
  late RecordingAdapter adapter;
  late ApiClient client;

  Future<void> build({
    int statusCode = 200,
    Map<String, dynamic> body = const {'status': 'success', 'data': {}},
    String? token,
  }) async {
    localData = FakeLocalData(storedToken: token);
    session = AuthSession(localData);
    await session.restore();
    adapter = RecordingAdapter(statusCode: statusCode, body: body);
    final dio = Dio()..httpClientAdapter = adapter;
    client = ApiClient.withTransport(session: session, transport: dio);
  }

  group('request context headers', () {
    test('sends the exact header set the website sends', () async {
      await build();
      await client.get(EndPoints.regions);

      final headers = adapter.lastRequest!.headers;
      expect(headers['device'], '1');
      expect(headers['lang'], 'en');
      expect(headers['country-code'], 'sa');
      expect(headers['Content-Type'], 'application/json');
      // no token stored, so no bearer
      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('injects the bearer once a token exists', () async {
      await build(token: 'tok-123');
      await client.get(EndPoints.profile);
      expect(adapter.lastRequest!.headers['Authorization'], 'Bearer tok-123');
    });

    test('country-code is always lowercased', () async {
      await build();
      await session.setCountryCode('EG');
      await client.get(EndPoints.branches);
      expect(adapter.lastRequest!.headers['country-code'], 'eg');
    });

    test('lang follows the session language', () async {
      await build();
      await session.setLanguageCode('ar');
      await client.get(EndPoints.regions);
      expect(adapter.lastRequest!.headers['lang'], 'ar');
    });
  });

  group('envelope normalisation', () {
    test('unwraps data on success', () async {
      await build(body: {
        'status': 'success',
        'data': [
          {'id': 5, 'name': 'Riyadh'}
        ],
        'meta': null,
      });
      final response = await client.get(EndPoints.regions);
      expect(response.success, isTrue);
      expect(response.data, isA<List<dynamic>>());
      expect((response.data as List).length, 1);
      expect(response.fieldErrors, isEmpty);
    });

    test('maps a 422 into fieldErrors keyed by request field', () async {
      await build(statusCode: 422, body: {
        'status': 'error',
        'message': ['This coupon code is not valid.'],
        'code': 422,
        'data': {
          'coupon_code': ['This coupon code is not valid.']
        },
      });
      final response = await client.get(EndPoints.checkoutContext);

      expect(response.success, isFalse);
      expect(response.isValidationError, isTrue);
      expect(response.message, 'This coupon code is not valid.');
      expect(response.fieldErrors['coupon_code']?.first,
          'This coupon code is not valid.');
    });

    test('keeps multiple messages for one field', () async {
      await build(statusCode: 422, body: {
        'status': 'error',
        'message': [
          'The status field must be an integer.',
          'The selected status is invalid.',
        ],
        'code': 422,
        'data': {
          'status': [
            'The status field must be an integer.',
            'The selected status is invalid.',
          ]
        },
      });
      final response = await client.get(EndPoints.bookings);
      expect(response.messages.length, 2);
      expect(response.fieldErrors['status']?.length, 2);
    });

    test('does not treat a non-422 data slot as field errors', () async {
      await build(statusCode: 404, body: {
        'status': 'error',
        'message': ['Target record was not found.'],
        'code': 404,
      });
      final response = await client.get(EndPoints.doctorDetail(9999));
      expect(response.fieldErrors, isEmpty);
      expect(response.statusCode, 404);
    });

    test('fails cleanly on a non-map payload', () async {
      await build(body: const {});
      adapter.body = const {'status': 'success'};
      final response = await client.get(EndPoints.regions);
      expect(response.success, isTrue);
      expect(response.data, isNull);
    });
  });

  group('401 handling — no refresh exists on this api', () {
    test('fires onUnauthorised for a protected endpoint', () async {
      await build(statusCode: 401, token: 'stale', body: {
        'status': 'error',
        'message': ['User is not logged in.'],
        'code': 401,
      });
      var fired = 0;
      client.onUnauthorised = () => fired++;

      final response = await client.get(EndPoints.profile);

      expect(response.isUnauthorised, isTrue);
      expect(fired, 1);
    });

    test('does NOT fire for a token-issuing endpoint', () async {
      await build(statusCode: 401, body: {
        'status': 'error',
        'message': ['Invalid credentials.'],
        'code': 401,
      });
      var fired = 0;
      client.onUnauthorised = () => fired++;

      await client.post(EndPoints.login, body: const {'mobile': '1'});

      // a bad password must surface on the login screen, not log the user out
      expect(fired, 0);
    });
  });

  group('query handling', () {
    test('drops null query values rather than sending them', () async {
      await build();
      await client.get(
        EndPoints.doctors,
        query: {'page': 1, 'search': null, 'region_id': 5},
      );
      final sent = adapter.lastRequest!.queryParameters;
      expect(sent.containsKey('search'), isFalse);
      expect(sent['page'], 1);
      expect(sent['region_id'], 5);
    });
  });
}
