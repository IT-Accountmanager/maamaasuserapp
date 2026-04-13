import 'package:url_launcher/url_launcher.dart';

// ignore: camel_case_types
class phonecall {
  static Future<void> makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}