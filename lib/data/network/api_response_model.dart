/// every api outcome collapses into this, so no view model ever branches on a
/// status code or digs through an error envelope.
class ApiResponseModel<T> {
  const ApiResponseModel({
    required this.success,
    this.data,
    this.messages = const [],
    this.fieldErrors = const {},
    this.statusCode,
    this.meta,
  });

  final bool success;
  final T? data;

  /// the api always returns `message` as a list of strings
  final List<String> messages;

  /// populated only on a 422. keyed by the request field name, so a view model
  /// can map a server error straight back onto the input that caused it.
  final Map<String, List<String>> fieldErrors;

  final int? statusCode;

  /// paging envelope, when the endpoint pages:
  /// { per_page, total, curr_page, last_page, next_page_url }
  final Map<String, dynamic>? meta;

  bool get isUnauthorised => statusCode == 401;
  bool get isValidationError => statusCode == 422;

  /// first message, or null. the usual thing a screen wants to show.
  String? get message => messages.isEmpty ? null : messages.first;

  ApiResponseModel<R> mapData<R>(R? Function(T value) transform) {
    final value = data;
    return ApiResponseModel<R>(
      success: success,
      data: value == null ? null : transform(value),
      messages: messages,
      fieldErrors: fieldErrors,
      statusCode: statusCode,
      meta: meta,
    );
  }

  factory ApiResponseModel.failure({
    required List<String> messages,
    int? statusCode,
    Map<String, List<String>> fieldErrors = const {},
  }) =>
      ApiResponseModel<T>(
        success: false,
        messages: messages,
        statusCode: statusCode,
        fieldErrors: fieldErrors,
      );
}
