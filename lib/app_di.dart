import 'package:get_it/get_it.dart';

import 'data/app_local_data.dart';
import 'data/auth_session.dart';
import 'data/base/app_base_model.dart';
import 'data/network/api_client.dart';
import 'repos/auth/login_repo.dart';
import 'repos/auth/login_repo_imp.dart';
import 'repos/auth/otp_repo.dart';
import 'repos/auth/otp_repo_imp.dart';
import 'repos/auth/password_repo.dart';
import 'repos/auth/password_repo_imp.dart';
import 'repos/auth/profile_repo.dart';
import 'repos/auth/profile_repo_imp.dart';
import 'repos/auth/register_repo.dart';
import 'repos/auth/register_repo_imp.dart';
import 'repos/discovery/branches_repo.dart';
import 'repos/discovery/branches_repo_imp.dart';
import 'repos/discovery/doctors_repo.dart';
import 'repos/discovery/doctors_repo_imp.dart';
import 'repos/discovery/regions_repo.dart';
import 'repos/discovery/regions_repo_imp.dart';
import 'repos/discovery/services_repo.dart';
import 'repos/discovery/services_repo_imp.dart';
import 'repos/auth/profile_update_repo.dart';
import 'repos/auth/profile_update_repo_imp.dart';
import 'repos/booking/bookings_repo.dart';
import 'repos/booking/bookings_repo_imp.dart';
import 'repos/booking/checkout_repo.dart';
import 'repos/booking/checkout_repo_imp.dart';
import 'repos/booking/slots_repo.dart';
import 'repos/booking/slots_repo_imp.dart';
import 'repos/support/support_repo.dart';
import 'repos/support/support_repo_imp.dart';

/// single place every dependency is registered.
class AppDi {
  AppDi._();

  static final GetIt locator = GetIt.instance;

  /// core singletons first, and the session is restored *before* this returns,
  /// so no screen can fire a request without the right token, language and
  /// country on it.
  static Future<void> initDi({
    required String baseUrl,
    required bool enableLogging,
  }) async {
    final localData = AppLocalData();
    await localData.init();
    locator.registerSingleton<AppLocalData>(localData);

    final session = AuthSession(localData);
    await session.restore();
    locator.registerSingleton<AuthSession>(session);

    final apiClient = ApiClient(
      session: session,
      baseUrl: baseUrl,
      enableLogging: enableLogging,
    );
    locator.registerSingleton<ApiClient>(apiClient);

    locator.registerSingleton<AppBaseModel>(AppBaseModel());

    _registerRepos();
  }

  static void _registerRepos() {
    locator.registerLazySingleton<LoginRepo>(LoginRepoImp.new);
    locator.registerLazySingleton<RegisterRepo>(RegisterRepoImp.new);
    locator.registerLazySingleton<OtpRepo>(OtpRepoImp.new);
    locator.registerLazySingleton<PasswordRepo>(PasswordRepoImp.new);
    locator.registerLazySingleton<ProfileRepo>(ProfileRepoImp.new);

    locator.registerLazySingleton<RegionsRepo>(RegionsRepoImp.new);
    locator.registerLazySingleton<ServicesRepo>(ServicesRepoImp.new);
    locator.registerLazySingleton<BranchesRepo>(BranchesRepoImp.new);
    locator.registerLazySingleton<DoctorsRepo>(DoctorsRepoImp.new);

    locator.registerLazySingleton<SlotsRepo>(SlotsRepoImp.new);
    locator.registerLazySingleton<CheckoutRepo>(CheckoutRepoImp.new);
    locator.registerLazySingleton<BookingsRepo>(BookingsRepoImp.new);
    locator.registerLazySingleton<ProfileUpdateRepo>(ProfileUpdateRepoImp.new);
    locator.registerLazySingleton<SupportRepo>(SupportRepoImp.new);
  }

  /// test seam — lets a test swap in fakes without booting the app.
  static Future<void> reset() => locator.reset();
}
