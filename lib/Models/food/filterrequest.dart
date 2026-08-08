class VendorFilterRequest {
  final double? minPrice;
  final double? maxPrice;
  final double? minimumRating;
  final bool? bogoOffer;
  final bool? dealsOfDay;
  final bool? goldOffer;
  final bool? pureVeg;
  final bool? noPackingCharges;
  final bool? lowPlasticPackaging;
  final String? orderType;
  final double? latitude;
  final double? longitude;

  VendorFilterRequest({
    this.minPrice,
    this.maxPrice,
    this.minimumRating,
    this.bogoOffer,
    this.dealsOfDay,
    this.goldOffer,
    this.pureVeg,
    this.noPackingCharges,
    this.lowPlasticPackaging,
    this.orderType,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      "minPrice": minPrice,
      "maxPrice": maxPrice,
      "minimumRating": minimumRating,
      "bogoOffer": bogoOffer,
      "dealsOfDay": dealsOfDay,
      "goldOffer": goldOffer,
      "pureVeg": pureVeg,
      "noPackingCharges": noPackingCharges,
      "lowPlasticPackaging": lowPlasticPackaging,
      "orderType": orderType,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}