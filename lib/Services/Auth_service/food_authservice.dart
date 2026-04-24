import '../../Models/food/aboutus_model.dart';
import '../../Models/food/team_model.dart';
import '../../Models/subscrptions/advertisement_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/food/table_confirmedlist_model.dart';
import '../../Models/food/restaurent_banner_model.dart';
import '../../Models/food/table_waitinglist_model.dart';
import '../../Models/subscrptions/coupon_model.dart';
import '../../Models/food/favorites_model.dart';
import '../../Models/food/tablecartmodel.dart';
import '../../Models/food/cart_model.dart';
import 'package:flutter/material.dart';
import '../../Models/food/dish.dart';
import 'Apiclient.dart';
import 'dart:convert';

// ignore: camel_case_types
class food_Authservice {
  static Future<AboutUsModel?> fetchAboutUsData(int vendorId) async {
    final endpoint = 'api/vendor/aboutus/get/$vendorId';

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AboutUsModel.fromJson(data);
      } else {
        jsonDecode(response.body);

        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<vendorteam>> fetchteam(int vendorId) async {
    final endpoint = 'api/adminteam/getall/$vendorId';

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((e) => vendorteam.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<String?> fetchUserPlanForVendor(int vendorId) async {
    final endpoint = "api/get/vendor_subscription/$vendorId/FOOD_AND_BEVERAGES";

    try {
      final response = await ApiClient.get(endpoint, service: "subscription");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          final plan = data.first;
          final planType = plan['subscriptionPlan']?['planType'];

          return planType?.toString();
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<Dish>> getAllDishes(int vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/dish/getby/vendor/user/$vendorId/$userId";

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final dishes = data
            .map((dishJson) {
              try {
                final dish = Dish.fromJson(dishJson);

                return dish;
              } catch (e) {
                return null;
              }
            })
            .whereType<Dish>()
            .toList();

        return dishes;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveOrderId(int orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('orderId', orderId);
  }

  static Future<Map<String, dynamic>?> fetchOrderById([int? orderId]) async {
    final endpoint = "api/orders/order/$orderId";

    try {
      if (orderId == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        orderId = prefs.getInt('orderId');

        if (orderId == null) {
          return null;
        }
      }

      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateOrderType(String orderType) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/cart/change/orderType/$orderType?userId=$userId";

    final res = await ApiClient.put(endpoint, {}, service: "food");

    if (res.statusCode != 200) {
      throw Exception("Failed to update order type: ${res.body}");
    }
  }

  static Future<bool> removeCartItem(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    // ✅ Relative endpoint only, no base URL
    final endpoint = "api/cart/items/$itemId?userId=$userId";

    try {
      final response = await ApiClient.delete(endpoint, service: 'food');

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> scheduleOrder({
    required int cartId,
    required DateTime date,
    required TimeOfDay time,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    List<String>? walletTypes,
    double? amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/orders/shedule/order/$cartId?userId=$userId";

    final body = {
      "date":
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      "time":
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00",
      "paymentMethod": paymentMethod,
      "razorpayPaymentId": razorpayPaymentId,
      "razorpayOrderId": razorpayOrderId,
      if (walletTypes != null && walletTypes.isNotEmpty)
        "walletTypes": walletTypes,
      if (amount != null) "amount": amount,
    };

    // 🔥 DEBUG START
    debugPrint("🟡 SCHEDULE ORDER API CALL");
    debugPrint("📍 Endpoint: $endpoint");
    debugPrint("📦 Body: $body");

    final startTime = DateTime.now();

    final response = await ApiClient.post(endpoint, body, service: "food");

    final duration = DateTime.now().difference(startTime).inMilliseconds;

    debugPrint("⏱ Response Time: ${duration}ms");
    debugPrint("📡 Status Code: ${response.statusCode}");
    debugPrint("📨 Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("✅ Schedule Order SUCCESS");
      debugPrint("📥 Parsed Response: $data");
      return data;
    } else {
      final parsed = jsonDecode(response.body);
      final msg =
          parsed['message'] ?? parsed['error'] ?? "Failed to schedule order";

      debugPrint("❌ Schedule Order FAILED: $msg");

      throw Exception(msg);
    }
  }

  static Future<Map<String, dynamic>> placeDirectOrder({
    required int cartId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    List<String>? walletTypes,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final buffer = StringBuffer(
      "api/orders/orders/create/$cartId?userId=$userId"
      "&paymentMethod=$paymentMethod"
      "&razorpayPaymentId=$razorpayPaymentId"
      "&razorpayOrderId=$razorpayOrderId",
    );

    for (final type in walletTypes ?? []) {
      buffer.write("&walletTypes=$type");
    }

    buffer.write("&amount=${amount.toStringAsFixed(2)}");

    final endpoint = buffer.toString();

    // 🔥 DEBUG START
    debugPrint("🟢 PLACE ORDER API CALL");
    debugPrint("📍 Endpoint: $endpoint");
    debugPrint("💰 Amount: $amount");
    debugPrint("💳 Payment Method: $paymentMethod");
    debugPrint("🪪 Razorpay Payment ID: $razorpayPaymentId");
    debugPrint("🧾 Razorpay Order ID: $razorpayOrderId");
    debugPrint("👛 Wallet Types: $walletTypes");

    final startTime = DateTime.now();

    final response = await ApiClient.post(endpoint, {}, service: "food");

    final duration = DateTime.now().difference(startTime).inMilliseconds;

    debugPrint("⏱ Response Time: ${duration}ms");
    debugPrint("📡 Status Code: ${response.statusCode}");
    debugPrint("📨 Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("✅ Place Order SUCCESS");
      debugPrint("📥 Parsed Response: $data");
      return data;
    } else {
      final parsed = jsonDecode(response.body);
      final msg =
          parsed['message'] ?? parsed['error'] ?? "Failed to place order";

      debugPrint("❌ Place Order FAILED: $msg");

      throw Exception(msg);
    }
  }

  static Future<bool> updateCartQuantity(
    // int cartId,
    int itemId,
    int quantity,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    // ✅ Relative endpoint only
    final uri = Uri.parse("api/cart/update/item").replace(
      queryParameters: {
        "userId": userId.toString(),
        "quantity": quantity.toString(),
        "itemId": itemId.toString(),
      },
    );

    final body = {"quantity": quantity};

    try {
      // ✅ Specify the service for correct base URL
      final response = await ApiClient.put(
        uri.toString(),
        body,
        service: 'food',
      );

      return response.statusCode == 200;
    } catch (e) {
      // print("⚠️ Error updating cart quantity: $e");
      return false;
    }
  }

  static Future<bool> addToCart({
    required int dishId,
    required int quantity,
    required sheduleorder,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final endpoint =
        "api/cart/add/item?userId=$userId&sheduleorder=$sheduleorder";
    final body = {"dishId": dishId, "quantity": quantity};

    try {
      final response = await ApiClient.post(endpoint, body, service: "food");

      final data = jsonDecode(response.body);
      final int? cartId = data['cartId'];
      if (cartId == null) return false;

      await prefs.setInt('cartId', cartId);

      // ✅ Cache shedule values from HTTP response by itemId
      final items = data['cartItems'] as List<dynamic>? ?? [];
      for (final item in items) {
        final itemId = item['itemId'];
        final shedule = item['shedule'] == true;
        await prefs.setBool('shedule_item_$itemId', shedule);
      }

      return true;
    } catch (e) {
      debugPrint("❌ [AddToCart] Error: $e");
      return false;
    }
  }

  static Future<int?> getItemIdByDishId(int dishId) async {
    try {
      final cart = await fetchCart();
      if (cart == null) return null;

      final item = cart.cartItems
          .cast<dynamic>()
          .where((i) => i.dishId == dishId)
          .toList();

      if (item.isNotEmpty) {
        return item.first.itemId;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<int?> getTableItemIdByDishId(int dishId, int seatingId) async {
    try {
      final List<TableCartModel> cartList = await fetchTableCart();

      if (cartList.isEmpty) {
        return null;
      }

      final TableCartModel cart = cartList.first;

      final matched = cart.cartItems
          .where((item) => item.dishId == dishId)
          .toList();

      if (matched.isNotEmpty) {
        return matched.first.itemId;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<CartModel?> fetchCart() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final endpoint = "api/cart/get/user/without-seating?userId=$userId";

    final response = await ApiClient.get(endpoint, service: "food");

    if (response.statusCode == 200) {
      debugPrint("response :${response.body}");
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final cartJson = data.first as Map<String, dynamic>;
        final items = cartJson['cartItems'] as List<dynamic>? ?? [];

        for (final item in items) {
          // ✅ Actually print something
          final map = item as Map<String, dynamic>;
          debugPrint('dish: ${map['dishName']}, shedule: ${map['shedule']}');
          debugPrint("prinitingcartdata : ${response.body}");
        }

        return CartModel.fromJson(cartJson);
      }
      return null;
    } else {
      final body = jsonDecode(response.body);
      final msg = body['message'] ?? body['error'] ?? "Failed to load cart";
      throw Exception(msg);
    }
  }

  static Future<bool> deleteCart() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt("userId") ?? 0;
    final endpoint = "api/cart/delete/user/cart?userId=$userId";

    try {
      final response = await ApiClient.delete(endpoint, service: "food");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> addToTableCart({
    required int dishId,
    required int quantity,
    required int seatingId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final String customerId = prefs.getString("customerId") ?? '';

    final endpoint =
        "api/cart/add/table/cart/add-item?userId=$userId&seatingId=$seatingId&customerId=$customerId";
    final body = {"dishId": dishId, "quantity": quantity};

    try {
      print("🟡 ADD TO TABLE CART START");
      print("➡️ Endpoint: $endpoint");
      print("➡️ Body: $body");
      print("➡️ userId: $userId, seatingId: $seatingId");

      final response = await ApiClient.post(endpoint, body, service: "food");

      print("📥 STATUS CODE: ${response.statusCode}");
      print("📥 RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("❌ API FAILED (Invalid status code)");
        return false;
      }

      final data = jsonDecode(response.body);
      print("✅ DECODED RESPONSE: $data");

      final int? cartId = data['cartId'];

      if (cartId != null) {
        await prefs.setInt('cartId', cartId);
        print("🟢 CART ID SAVED: $cartId");
      } else {
        print("⚠️ cartId NOT FOUND in response");
      }

      print("🟢 ADD TO CART SUCCESS");
      return true;
    } catch (e, stack) {
      print("🔥 ERROR IN addToTableCart");
      print("❌ Error: $e");
      print("📍 StackTrace: $stack");
      return false;
    }
  }

  static Future<List<FavoriteDish>> getFavoritesByUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/favourite/getallbyuserid/$userId";

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        final favorites = jsonData
            .map((item) => FavoriteDish.fromJson(item))
            .toList();

        return favorites;
      } else {
        throw Exception(
          "Failed to load favorite dishes: ${response.statusCode}",
        );
      }
    } catch (e) {
      rethrow;
    } finally {}
  }

  static Future<int> submitBooking({
    required int vendorId,
    required String guestName,
    required String phoneNumber,
    required String bookingDate,
    required String startTime,
    required int capacity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      debugPrint("❌ No userId provided");
      return 0;
    }

    final endpoint =
        "api/seatingdetails/shedule/advance/booking/$userId/$vendorId";

    final body = {
      "guestName": guestName,
      "phoneNumber": phoneNumber,
      "bookingDate": bookingDate,
      "startTime": startTime,
      "capacity": capacity,
    };

    try {
      final response = await ApiClient.post(endpoint, body, service: "food");

      debugPrint("📤 Booking request: ${jsonEncode(body)}");
      debugPrint(
        "📥 Booking response: ${response.statusCode} ${response.body}",
      );

      return response.statusCode; // ✅ IMPORTANT
    } catch (e) {
      debugPrint("⚠️ Error submitting booking: $e");
      return 0;
    }
  }

  static Future<bool> bookNow({
    required int vendorId,
    required String guestName,
    required String phoneNumber,
    required int capacity,
    int durationMinutes = 45,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    // debugPrint("🟠 [BOOK_API] Preparing booking request...");

    if (userId == 0) {
      // debugPrint("❌ [BOOK_API] No userId provided");
      return false;
    }

    final endpoint =
        "api/seatingdetails/booknow/$userId/$vendorId?capacity=$capacity&guestName=$guestName&phoneNumber=$phoneNumber";

    try {
      // debugPrint("📤 [BOOK_API] Sending POST to: $endpoint");

      final response = await ApiClient.post(endpoint, {}, service: "food");

      // debugPrint("📥 [BOOK_API] Response: ${response.statusCode} → ${response.body}");

      final ok = response.statusCode == 200 || response.statusCode == 202;
      // debugPrint(
      //   ok
      //       ? "✅ [BOOK_API] Booking succeeded"
      //       : "⚠️ [BOOK_API] Booking failed with status ${response.statusCode}",
      // );

      return ok;
    } catch (e) {
      // debugPrint("🚨 [BOOK_API] Error submitting booking: $e");
      return false;
    }
  }

  //
  static Future<bool> addToFavorites(int dishId) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = 'api/favourite/add/$userId/$dishId';
    final body = {'userId': userId, 'dishId': dishId};

    try {
      final response = await ApiClient.post(endpoint, body, service: "food");

      if (response.statusCode == 200) {
        jsonDecode(response.body);

        return true; // ✅ FIX
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {}
  }

  static Future<bool> unfavoriteDish(int favId) async {
    final endpoint = "api/favourite/delete/$favId";

    try {
      final response = await ApiClient.delete(endpoint, service: "food");

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<WaitingItem>> fetchWaitingList() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      return [];
    }

    final endpoint = "api/seatingdetails/waiting/user/$userId";

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
      ); // Using Services helper

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          return [WaitingItem.fromJson(body)];
        } else if (body is List) {
          return body.map((e) => WaitingItem.fromJson(e)).toList();
        }
      }

      // debugPrint("❌ Failed to fetch waiting list: ${response.body}");
      return [];
    } catch (e) {
      // debugPrint("⚠️ Error fetching waiting list: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      return [];
    }

    // ✅ Relative endpoint only
    final endpoint = "api/orders/user/orders?userId=$userId";

    try {
      // ✅ Use correct service if needed
      final response = await ApiClient.get(endpoint, service: 'food');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('orders')) {
          return (data['orders'] as List).cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> cancelOrder(int orderId) async {
    final endpoint = "api/orders/cancal/total/order/$orderId";

    final response = await ApiClient.put(
      endpoint,
      null, // no body needed
      service: "food",
    );

    if (response.statusCode == 200) {
      debugPrint("response body:${response.body}");
      return true;
    } else {
      print("Cancel failed: ${response.body}");
      return false;
    }
  }

  static Future<int> fetchRating(int orderId) async {
    // ✅ Relative endpoint only
    final endpoint = "api/orders/order/$orderId";
    try {
      // ✅ Use ApiClient.get and specify service if needed
      final response = await ApiClient.get(endpoint, service: 'food');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["ratings"] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> submitRating(
    int orderId,
    int rating,
    String feedback,
    String category,
  ) async {
    final endpoint = "api/orders/feedback/$orderId";

    try {
      final response = await ApiClient.put(endpoint, {
        "ratings": rating,
        "feedback": feedback,
        "ratingCategory": category,
        "ratedAt": DateTime.now().toIso8601String(),
      }, service: 'food');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("response:${response.body}");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<List<ConfirmedList>> fetchConfirmedList() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      return [];
    }

    final endpoint = "api/seatingdetails/get/by/$userId";

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
      ); // Using Services helper
      debugPrint(
        "📥 Confirmed list response: ${response.statusCode} ${response.body}",
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          return [ConfirmedList.fromJson(body)];
        } else if (body is List) {
          return body.map((e) => ConfirmedList.fromJson(e)).toList();
        }
      }

      // debugPrint("❌ Failed to fetch confirmed list: ${response.body}");
      return [];
    } catch (e) {
      // debugPrint("⚠️ Error fetching confirmed list: $e");
      return [];
    }
  }

  static Future<bool> sendArrivalStatus(int seatingId) async {
    final endpoint = "api/seatingdetails/seating-details/$seatingId";
    final body = {'arrivalStatus': 'ARRIVED'};

    debugPrint("🚀 [sendArrivalStatus] START ----------------------");
    debugPrint("📍 seatingId: $seatingId");
    debugPrint("🌐 endpoint: $endpoint");
    debugPrint("📦 body: $body");

    try {
      final response = await ApiClient.put(endpoint, body, service: "food");

      debugPrint("📡 Response Status Code: ${response.statusCode}");
      debugPrint("📡 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ API SUCCESS - Saving to local storage");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', seatingId);

        debugPrint("💾 Stored seatingId in SharedPreferences: $seatingId");
        debugPrint("🎉 [sendArrivalStatus] SUCCESS -------------------");

        return true;
      } else {
        debugPrint("⚠️ API FAILED with status: ${response.statusCode}");

        // 🔥 Print backend error
        debugPrint("🧾 Error Response Body: ${response.body}");

        debugPrint("❌ [sendArrivalStatus] FAILED -------------------");
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("🔥 Exception in sendArrivalStatus: $e");
      debugPrint("🧵 StackTrace: $stackTrace");
      debugPrint("❌ [sendArrivalStatus] ERROR --------------------");
      return false;
    }
  }

  static Future<List<TableCartModel>> fetchTableCart() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/cart/get/user/with-seating?userId=$userId";

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      debugPrint("📡 Fetch table cart URL: $endpoint");
      debugPrint("📥 Response status: ${response.statusCode}");
      debugPrint("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TableCartModel.fromJson(json)).toList();
      } else {
        debugPrint('❌ Failed to load cart data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching table cart: $e');
      return [];
    }
  }

  static Future<bool> updateCartItemStatus({
    required int itemId,
    required String status,
    String? note,
  }) async {
    final endpoint = "api/cart/cartitem/status/$itemId?status=$status";

    try {
      // Call PUT with just the endpoint
      final response = await ApiClient.put(endpoint, {}, service: "food");

      // debugPrint("🛠️ PUT Request URL: $endpoint");
      // debugPrint("🔹 Response: ${response.statusCode} ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      // debugPrint("❌ Error updating cart item status: $e");
      return false;
    }
  }

  static Future<bool> updateCartItemQuantity({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('userId');
      if (userId == null || userId == 0) {
        // debugPrint("❌ Invalid or missing userId in SharedPreferences");
        return false;
      }

      final endpoint =
          "api/cart/update/item?userId=$userId&quantity=$quantity&itemId=$itemId";

      // Use an empty body if your Services does not expect one
      final response = await ApiClient.put(endpoint, {}, service: "food");

      debugPrint("🛠️ PUT Request URL: $endpoint");
      debugPrint("🔹 Response: ${response.statusCode} ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Exception while updating cart item quantity: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> placeOrder({
    required int userId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    String? walletType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');

    if (cartId == null) {
      return {"success": false, "error": "Cart ID missing"};
    }

    final buffer = StringBuffer(
      "api/orders/orders/create/$cartId"
      "?userId=$userId"
      "&paymentMethod=$paymentMethod"
      "&razorpayPaymentId=$razorpayPaymentId"
      "&razorpayOrderId=$razorpayOrderId",
    );

    if (walletType != null) {
      buffer.write("&walletType=$walletType");
    }

    final url = buffer.toString();
    debugPrint("📤 Placing order with URL: $url");

    try {
      final response = await ApiClient.post(url, {}, service: 'food');
      debugPrint("📥 Response Status: ${response.statusCode}");
      debugPrint("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final orderId = data['orderId'];
        if (orderId == null) {
          debugPrint("⚠️ orderId missing in Services response");
          return {
            "success": false,
            "error": "Invalid response: orderId missing",
          };
        }

        await prefs.setInt('orderId', orderId);
        return {"success": true, "orderId": orderId};
      } else {
        return {
          "success": false,
          "error": "Failed to place order: ${response.body}",
        };
      }
    } catch (e) {
      debugPrint("⚠️ Error placing order: $e");
      return {"success": false, "error": e.toString()};
    }
  }

  // 🔥 FIXED updateCartSettings - Handles both apply & remove correctly
  static Future<CouponResult> updateCartSettings({
    required int cartId,
    dynamic couponId, // nullable
    required String applyCoupon,
  }) async {
    try {
      final endpoint = "api/cart/coupon/$cartId";

      final Map<String, dynamic> body = {"applyCoupon": applyCoupon};

      if (couponId != null) {
        body["id"] = couponId is String ? int.parse(couponId) : couponId;
      }

      debugPrint("🔥 PUT $endpoint");
      debugPrint("🔥 BODY: ${jsonEncode(body)}");

      final response = await ApiClient.put(endpoint, body, service: "food");

      debugPrint("🔥 STATUS: ${response.statusCode}");
      debugPrint("🔥 RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return CouponResult(success: true);
      } else {
        // Try to parse error message from backend
        // ignore: unnecessary_null_comparison
        final errorMsg =
            jsonDecode(response.body)["message"] ?? "Failed to apply coupon";

        return CouponResult(success: false, error: errorMsg);
      }
    } catch (e) {
      debugPrint("❌ updateCartSettings Error: $e");
      return CouponResult(success: false, error: e.toString());
    }
  }

  static Future<bool> updateServiceCharges({
    required int cartId,
    required String serviceCharge,
  }) async {
    final endpoint = "api/cart/coupon/$cartId";

    final body = {"serviceCharge": serviceCharge};

    // debugPrint("🔹 PUT Endpoint: $endpoint");
    // debugPrint("🔹 Request Body: $body");

    try {
      final response = await ApiClient.put(endpoint, body, service: "food");

      // debugPrint("🔹 Status Code: ${response.statusCode}");
      // debugPrint("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // debugPrint("✅ Service charges updated successfully");
        return true;
      } else {
        // debugPrint("❌ Failed to update service charges");
        return false;
      }
    } catch (e) {
      // debugPrint("❌ Exception updating service charges: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> createCart(String orderType) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint =
        'api/cart/create/cart/orderType?userId=$userId&orderType=$orderType';

    try {
      final response = await ApiClient.post(endpoint, {}, service: "food");

      final body = jsonDecode(response.body);

      print("📡 STATUS: ${response.statusCode}");
      print("📥 BODY: $body");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final int? cartId = body['cartId'];

        if (cartId != null && cartId > 0) {
          await prefs.setInt('cartId', cartId);
          await prefs.setString('orderType', orderType);

          return {"success": true, "cartId": cartId};
        }
      }

      /// ❌ Handle backend error message
      return {
        "success": false,
        "message": body['message'] ?? "Something went wrong",
      };
    } catch (e) {
      return {"success": false, "message": "Network error"};
    }
  }

  static Future<List<Restaurent_Banner>> fetchBanner() async {
    final endpoint = 'api/bannner/getall';

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
      ); // token included

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => Restaurent_Banner.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<String?> createOrder(double amount) async {
    try {
      String endpoint = "api/payments/create-order/user";

      final body = {
        "amount": amount,
        "currency": "INR",
        "receipt": "receipt#${DateTime.now().millisecondsSinceEpoch}",
        "notes": {"key1": "value3", "key2": "value2"},
      };

      final res = await ApiClient.post(endpoint, body, service: "food");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["orderId"] ?? data["id"]; // ensure correct key
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // 2️⃣ CAPTURE PAYMENT
  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      String endpoint = "api/payments/capture";

      final body = {
        "paymentId": paymentId,
        "amount": amount,
        "currency": "INR",
        "receipt":
            "order#${DateTime.now().millisecondsSinceEpoch} for wallet top-up",
      };

      final res = await ApiClient.post(endpoint, body, service: "food");

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Advertisement>> fetchAdvertisements() async {
    const String endpoint = 'api/advertisements/valid';

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
        // requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Supports Services returning object OR list
        final List<dynamic> adsList = data is List ? data : [data];

        return adsList.map((e) => Advertisement.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<int> fetchCartCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final customerId = prefs.getString('customerId');

      if (userId == null) return 0;

      final response = await ApiClient.get(
        "api/cart/user/cart/count?userId=$userId&customerId=$customerId",
        service: "food", // or "Mamaswebsite" depending on your setup
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        debugPrint("❌ Failed to fetch cart count → ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      debugPrint("💥 Error fetching cart count: $e");
      return 0;
    }
  }

  static Future<bool> updateDeliveryAddress({
    required int cartId,
    required int addressId,
  }) async {
    try {
      final body = {"addressId": addressId, "cartId": cartId};

      final response = await ApiClient.post(
        "api/cart/delivery/$cartId/address/$addressId",
        body,
        service: "food",
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<CouponModel>> fetchCoupons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      // debugPrint("🧾 SharedPreferences userId = $userId");

      if (userId == null) {
        // debugPrint("❌ No userId found in SharedPreferences");
        return [];
      }

      final endpoint = "api/coupon/user/$userId";
      // debugPrint("📡 Services Endpoint: $endpoint");

      final response = await ApiClient.get(endpoint, service: 'food');

      // debugPrint("📥 Status Code: ${response.statusCode}");
      // debugPrint("📥 Raw Response Body:");
      // debugPrint(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // debugPrint("✅ Coupons count: ${data.length}");

        /// Pretty print full JSON
        // debugPrint("🧾 Pretty JSON Response:");
        // debugPrint(encoder.convert(data));

        /// Log each coupon separately (very useful)
        // for (int i = 0; i < data.length; i++) {
        //   debugPrint("🎟 Coupon [$i]: ${encoder.convert(data[i])}");
        // }

        return data.map((e) => CouponModel.fromJson(e)).toList();
      } else {
        // debugPrint(
        //   "⚠️ Services Error ${response.statusCode} → ${response.body}",
        // );
        return [];
      }
    } catch (e) {
      // debugPrint("❌ Exception in fetchCoupons: $e");
      // debugPrint("📛 StackTrace:");
      // debugPrint(stack.toString());
      return [];
    }
  }
}
