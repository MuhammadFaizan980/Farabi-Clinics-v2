import '../../app_di.dart';
import '../app_local_data.dart';
import '../auth_session.dart';
import '../network/api_client.dart';

/// gives every repo its collaborators without constructor noise. repos must
/// never contain widgets, BuildContext or navigation.
mixin class AppBaseRepo {
  ApiClient get apiClient => AppDi.locator<ApiClient>();

  AppLocalData get appLocalData => AppDi.locator<AppLocalData>();

  AuthSession get authSession => AppDi.locator<AuthSession>();
}
