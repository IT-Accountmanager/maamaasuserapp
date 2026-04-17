import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/subscrptions/address_model.dart';

import '../../Models/subscrptions/location_model.dart';
import '../../Models/subscrptions/transaction_model.dart';
import '../../Models/subscrptions/user_account.dart';
import '../../Models/subscrptions/wallet_model.dart';
import 'Apiclient.dart';

class subscription_AuthService {
  static const _secureStorage = FlutterSecureStorage();

  static final String baseUrlgateway =
      "https://backend.maamaas.com/subscription";
      // "http://testing.maamaas.com:8080/subscription";

  Future<String> registerUser({
    required String userName,
    required String password,
    required String emailId,
    required String mobileNumber,
    required String userType,
    String? referralCodeUsed,
    String? companyName,
  }) async {
    final Uri url = Uri.parse('$baseUrlgateway/api/user/registration');
    final String localDateTime = DateTime.now().toLocal().toIso8601String();

    final Map<String, dynamic> body = {
      "userName": userName,
      "password": password,
      "emailId": emailId,
      "mobileNumber": mobileNumber,
      "role": "ROLE_USER",
      "userType": userType,
      "registeredTime": localDateTime,
      "referralCodeUsed": referralCodeUsed,
    };

    if (userType == "PROFESSIONAL" &&
        companyName != null &&
        companyName.isNotEmpty) {
      body["companyName"] = companyName;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // ✅ SUCCESS
      if (response.statusCode == 200 || response.statusCode == 201) {
        return "success";
      }

      // ❌ ERROR
      try {
        final errorJson = jsonDecode(response.body);
        return errorJson["message"] ?? errorJson["error"] ?? "Signup failed";
      } catch (_) {
        return response.body;
      }
    } catch (e) {
      return "Something went wrong. Please check your internet connection.";
    }
  }

  Future<String> verifyOTP({
    required String mobile,
    required String otp,
  }) async {
    try {
      final Uri url = Uri.parse(
        '$baseUrlgateway/api/user/registration/verifyotp',
      ).replace(queryParameters: {'mobile': mobile.trim(), 'otp': otp.trim()});

      final response = await http.post(url);

      // ✅ Success
      if (response.statusCode == 200) {
        return "success";
      }

      // ❌ Error
      try {
        final errorJson = jsonDecode(response.body);
        return errorJson["message"] ??
            errorJson["error"] ??
            "OTP verification failed";
      } catch (_) {
        // backend returns plain text
        return response.body;
      }
    } catch (e) {
      return "Something went wrong. Please check your internet connection.";
    }
  }

