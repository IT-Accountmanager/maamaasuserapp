// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/food/category_dish.dart';
import '../../Models/food/dish.dart';
import '../../Models/food/food_categries_model.dart';
import '../../Models/food/restaurent_banner_model.dart';
import '../../screens/Food&beverages/Menu/menu_screen.dart';
import 'Apiclient.dart';

Future<String> _buildUserContextQuery() async {
  final prefs = await SharedPreferences.getInstance();

  final userId = prefs.getInt('userId');
  final lat = prefs.getDouble('latitude');
  final lng = prefs.getDouble('longitude');

  // ✅ Logged-in user
  if (userId != null && userId > 0 && !ApiClient.isGuestUser) {
    final query = "userId=$userId";

    return query;
  }

  // ✅ Guest user with location
  if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
    final query = "latitude=$lat&longitude=$lng";

    return query;
  }

  return "";
}

class Authservice {
  Future<List<FoodCategory>> fetchFoodCategories() async {
    final query = await _buildUserContextQuery();
    final url = "api/dish/dish/getall/categeory?$query";

    final response = await ApiClient.get(
      url,
      service: "food",
      requiresAuth: false,
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> decoded = json.decode(response.body);

        return decoded.map((e) => FoodCategory.fromJson(e)).toList();
      } catch (e, st) {
        throw Exception('Parsing failed');
      }
    } else {
      throw Exception('Failed to load dishes');
    }
  }

  static Future<List<Restaurent_Banner>> fetchnearbyresturents() async {
    final query = await _buildUserContextQuery();
    final endpoint = "api/user/nearby-vendors/get?$query";

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        return jsonData
            .map((item) => Restaurent_Banner.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e, st) {
      throw Exception('Failed to load banners');
    }
  }

  Future<Restaurent_Banner> fetchVendorBanner(int vendorId) async {
    final endpoint = 'api/banner/$vendorId';

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
        requiresAuth: false,
      );

      if (response.body.isNotEmpty) {
      } else {}

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final banner = Restaurent_Banner.fromJson(jsonData);

        return banner;
      } else {
        throw Exception('Failed to load banner data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load banner data');
    }
  }

  static Future<MenuResponse> fetchMenu(int vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    String endpoint;

    // ✅ If logged in → send vendorId + userId
    if (userId != null && userId > 0) {
      endpoint =
          "api/dish/getby/vendor/user/dishes?vendorId=$vendorId&userId=$userId";
    }
    // ✅ If guest → send only vendorId
    else {
      endpoint = "api/dish/getby/vendor/user/dishes?vendorId=$vendorId";
    }

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final List<CategoryDish> categories = [];
        final List<Dish> dishes = [];

        for (final item in data) {
          if (item['isCategory'] == true || item['parentId'] == 0) {
            categories.add(CategoryDish.fromJson(item));
          } else {
            dishes.add(Dish.fromJson(item));
          }
        }

        return MenuResponse(categories: categories, dishes: dishes);
      }

      final errorJson = jsonDecode(response.body);
      return MenuResponse(
        categories: [],
        dishes: [],
        hasError: true,
        errorMessage: errorJson['message'] ?? 'Something went wrong',
      );
    } catch (e) {
      return MenuResponse(
        categories: [],
        dishes: [],
        hasError: true,
        errorMessage: 'Unable to load menu. Please try again.',
      );
    }
  }
}
