/// saudi mobile normalisation. the api expects the national form *with* the
/// leading zero (0564772491) — verified against the live login endpoint.
class MobileNumber {
  MobileNumber._();

  static const String saudiDialCode = '+966';

  static String digitsOnly(String input) =>
      input.replaceAll(RegExp(r'\D'), '');

  /// accepts 05XXXXXXXX, 5XXXXXXXX, 9665XXXXXXXX or +9665XXXXXXXX and returns
  /// the 10-digit national form.
  static String national(String input) {
    var digits = digitsOnly(input);
    if (digits.startsWith('966')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '0$digits';
  }

  static bool isValidSaudi(String input) =>
      RegExp(r'^05\d{8}$').hasMatch(national(input));
}
