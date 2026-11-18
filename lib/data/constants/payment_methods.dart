/// maps a gateway slug from the api onto the `payment_method` value that
/// POST /bookings accepts. captured from the website's own constants.
class PaymentMethods {
  PaymentMethods._();

  static const Map<String, String> _bySlug = {
    'cash': 'cash',
    'paytabs': 'paytabs',
    'insurance': 'insurance',
  };

  /// gateways that complete without leaving the app
  static const Set<String> immediate = {'cash', 'insurance', 'free'};

  static String forSlug(String slug) => _bySlug[slug] ?? slug;

  static bool isImmediate(String slug) => immediate.contains(forSlug(slug));
}
