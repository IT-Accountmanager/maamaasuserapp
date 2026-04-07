class Dish {
  final int dishId;
  final String? dishName;
  final String? tag;
  final String? stock;
  final int? parentId;
  final double? price;
  final double? effectivePrice;
  final String? dishImage;
  final String ?description;
  // bool? favorite;
  int? stockQuantity;
  final int balanceQuantity;
  final num discount;
  final String menuStatus;

  Dish({
    required this.dishId,
    this.dishName,
    this.tag,
    this.stock,
    this.parentId,
    this.price,
    this.effectivePrice,
    this.dishImage,
    this.stockQuantity,
    this.description,
    // this.favorite = false,
    required this.balanceQuantity,
    required this.discount,
    required this.menuStatus
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      dishId: json['dishId'],
      dishName: json['dishName'],
      tag: json['tag'],
      stock: json['stock'],
      parentId: json['parentId'],
      stockQuantity: json['stockQuantity'],
      price: json['price']?.toDouble(),
      effectivePrice: json['effectivePrice']?.toDouble(),
      dishImage: json['dishImage']?.toString(),
      description: json['description']?.toString(),
      // favorite: json['favorite'] ?? false,
      balanceQuantity: json['balanceQuantity'] ?? 0,
      discount: json['discount']?? 0,
      menuStatus: json['menuStatus'],
    );
  }
}
