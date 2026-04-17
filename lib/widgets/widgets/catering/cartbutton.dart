import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Models/caterings/catering_cart_model.dart';
import '../../../Models/caterings/packages_model.dart';
import '../../../Services/Auth_service/catering_authservice.dart';
import '../../../utils/utils.dart';
import 'package:maamaas/Services/App_color_service/app_colours.dart';

import '../food/currentcart_notifier.dart';

class CateringCartButton extends StatefulWidget {
  final Package package; // ✅ Strongly type it
  const CateringCartButton({super.key, required this.package});

  @override
  State<CateringCartButton> createState() => _CateringCartButtonState();
}

class _CateringCartButtonState extends State<CateringCartButton> {
  int itemCount = 0;
  int? cartId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuantity();
  }

  Future<void> _loadQuantity() async {
    try {
      setState(() => _isLoading = true);

      final catering_Cart? cart = await catering_authservice.fetchUserCart();
      final packageId = widget.package.id;

      if (cart == null || cart.items.isEmpty) {
        setState(() => itemCount = 0);
        return;
      }

      final CartPackage? packageInCart = cart.items.firstWhereOrNull(
        (item) => item.packageId == packageId,
      );

      if (packageInCart != null) {
        final qty = packageInCart.quantity;
        cartId = cart.id;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("package_${packageId}_quantity", qty);
        await prefs.setInt("package_${packageId}_cartId", cartId!);

        setState(() => itemCount = qty);

        _updateGlobalItemCount(cart.items);
      } else {
        setState(() => itemCount = 0);
      }
    } catch (e) {
      debugPrint("❌ Error fetching catering cart quantity: $e");
      await _loadQuantityFromCache();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Fallback: Load from cache
  Future<void> _loadQuantityFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packageId = widget.package.id;
      final cachedQty = prefs.getInt("package_${packageId}_quantity") ?? 0;
      final cachedCartId = prefs.getInt("package_${packageId}_cartId");

      setState(() {
        itemCount = cachedQty;
        cartId = cachedCartId;
      });
    } catch (e) {
      debugPrint("❌ Error loading quantity from cache: $e");
      setState(() => itemCount = 0);
    }
  }

  void _updateGlobalItemCount(List<CartPackage> items) {
    final totalCount = items.fold<int>(0, (sum, item) => sum + item.quantity);

    Utils.itemCount.value = totalCount;
  }

  // ✅ Add to cart
  Future<bool> _handleAddToCart(int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      final success = await catering_authservice.addToCart(
        userId: userId,
        packageId: widget.package.id,
        quantity: quantity,
      );

      if (success) {
        await _fetchAndStoreCartId();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Error adding to cart: $e");
      return false;
    }
  }

  // ✅ Fetch and store cartId after adding
  Future<void> _fetchAndStoreCartId() async {
    try {
      final catering_Cart? cart = await catering_authservice.fetchUserCart();
      if (cart == null || cart.items.isEmpty) return;

      final packageId = widget.package.id;

      CartPackage? packageInCart;
      for (final item in cart.items) {
        if (item.packageId == packageId) {
          packageInCart = item;
          break;
        }
      }

      if (packageInCart != null) {
        cartId = cart.id;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("package_${packageId}_cartId", cartId!);
      }
    } catch (e) {
      debugPrint("❌ Error fetching cart ID: $e");
    }
  }

  // ✅ Update cart quantity
  Future<bool> _updateCartQuantity(int quantity) async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final packageId = widget.package.id;
      final currentCartId =
          cartId ?? prefs.getInt("package_${packageId}_cartId");

      if (currentCartId == null) {
        debugPrint("❌ No cart ID found for update");
        return false;
      }

      debugPrint(
        "📦 Updating cart → cartId: $currentCartId, packageId: $packageId, qty: $quantity",
      );

      final success = await catering_authservice.updateCartQuantity(
        cartId: currentCartId,
        userId: userId,
        packageId: packageId,
        quantity: quantity,
      );

      if (success) {
        await prefs.setInt("package_${packageId}_quantity", quantity);
        setState(() => itemCount = quantity);
        await _refreshGlobalCount();
        debugPrint("✅ Cart quantity updated successfully");
        return true;
      } else {
        debugPrint("❌ Backend update failed");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error updating cart quantity: $e");
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Remove from cart
  Future<void> _handleRemoveFromCart() async {
    try {
      setState(() => _isLoading = true);

      final removed = await catering_authservice.clearCart();

      if (removed) {
        setState(() {
          itemCount = 0;
          cartId = null;
        });

        CartNotifier.count.value = 0;

        AppAlert.success(context, "Item removed from cart");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshGlobalCount() async {
    try {
      final catering_Cart? cart = await catering_authservice.fetchUserCart();
      if (cart != null) {
        _updateGlobalItemCount(cart.items);
      }
    } catch (e) {
      debugPrint("❌ Error refreshing global count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 40,
      child: _isLoading
          ? Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.of(context).primary,
                  strokeWidth: 2,
                ),
              ),
            )
          : itemCount == 0
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                setState(() => _isLoading = true);

                final success = await _handleAddToCart(1);

                setState(() => _isLoading = false);

                if (success) {
                  setState(() {
                    itemCount = 1;
                  });

                  // 🔥 GLOBAL SYNC FIX
                  CartNotifier.count.value = CartNotifier.count.value + 1;
                }
              },
              child: Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Container(
              width: 120,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.of(context).primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () async {
                      if (itemCount > 1) {
                        final newCount = itemCount - 1;
                        setState(() => itemCount = newCount);
                        await _updateCartQuantity(newCount);
                      } else {
                        await _handleRemoveFromCart();
                      }
                    },
                  ),
                  Text(
                    "$itemCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    onPressed: () async {
                      final newCount = itemCount + 1;

                      setState(() => itemCount = newCount);

                      final success = await _updateCartQuantity(newCount);

                      if (success) {
                        CartNotifier.count.value = CartNotifier.count.value + 1;
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
