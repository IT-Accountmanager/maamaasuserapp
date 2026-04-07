class BannerItemtoprestaurents {
  final int bannerId;
  final String companyName;
  final String? establishedYear;
  final String? whatsappLink;
  final String? instagramLink;
  final String? facebookLink;
  final String? twitterLink;
  final String? companyLogo;
  final String? companyBanner;
  final int vendorId;
  final List<String> orderTypes;
  final String? city;
  final String? appType;
  // ignore: non_constant_identifier_names
  final String Type;
  final String? state;
  final double? latitude;
  final double? longitude;
  final int? pincode;
  final String? fullAddress;
  final String? addressLine;
  final bool? restaurantStatus;

  BannerItemtoprestaurents({
    required this.bannerId,
    required this.companyName,
    this.establishedYear,
    this.whatsappLink,
    this.instagramLink,
    this.facebookLink,
    this.twitterLink,
    this.companyLogo,
    this.companyBanner,
    required this.vendorId,
    required this.orderTypes,
    this.city,
    this.appType,
    this.state,
    this.latitude,
    this.longitude,
    this.pincode,
    this.fullAddress,
    this.addressLine,
    this.restaurantStatus,
    // ignore: non_constant_identifier_names
    required this.Type,
  });

  /// ✅ Factory constructor to parse JSON
  factory BannerItemtoprestaurents.fromJson(Map<String, dynamic> json) {
    return BannerItemtoprestaurents(
      bannerId: json['bannerId'] ?? 0,
      companyName: json['companyName'] ?? '',
      establishedYear: json['establishedYear'],
      whatsappLink: json['whatsappLink'],
      instagramLink: json['instagramLink'],
      facebookLink: json['facebookLink'],
      twitterLink: json['twitterLink'],
      companyLogo: json['companyLogo'],
      companyBanner: json['companyBanner'],
      vendorId: json['vendorId'] ?? 0,
      orderTypes: (json['orderTypes'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      city: json['city'],
      appType: json['appType'],
      Type: json['Type']?.toString() ?? "",
      state: json['state'],
      latitude: (json['latitude'] != null)
          ? json['latitude'].toDouble()
          : null,
      longitude: (json['longitude'] != null)
          ? json['longitude'].toDouble()
          : null,
      pincode: json['pincode'],
      fullAddress: json['fullAddress'],
      addressLine: json['addressLine'],
      restaurantStatus: json['RestaurentStatus'] ?? false,
    );
  }

  /// ✅ Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'bannerId': bannerId,
      'companyName': companyName,
      'establishedYear': establishedYear,
      'whatsappLink': whatsappLink,
      'instagramLink': instagramLink,
      'facebookLink': facebookLink,
      'twitterLink': twitterLink,
      'companyLogo': companyLogo,
      'companyBanner': companyBanner,
      'vendorId': vendorId,
      'orderTypes': orderTypes,
      'city': city,
      'appType': appType,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'pincode': pincode,
      'fullAddress': fullAddress,
      'addressLine': addressLine,
      'RestaurentStatus': restaurantStatus,
    };
  }
}
