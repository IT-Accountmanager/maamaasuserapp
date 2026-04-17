import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maamaas/screens/Food&beverages/food_cartscreen.dart';
import 'package:maamaas/screens/Food&beverages/table/tablecart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/Auth_service/Apiclient.dart';

class CommonCartScreen extends StatefulWidget {
  Function()? reloadCart;

  CommonCartScreen({super.key});

  @override
  State<CommonCartScreen> createState() => _CommonCartScreenState();
}

class _CommonCartScreenState extends State<CommonCartScreen> {
  bool isLoading = true;
  String? activeCartType;
  int? seatingId;

  @override
  void initState() {
    super.initState();
    widget.reloadCart = detectCart;
    detectCart();
  }

  /// ✅ Safe JSON Decode (prevents crash)
  dynamic safeDecode(String body) {
    if (body.isEmpty) return null;

    try {
      return jsonDecode(body);
    } catch (e) {
      debugPrint("❌ JSON Decode Error: $e");
      return null;
    }
  }

  Future<void> detectCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final endpoint = 'api/cart/get/user/with-seating?userId=$userId';
    final endpoint1 = 'api/cart/get/user/without-seating?userId=$userId';

    debugPrint("🔍 Detecting cart for userId: $userId");

    try {
      /// =========================
      /// 🟢 1️⃣ TABLE CART CHECK
      /// =========================
      debugPrint("📡 Calling TABLE cart API...");

      final tableResponse = await ApiClient.get(endpoint, service: "food");

      debugPrint("📊 Table Status: ${tableResponse.statusCode}");
      debugPrint("📥 Table RAW: ${tableResponse.body}");

      if (tableResponse.statusCode == 200) {
        var decoded = safeDecode(tableResponse.body);

        /// handle double encoded JSON
        if (decoded is String) {
          decoded = safeDecode(decoded);
        }

        if (decoded is List && decoded.isNotEmpty) {
          debugPrint("✅ TABLE CART FOUND");

          setState(() {
            activeCartType = "TABLE_DINE_IN";
            seatingId = decoded[0]['seatingId'];
            isLoading = false;
          });

          return;
        }
      }

      /// =========================
      /// 🟢 2️⃣ NORMAL CART CHECK
      /// =========================
      debugPrint("📡 Calling NORMAL cart API...");

      final normalResponse = await ApiClient.get(endpoint1, service: "food");

      debugPrint("📊 Normal Status: ${normalResponse.statusCode}");
      debugPrint("📥 Normal RAW: ${normalResponse.body}");

      if (normalResponse.statusCode == 200) {
        var normalData = safeDecode(normalResponse.body);

        if (normalData is List && normalData.isNotEmpty) {
          debugPrint("✅ NORMAL CART FOUND");

          setState(() {
            activeCartType = "NORMAL";
            isLoading = false;
          });

          return;
        }
      }

      /// =========================
      /// ❌ NO CART
      /// =========================
      debugPrint("❌ NO CART FOUND");

      setState(() {
        activeCartType = null;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("🚨 ERROR in detectCart: $e");

      setState(() {
        activeCartType = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// ⏳ Loading State
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    /// ❌ No Cart Found
    if (activeCartType == null) {
      return const Scaffold(body: Center(child: Text("Cart is empty")));
    }

    /// 🟢 TABLE CART
    if (activeCartType == "TABLE_DINE_IN") {
      return tablecart(seatingId: seatingId!);
    }

    /// 🟢 NORMAL CART
    return food_cartScreen();
  }
}
