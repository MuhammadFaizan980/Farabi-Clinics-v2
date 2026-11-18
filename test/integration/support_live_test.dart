@Tags(['live'])
library;

import 'dart:io';

import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/models/support/support_models.dart';
import 'package:farabi_booking_app/data/network/api_client.dart';
import 'package:farabi_booking_app/data/network/end_points.dart';
import 'package:farabi_booking_app/repos/support/support_repo.dart';
import 'package:farabi_booking_app/repos/support/support_repo_imp.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = null);

  setUp(() async {
    await AppDi.reset();
    final session = AuthSession(FakeLocalData());
    await session.restore();
    AppDi.locator
      ..registerSingleton<AuthSession>(session)
      ..registerSingleton<ApiClient>(
        ApiClient(
          session: session,
          baseUrl: EndPoints.baseUrlDev,
          enableLogging: false,
        ),
      )
      ..registerSingleton<SupportRepo>(SupportRepoImp());
  });

  tearDown(() => AppDi.reset());

  test('careers load with real postings', () async {
    final response = await AppDi.locator<SupportRepo>().jobs();
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data, isNotEmpty);
    expect(response.data!.first.names.display('en'), isNotEmpty);
  });

  test('career departments load and de-duplicate', () async {
    final response = await AppDi.locator<SupportRepo>().departments();
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data, isNotEmpty);
    expect(response.data!.toSet().length, response.data!.length);
  });

  test('blog returns an empty list rather than an error', () async {
    final response = await AppDi.locator<SupportRepo>().posts();
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data, isEmpty);
  });

  test('contact-us reaches the server over multipart', () async {
    // deliberately invalid so this never files a real enquiry — the point is
    // to prove the multipart request is accepted and validated server-side
    final response = await AppDi.locator<SupportRepo>().submitContact(
      const ContactRequestModel(
        name: '',
        phone: '',
        branchId: -1,
        serviceId: -1,
        aboutUs: '',
      ),
    );

    expect(response.success, isFalse);
    // a 422 means the body parsed; a 415 or 500 would mean the encoding is wrong
    expect(response.statusCode, 422);
    expect(response.fieldErrors, isNotEmpty);
  });
}
