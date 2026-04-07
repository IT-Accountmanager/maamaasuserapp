// ignore: camel_case_types
class grocery_Banner {
  final int bannerId;
  final String companyName;
  final String establishedYear;
  final String whatsappLink;
  final String instagramLink;
  final String facebookLink;
  final String twitterLink;
  final String companyBanner;
  final String companyLogo;
  final int vendorId;
  final String city;
  final List<String> orderTypes;
  final String addressLine;


  grocery_Banner({
    required this.bannerId,
    required this.companyName,
    required this.establishedYear,
    required this.whatsappLink,
    required this.instagramLink,
    required this.facebookLink,
    required this.twitterLink,
    required this.companyBanner,
    required this.companyLogo,
    required this.vendorId,
    required this.city,
    required this.orderTypes,
    required this.addressLine
  });

  factory grocery_Banner.fromJson(Map<String, dynamic> json) {
    return grocery_Banner(
      bannerId: json['bannerId'],
      companyName: json['companyName'],
      establishedYear: json['establishedYear'],
      whatsappLink: json['whatsappLink'],
      instagramLink: json['instagramLink'],
      facebookLink: json['facebookLink'],
      twitterLink: json['twitterLink'],
      companyBanner: json['companyBanner'],
      companyLogo: json['companyLogo'], // 👈 New
      vendorId: json['vendorId'],
      city: json['city'] ?? '',
      orderTypes: List<String>.from(json['orderTypes'] ?? []),
      addressLine: json['addressLine'] ?? '',
    );
  }
}

