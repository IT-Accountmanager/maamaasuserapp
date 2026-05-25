import 'package:maamaas/screens/Food&beverages/food_cartscreen.dart';
import '../../Models/promotions_model/promotions_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/advertisements/banneradvertisement.dart';
import '../../Services/Auth_service/Apiclient.dart';
import 'table/tablecart.dart' hide cartuser;
import 'package:flutter/material.dart';
import '../Mainscreen.dart';
import 'dart:convert';

// ignore: must_be_immutable
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
  List<Campaign> homepageAds = [];

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

      debugPrint("❌ NO CART FOUND");

      setState(() {
        activeCartType = null;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("🚨 ERROR in detectCart: $e");
      if (!mounted) return;

      setState(() {
        activeCartType = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    /// ❌ No Cart Found
    if (activeCartType == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 👈 important
            children: [
              Container(
                width: 90.r,
                height: 90.r,
                decoration: BoxDecoration(
                  color: cartuser.violetDim,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 40.sp,
                  color: cartuser.violet,
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: cartuser.textPrimary,
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                'Add some delicious items to get started',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: cartuser.textSecondary,
                ),
              ),

              SizedBox(height: 24.h),

              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MainScreenfood()),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: cartuser.violet,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: cartuser.violet.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'Browse Menu',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              if (homepageAds.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: BannerAdvertisement(ads: homepageAds, height: 200),
                ),
            ],
          ),
        ),
      );
    }

    /// 🟢 TABLE CART
    if (activeCartType == "TABLE_DINE_IN") {
      return tablecart(seatingId: seatingId!);
    }

    /// 🟢 NORMAL CART
    return food_cartScreen();
  }
}
