class Discount {
  final int? dishId;
  final String? dishName;
  final double  discount;
  final String? tag;
  final String? stock;
  final int? parentId;
  final double? price;
  final double? effectivePrice;
  final String? dishImage;
  final String ?description;
  final int balanceQuantity;
  final int stockQuantity;

  Discount({
    this.dishId,
    this.dishName,
    required this.discount,
    this.tag,
    this.stock,
    this.parentId,
    this.price,
    this.effectivePrice,
    this.dishImage,
    this.description,
    required this.balanceQuantity,
    required this.stockQuantity,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      dishId: json['dishId'] as int?,
      dishName: json['dishName'] as String?,
      discount: (json['discount'] ?? 0).toDouble(),
      price: (json['price']?? 0).toDouble(),
      tag: json['tag'],
      stock: json['stock'],
      parentId: json['parentId'],
      effectivePrice: json['effectivePrice']?.toDouble(),
      dishImage: json['dishImage']?.toString(),
      description: json['description']?.toString(),
      balanceQuantity: json['balanceQuantity']?? 0,
      stockQuantity: json['stockQuantity']?? 0,
    );
  }
}
