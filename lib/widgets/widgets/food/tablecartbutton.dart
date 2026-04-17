import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../screens/Food&beverages/table/tablecart.dart';
import '../../widgets/food/currentcart_notifier.dart';

// ignore: camel_case_types
class food_tableCart_count extends StatefulWidget {
  final double? savedAmount; // final VoidCallback? onCartUpdated;

  const food_tableCart_count({super.key, this.savedAmount});

  @override
  State<food_tableCart_count> createState() => _OrderCartFooterState();
}

class _OrderCartFooterState extends State<food_tableCart_count> {
  @override
  void initState() {
    super.initState();
    loadCartData();
  }

  Future<void> loadCartData() async {
    try {
      final count = await food_Authservice.fetchCartCount();
      CartNotifier.count.value = count;
    } catch (e) {
      // print("Error loading cart data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: isSmallScreen ? 2 : 1,
              child: ValueListenableBuilder<int>(
                valueListenable: CartNotifier.count,
                builder: (context, count, _) {
                  return _buildCartSummary(count, isSmallScreen: isSmallScreen);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(int count, {required bool isSmallScreen}) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        int? seatingId = prefs.getInt('id');
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => tablecart(seatingId: seatingId!)),
        );
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6D5BFF), Color(0xFF8C6BFF)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 18,
                      minWidth: 18,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