  static Future<String> login({
    required String identifier,
    required String password,
    bool isProfessional = false,
  }) async {
    final url = Uri.parse('$baseUrlgateway/api/auth/login/user').replace(
      queryParameters: {"identifier": identifier, "password": password},
    );

    final body = jsonEncode({
      "username": identifier,
      "password": password,
      "userType": isProfessional ? "PROFESSIONAL" : "PERSONAL",
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint("📤 REQUEST BODY:");

      debugPrint("📨 RESPONSE STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final String token = data['token'] ?? "";
        final String refreshToken = data['refreshToken'] ?? "";

        if (token.isEmpty || refreshToken.isEmpty) {
          return "Missing tokens in response";
        }

        await _secureStorage.write(key: 'token', value: token);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);

        final prefs = await SharedPreferences.getInstance();
        final userId = (data['userId'] ?? 0) as int;
        final customerId = (data['customerId'] ?? '') as String;

        await prefs.setInt('userId', userId);
        await prefs.setString("customerId", customerId);
        await prefs.setBool('isLoggedIn', true);

        debugPrint("✅ LOGIN SUCCESSFUL");
        return "success";
      } else {
        String errorMsg = "Login failed! Please try again.";
        try {
          final errorJson = jsonDecode(response.body);
          errorMsg = errorJson['message'] ?? errorJson['error'] ?? errorMsg;
        } catch (_) {
          errorMsg = response.body;
        }

        return errorMsg;
      }
    } catch (e) {
      return "Something went wrong. Please check your internet connection.";
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    return userId != null && userId > 0;
  }

  static Future<bool> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final endpoint = "api/user/delete/account/$userId";

      final response = await ApiClient.delete(
        endpoint,
        service: "subscription",
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final endpoint = '$baseUrlgateway/api/user/forget/password';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': email, // or 'email' depending on your backend key
        }),
      );

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          return {
            'success': true,
            'message': decoded['message'] ?? 'Reset link sent!',
          };
        } catch (_) {
          return {
            'success': true,
            'message': response.body.isNotEmpty
                ? response.body
                : 'Reset link sent!',
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['error'] ?? 'Something went wrong',
          };
        } catch (_) {
          return {
            'success': false,
            'message': response.body.isNotEmpty
                ? response.body
                : 'Something went wrong',
          };
        }
      }
    } catch (e) {
      // print("Unexpected error: $e");
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  static Future<List<Transactions>> fetchTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        return [];
      }

      final endpoint =
          "api/user/wallet/transactions/$userId"; // ✅ no leading slash

      final response = await ApiClient.get(
        endpoint,
        service: "subscription",
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) => Transactions.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Wallet?> fetchWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final endpoint = "api/user/wallet/$userId";

      final response = await ApiClient.get(endpoint, service: "subscription");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Wallet.fromJson(jsonData);
      } else {
        return null; // return null instead of crashing
      }
    } catch (e) {
      return null; // safe return
    }
  }

  static Future<List<Address>> fetchAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        return [];
      }

      final endpoint = "$baseUrlgateway/api/user/get/addresses/$userId";

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          // Do NOT include Authorization header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Address.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ✅ Add new address
  static Future<bool> addAddress(Map<String, dynamic> body) async {
    final endpoint = Uri.parse("$baseUrlgateway/api/user/location/add");

    try {
      final response = await http.post(
        endpoint,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateAddress(
    int addressId,
    Map<String, dynamic> body,
  ) async {
    try {
      final endpoint = "api/user/update/$addressId";

      final response = await ApiClient.put(
        endpoint,
        body,
        service: "subscription",
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  // ✅ Delete address
  static Future<bool> deleteAddress(int addressId) async {
    try {
      // 🔹 Only relative endpoint (no base URL here)
      final endpoint = "api/user/delete/$addressId";

      // 🔹 Use the helper method
      final response = await ApiClient.delete(
        endpoint,
        service: "subscription",
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateProfileImage(File profileImage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      final response = await ApiClient.sendMultipartRequest(
        service: "subscription",
        endpoint: "api/user/editprofile/$userId",
        method: "PUT",
        // same as Postman
        data: {
          // EXACTLY like Postman: key=userProfileData, value={}
          'userProfileData': '{}',
        },
        files: {
          // field name must match Postman: profileImage
          'profileImage': profileImage,
        },
      );

      final success = response.statusCode == 200 || response.statusCode == 201;
      return success;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> createOrder(double amount) async {
    try {
      String endpoint = "api/user/create-order";

      final body = {
        "amount": amount,
        "currency": "INR",
        "receipt": "receipt#${DateTime.now().millisecondsSinceEpoch}",
        "notes": {"key1": "value3", "key2": "value2"},
      };

      final res = await ApiClient.post(endpoint, body, service: "subscription");

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
      final String endpoint = "$baseUrlgateway/api/user/capture";

      final Map<String, dynamic> body = {
        "paymentId": paymentId,
        "amount": amount,
        "currency": "INR",
        "receipt":
            "order#${DateTime.now().millisecondsSinceEpoch} for wallet top-up",
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3️⃣ ADD CASH TO WALLET
  static Future<bool> addCashToWallet({
    required String paymentId,
    String? orderId,
    required double amount,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      if (userId == 0) {
        return false;
      }

      final endpoint =
          "api/user/addCash/self-loaded?userId=$userId&amount=$amount&paymentId=$paymentId&orderId=${orderId ?? 'NA'}";

      final res = await ApiClient.post(endpoint, {}, service: "subscription");

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
    required String city,
  }) async {
    try {
      debugPrint("📍 [Location Update] Starting...");

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      final customerId = prefs.getString('customerId');

      if (userId == null) {
        //
        return false;
      }

      final endpoint = "$baseUrlgateway/api/user/curret/location/update";

      final body = {
        "userId": userId,
        "customerId": customerId,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "city": city,
        "updatedAt": DateTime.now().toIso8601String(),
      };

      debugPrint("📤 [Location Update] Endpoint: $endpoint");
      debugPrint("📤 [Location Update] Request Body: $body");

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint("📥 [Location Update] Status Code: ${response.statusCode}");
      debugPrint("📥 [Location Update] Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ [Location Update] Success");
        return true;
      } else {
        debugPrint(
          "❌ [Location Update] Failed with status ${response.statusCode}",
        );
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("🔥 [Location Update] Exception: $e");
      debugPrint("🧵 StackTrace: $stackTrace");
      return false;
    }
  }

  static Future<UserLocationModel?> fetchCurrentLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId") ?? 0;
      final url = "$baseUrlgateway/api/user/get/current/location/$userId";

      print("🌐 GET URL: $url");

      var response = await http.get(Uri.parse(url));

      print("📥 STATUS: ${response.statusCode}");
      print("📥 BODY: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final jsonData = jsonDecode(response.body);
        return UserLocationModel.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      print("❌ FETCH ERROR: $e");
      return null;
    }
  }

  static Future<UserAccount?> getAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      return null;
    }

    final response = await ApiClient.get(
      "api/user/account/get/$userId",
      service: "subscription",
    );

    if (response.statusCode == 200) {
      return UserAccount.fromJson(jsonDecode(response.body));
    } else {
      return null; // don't throw exception
    }
  }

  static Future<bool> saveAccount(UserAccount account) async {
    final endpoint = "api/user/account/save"; // POST endpoint

    debugPrint("📤 [saveAccount] Request started");
    debugPrint("➡️ Endpoint: $endpoint");
    debugPrint("📦 Payload: ${account.toJson()}");

    try {
      final response = await ApiClient.post(
        endpoint,
        account.toJson(),
        service: 'subscription',
      );

      debugPrint("📥 [saveAccount] Response received");
      debugPrint("🔢 Status Code: ${response.request}");
      debugPrint("🔢 Status Code: ${response.statusCode}");
      debugPrint("📄 Response Body: ${response.body}");

      final isSuccess =
          response.statusCode == 200 || response.statusCode == 201;

      debugPrint(
        isSuccess ? "✅ Account saved successfully" : "❌ Failed to save account",
      );

      return isSuccess;
    } catch (e, stackTrace) {
      debugPrint("🚨 [saveAccount] Exception occurred");
      debugPrint("❗ Error: $e");
      debugPrint("🧵 StackTrace: $stackTrace");

      return false;
    }
  }

  static Future<bool> logout() async {
    debugPrint("🚪 Logout started");

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      debugPrint("👤 User ID: $userId");

      debugPrint("🔐 Calling AUTH logout Services...");

      await ApiClient.post("api/auth/logout", {}, service: "subscription");

      if (userId != null) {
        debugPrint("🔔 Deleting notification token for userId=$userId");

        await ApiClient.delete(
          "api/user/delete-token/$userId",
          service: "notification",
        );
      }
    } catch (e) {
      debugPrint("❌ Logout API error: $e");
    } finally {
      debugPrint("🧹 Clearing local storage...");

      // 🔐 Clear secure storage
      await _secureStorage.deleteAll();

      // Verify secure storage
      final secureData = await _secureStorage.readAll();
      debugPrint("🔐 Remaining SecureStorage: $secureData");

      // 📦 Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Verify shared prefs
      final newPrefs = await SharedPreferences.getInstance();
      debugPrint("📭 Remaining SharedPrefs: ${newPrefs.getKeys()}");
    }

    return true;
  }
}
