class CategoryDish{
  final int dishId;
  final int? vendorId;
  final double price;
  final double effectivePrice;
  final String? dishName;
  final String? tag;
  final String? stock; // <-- Changed from int? to String?
  final int? parentId;
  final String? menuStatus;
  final String? chefType;
  final double gst;
  final double packingCharges;
  final String? dishImage;
  final String ?description;// nullable
  final int? balanceQuantity;




  CategoryDish({
    required this.dishId,
    this.vendorId,
    required this.price,
    required this.effectivePrice,
    required this.gst,
    required this.packingCharges,
    this.dishName,
    this.tag,
    this.stock,
    this.parentId,
    this.menuStatus,
    this.chefType,
    this.dishImage,
    this.description,
    this.balanceQuantity,

  });

  factory CategoryDish.fromJson(Map<String, dynamic> json) {
    return CategoryDish(
      dishId: json['dishId'],
      vendorId: json['vendorId'],
      price: (json['price'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      packingCharges: (json['packingCharges'] ?? 0).toDouble(),
      effectivePrice: (json['effectivePrice'] ?? 0).toDouble(),
      dishName: json['dishName'],
      tag: json['tag'],
      stock: json['stock'],
      parentId: json['parentId'],
      menuStatus: json['menuStatus'],
      chefType: json['chefType'],
      dishImage: json['dishImage'],
      description: json['description']?.toString(),
        balanceQuantity:json['balanceQuantity']
    );
  }

}
