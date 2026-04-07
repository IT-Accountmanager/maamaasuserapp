class FavoriteDish {
  final int? favId;
  final int? dishId;
  final int? userId;
  final int? vendorId;
  final String? dishName;
  final String? description;
  final double? price;
  final double? gst;
  final double? packingCharges;
  final double? effectivePrice;
  final String? dishImage;
  final String? stock;
  final int balanceQuantity;

  FavoriteDish({
    this.favId,
    this.dishId,
    this.vendorId,
    this.userId,
    this.dishName,
    this.description,
    this.price,
    this.gst,
    this.packingCharges,
    this.effectivePrice,
    this.dishImage,
    this.stock,
    required this.balanceQuantity,
  });

  factory FavoriteDish.fromJson(Map<String, dynamic> json) {
    return FavoriteDish(
      favId: json['favId'],
      dishId: json['dishId'],
      userId: json['userId'],
      vendorId: json['vendorId'],
      dishName: json['dishName'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble(),
      gst: (json['gst'] as num?)?.toDouble(),
      packingCharges: (json['packingCharges'] as num?)?.toDouble(),
      effectivePrice: (json['effectivePrice'] as num?)?.toDouble(),
      dishImage: json['dishImage'],
      stock: json['stock'],
      balanceQuantity: json['balanceQuantity'] ?? 0,
    );
  }
}
