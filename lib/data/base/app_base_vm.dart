import 'package:stacked/stacked.dart';

import '../../app_di.dart';
import '../network/api_response_model.dart';

/// base for every view model. a view model talks only to repos resolved from
/// get_it — never to the api client or dio.
abstract class AppBaseVm extends BaseViewModel {
  T repo<T extends Object>() => AppDi.locator<T>();

  String? _errorMessage;
  Map<String, List<String>> _fieldErrors = const {};

  String? get errorMessage => _errorMessage;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  bool get hasFailure => _errorMessage != null;

  /// server-side error for a specific input, if any.
  String? fieldError(String field) {
    final messages = _fieldErrors[field];
    if (messages == null || messages.isEmpty) return null;
    return messages.first;
  }

  void setErrorMessage(String? message, {bool notify = true}) {
    _errorMessage = message;
    if (notify) notifyListeners();
  }

  void clearFailure({bool notify = true}) {
    _errorMessage = null;
    _fieldErrors = const {};
    if (notify) notifyListeners();
  }

  /// pulls the normalised failure out of a response and onto this view model.
  void captureFailure(ApiResponseModel<dynamic> response,
      {bool notify = true}) {
    _errorMessage = response.message ?? 'unexpected';
    _fieldErrors = response.fieldErrors;
    if (notify) notifyListeners();
  }
}
