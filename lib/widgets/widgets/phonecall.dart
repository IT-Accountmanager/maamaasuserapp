import 'package:url_launcher/url_launcher.dart';

// ignore: camel_case_types
// class phonecall {
//   static const String supportNumber = '+919063888450';
//   static Future<void> makePhoneCall(String phoneNumber) async {
//     final uri = Uri.parse('tel:$phoneNumber');
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }
// }

class phonecall {
  static const String supportNumber = '+919154949218';

  static Future<void> makePhoneCall([String? phoneNumber]) async {
    final uri = Uri.parse('tel:${phoneNumber ?? supportNumber}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
