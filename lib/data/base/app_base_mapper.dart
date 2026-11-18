/// raw map/list → model conversion lives only in mappers. repos and view models
/// never parse json.
abstract class AppBaseMapper {
  const AppBaseMapper();

  static Map<String, dynamic> asMap(dynamic raw) =>
      raw is Map ? Map<String, dynamic>.from(raw) : const {};

  static List<Map<String, dynamic>> asList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  static String? asString(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    return '$raw';
  }

  static int? asInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  /// prices arrive as decimal strings ("45.00"), never as numbers.
  static double? asDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  static bool asBool(dynamic raw, {bool fallback = false}) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) return raw == 'true' || raw == '1';
    return fallback;
  }

  /// every timestamp the api returns is utc with a trailing Z.
  static DateTime? asUtcDateTime(dynamic raw) {
    final value = asString(raw);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }
}
