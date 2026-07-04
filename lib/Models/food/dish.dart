class Dish {
  final int dishId;
  final String? dishName;
  final String? tag;
  final String? stock;
  final int? parentId;
  final int? categoryId;

  final double? price;
  final double? deliveryPrice;
  final double? effectivePrice;
  final double? gst;
  final double? packingCharges;

  final String? dishImage;
  final String? description;
  final String? menuStatus;
  final String? chefType;
  final String? dishCode;
  final String? offerType;
  final String? resetQuantity;
  final String? companyName;

  int? stockQuantity;
  final int consumedQuantity;
  final int balanceQuantity;

  final num discount;

  final bool? includeGst;
  final bool? unlimited;
  final bool? promotionAvailable;

  final String? promotionText;
  final String? discountEndDate;

  final int? vendorId;

  final List<Addon> addons;

  Dish({
    required this.dishId,
    this.dishName,
    this.tag,
    this.stock,
    this.parentId,
    this.categoryId,
    this.price,
    this.deliveryPrice,
    this.effectivePrice,
    this.gst,
    this.packingCharges,
    this.dishImage,
    this.description,
    this.menuStatus,
    this.chefType,
    this.dishCode,
    this.offerType,
    this.resetQuantity,
    this.companyName,
    this.stockQuantity,
    required this.consumedQuantity,
    required this.balanceQuantity,
    required this.discount,
    this.includeGst,
    this.unlimited,
    this.promotionAvailable,
    this.promotionText,
    this.discountEndDate,
    this.vendorId,
    required this.addons,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      dishId: json['dishId'],
      dishName: json['dishName'],
      tag: json['tag'],
      stock: json['stock'],
      parentId: json['parentId'],
      categoryId: json['categoryId'],

      price: (json['price'] as num?)?.toDouble(),
      deliveryPrice: (json['deliveryPrice'] as num?)?.toDouble(),
      effectivePrice: (json['effectivePrice'] as num?)?.toDouble(),
      gst: (json['gst'] as num?)?.toDouble(),
      packingCharges: (json['packingCharges'] as num?)?.toDouble(),

      dishImage: json['dishImage']?.toString(),
      description: json['description']?.toString(),

      menuStatus: json['menuStatus'],
      chefType: json['chefType'],
      dishCode: json['dishCode'],
      offerType: json['offerType']?.toString(),
      resetQuantity: json['resetQuantity']?.toString(),
      companyName: json['companyName']?.toString(),

      stockQuantity: json['stockQuantity'],
      consumedQuantity: json['consumedQuantity'] ?? 0,
      balanceQuantity: json['balanceQuantity'] ?? 0,

      discount: json['discount'] ?? 0,

      includeGst: json['includeGst'],
      unlimited: json['unlimited'],
      promotionAvailable: json['promotionAvailable'] ?? false,
      promotionText: json['promotionText'] ?? '',
      discountEndDate: json['discountEndDate']?.toString(),

      vendorId: json['vendorId'],

      addons:
          (json['addons'] as List<dynamic>?)
              ?.map((e) => Addon.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Addon {
  final int addonId;
  final String addonName;
  final double addonPrice;
  final bool available;

  Addon({
    required this.addonId,
    required this.addonName,
    required this.addonPrice,
    required this.available,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      addonId: json['addonId'],
      addonName: json['addonName'] ?? '',
      addonPrice: (json['addonPrice'] as num?)?.toDouble() ?? 0.0,
      available: json['available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'addonId': addonId,
    'addonName': addonName,
    'addonPrice': addonPrice,
    'available': available,
  };
}
