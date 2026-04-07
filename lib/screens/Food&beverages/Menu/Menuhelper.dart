import '../../../Models/caterings/dish.dart';
import '../../../Models/food/category_dish.dart';

class MenuResponse {
  final List<CategoryDish> categories;
  final List<Dish> dishes;
  final String? errorMessage;
  final bool hasError;

  MenuResponse({
    required this.categories,
    required this.dishes,
    this.errorMessage,
    this.hasError = false,
  });
}

enum BannerContentType { none, about, gallery }