class Restaurent_Banner {
  final int vendorId;
  final int bannerId;
  final String companyName;
  final String establishedYear;
  final String whatsappLink;
  final String instagramLink;
  final String facebookLink;
  final String twitterLink;
  final String youtubeLink;
  final String linkedinLink;
  final String companyBanner;
  final String companyLogo;
  final String startTime;
  final String lastTime;
  final String city;
  final String appType;
  final String type; // ✅ renamed (clean)
  final List<String> orderTypes;
  final String addressLine;
  final double distance; // ✅ facebookLink
  final double ratings;  // ✅ NON-NULL youtubeLink
  final String position;

  Restaurent_Banner({
    required this.bannerId,
    required this.companyName,
    required this.establishedYear,
    required this.whatsappLink,
    required this.instagramLink,
    required this.facebookLink,
    required this.twitterLink,
    required this.youtubeLink,
    required this.linkedinLink,
    required this.companyBanner,
    required this.companyLogo,
    required this.startTime,
    required this.lastTime,
    required this.vendorId,
    required this.city,
    required this.orderTypes,
    required this.addressLine,
    required this.appType,
    required this.type,
    required this.distance,
    required this.ratings,
    required this.position,
  });

  factory Restaurent_Banner.fromJson(Map<String, dynamic> json) {
    return Restaurent_Banner(
      bannerId: json['bannerId'] ?? 0,
      companyName: json['companyName'] ?? "",
      establishedYear: json['establishedYear'] ?? "",
      whatsappLink: json['whatsappLink'] ?? "",
      instagramLink: json['instagramLink'] ?? "",
      facebookLink: json['facebookLink'] ?? "",
      twitterLink: json['twitterLink'] ?? "",
      youtubeLink:json['youtubeLink'] ?? '',
      linkedinLink:json['linkedinLink']?? '',
      companyBanner: json['companyBanner'] ?? "",
      companyLogo: json['companyLogo'] ?? "",
      startTime: json['startTime']?? '',
      lastTime: json['lastTime']?? '',
      vendorId: json['vendorId'] ?? 0,
      city: json['city'] ?? "",
      orderTypes: List<String>.from(json['orderTypes'] ?? []),
      addressLine: json['addressLine'] ?? "",
      appType: json['appType'] ?? "",

      // ✅ FIXED KEY
      type: json['type']?.toString() ?? "",

      // ✅ FORCE DOUBLE
      distance: (json['distance'] ?? 0).toDouble(),

      // ✅ SAFE DOUBLE
      ratings: (json['ratings'] ?? 0).toDouble(),

      position: json["position"]?.toString() ?? "",
    );
  }
}