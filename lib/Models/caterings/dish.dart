class Dish {
  final int dishId;
  final String dishName;
  final String dishDescription;
  final num dishPrice;
  final String dishImage;
  final num discountPercentage;
  final int parentId;
  final num effectivePrice;
  final String dishType;

  Dish({
    required this.dishId,
    required this.dishName,
    required this.parentId,
    required this.dishDescription,
    required this.dishPrice,
    required this.dishImage,
    required this.discountPercentage,
    required this.effectivePrice,
    required this.dishType,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      dishId: json['dishId']?? 0,
      dishName: json['dishName']?? '',
      parentId: json['parentId']?? 0,
      dishDescription: json['dishDescription']?? '',
      dishPrice: json['dishPrice']?? 0,
      dishImage: json['dishImage']??'',
      discountPercentage: json['discountPercentage']?? 0,
      dishType: json['dishType']??'',
      effectivePrice: json['effectivePrice']??0,
    );
  }
}