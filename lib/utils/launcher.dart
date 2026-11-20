import 'package:url_launcher/url_launcher.dart';

/// opens the phone dialler for [phone]; a number that cannot be launched is
/// ignored rather than throwing
Future<void> dial(String phone) async {
  final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (cleaned.isEmpty) return;
  final uri = Uri(scheme: 'tel', path: cleaned);
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

/// opens a web address (a job-description file, for instance) outside the app
Future<void> openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
