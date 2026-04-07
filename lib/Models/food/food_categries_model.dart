class FoodCategory {
  final String name;
  final String? image;
  final List<int> vendorIds;

  FoodCategory({
    required this.name,
    this.image,
    required this.vendorIds,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      name: json['categoryName'].toString().trim(),
      image: json['image'],
      vendorIds: List<int>.from(json['vendorIds'] ?? []),
    );
  }
}