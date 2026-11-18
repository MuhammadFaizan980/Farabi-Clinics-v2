@Tags(['live'])
library;

import 'dart:io';

import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/network/api_client.dart';
import 'package:farabi_booking_app/data/network/end_points.dart';
import 'package:farabi_booking_app/repos/discovery/branches_repo.dart';
import 'package:farabi_booking_app/repos/discovery/branches_repo_imp.dart';
import 'package:farabi_booking_app/repos/discovery/doctors_repo.dart';
import 'package:farabi_booking_app/repos/discovery/doctors_repo_imp.dart';
import 'package:farabi_booking_app/repos/discovery/regions_repo.dart';
import 'package:farabi_booking_app/repos/discovery/regions_repo_imp.dart';
import 'package:farabi_booking_app/repos/discovery/services_repo.dart';
import 'package:farabi_booking_app/repos/discovery/services_repo_imp.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

/// phase 3's data layer against the real dev api.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = null);

  late AuthSession session;

  setUp(() async {
    await AppDi.reset();
    session = AuthSession(FakeLocalData());
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
      ..registerSingleton<RegionsRepo>(RegionsRepoImp())
      ..registerSingleton<ServicesRepo>(ServicesRepoImp())
      ..registerSingleton<BranchesRepo>(BranchesRepoImp())
      ..registerSingleton<DoctorsRepo>(DoctorsRepoImp());
  });

  tearDown(() => AppDi.reset());

  test('regions load and localise', () async {
    final response = await AppDi.locator<RegionsRepo>().regions();
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data, isNotEmpty);
    final riyadh = response.data!.firstWhere((r) => r.id == 5);
    expect(riyadh.names.display('en'), 'Riyadh');
    expect(riyadh.names.display('ar'), isNotEmpty);
  });

  test('country scoping really filters — sa has branches, eg does not',
      () async {
    final sa = await AppDi.locator<BranchesRepo>().branches();
    expect(sa.success, isTrue);
    expect(sa.data, isNotEmpty);

    await session.setCountryCode('EG');
    final eg = await AppDi.locator<BranchesRepo>().branches();
    expect(eg.success, isTrue);
    expect(eg.data, isEmpty, reason: 'country-code scopes the data');
  });

  test('main services load', () async {
    final response = await AppDi.locator<ServicesRepo>().mainServices();
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data, isNotEmpty);
  });

  test('doctors load and paginate without crashing on a null meta', () async {
    final response = await AppDi.locator<DoctorsRepo>().doctors(page: 1);
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data!.items, isNotEmpty);
    // meta is null on the test host — must surface as unknown, not zero
    expect(response.data!.total, isNull);
  });

  test('doctor detail carries per-branch working hours', () async {
    final response = await AppDi.locator<DoctorsRepo>().doctorDetail(3);
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data!.id, 3);
    expect(response.data!.branches, isNotEmpty);
  });

  test('branch detail resolves', () async {
    final response = await AppDi.locator<BranchesRepo>().branchDetail(8);
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data!.id, 8);
  });

  test('service detail parses the decimal price string', () async {
    final response = await AppDi.locator<ServicesRepo>().serviceDetail(19);
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data!.price, 45.0);
  });

  test('bookable services for a doctor narrow correctly', () async {
    final response =
        await AppDi.locator<ServicesRepo>().services(doctorId: 3);
    expect(response.success, isTrue, reason: response.message ?? '');
    expect(response.data!.map((s) => s.id), contains(19));
  });

  test('an unknown id returns a clean 404 rather than throwing', () async {
    final response = await AppDi.locator<DoctorsRepo>().doctorDetail(999999);
    expect(response.success, isFalse);
    expect(response.statusCode, 404);
    expect(response.message, isNotNull);
  });

  test('arabic lang header localises the payload', () async {
    await session.setLanguageCode('ar');
    final response = await AppDi.locator<RegionsRepo>().regions();
    expect(response.success, isTrue);
    final riyadh = response.data!.firstWhere((r) => r.id == 5);
    // `name` is resolved server-side from the lang header
    expect(riyadh.names.nameAr, isNotNull);
    expect(riyadh.names.display('ar'), riyadh.names.nameAr);
  });
}
