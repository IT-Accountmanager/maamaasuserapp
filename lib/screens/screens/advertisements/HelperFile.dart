import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class advertisement {

  static Future<String> createDynamicLink(String campaignId) async {
    final dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: 'https://yourapp.page.link',
      link: Uri.parse('https://yourapp.com/campaign?id=$campaignId'),
      androidParameters: AndroidParameters(
        packageName: 'com.yourapp.package',
        minimumVersion: 1,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check this campaign!',
        description: 'Exciting offer waiting for you!',
      ),
    );

    final shortLink = await FirebaseDynamicLinks.instance.buildShortLink(
      dynamicLinkParams,
    );

    return shortLink.shortUrl.toString();
  }
}
