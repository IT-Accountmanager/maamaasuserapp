import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  //
  //   debugPrint("🔍 UserContext Debug:");
  //   debugPrint("➡️ userId: $userId");
  //   debugPrint("➡️ isGuestUser: ${ApiClient.isGuestUser}");
  //   debugPrint("➡️ latitude: $lat");
  //   debugPrint("➡️ longitude: $lng");

  // ✅ Logged-in user
  if (userId != null && userId > 0 && !ApiClient.isGuestUser) {
    final query = "userId=$userId";
    //     debugPrint("✅ Using Logged-in user query: $query");
    return query;
  }

  // ✅ Guest user with location
  if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
    final query = "latitude=$lat&longitude=$lng";
    //     debugPrint("✅ Using Guest location query: $query");
    return query;
  }

  // ❌ No valid context
  //   debugPrint("❌ No valid user context found. Returning empty query.");
  return "";
}

class Authservice {
  static Future<List<FoodCategory>> fetchFoodCategories() async {
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
      } catch (e) {
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
    } catch (e) {
      throw Exception('Failed to load banners');
    }
  }

  static Future<Restaurent_Banner> fetchVendorBanner(int vendorId) async {
    final endpoint = 'api/banner/$vendorId';

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
        requiresAuth: false,
      );

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

    // ✅ Decide endpoint
    if (userId != null && userId > 0) {
      endpoint =
          "api/dish/getby/vendor/user/dishes?vendorId=$vendorId&userId=$userId";
    } else {
      endpoint = "api/dish/getby/vendor/user/dishes?vendorId=$vendorId";
    }

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
        requiresAuth: false,
      );
      //
      // print("📥 STATUS CODE: ${response.statusCode}");
      // print("📥 RAW BODY: ${response.body}");

      // if (response.statusCode == 200) {
      //   final List<dynamic> data = jsonDecode(response.body);
      //
      //   // print("📊 Total items received: ${data.length}");
      //
      //   // final List<Dish> categories = [];
      //   // final List<Dish> dishes = [];
      //   //
      //   // for (final item in data) {
      //   //   // print("🔍 ITEM: $item");
      //   //
      //   //   final isCategory =
      //   //       item['isCategory'] == true || item['parentId'] == 0;
      //   //
      //   //   if (isCategory) {
      //   //     categories.add(Dish.fromJson(item));
      //   //   } else {
      //   //     dishes.add(Dish.fromJson(item));
      //   //   }
      //   // }
      //   //
      //   // // print("📂 Categories count: ${categories.length}");
      //   // // print("🍛 Dishes count: ${dishes.length}");
      //   //
      //   // return MenuResponse(categories: categories, dishes: dishes);
      //
      //
      //   final allItems = data
      //       .map((e) => Dish.fromJson(e))
      //       .toList();
      //
      //   print("Total Parsed Items = ${allItems.length}");
      //   print("DATA COUNT = ${data.length}");
      //   return MenuResponse(
      //     categories: [],
      //     dishes: allItems,
      //   );
      // }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // print("DATA COUNT = ${data.length}");

        final List<Dish> categories = [];
        final List<Dish> dishes = [];

        for (final item in data) {
          final isCategory =
              item['isCategory'] == true || item['parentId'] == 0;

          if (isCategory) {
            categories.add(Dish.fromJson(item));
          } else {
            dishes.add(Dish.fromJson(item));
          }
        }

        // print("CATEGORIES COUNT = ${categories.length}");
        // print("DISHES COUNT = ${dishes.length}");

        return MenuResponse(categories: categories, dishes: dishes);
      }

      // ❌ API returned error
      // print("❌ API ERROR RESPONSE");

      final errorJson = jsonDecode(response.body);
      // print("❌ ERROR MESSAGE: ${errorJson['message']}");

      return MenuResponse(
        categories: [],
        dishes: [],
        hasError: true,
        errorMessage: errorJson['message'] ?? 'Something went wrong',
      );
    } catch (e, stackTrace) {
      // print("❌ EXCEPTION = $e");
      // print("❌ STACKTRACE = $stackTrace");

      return MenuResponse(
        categories: [],
        dishes: [],
        hasError: true,
        errorMessage: 'Unable to load menu. Please try again.',
      );
    } finally {
      // print("🏁 [Menu API] END --------------------------");
    }
  }
}
