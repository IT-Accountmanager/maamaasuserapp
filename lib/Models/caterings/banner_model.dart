// ignore: camel_case_types
class catering_BannerModel {
  final int bannerId;
  final int vendorId;
  final String companyName;
  final String establishedYear;
  final String companyLogo;
  final String companyBanner;
  final String whatsappLink;
  final String instagramLink;
  final String facebookLink;
  final String twitterLink;
  final num distance;


  catering_BannerModel({
    required this.bannerId,
    required this.vendorId,
    required this.companyName,
    required this.establishedYear,
    required this.companyLogo,
    required this.companyBanner,
    required this.facebookLink,
    required this.instagramLink,
    required this.twitterLink,
    required this.whatsappLink,
    required this.distance,
  });

  factory catering_BannerModel.fromJson(Map<String, dynamic> json) {
    return catering_BannerModel(
      bannerId: json['bannerId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      companyName: json['companyName'] ?? '',
      establishedYear: json['establishedYear']?.toString() ?? '',
      companyLogo: json['companyLogo'] ?? '',
      companyBanner: json['companyBanner'] ?? '',
      facebookLink: json['facebookLink'] ?? '',
      instagramLink: json['instagramLink'] ?? '',
      whatsappLink: json['whatsappLink'] ?? '',
      twitterLink: json['twitterLink'] ?? '',
      distance: json['distance'] ?? 0,
    );
  }
}
