// // import '../../Models/promotions_model/promotions_model.dart';
// // import '../../Services/Auth_service/Subscription_authservice.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../Services/Auth_service/food_authservice.dart';
// // import '../../Services/Auth_service/promotion_services_Authservice.dart';
// // import '../../Services/paymentservice/razorpayservice.dart';
// // import '../../Services/websockets/web_socket_manager.dart';
// // import '../../widgets/widgets/skeleton/cart_skeleton.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../../Services/scaffoldmessenger/messenger.dart';
// // import 'package:maamaas/screens/foodmainscreen.dart';
// // import 'package:maamaas/widgets/signinrequired.dart';
// // import '../../Models/subscrptions/coupon_model.dart';
// // import '../../Models/subscrptions/wallet_model.dart';
// // import '../../providers/addressmodel_provider.dart';
// // import '../../widgets/widgets/cart wallet.dart';
// // import '../../Models/food/cart_model.dart';
// // import '../screens/advertisements/banneradvertisement.dart';
// // import '../screens/ordertypebutton.dart';
// // import 'package:flutter/gestures.dart';
// // import 'package:flutter/material.dart';
// // import '../screens/saved_address.dart';
// // import 'Menu/menu_screen.dart';
// // import 'food_invoice.dart';
// //
// // // ── Design tokens ─────────────────────────────────────────────────────────────
// // class _C {
// //   static const bg = Color(0xFFF5F6FA);
// //   static const surface = Color(0xFFFFFFFF);
// //   static const border = Color(0xFFE8ECF4);
// //
// //   static const violet = Color(0xFF6C63FF);
// //   static const violetDim = Color(0x1A6C63FF);
// //
// //   static const textPrimary = Color(0xFF1A1D2E);
// //   static const textSecondary = Color(0xFF64748B);
// //   static const textMuted = Color(0xFFB0B8CC);
// //
// //   static const green = Color(0xFF10B981);
// //   static const red = Color(0xFFEF4444);
// //   static const amber = Color(0xFFF59E0B);
// // }
// //
// // // Add inside _food_cartScreenState class
// // String? _safeStr(dynamic v) {
// //   if (v == null) return null;
// //   if (v is String) return v;
// //   if (v is num || v is bool) return v.toString();
// //   if (v is Map) {
// //     return v['url']?.toString() ?? v['path']?.toString() ?? v.toString();
// //   }
// //   return null;
// // }
// //
// // String _safeStrOr(dynamic v, [String fallback = '']) => _safeStr(v) ?? fallback;
// //
// // // ignore: camel_case_types
// // class food_cartScreen extends ConsumerStatefulWidget {
// //   final int? vendorId;
// //   final int? cartId;
// //   final double? savedAmount;
// //   final bool showSavedPopup;
// //
// //   const food_cartScreen({
// //     super.key,
// //     this.vendorId,
// //     this.cartId,
// //     this.savedAmount,
// //     this.showSavedPopup = false,
// //   });
// //
// //   @override
// //   ConsumerState<food_cartScreen> createState() => _food_cartScreenState();
// // }
// //
// // // ignore: camel_case_types
// // class _food_cartScreenState extends ConsumerState<food_cartScreen> {
// //   CartModel? cartData;
// //   bool isLoading = true;
// //   bool isPlacingOrder = false;
// //   bool couponApplied = false;
// //   String selectedPaymentMethod = "";
// //   String couponCode = "";
// //   bool isExpanded = false;
// //   Wallet? wallet;
// //   int? appliedCouponId;
// //   String? appliedCouponCode;
// //   DateTime? _selectedDate;
// //   TimeOfDay? _selectedTime;
// //   late ScrollController _scrollController;
// //   String _orderType = "";
// //   final bool _isPlacingOrder = false;
// //   bool isCouponLoading = false;
// //   Set<String> selectedSubWallets = {};
// //   int userId = 0;
// //   List<Campaign> homepageAds = [];
// //   bool _isSummaryExpanded = false;
// //   final List<Map<String, dynamic>> _pendingSocketUpdates = [];
// //
// //   // ── Payment UI overlay states ──────────────────────────────────────────
// //   bool _isRazorpayLoading = false; // "Opening payment gateway…"
// //   bool _isProcessingPayment = false; // "Confirming your payment…"
// //   bool _showOrderSuccess = false; // animated success before invoice nav
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _scrollController = ScrollController();
// //     _loadWallet();
// //     _loadCart();
// //     _initCartSocket();
// //     _loadAds();
// //     if (cartData?.hasAnyScheduledItem ?? false) {
// //       _orderType = 'schedule';
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     WebSocketManager().unsubscribeUserCart(userId);
// //     super.dispose();
// //   }
// //
// //   Future<void> _loadWallet() async {
// //     try {
// //       final w = await subscription_AuthService.fetchWallet();
// //       if (!mounted) return;
// //       setState(() => wallet = w);
// //     } catch (_) {
// //       if (!mounted) return;
// //       AppAlert.error(context, "❌ Failed to load wallet");
// //     }
// //   }
// //
// //   List<String> mapWalletsToEnum(List<String> s) => s.map((w) {
// //     switch (w) {
// //       case "Cashbacks":
// //         return "CASHBACK";
// //       case "Self Loaded":
// //         return "SELF_LOADED";
// //       case "Postpaid used amount":
// //         return "POST_PAID";
// //       case "Company Loaded":
// //         return "COMPANY_LOADED";
// //       case "Earned Amount":
// //         return "EARNED_AMOUNT";
// //       default:
// //         return w.toUpperCase().replaceAll(' ', '_');
// //     }
// //   }).toList();
// //
// //   void _initCartSocket() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     userId = prefs.getInt('userId') ?? 0;
// //     WebSocketManager().subscribeUserCart(userId, _updateCartFromSocket);
// //   }
// //
// //   void _flushPendingSocketUpdates() {
// //     for (final update in _pendingSocketUpdates) {
// //       _applySocketUpdate(update);
// //     }
// //     _pendingSocketUpdates.clear();
// //   }
// //
// //   void _applySocketUpdate(Map<String, dynamic> data) {
// //     print("🟡 RAW SOCKET DATA: $data");
// //     final List items = data['cartItems'] ?? [];
// //
// //     if (!mounted) return;
// //
// //     setState(() {
// //       cartData!.cartItems = items.map((json) {
// //         final idx = cartData!.cartItems.indexWhere(
// //           (i) => i.itemId == json['itemId'],
// //         );
// //
// //         if (idx != -1) {
// //           final old = cartData!.cartItems[idx];
// //           // ✅ Create a NEW object so Flutter detects the change
// //           return CartItem(
// //             itemId: old.itemId,
// //             dishName: old.dishName,
// //             dishId: old.dishId,
// //             chefType: old.chefType,
// //             dishImage: old.dishImage,
// //             actualPrice: (json['actualPrice'] ?? old.actualPrice).toDouble(),
// //             gst: (json['gst'] ?? old.gst).toDouble(),
// //             quantity: json['quantity'] ?? old.quantity,
// //             price: (json['price'] ?? old.price).toDouble(),
// //             totalPrice: (json['totalPrice'] ?? old.totalPrice).toDouble(),
// //             packingCharges: (json['packingCharges'] ?? old.packingCharges)
// //                 .toDouble(),
// //             balanceQuantity: json['balanceQuantity'] ?? old.balanceQuantity,
// //             available: json['available'] ?? old.available,
// //             shedule: json.containsKey('shedule')
// //                 ? json['shedule'] == true
// //                 : old.shedule,
// //           );
// //         }
// //
// //         return CartItem.fromJson(json);
// //       }).toList();
// //
// //       final rawCoupon = data['couponCode'];
// //
// //       cartData!.subtotal = (data['subtotal'] ?? 0).toDouble();
// //       cartData!.gstTotal = (data['gstTotal'] ?? 0).toDouble();
// //       cartData!.packingTotal = (data['packingTotal'] ?? 0).toDouble();
// //       cartData!.platformCharges = (data['platformCharges'] ?? 0).toDouble();
// //       cartData!.deliveryCharges = (data['deliveryCharges'] ?? 0).toDouble();
// //       cartData!.discountAmount = (data['discountAmount'] ?? 0).toDouble();
// //       cartData!.grandTotal = (data['grandTotal'] ?? 0).toDouble();
// //       cartData!.cgst = (data['cgst'] ?? 0).toDouble();
// //       cartData!.sgst = (data['sgst'] ?? 0).toDouble();
// //       cartData!.deliveryAddress =
// //           data['deliveryAddress'] ?? cartData!.deliveryAddress;
// //       cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
// //       cartData!.name = data['name'] ?? cartData!.name;
// //       // cartData!.couponCode = data['couponCode'];
// //
// //       cartData!.couponCode = rawCoupon is String
// //           ? rawCoupon
// //           : rawCoupon is Map
// //           ? rawCoupon['code']
// //           : null;
// //     });
// //   }
// //
// //   void _updateCartFromSocket(Map<String, dynamic> data) {
// //     print("🟡 RAW SOCKET DATA: $data");
// //
// //     if (cartData == null) {
// //       print("❌ cartData is NULL → skipping update");
// //       return;
// //     }
// //
// //     final List items = data['cartItems'] ?? [];
// //     print("📦 Incoming cart items count: ${items.length}");
// //
// //     setState(() {
// //       cartData!.cartItems = items.map((json) {
// //         print("➡️ Processing item: $json");
// //
// //         final idx = cartData!.cartItems.indexWhere(
// //           (i) => i.itemId == json['itemId'],
// //         );
// //
// //         if (idx != -1) {
// //           final item = cartData!.cartItems[idx];
// //
// //           print("🔁 Updating existing item: ${item.itemId}");
// //           print(
// //             "   OLD -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
// //           );
// //
// //           item.quantity = json['quantity'] ?? item.quantity;
// //           item.totalPrice = (json['totalPrice'] ?? item.totalPrice).toDouble();
// //           item.price = (json['price'] ?? item.price).toDouble();
// //           item.packingCharges = (json['packingCharges'] ?? item.packingCharges)
// //               .toDouble();
// //
// //           if (json.containsKey('shedule')) {
// //             item.shedule = json['shedule'] == true;
// //           } else {
// //             print("⚠️shedule missing from socket, keeping old value");
// //           }
// //
// //           print("UPDATED isScheduled: ${item.shedule}");
// //           print(
// //             "NEW -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
// //           );
// //
// //           return item;
// //         }
// //
// //         print("🆕 New item added: ${json['itemId']}");
// //         return CartItem.fromJson(json);
// //       }).toList();
// //
// //       final rawCoupon = data['couponCode'];
// //
// //       // prices ...
// //       cartData!.subtotal = (data['subtotal'] ?? 0).toDouble();
// //       cartData!.gstTotal = (data['gstTotal'] ?? 0).toDouble();
// //       cartData!.packingTotal = (data['packingTotal'] ?? 0).toDouble();
// //       cartData!.platformCharges = (data['platformCharges'] ?? 0).toDouble();
// //       cartData!.deliveryCharges = (data['deliveryCharges'] ?? 0).toDouble();
// //       cartData!.discountAmount = (data['discountAmount'] ?? 0).toDouble();
// //       cartData!.grandTotal = (data['grandTotal'] ?? 0).toDouble();
// //       cartData!.cgst = (data['cgst'] ?? 0).toDouble();
// //       cartData!.sgst = (data['sgst'] ?? 0).toDouble();
// //
// //       // cartData!.deliveryAddress =
// //       //     data['deliveryAddress'] ?? cartData!.deliveryAddress;
// //       // cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
// //       // cartData!.name = data['name'] ?? cartData!.name;
// //       // cartData!.couponCode = data['couponCode'];
// //
// //       cartData!.deliveryAddress = _safeStrOr(data['deliveryAddress']).isNotEmpty
// //           ? _safeStrOr(data['deliveryAddress'])
// //           : cartData!.deliveryAddress;
// //       cartData!.mobileNo = _safeStrOr(data['mobileNo']).isNotEmpty
// //           ? _safeStrOr(data['mobileNo'])
// //           : cartData!.mobileNo;
// //       cartData!.name = _safeStrOr(data['name']).isNotEmpty
// //           ? _safeStrOr(data['name'])
// //           : cartData!.name;
// //       cartData!.couponCode = rawCoupon is String
// //           ? rawCoupon
// //           : rawCoupon is Map
// //           ? rawCoupon['code']
// //           : null;
// //
// //       // // ✅ FIX: Re-sync _orderType after items update
// //       // if (cartData!.hasAnyScheduledItem) {
// //       //   _orderType = 'schedule';
// //       //   print("🚨 Socket update: orderType set to schedule");
// //       // } else if (_orderType == 'schedule') {
// //       //   // All scheduled items removed — revert to default
// //       //   _orderType = cartData!.orderType.toLowerCase(); // e.g. 'delivery'
// //       //   print("🔄 Socket update: no scheduled items, reverting orderType");
// //       // }
// //     });
// //
// //     // print("✅ Cart UI updated successfully\n");
// //     // _loadCart();
// //   }
// //
// //   Future<void> _loadCart() async {
// //     setState(() => isLoading = true);
// //     try {
// //       final c = await food_Authservice.fetchCart();
// //       if (mounted) {
// //         setState(() {
// //           cartData = c;
// //
// //           print("📦 Cart Loaded:");
// //           print("   Total Items: ${cartData?.cartItems.length}");
// //
// //           for (var item in cartData!.cartItems) {
// //             print("   👉 ${item.dishName} → isScheduled: ${item.shedule}");
// //           }
// //
// //           print("🔥 hasAnyScheduledItem: ${cartData?.hasAnyScheduledItem}");
// //
// //           // ✅ Sync orderType from loaded cart
// //           if (cartData?.hasAnyScheduledItem ?? false) {
// //             _orderType = 'schedule';
// //             print("🚨 _loadCart: orderType set to schedule");
// //           }
// //
// //           isLoading = false;
// //         });
// //         _flushPendingSocketUpdates();
// //       }
// //     } catch (_) {
// //       if (mounted) setState(() => isLoading = false);
// //     }
// //   }
// //
// //   double getSelectedWalletBalance() {
// //     if (wallet == null) return 0;
// //     double t = 0;
// //     if (selectedSubWallets.contains("Company Loaded")) {
// //       t += wallet!.companyLoadedAmount;
// //     }
// //     if (selectedSubWallets.contains("Self Loaded")) {
// //       t += wallet!.selfLoadedAmount;
// //     }
// //     if (selectedSubWallets.contains("Cashbacks")) t += wallet!.cashbackAmount;
// //     if (selectedSubWallets.contains("Postpaid used amount")) {
// //       t += wallet!.postPaidUsage;
// //     }
// //     return t;
// //   }
// //
// //   Future<void> placeOrder() async {
// //     final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
// //     if (hasScheduledItems && (_selectedDate == null || _selectedTime == null)) {
// //       AppAlert.error(
// //         context,
// //         "📅 Please select date & time to schedule your order",
// //       );
// //       return;
// //     }
// //
// //     if ((cartData?.orderType ?? '').trim().toLowerCase() == 'delivery') {
// //       if ((cartData?.deliveryAddress ?? '').trim().isEmpty) {
// //         AppAlert.error(context, "⚠️ Please select delivery address");
// //         return;
// //       }
// //     }
// //     if (selectedPaymentMethod == "Maamaas_Wallet") {
// //       final wb = getSelectedWalletBalance();
// //       final gt = (cartData?.grandTotal ?? 0).toDouble();
// //       if (wb < gt) {
// //         AppAlert.error(
// //           context,
// //           "❌ Insufficient wallet balance\nWallet: ₹${wb.toStringAsFixed(2)}\nOrder Total: ₹${gt.toStringAsFixed(2)}",
// //         );
// //         return;
// //       }
// //     }
// //     if (selectedPaymentMethod.isEmpty) {
// //       AppAlert.error(context, "⚠️ Please select a payment method");
// //       return;
// //     }
// //
// //     setState(() => isPlacingOrder = true);
// //     try {
// //       final bool isUserScheduled =
// //           _selectedDate != null || _selectedTime != null;
// //
// //       if (selectedPaymentMethod == "Online_Payment") {
// //         final amount = (cartData?.grandTotal ?? 0).toDouble();
// //         final orderId = await food_Authservice.createOrder(amount);
// //         if (orderId == null) {
// //           AppAlert.error(context, "❌ Failed to create payment order");
// //           return;
// //         }
// //         final rp = RazorpayService();
// //         rp.onSuccess = (res) async {
// //           final pid = res.paymentId!;
// //           final oid = res.orderId!;
// //           // ── Show "processing payment" overlay ──────────────────────────
// //           if (mounted) setState(() => _isProcessingPayment = true);
// //           final ok = isUserScheduled
// //               ? await _placeScheduledOrder(
// //                   paymentMethod: "Online_Payment",
// //                   razorpayPaymentId: pid,
// //                   razorpayOrderId: oid,
// //                   amount: amount,
// //                 )
// //               : await _placeDirectOrder(
// //                   paymentMethod: "Online_Payment",
// //                   razorpayPaymentId: pid,
// //                   razorpayOrderId: oid,
// //                   amount: amount,
// //                 );
// //           if (mounted) setState(() => _isProcessingPayment = false);
// //           if (ok) {
// //             final captured = await food_Authservice.capturePayment(
// //               paymentId: pid,
// //               amount: amount,
// //             );
// //             if (!captured) {
// //               AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
// //             }
// //           } else {
// //             AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
// //           }
// //         };
// //         rp.onError = (res) {
// //           if (mounted) setState(() => _isRazorpayLoading = false);
// //           AppAlert.error(context, "Payment failed: ${res.message}");
// //         };
// //         // ── Show "opening gateway" overlay, hide when Razorpay sheet appears
// //         if (mounted) setState(() => _isRazorpayLoading = true);
// //         await Future.delayed(const Duration(milliseconds: 700));
// //         if (mounted) setState(() => _isRazorpayLoading = false);
// //         rp.startPayment(
// //           orderId: orderId,
// //           amount: amount,
// //           description: "Online Payment via Razorpay",
// //         );
// //         return;
// //       }
// //
// //       final amt = cartData!.grandTotal.toDouble();
// //       if (isUserScheduled) {
// //         await _placeScheduledOrder(
// //           paymentMethod: selectedPaymentMethod,
// //           razorpayPaymentId: "",
// //           razorpayOrderId: "",
// //           amount: amt,
// //         );
// //       } else {
// //         await _placeDirectOrder(
// //           paymentMethod: selectedPaymentMethod,
// //           razorpayPaymentId: "",
// //           razorpayOrderId: "",
// //           amount: amt,
// //         );
// //       }
// //     } catch (e) {
// //       debugPrint("❌ Place Order Error: $e");
// //
// //       String message = "Error placing order";
// //
// //       if (e.toString().contains("Exception:")) {
// //         message = e.toString().replaceFirst("Exception: ", "");
// //       } else {
// //         message = e.toString();
// //       }
// //
// //       AppAlert.error(context, message);
// //     } finally {
// //       if (mounted) setState(() => isPlacingOrder = false);
// //     }
// //   }
// //
// //   Future<bool> _placeScheduledOrder({
// //     required String paymentMethod,
// //     required String razorpayPaymentId,
// //     required String razorpayOrderId,
// //     required double amount,
// //   }) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final cartId = prefs.getInt('cartId');
// //     if (cartId == null) return false;
// //     final result = await food_Authservice.scheduleOrder(
// //       cartId: cartId,
// //       date: _selectedDate ?? DateTime.now(),
// //       time: _selectedTime ?? TimeOfDay.now(),
// //       paymentMethod: paymentMethod,
// //       razorpayPaymentId: razorpayPaymentId,
// //       razorpayOrderId: razorpayOrderId,
// //       walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
// //       amount: amount,
// //     );
// //     if (result.containsKey('orderId')) {
// //       final oid = result['orderId'];
// //       await prefs.setInt('orderId', oid);
// //       if (mounted) {
// //         setState(() => _showOrderSuccess = true);
// //         await Future.delayed(const Duration(milliseconds: 2200));
// //         if (mounted) {
// //           Navigator.pushReplacement(
// //             context,
// //             MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
// //           );
// //         }
// //       }
// //       return true;
// //     }
// //     return false;
// //   }
// //
// //   Future<bool> _placeDirectOrder({
// //     required String paymentMethod,
// //     required String razorpayPaymentId,
// //     required String razorpayOrderId,
// //     required double amount,
// //   }) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final cartId = prefs.getInt('cartId');
// //     if (cartId == null) return false;
// //     final result = await food_Authservice.placeDirectOrder(
// //       cartId: cartId,
// //       paymentMethod: paymentMethod,
// //       razorpayPaymentId: razorpayPaymentId,
// //       razorpayOrderId: razorpayOrderId,
// //       walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
// //       amount: amount,
// //     );
// //     if (result.containsKey('orderId')) {
// //       final oid = result['orderId'];
// //       await prefs.setInt('orderId', oid);
// //       if (mounted) {
// //         setState(() => _showOrderSuccess = true);
// //         await Future.delayed(const Duration(milliseconds: 2200));
// //         if (mounted) {
// //           Navigator.pushReplacement(
// //             context,
// //             MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
// //           );
// //         }
// //       }
// //       return true;
// //     }
// //     return false;
// //   }
// //
// //   Future<void> changeQuantity(CartItem item, int newQty) async {
// //     final old = item.quantity;
// //     setState(() => item.quantity = newQty);
// //     final ok = await food_Authservice.updateCartQuantity(item.itemId, newQty);
// //     if (!ok) {
// //       setState(() {
// //         item.quantity = old;
// //         item.totalPrice = item.price * old;
// //       });
// //     }
// //   }
// //
// //   Future<void> _onRefresh() async {
// //     final c = await food_Authservice.fetchCart();
// //     final w = await subscription_AuthService.fetchWallet();
// //     if (!mounted) return;
// //     setState(() {
// //       cartData = c;
// //       wallet = w;
// //     });
// //   }
// //
// //   Future<void> _loadAds() async {
// //     try {
// //       final result = await promotion_Authservice.fetchcampaign();
// //       setState(
// //         () => homepageAds = result
// //             .where(
// //               (c) =>
// //                   c.status == Status.ACTIVE &&
// //                   c.approvalStatus == ApprovalStatus.APPROVED &&
// //                   c.addDisplayPosition == AddDisplayPosition.CHECKOUT_PAGE,
// //             )
// //             .toList(),
// //       );
// //     } catch (_) {}
// //   }
// //
// //   String _fmt(num? v) => (v ?? 0).toStringAsFixed(2);
// //
// //   // ═══════════════════════════════════════════════════════════════════════════
// //   @override
// //   Widget build(BuildContext context) {
// //     final grandTotal = cartData?.grandTotal ?? 0;
// //     ScreenUtil.init(context);
// //     return Stack(
// //       children: [
// //         Scaffold(
// //           backgroundColor: _C.bg,
// //           appBar: _buildAppBar(),
// //           body: AuthGuard(
// //             child: SafeArea(
// //               child: RefreshIndicator(
// //                 onRefresh: _onRefresh,
// //                 color: _C.violet,
// //                 backgroundColor: _C.surface,
// //                 child: isLoading
// //                     ? SingleChildScrollView(
// //                         physics: const AlwaysScrollableScrollPhysics(),
// //                         padding: EdgeInsets.all(16.w),
// //                         child: const CartSkeleton(
// //                           type: CartSkeletonType.fullCart,
// //                         ),
// //                       )
// //                     : SingleChildScrollView(
// //                         controller: _scrollController,
// //                         physics: const AlwaysScrollableScrollPhysics(),
// //                         padding: EdgeInsets.symmetric(
// //                           horizontal: 16.w,
// //                           vertical: 12.h,
// //                         ),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             if (cartData == null || cartData!.cartItems.isEmpty)
// //                               _buildEmptyCart()
// //                             else ...[
// //                               _buildCartItems(),
// //                               SizedBox(height: 10.h),
// //                               _buildAddMoreText(),
// //                               SizedBox(height: 12.h),
// //
// //                               OrderCartFooter(
// //                                 onOrderTypeChanged: () async {
// //                                   final c = await food_Authservice.fetchCart();
// //                                   setState(() => cartData = c);
// //                                 },
// //                               ),
// //
// //                               // ── Ads banner ───────────────────────────
// //                               if (homepageAds.isNotEmpty) ...[
// //                                 SizedBox(height: 12.h),
// //                                 _sectionLabel('Recommended for you'),
// //                                 SizedBox(height: 8.h),
// //                                 ClipRRect(
// //                                   borderRadius: BorderRadius.circular(16.r),
// //                                   child: BannerAdvertisement(
// //                                     ads: homepageAds,
// //                                     height: 160,
// //                                   ),
// //                                 ),
// //                               ],
// //
// //                               SizedBox(height: 12.h),
// //                               _buildCouponRow(),
// //                               SizedBox(height: 10.h),
// //
// //                               if ((cartData?.orderType ?? '')
// //                                       .trim()
// //                                       .toLowerCase() ==
// //                                   'delivery')
// //                                 _buildDeliveryAddress(),
// //
// //                               SizedBox(height: 10.h),
// //                               _buildSummaryCard(),
// //                               SizedBox(height: 12.h),
// //                               _buildScheduleOrder(),
// //                               SizedBox(height: 12.h),
// //                               _buildPaymentToggle(),
// //                               if (isExpanded) ...[
// //                                 SizedBox(height: 12.h),
// //                                 _buildCheckoutDetails(),
// //                               ],
// //                               SizedBox(height: 24.h),
// //                             ],
// //                           ],
// //                         ),
// //                       ),
// //               ),
// //             ),
// //           ),
// //         ),
// //         if (_isPlacingOrder)
// //           Positioned.fill(
// //             child: AbsorbPointer(
// //               child: Container(
// //                 color: Colors.black.withOpacity(0.35),
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: _C.violet),
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //         // ── Razorpay opening overlay ──────────────────────────────────────
// //         if (_isRazorpayLoading)
// //           Positioned.fill(
// //             child: AbsorbPointer(child: _RazorpayLoadingOverlay()),
// //           ),
// //
// //         // ── Payment processing overlay ────────────────────────────────────
// //         if (_isProcessingPayment)
// //           Positioned.fill(
// //             child: AbsorbPointer(child: _PaymentProcessingOverlay()),
// //           ),
// //
// //         // ── Order success overlay ─────────────────────────────────────────
// //         if (_showOrderSuccess)
// //           Positioned.fill(
// //             child: AbsorbPointer(
// //               child: _OrderSuccessOverlay(
// //                 grandTotal: (cartData?.grandTotal ?? 0.0).toDouble(),
// //               ),
// //             ),
// //           ),
// //       ],
// //     );
// //   }
// //
// //   // ── AppBar ──────────────────────────────────────────────────────────────
// //   PreferredSizeWidget _buildAppBar() {
// //     return AppBar(
// //       backgroundColor: _C.surface,
// //       elevation: 0,
// //       centerTitle: true,
// //       title: Text(
// //         'Review Your Cart',
// //         style: TextStyle(
// //           fontSize: 17.sp,
// //           fontWeight: FontWeight.w700,
// //           color: _C.textPrimary,
// //         ),
// //       ),
// //       iconTheme: const IconThemeData(color: _C.textPrimary),
// //       actions: [
// //         GestureDetector(
// //           onTap: () async {
// //             final ok = await food_Authservice.deleteCart();
// //             if (!mounted) return;
// //             if (ok) {
// //               Navigator.pushReplacement(
// //                 context,
// //                 MaterialPageRoute(builder: (_) => MainScreenfood()),
// //               );
// //               AppAlert.success(context, 'Cart cleared');
// //             } else {
// //               AppAlert.error(context, 'Failed to clear cart');
// //             }
// //           },
// //           child: Container(
// //             margin: EdgeInsets.only(right: 12.w),
// //             padding: EdgeInsets.all(8.w),
// //             decoration: BoxDecoration(
// //               color: _C.red.withOpacity(0.08),
// //               shape: BoxShape.circle,
// //               border: Border.all(color: _C.red.withOpacity(0.2)),
// //             ),
// //             child: Icon(
// //               Icons.delete_outline_rounded,
// //               size: 18.sp,
// //               color: _C.red,
// //             ),
// //           ),
// //         ),
// //       ],
// //       bottom: PreferredSize(
// //         preferredSize: const Size.fromHeight(1),
// //         child: Container(height: 1, color: _C.border),
// //       ),
// //     );
// //   }
// //
// //   // ── Section label ───────────────────────────────────────────────────────
// //   Widget _sectionLabel(String text) {
// //     return Text(
// //       text,
// //       style: TextStyle(
// //         fontSize: 14.sp,
// //         fontWeight: FontWeight.w700,
// //         color: _C.textPrimary,
// //       ),
// //     );
// //   }
// //
// //   // ── Cart items card ─────────────────────────────────────────────────────
// //   Widget _buildCartItems() {
// //     if (cartData == null || cartData!.cartItems.isEmpty) {
// //       return const SizedBox.shrink();
// //     }
// //
// //     return _card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           ...cartData!.cartItems.map((item) {
// //             final isLast = item == cartData!.cartItems.last;
// //             return Column(
// //               key: ValueKey(item.itemId),
// //               children: [
// //                 Padding(
// //                   padding: EdgeInsets.symmetric(vertical: 10.h),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         child: Text(
// //                           item.dishName,
// //                           maxLines: 2,
// //                           overflow: TextOverflow.ellipsis,
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             fontWeight: FontWeight.w600,
// //                             color: _C.textPrimary,
// //                           ),
// //                         ),
// //                       ),
// //
// //                       SizedBox(width: 8.w),
// //
// //                       _buildQtyControl(item),
// //
// //                       SizedBox(width: 12.w),
// //
// //                       SizedBox(
// //                         width: 80.w, // ✅ FIXED WIDTH
// //                         child: Text(
// //                           '₹${item.totalPrice.toStringAsFixed(2)}',
// //                           textAlign: TextAlign.right, // ✅ ALIGN RIGHT
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             fontWeight: FontWeight.w700,
// //                             color: _C.violet,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 if (!isLast) Divider(height: 1, color: _C.border),
// //               ],
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildQtyControl(CartItem item) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: _C.bg,
// //         borderRadius: BorderRadius.circular(10.r),
// //         border: Border.all(color: _C.border),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           _qtyBtn(
// //             Icons.remove_rounded,
// //             _C.red,
// //             () => changeQuantity(item, item.quantity - 1),
// //           ),
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 10.w),
// //             child: Text(
// //               '${item.quantity}',
// //               style: TextStyle(
// //                 fontSize: 13.sp,
// //                 fontWeight: FontWeight.w700,
// //                 color: _C.textPrimary,
// //               ),
// //             ),
// //           ),
// //           _qtyBtn(
// //             Icons.add_rounded,
// //             _C.green,
// //             () => changeQuantity(item, item.quantity + 1),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _qtyBtn(IconData icon, Color color, VoidCallback onTap) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: EdgeInsets.all(6.w),
// //         decoration: BoxDecoration(
// //           color: color.withOpacity(0.10),
// //           borderRadius: BorderRadius.circular(8.r),
// //         ),
// //         child: Icon(icon, size: 14.sp, color: color),
// //       ),
// //     );
// //   }
// //
// //   // ── "Add more items" text ───────────────────────────────────────────────
// //   Widget _buildAddMoreText() {
// //     return Center(
// //       child: RichText(
// //         text: TextSpan(
// //           text: 'Missed something? ',
// //           style: TextStyle(fontSize: 13.sp, color: _C.textSecondary),
// //           children: [
// //             TextSpan(
// //               text: 'Add more items',
// //               style: TextStyle(
// //                 fontSize: 13.sp,
// //                 fontWeight: FontWeight.w700,
// //                 color: _C.violet,
// //                 decoration: TextDecoration.underline,
// //               ),
// //               recognizer: TapGestureRecognizer()
// //                 ..onTap = () => Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (_) => MenuScreen(vendorId: cartData!.vendorId),
// //                   ),
// //                 ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Coupon row ──────────────────────────────────────────────────────────
// //   Widget _buildCouponRow() {
// //     final applied = (cartData?.couponCode ?? '').isNotEmpty;
// //
// //     return GestureDetector(
// //       onTap: applied ? null : _showCouponBottomSheet,
// //       child: _card(
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 36.r,
// //               height: 36.r,
// //               decoration: BoxDecoration(
// //                 color: applied ? _C.green.withOpacity(0.10) : _C.violetDim,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 applied
// //                     ? Icons.check_circle_rounded
// //                     : Icons.local_offer_rounded,
// //                 size: 18.sp,
// //                 color: applied ? _C.green : _C.violet,
// //               ),
// //             ),
// //             SizedBox(width: 12.w),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     applied ? 'Coupon Applied' : 'Apply Coupon',
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: applied ? _C.green : _C.textPrimary,
// //                     ),
// //                   ),
// //                   if (applied)
// //                     Text(
// //                       appliedCouponCode ?? '',
// //                       style: TextStyle(
// //                         fontSize: 11.sp,
// //                         color: _C.textSecondary,
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //             if (applied)
// //               GestureDetector(
// //                 onTap: () async {
// //                   if (cartData?.cartId == null) return;
// //                   final result = await food_Authservice.updateCartSettings(
// //                     cartId: cartData!.cartId,
// //                     couponId: cartData!.couponId,
// //                     applyCoupon: "NOT_APPLIED",
// //                   );
// //                   if (!result.success) {
// //                     AppAlert.error(context, "Failed to remove coupon");
// //                     return;
// //                   }
// //                   setState(() {
// //                     appliedCouponCode = null;
// //                     appliedCouponId = null;
// //                   });
// //                   AppAlert.success(context, "Coupon removed");
// //                 },
// //                 child: Container(
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: 10.w,
// //                     vertical: 5.h,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: _C.red.withOpacity(0.08),
// //                     borderRadius: BorderRadius.circular(20.r),
// //                     border: Border.all(color: _C.red.withOpacity(0.2)),
// //                   ),
// //                   child: Text(
// //                     'Remove',
// //                     style: TextStyle(
// //                       fontSize: 11.sp,
// //                       color: _C.red,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //               )
// //             else
// //               Icon(
// //                 Icons.chevron_right_rounded,
// //                 size: 20.sp,
// //                 color: _C.textMuted,
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _showCouponBottomSheet() async {
// //     setState(() => isCouponLoading = true);
// //     final coupons = await food_Authservice.fetchCoupons();
// //     final cartVendor = cartData?.vendorId;
// //     setState(() => isCouponLoading = false);
// //
// //     coupons.sort((a, b) {
// //       if (a.isExpired != b.isExpired) return a.isExpired ? 1 : -1;
// //       final am = !a.isApplicableForVendor(cartVendor);
// //       final bm = !b.isApplicableForVendor(cartVendor);
// //       if (am != bm) return am ? 1 : -1;
// //       return 0;
// //     });
// //
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (ctx) => Scaffold(
// //         backgroundColor: Colors.transparent,
// //         body: SafeArea(
// //           top: false,
// //           child: Container(
// //             height: MediaQuery.of(ctx).size.height * 1,
// //             decoration: BoxDecoration(
// //               color: _C.bg,
// //               borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
// //             ),
// //             child: Column(
// //               children: [
// //                 _couponHeader(),
// //                 coupons.isEmpty
// //                     ? Expanded(child: _emptyCouponView())
// //                     : Expanded(
// //                         child: ListView.builder(
// //                           padding: EdgeInsets.all(16.w),
// //                           itemCount: coupons.length,
// //                           itemBuilder: (_, i) {
// //                             final c = coupons[i];
// //                             return _couponTile(
// //                               coupon: c,
// //                               isExpired: c.isExpired,
// //                               isMismatch: !c.isApplicableForVendor(cartVendor),
// //                               isDisabled:
// //                                   c.isExpired ||
// //                                   !c.isApplicableForVendor(cartVendor),
// //                             );
// //                           },
// //                         ),
// //                       ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _couponHeader() {
// //     return Container(
// //       padding: EdgeInsets.fromLTRB(30.w, 20.h, 16.w, 16.h),
// //       decoration: BoxDecoration(
// //         color: _C.surface,
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
// //         border: Border(bottom: BorderSide(color: _C.border)),
// //       ),
// //       child: Row(
// //         children: [
// //           Text(
// //             'Available Coupons',
// //             style: TextStyle(
// //               fontSize: 16.sp,
// //               fontWeight: FontWeight.w800,
// //               color: _C.textPrimary,
// //             ),
// //           ),
// //           const Spacer(),
// //           GestureDetector(
// //             onTap: () => Navigator.pop(context),
// //             child: Container(
// //               padding: EdgeInsets.all(6.w),
// //               decoration: BoxDecoration(
// //                 color: _C.border,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 Icons.close_rounded,
// //                 size: 16.sp,
// //                 color: _C.textSecondary,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _couponTile({
// //     required CouponModel coupon,
// //     required bool isExpired,
// //     required bool isMismatch,
// //     required bool isDisabled,
// //   }) {
// //     final color = isExpired
// //         ? _C.red
// //         : isMismatch
// //         ? _C.amber
// //         : _C.green;
// //
// //     return Container(
// //       margin: EdgeInsets.only(bottom: 10.h),
// //       decoration: BoxDecoration(
// //         color: _C.surface,
// //         borderRadius: BorderRadius.circular(14.r),
// //         border: Border.all(color: color.withOpacity(0.3)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: ListTile(
// //         contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
// //         leading: Container(
// //           width: 38.r,
// //           height: 38.r,
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.10),
// //             shape: BoxShape.circle,
// //           ),
// //           child: Icon(Icons.local_offer_rounded, color: color, size: 18.sp),
// //         ),
// //         title: Row(
// //           children: [
// //             Text(
// //               coupon.code,
// //               style: TextStyle(
// //                 fontWeight: FontWeight.w700,
// //                 fontSize: 13.sp,
// //                 color: _C.textPrimary,
// //               ),
// //             ),
// //             SizedBox(width: 8.w),
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
// //               decoration: BoxDecoration(
// //                 color: _C.violet.withOpacity(0.08),
// //                 borderRadius: BorderRadius.circular(6.r),
// //               ),
// //               child: Text(
// //                 coupon.couponType,
// //                 style: TextStyle(
// //                   fontSize: 10.sp,
// //                   color: _C.violet,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //         subtitle: Padding(
// //           padding: EdgeInsets.only(top: 4.h),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 isExpired
// //                     ? 'Expired'
// //                     : isMismatch
// //                     ? 'Not applicable for this restaurant'
// //                     : coupon.discountType == "PERCENTAGE"
// //                     ? 'Get ${coupon.discountPercentage.toStringAsFixed(0)}% off'
// //                     : 'Get ₹${coupon.discountPercentage.toStringAsFixed(0)} off',
// //                 style: TextStyle(fontSize: 12.sp, color: color),
// //               ),
// //               if (!isExpired && !isMismatch)
// //                 Text(
// //                   coupon.minimumOrderValue <= 0
// //                       ? 'Applicable on any order'
// //                       : 'Min order ₹${coupon.minimumOrderValue.toInt()}',
// //                   style: TextStyle(fontSize: 11.sp, color: _C.textMuted),
// //                 ),
// //             ],
// //           ),
// //         ),
// //         trailing: isDisabled
// //             ? Icon(Icons.block_rounded, color: color, size: 18.sp)
// //             : Icon(
// //                 Icons.arrow_forward_ios_rounded,
// //                 size: 14.sp,
// //                 color: _C.textMuted,
// //               ),
// //         onTap: isDisabled
// //             ? () => AppAlert.error(
// //                 context,
// //                 isExpired
// //                     ? 'Coupon expired'
// //                     : 'Not applicable for this restaurant',
// //               )
// //             : () => _applyCoupon(coupon),
// //       ),
// //     );
// //   }
// //
// //   Widget _emptyCouponView() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.confirmation_number_outlined,
// //             size: 48.sp,
// //             color: _C.textMuted,
// //           ),
// //           SizedBox(height: 12.h),
// //           Text(
// //             'No coupons available',
// //             style: TextStyle(
// //               fontSize: 15.sp,
// //               fontWeight: FontWeight.w700,
// //               color: _C.textSecondary,
// //             ),
// //           ),
// //           SizedBox(height: 4.h),
// //           Text(
// //             'Check back later for new offers',
// //             style: TextStyle(fontSize: 12.sp, color: _C.textMuted),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<void> _applyCoupon(CouponModel coupon) async {
// //     if (cartData?.cartId == null) {
// //       AppAlert.error(context, "Cart is empty");
// //       return;
// //     }
// //     final result = await food_Authservice.updateCartSettings(
// //       cartId: cartData!.cartId,
// //       couponId: coupon.id,
// //       applyCoupon: "APPLIED",
// //     );
// //     if (!result.success) {
// //       AppAlert.error(context, result.error ?? "Failed to apply coupon");
// //       return;
// //     }
// //     await _loadCart();
// //     setState(() {
// //       appliedCouponCode = coupon.code;
// //       appliedCouponId = coupon.id;
// //     });
// //     AppAlert.success(context, "Coupon ${coupon.code} applied!");
// //     Navigator.pop(context);
// //   }
// //
// //   // ── Delivery address ────────────────────────────────────────────────────
// //   Widget _buildDeliveryAddress() {
// //     ref.watch(addressProvider);
// //     final hasAddr = (cartData?.deliveryAddress ?? '').trim().isNotEmpty;
// //
// //     return GestureDetector(
// //       onTap: () => Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (_) => SavedAddress(
// //             hideExtraWidgets: true,
// //             onAddressSelected: (address) async {
// //               // ✅ Update local state
// //               await ref
// //                   .read(addressProvider.notifier)
// //                   .updateLocalAddress(
// //                     city: address.city,
// //                     stateName: address.state,
// //                     pincode: address.pincode,
// //                     latitude: address.latitude,
// //                     longitude: address.longitude,
// //                     fullAddress: address.fullAddress,
// //                     category: address.category, // 🔥 important
// //                   );
// //
// //               // ✅ Update cart address (only for saved addresses)
// //               if (address.addressId != 0) {
// //                 final ok = await AddressNotifier.updateDeliveryAddress(
// //                   cartId: cartData!.cartId,
// //                   addressId: address.addressId,
// //                 );
// //
// //                 if (!ok && mounted) {
// //                   AppAlert.error(context, "Failed to update cart address");
// //                 }
// //               }
// //             },
// //           ),
// //         ),
// //       ),
// //       child: _card(
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 40.r,
// //               height: 40.r,
// //               decoration: BoxDecoration(
// //                 color: hasAddr
// //                     ? _C.violet.withOpacity(0.08)
// //                     : _C.red.withOpacity(0.08),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 Icons.location_on_rounded,
// //                 size: 20.sp,
// //                 color: hasAddr ? _C.violet : _C.red,
// //               ),
// //             ),
// //             SizedBox(width: 12.w),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     hasAddr ? 'Delivery Address' : 'Select Delivery Address',
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: _C.textPrimary,
// //                     ),
// //                   ),
// //                   if (hasAddr) ...[
// //                     SizedBox(height: 2.h),
// //                     Text(
// //                       [
// //                         cartData!.deliveryAddress,
// //                         cartData!.name,
// //                         cartData!.mobileNo,
// //                       ].where((e) => e.toString().trim().isNotEmpty).join(', '),
// //                       style: TextStyle(
// //                         fontSize: 11.sp,
// //                         color: _C.textSecondary,
// //                       ),
// //                       maxLines: 2,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     SizedBox(height: 2.h),
// //                     Text(
// //                       'Tap to change',
// //                       style: TextStyle(
// //                         fontSize: 11.sp,
// //                         color: _C.violet,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //             Icon(Icons.chevron_right_rounded, size: 20.sp, color: _C.textMuted),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Order summary card ──────────────────────────────────────────────────
// //   Widget _buildSummaryCard() {
// //     if (cartData == null || isLoading) {
// //       return CartSkeleton(type: CartSkeletonType.summary);
// //     }
// //
// //     final orderType = cartData?.orderType ?? '';
// //     final subtotal = cartData?.subtotal ?? 0;
// //     final packing = cartData?.packingTotal ?? 0;
// //     final delivery = cartData?.deliveryCharges ?? 0;
// //     final platform = cartData?.platformCharges ?? 0;
// //     final discount = cartData?.discountAmount ?? 0;
// //     final gst = cartData?.gstTotal ?? 0;
// //     final grandTotal = cartData?.grandTotal ?? 0;
// //     final type = orderType.toUpperCase();
// //
// //     return _card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Header
// //           GestureDetector(
// //             onTap: () =>
// //                 setState(() => _isSummaryExpanded = !_isSummaryExpanded),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 36.r,
// //                   height: 36.r,
// //                   decoration: BoxDecoration(
// //                     color: _C.violetDim,
// //                     borderRadius: BorderRadius.circular(10.r),
// //                   ),
// //                   child: Icon(
// //                     Icons.receipt_long_rounded,
// //                     size: 18.sp,
// //                     color: _C.violet,
// //                   ),
// //                 ),
// //                 SizedBox(width: 10.w),
// //                 Expanded(
// //                   child: Text(
// //                     'Order Summary',
// //                     style: TextStyle(
// //                       fontSize: 14.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: _C.textPrimary,
// //                     ),
// //                   ),
// //                 ),
// //                 AnimatedRotation(
// //                   turns: _isSummaryExpanded ? 0.5 : 0,
// //                   duration: const Duration(milliseconds: 200),
// //                   child: Icon(
// //                     Icons.keyboard_arrow_down_rounded,
// //                     color: _C.textSecondary,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           // Expandable details
// //           AnimatedCrossFade(
// //             duration: const Duration(milliseconds: 200),
// //             crossFadeState: _isSummaryExpanded
// //                 ? CrossFadeState.showFirst
// //                 : CrossFadeState.showSecond,
// //
// //             firstChild: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 SizedBox(height: 12.h),
// //                 Divider(height: 1, color: _C.border),
// //                 SizedBox(height: 10.h),
// //
// //                 _summaryRow('Subtotal', subtotal),
// //
// //                 if (platform > 0) _summaryRow('Platform Charges', platform),
// //
// //                 if ((type == 'DELIVERY' || type == 'TAKEAWAY') && packing > 0)
// //                   _summaryRow('Packing Charges', packing),
// //
// //                 if (orderType.toUpperCase() == 'DELIVERY')
// //                   _summaryRow('Delivery Charges', delivery),
// //
// //                 if (discount > 0)
// //                   _summaryRow('Discount', -discount, color: _C.green),
// //
// //                 if ((gst / 2) > 0) ...[
// //                   _summaryRow('SGST', gst / 2),
// //                   _summaryRow('CGST', gst / 2),
// //                 ],
// //
// //                 SizedBox(height: 4.h),
// //               ],
// //             ),
// //
// //             secondChild: const SizedBox.shrink(),
// //           ),
// //
// //           Divider(height: 16.h, color: _C.border),
// //
// //           // Grand total
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'Grand Total',
// //                 style: TextStyle(
// //                   fontSize: 15.sp,
// //                   fontWeight: FontWeight.w800,
// //                   color: _C.textPrimary,
// //                 ),
// //               ),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.end,
// //                 children: [
// //                   Text(
// //                     '₹${_fmt(grandTotal)}',
// //                     style: TextStyle(
// //                       fontSize: 15.sp,
// //                       fontWeight: FontWeight.w800,
// //                       color: _C.violet,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _summaryRow(String label, num value, {Color? color}) {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(vertical: 3.h),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(
// //             label,
// //             style: TextStyle(fontSize: 12.sp, color: _C.textSecondary),
// //           ),
// //           Text(
// //             value < 0 ? '-₹${_fmt(-value)}' : '₹${_fmt(value)}',
// //             style: TextStyle(
// //               fontSize: 12.sp,
// //               fontWeight: FontWeight.w600,
// //               color: color ?? _C.textPrimary,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Schedule order ──────────────────────────────────────────────────────
// //   Widget _buildScheduleOrder() {
// //     // bool hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
// //     final isUserScheduled =
// //         _orderType == "schedule" &&
// //         _selectedDate != null &&
// //         _selectedTime != null;
// //
// //     final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
// //
// //     return _card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           /// Header
// //           Text(
// //             "If you want Schedule your order!",
// //             style: TextStyle(
// //               fontSize: 14.sp,
// //               fontWeight: FontWeight.w700,
// //               color: _C.textPrimary,
// //             ),
// //           ),
// //           SizedBox(height: 6.h),
// //           Text(
// //             "Pick a convenient date & time",
// //             style: TextStyle(fontSize: 12.sp, color: _C.textSecondary),
// //           ),
// //
// //           SizedBox(height: 14.h),
// //
// //           if (hasScheduledItems) ...[
// //             Container(
// //               margin: EdgeInsets.only(bottom: 12.h),
// //               padding: EdgeInsets.all(12.w),
// //               decoration: BoxDecoration(
// //                 color: Colors.orange.withOpacity(0.08),
// //                 borderRadius: BorderRadius.circular(10.r),
// //                 border: Border.all(color: Colors.orange.withOpacity(0.3)),
// //               ),
// //               child: Row(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Icon(Icons.info_outline, color: Colors.orange, size: 18.sp),
// //                   SizedBox(width: 8.w),
// //                   Expanded(
// //                     child: Text(
// //                       "Some items in your cart are not available right now. Please schedule your order to continue.",
// //                       style: TextStyle(
// //                         fontSize: 12.sp,
// //                         color: _C.textPrimary,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //
// //           /// CTA Button (when not scheduled)
// //           if (!isUserScheduled)
// //             GestureDetector(
// //               onTap: () async {
// //                 setState(() {
// //                   _orderType = 'schedule';
// //                 });
// //                 await _pickScheduleDateTime();
// //               },
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(vertical: 14.h),
// //                 decoration: BoxDecoration(
// //                   color: _C.violet.withOpacity(0.08),
// //                   borderRadius: BorderRadius.circular(12.r),
// //                   border: Border.all(color: _C.violet.withOpacity(0.3)),
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Icon(Icons.access_time, color: _C.violet, size: 18.sp),
// //                     SizedBox(width: 8.w),
// //
// //                     Text(
// //                       hasScheduledItems && !isUserScheduled
// //                           ? "Schedule to Continue"
// //                           : "Choose Date & Time",
// //                       style: TextStyle(
// //                         fontSize: 13.sp,
// //                         fontWeight: FontWeight.w600,
// //                         color: _C.violet,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //
// //           /// Scheduled State UI
// //           if (isUserScheduled) ...[
// //             SizedBox(height: 12.h),
// //             Container(
// //               padding: EdgeInsets.all(14.w),
// //               decoration: BoxDecoration(
// //                 color: _C.green.withOpacity(0.06),
// //                 borderRadius: BorderRadius.circular(12.r),
// //                 border: Border.all(color: _C.green.withOpacity(0.3)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(
// //                     Icons.check_circle_rounded,
// //                     color: _C.green,
// //                     size: 20.sp,
// //                   ),
// //                   SizedBox(width: 10.w),
// //
// //                   /// Date + Time
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           "Order Scheduled 🎉",
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             fontWeight: FontWeight.w700,
// //                             color: _C.green,
// //                           ),
// //                         ),
// //                         SizedBox(height: 2.h),
// //                         Text(
// //                           '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  •  ${_selectedTime!.format(context)}',
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             color: _C.textSecondary,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //
// //                   /// Edit Button
// //                   GestureDetector(
// //                     onTap: _pickScheduleDateTime,
// //                     child: Container(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: 10.w,
// //                         vertical: 6.h,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: _C.violet.withOpacity(0.08),
// //                         borderRadius: BorderRadius.circular(8.r),
// //                         border: Border.all(color: _C.violet.withOpacity(0.2)),
// //                       ),
// //                       child: Text(
// //                         "Edit",
// //                         style: TextStyle(
// //                           fontSize: 11.sp,
// //                           fontWeight: FontWeight.w600,
// //                           color: _C.violet,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<void> _pickScheduleDateTime() async {
// //     final now = DateTime.now();
// //     final first = now.add(const Duration(minutes: 25));
// //
// //     final date = await showDatePicker(
// //       context: context,
// //       initialDate: first,
// //       firstDate: first,
// //       lastDate: now.add(const Duration(days: 365)),
// //       builder: (ctx, child) => Theme(
// //         data: Theme.of(ctx).copyWith(
// //           colorScheme: const ColorScheme.light(
// //             primary: _C.violet,
// //             onPrimary: Colors.white,
// //             onSurface: Colors.black,
// //           ),
// //           textButtonTheme: TextButtonThemeData(
// //             style: TextButton.styleFrom(foregroundColor: _C.violet),
// //           ),
// //         ),
// //         child: child!,
// //       ),
// //     );
// //     if (date == null) return;
// //
// //     while (true) {
// //       final time = await showTimePicker(
// //         context: context,
// //         initialTime: TimeOfDay.now(),
// //         builder: (ctx, child) => Theme(
// //           data: Theme.of(ctx).copyWith(
// //             timePickerTheme: TimePickerThemeData(
// //               backgroundColor: Colors.white,
// //               dialHandColor: _C.violet,
// //               dialBackgroundColor: _C.bg,
// //             ),
// //             colorScheme: const ColorScheme.light(
// //               primary: _C.violet,
// //               onPrimary: Colors.white,
// //               onSurface: Colors.black,
// //             ),
// //             textButtonTheme: TextButtonThemeData(
// //               style: TextButton.styleFrom(foregroundColor: _C.violet),
// //             ),
// //           ),
// //           child: child!,
// //         ),
// //       );
// //       if (time == null) return;
// //
// //       final selected = DateTime(
// //         date.year,
// //         date.month,
// //         date.day,
// //         time.hour,
// //         time.minute,
// //       );
// //       if (selected.isBefore(now.add(const Duration(minutes: 25)))) {
// //         AppAlert.error(context, "Select a time at least 25 minutes from now");
// //         continue;
// //       }
// //       setState(() {
// //         _selectedDate = date;
// //         _selectedTime = time;
// //       });
// //       break;
// //     }
// //   }
// //
// //   // ── Payment toggle button ───────────────────────────────────────────────
// //   Widget _buildPaymentToggle() {
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() => isExpanded = !isExpanded);
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           if (isExpanded) {
// //             _scrollController.animateTo(
// //               _scrollController.position.maxScrollExtent,
// //               duration: const Duration(milliseconds: 400),
// //               curve: Curves.easeOut,
// //             );
// //           }
// //         });
// //       },
// //       child: Container(
// //         width: double.infinity,
// //         padding: EdgeInsets.symmetric(vertical: 14.h),
// //         decoration: BoxDecoration(
// //           gradient: const LinearGradient(
// //             colors: [Color(0xFF6C63FF), Color(0xFF4A43C9)],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //           ),
// //           borderRadius: BorderRadius.circular(16.r),
// //           boxShadow: [
// //             BoxShadow(
// //               color: _C.violet.withOpacity(0.30),
// //               blurRadius: 16,
// //               offset: const Offset(0, 6),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               isExpanded
// //                   ? Icons.keyboard_arrow_up_rounded
// //                   : Icons.payment_rounded,
// //               color: Colors.white,
// //               size: 20.sp,
// //             ),
// //             SizedBox(width: 8.w),
// //             Text(
// //               isExpanded ? 'Hide Payment Options' : 'Choose Payment Method',
// //               style: TextStyle(
// //                 fontSize: 15.sp,
// //                 fontWeight: FontWeight.w700,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCheckoutDetails() {
// //     return Column(
// //       children: [
// //         cartwallet(
// //           wallet: wallet,
// //           onSelectionChanged: (method, subWallets) {
// //             setState(() {
// //               selectedPaymentMethod = method;
// //               selectedSubWallets = subWallets;
// //             });
// //           },
// //         ),
// //         SizedBox(height: 14.h),
// //         _buildPlaceOrderButton(),
// //       ],
// //     );
// //   }
// //
// //   // ── Place order button ──────────────────────────────────────────────────
// //   Widget _buildPlaceOrderButton() {
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 54.h,
// //       child: ElevatedButton(
// //         onPressed: isPlacingOrder ? null : placeOrder,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: _C.green,
// //           foregroundColor: Colors.white,
// //           elevation: 0,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16.r),
// //           ),
// //           shadowColor: _C.green.withOpacity(0.3),
// //         ),
// //         child: isPlacingOrder
// //             ? SizedBox(
// //                 width: 20.r,
// //                 height: 20.r,
// //                 child: const CircularProgressIndicator(
// //                   color: Colors.white,
// //                   strokeWidth: 2.5,
// //                 ),
// //               )
// //             : Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Icon(Icons.check_circle_rounded, size: 18.sp),
// //                   SizedBox(width: 8.w),
// //                   Text(
// //                     'Place Order',
// //                     style: TextStyle(
// //                       fontSize: 15.sp,
// //                       fontWeight: FontWeight.w700,
// //                     ),
// //                   ),
// //                   SizedBox(width: 8.w),
// //                   Container(
// //                     padding: EdgeInsets.symmetric(
// //                       horizontal: 10.w,
// //                       vertical: 4.h,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.15),
// //                       borderRadius: BorderRadius.circular(20.r),
// //                     ),
// //                     child: Text(
// //                       '₹${(cartData?.grandTotal ?? 0).toStringAsFixed(2)}',
// //                       style: TextStyle(
// //                         fontSize: 13.sp,
// //                         fontWeight: FontWeight.w700,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //       ),
// //     );
// //   }
// //
// //   // ── Empty cart ──────────────────────────────────────────────────────────
// //   Widget _buildEmptyCart() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           SizedBox(height: 40.h),
// //           Container(
// //             width: 90.r,
// //             height: 90.r,
// //             decoration: BoxDecoration(
// //               color: _C.violetDim,
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(
// //               Icons.shopping_bag_outlined,
// //               size: 40.sp,
// //               color: _C.violet,
// //             ),
// //           ),
// //           SizedBox(height: 20.h),
// //           Text(
// //             'Your cart is empty',
// //             style: TextStyle(
// //               fontSize: 18.sp,
// //               fontWeight: FontWeight.w800,
// //               color: _C.textPrimary,
// //             ),
// //           ),
// //           SizedBox(height: 6.h),
// //           Text(
// //             'Add some delicious items to get started',
// //             style: TextStyle(fontSize: 13.sp, color: _C.textSecondary),
// //           ),
// //           SizedBox(height: 24.h),
// //           GestureDetector(
// //             onTap: () => Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(builder: (_) => MainScreenfood()),
// //             ),
// //             child: Container(
// //               padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
// //               decoration: BoxDecoration(
// //                 color: _C.violet,
// //                 borderRadius: BorderRadius.circular(14.r),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: _C.violet.withOpacity(0.3),
// //                     blurRadius: 16,
// //                     offset: const Offset(0, 6),
// //                   ),
// //                 ],
// //               ),
// //               child: Text(
// //                 'Browse Menu',
// //                 style: TextStyle(
// //                   fontSize: 14.sp,
// //                   fontWeight: FontWeight.w700,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           SizedBox(height: 24.h),
// //           if (homepageAds.isNotEmpty)
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(16.r),
// //               child: BannerAdvertisement(ads: homepageAds, height: 200),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Shared card shell ───────────────────────────────────────────────────
// //   Widget _card({required Widget child, EdgeInsets? padding}) {
// //     return Container(
// //       width: double.infinity,
// //       padding: padding ?? EdgeInsets.all(16.w),
// //       decoration: BoxDecoration(
// //         color: _C.surface,
// //         borderRadius: BorderRadius.circular(16.r),
// //         border: Border.all(color: _C.border),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: child,
// //     );
// //   }
// // }
// //
// // // ═══════════════════════════════════════════════════════════════════════════════
// // // 1. Razorpay "Opening Gateway" overlay
// // // ═══════════════════════════════════════════════════════════════════════════════
// // class _RazorpayLoadingOverlay extends StatefulWidget {
// //   @override
// //   State<_RazorpayLoadingOverlay> createState() =>
// //       _RazorpayLoadingOverlayState();
// // }
// //
// // class _RazorpayLoadingOverlayState extends State<_RazorpayLoadingOverlay>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _ctrl;
// //   late Animation<double> _fade;
// //   late Animation<double> _scale;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _ctrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 450),
// //     )..forward();
// //     _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
// //     _scale = Tween<double>(
// //       begin: 0.88,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
// //   }
// //
// //   @override
// //   void dispose() {
// //     _ctrl.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FadeTransition(
// //       opacity: _fade,
// //       child: Container(
// //         color: Colors.black.withOpacity(0.60),
// //         child: Center(
// //           child: ScaleTransition(
// //             scale: _scale,
// //             child: Container(
// //               margin: EdgeInsets.symmetric(horizontal: 40.w),
// //               padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 28.w),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(24.r),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: const Color(0xFF6C63FF).withOpacity(0.18),
// //                     blurRadius: 40,
// //                     offset: const Offset(0, 12),
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   // Razorpay-like logo badge
// //                   Container(
// //                     width: 64.r,
// //                     height: 64.r,
// //                     decoration: BoxDecoration(
// //                       gradient: const LinearGradient(
// //                         colors: [Color(0xFF072654), Color(0xFF3395FF)],
// //                         begin: Alignment.topLeft,
// //                         end: Alignment.bottomRight,
// //                       ),
// //                       borderRadius: BorderRadius.circular(18.r),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: const Color(0xFF3395FF).withOpacity(0.35),
// //                           blurRadius: 16,
// //                           offset: const Offset(0, 6),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Icon(
// //                       Icons.payment_rounded,
// //                       color: Colors.white,
// //                       size: 30.sp,
// //                     ),
// //                   ),
// //                   SizedBox(height: 20.h),
// //                   Text(
// //                     'Opening Payment Gateway',
// //                     style: TextStyle(
// //                       fontSize: 16.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: const Color(0xFF1A1D2E),
// //                     ),
// //                   ),
// //                   SizedBox(height: 6.h),
// //                   Text(
// //                     'Redirecting to Razorpay…',
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       color: const Color(0xFF64748B),
// //                     ),
// //                   ),
// //                   SizedBox(height: 24.h),
// //                   SizedBox(
// //                     width: 28.r,
// //                     height: 28.r,
// //                     child: const CircularProgressIndicator(
// //                       color: Color(0xFF3395FF),
// //                       strokeWidth: 3,
// //                     ),
// //                   ),
// //                   SizedBox(height: 18.h),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.lock_outline_rounded,
// //                         size: 13.sp,
// //                         color: const Color(0xFF10B981),
// //                       ),
// //                       SizedBox(width: 4.w),
// //                       Text(
// //                         '256-bit SSL secured',
// //                         style: TextStyle(
// //                           fontSize: 11.sp,
// //                           color: const Color(0xFF10B981),
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ═══════════════════════════════════════════════════════════════════════════════
// // // 2. Payment Processing overlay (after Razorpay success, before order API)
// // // ═══════════════════════════════════════════════════════════════════════════════
// // class _PaymentProcessingOverlay extends StatefulWidget {
// //   @override
// //   State<_PaymentProcessingOverlay> createState() =>
// //       _PaymentProcessingOverlayState();
// // }
// //
// // class _PaymentProcessingOverlayState extends State<_PaymentProcessingOverlay>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _ctrl;
// //   late Animation<double> _fade;
// //   late Animation<double> _scale;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _ctrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 400),
// //     )..forward();
// //     _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
// //     _scale = Tween<double>(
// //       begin: 0.88,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
// //   }
// //
// //   @override
// //   void dispose() {
// //     _ctrl.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FadeTransition(
// //       opacity: _fade,
// //       child: Container(
// //         color: Colors.black.withOpacity(0.65),
// //         child: Center(
// //           child: ScaleTransition(
// //             scale: _scale,
// //             child: Container(
// //               margin: EdgeInsets.symmetric(horizontal: 40.w),
// //               padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 28.w),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(24.r),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: const Color(0xFF6C63FF).withOpacity(0.2),
// //                     blurRadius: 40,
// //                     offset: const Offset(0, 12),
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Container(
// //                     width: 64.r,
// //                     height: 64.r,
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFF0FDF4),
// //                       shape: BoxShape.circle,
// //                       border: Border.all(
// //                         color: const Color(0xFF10B981).withOpacity(0.3),
// //                         width: 2,
// //                       ),
// //                     ),
// //                     child: Icon(
// //                       Icons.sync_rounded,
// //                       color: const Color(0xFF10B981),
// //                       size: 30.sp,
// //                     ),
// //                   ),
// //                   SizedBox(height: 20.h),
// //                   Text(
// //                     'Confirming Payment',
// //                     style: TextStyle(
// //                       fontSize: 16.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: const Color(0xFF1A1D2E),
// //                     ),
// //                   ),
// //                   SizedBox(height: 6.h),
// //                   Text(
// //                     'Please wait while we confirm\nyour payment and place your order…',
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       color: const Color(0xFF64748B),
// //                       height: 1.5,
// //                     ),
// //                   ),
// //                   SizedBox(height: 24.h),
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(8.r),
// //                     child: SizedBox(
// //                       height: 5.h,
// //                       child: LinearProgressIndicator(
// //                         backgroundColor: const Color(0xFFE8ECF4),
// //                         valueColor: const AlwaysStoppedAnimation<Color>(
// //                           Color(0xFF10B981),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 14.h),
// //                   Text(
// //                     'Do not press back or close the app',
// //                     style: TextStyle(
// //                       fontSize: 11.sp,
// //                       color: const Color(0xFFF59E0B),
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ═══════════════════════════════════════════════════════════════════════════════
// // // 3. Order Success overlay (before navigating to invoice)
// // // ═══════════════════════════════════════════════════════════════════════════════
// // class _OrderSuccessOverlay extends StatefulWidget {
// //   final double grandTotal;
// //   const _OrderSuccessOverlay({required this.grandTotal});
// //
// //   @override
// //   State<_OrderSuccessOverlay> createState() => _OrderSuccessOverlayState();
// // }
// //
// // class _OrderSuccessOverlayState extends State<_OrderSuccessOverlay>
// //     with TickerProviderStateMixin {
// //   late AnimationController _bgCtrl;
// //   late AnimationController _checkCtrl;
// //   late AnimationController _textCtrl;
// //   late AnimationController _pulseCtrl;
// //
// //   late Animation<double> _bgFade;
// //   late Animation<double> _circleFade;
// //   late Animation<double> _circleScale;
// //   late Animation<double> _checkDraw;
// //   late Animation<double> _textFade;
// //   late Animation<Offset> _textSlide;
// //   late Animation<double> _pulse;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     _bgCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 350),
// //     );
// //     _checkCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 550),
// //     );
// //     _textCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 400),
// //     );
// //     _pulseCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 900),
// //     )..repeat(reverse: true);
// //
// //     _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);
// //     _circleFade = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut);
// //     _circleScale = Tween<double>(
// //       begin: 0.4,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));
// //     _checkDraw = CurvedAnimation(
// //       parent: _checkCtrl,
// //       curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
// //     );
// //     _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
// //     _textSlide = Tween<Offset>(
// //       begin: const Offset(0, 0.3),
// //       end: Offset.zero,
// //     ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
// //     _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(_pulseCtrl);
// //
// //     _bgCtrl.forward().then((_) {
// //       _checkCtrl.forward().then((_) {
// //         _textCtrl.forward();
// //       });
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _bgCtrl.dispose();
// //     _checkCtrl.dispose();
// //     _textCtrl.dispose();
// //     _pulseCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FadeTransition(
// //       opacity: _bgFade,
// //       child: Container(
// //         color: Colors.black.withOpacity(0.70),
// //         child: Center(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               // ── Animated check circle ─────────────────────────────────
// //               ScaleTransition(
// //                 scale: _circleScale,
// //                 child: FadeTransition(
// //                   opacity: _circleFade,
// //                   child: ScaleTransition(
// //                     scale: _pulse,
// //                     child: Stack(
// //                       alignment: Alignment.center,
// //                       children: [
// //                         // Outer glow ring
// //                         Container(
// //                           width: 110.r,
// //                           height: 110.r,
// //                           decoration: BoxDecoration(
// //                             shape: BoxShape.circle,
// //                             color: const Color(0xFF10B981).withOpacity(0.15),
// //                           ),
// //                         ),
// //                         // Inner circle
// //                         Container(
// //                           width: 80.r,
// //                           height: 80.r,
// //                           decoration: const BoxDecoration(
// //                             shape: BoxShape.circle,
// //                             gradient: LinearGradient(
// //                               colors: [Color(0xFF10B981), Color(0xFF059669)],
// //                               begin: Alignment.topLeft,
// //                               end: Alignment.bottomRight,
// //                             ),
// //                           ),
// //                         ),
// //                         // Check icon drawn with animation
// //                         FadeTransition(
// //                           opacity: _checkDraw,
// //                           child: Icon(
// //                             Icons.check_rounded,
// //                             color: Colors.white,
// //                             size: 40.sp,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //
// //               SizedBox(height: 28.h),
// //
// //               // ── Animated text ─────────────────────────────────────────
// //               SlideTransition(
// //                 position: _textSlide,
// //                 child: FadeTransition(
// //                   opacity: _textFade,
// //                   child: Column(
// //                     children: [
// //                       Text(
// //                         'Order Placed! 🎉',
// //                         style: TextStyle(
// //                           fontSize: 24.sp,
// //                           fontWeight: FontWeight.w800,
// //                           color: Colors.white,
// //                           letterSpacing: -0.5,
// //                         ),
// //                       ),
// //                       SizedBox(height: 8.h),
// //                       Text(
// //                         '₹${widget.grandTotal.toStringAsFixed(2)} paid successfully',
// //                         style: TextStyle(
// //                           fontSize: 15.sp,
// //                           color: Colors.white.withOpacity(0.80),
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                       SizedBox(height: 6.h),
// //                       Text(
// //                         'Redirecting to your invoice…',
// //                         style: TextStyle(
// //                           fontSize: 12.sp,
// //                           color: Colors.white.withOpacity(0.55),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// //
// // import '../../Models/promotions_model/promotions_model.dart';
// // import '../../Services/Auth_service/Subscription_authservice.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../Services/Auth_service/food_authservice.dart';
// // import '../../Services/Auth_service/promotion_services_Authservice.dart';
// // import '../../Services/paymentservice/razorpayservice.dart';
// // import '../../Services/websockets/web_socket_manager.dart';
// // import '../../widgets/widgets/skeleton/cart_skeleton.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../../Services/scaffoldmessenger/messenger.dart';
// // import 'package:maamaas/screens/foodmainscreen.dart';
// // import 'package:maamaas/widgets/signinrequired.dart';
// // import '../../Models/subscrptions/coupon_model.dart';
// // import '../../Models/subscrptions/wallet_model.dart';
// // import '../../providers/addressmodel_provider.dart';
// // import '../../widgets/widgets/cart wallet.dart';
// // import '../../Models/food/cart_model.dart';
// // import '../screens/advertisements/banneradvertisement.dart';
// // import '../screens/ordertypebutton.dart';
// // import 'package:flutter/gestures.dart';
// // import 'package:flutter/material.dart';
// // import '../screens/saved_address.dart';
// // // import 'FOODCARTDUMMY.dart';
// // import 'Menu/menu_screen.dart';
// // import 'food_invoice.dart';
// //
// // // ── Design tokens ─────────────────────────────────────────────────────────────
// // class _C {
// //   static const bg = Color(0xFFF5F6FA);
// //   static const surface = Color(0xFFFFFFFF);
// //   static const border = Color(0xFFE8ECF4);
// //
// //   static const violet = Color(0xFF6C63FF);
// //   static const violetDim = Color(0x1A6C63FF);
// //
// //   static const textPrimary = Color(0xFF1A1D2E);
// //   static const textSecondary = Color(0xFF64748B);
// //   static const textMuted = Color(0xFFB0B8CC);
// //
// //   static const green = Color(0xFF10B981);
// //   static const red = Color(0xFFEF4444);
// //   static const amber = Color(0xFFF59E0B);
// // }
// //
// // // Add inside _food_cartScreenState class
// // String? _safeStr(dynamic v) {
// //   if (v == null) return null;
// //   if (v is String) return v;
// //   if (v is num || v is bool) return v.toString();
// //   if (v is Map) {
// //     return v['url']?.toString() ?? v['path']?.toString() ?? v.toString();
// //   }
// //   return null;
// // }
// //
// // String _safeStrOr(dynamic v, [String fallback = '']) => _safeStr(v) ?? fallback;
// //
// // // ignore: camel_case_types
// // class food_cartScreen extends ConsumerStatefulWidget {
// //   final int? vendorId;
// //   final int? cartId;
// //   final double? savedAmount;
// //   final bool showSavedPopup;
// //
// //   const food_cartScreen({
// //     super.key,
// //     this.vendorId,
// //     this.cartId,
// //     this.savedAmount,
// //     this.showSavedPopup = false,
// //   });
// //
// //   @override
// //   ConsumerState<food_cartScreen> createState() => _food_cartScreenState();
// // }
// //
// // // ignore: camel_case_types
// // class _food_cartScreenState extends ConsumerState<food_cartScreen> {
// //   CartModel? cartData;
// //   bool isLoading = true;
// //   bool isPlacingOrder = false;
// //   bool couponApplied = false;
// //   String selectedPaymentMethod = "";
// //   String couponCode = "";
// //   bool isExpanded = false;
// //   Wallet? wallet;
// //   int? appliedCouponId;
// //   String? appliedCouponCode;
// //   DateTime? _selectedDate;
// //   TimeOfDay? _selectedTime;
// //   late ScrollController _scrollController;
// //   String _orderType = "";
// //   bool isCouponLoading = false;
// //   Set<String> selectedSubWallets = {};
// //   int userId = 0;
// //   List<Campaign> homepageAds = [];
// //   bool _isSummaryExpanded = false;
// //   final List<Map<String, dynamic>> _pendingSocketUpdates = [];
// //
// //   // ── Payment UI overlay states ──────────────────────────────────────────
// //   bool _isRazorpayLoading = false;   // "Opening payment gateway…"
// //   bool _isProcessingPayment = false; // "Confirming your payment…"
// //   bool _showOrderSuccess = false;    // animated success before invoice nav
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _scrollController = ScrollController();
// //     _loadWallet();
// //     _loadCart();
// //     _initCartSocket();
// //     _loadAds();
// //     if (cartData?.hasAnyScheduledItem ?? false) {
// //       _orderType = 'schedule';
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     WebSocketManager().unsubscribeUserCart(userId);
// //     super.dispose();
// //   }
// //
// //   Future<void> _loadWallet() async {
// //     try {
// //       final w = await subscription_AuthService.fetchWallet();
// //       if (!mounted) return;
// //       setState(() => wallet = w);
// //     } catch (_) {
// //       if (!mounted) return;
// //       AppAlert.error(context, "❌ Failed to load wallet");
// //     }
// //   }
// //
// //   List<String> mapWalletsToEnum(List<String> s) => s.map((w) {
// //     switch (w) {
// //       case "Cashbacks":
// //         return "CASHBACK";
// //       case "Self Loaded":
// //         return "SELF_LOADED";
// //       case "Postpaid used amount":
// //         return "POST_PAID";
// //       case "Company Loaded":
// //         return "COMPANY_LOADED";
// //       case "Earned Amount":
// //         return "EARNED_AMOUNT";
// //       default:
// //         return w.toUpperCase().replaceAll(' ', '_');
// //     }
// //   }).toList();
// //
// //   void _initCartSocket() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     userId = prefs.getInt('userId') ?? 0;
// //     WebSocketManager().subscribeUserCart(userId, _updateCartFromSocket);
// //   }
// //
// //   // void _updateCartFromSocket(Map<String, dynamic> data) {
// //   //   if (cartData == null) {
// //   //     print("⏳ cartData not ready → queuing socket update");
// //   //     _pendingSocketUpdates.add(data);
// //   //     return;
// //   //   }
// //   //   _applySocketUpdate(data);
// //   // }
// //
// //   void _flushPendingSocketUpdates() {
// //     for (final update in _pendingSocketUpdates) {
// //       _applySocketUpdate(update);
// //     }
// //     _pendingSocketUpdates.clear();
// //   }
// //
// //   void _applySocketUpdate(Map<String, dynamic> data) {
// //     print("🟡 RAW SOCKET DATA: $data");
// //     final List items = data['cartItems'] ?? [];
// //
// //     if (!mounted) return;
// //
// //     setState(() {
// //       cartData!.cartItems = items.map((json) {
// //         final idx = cartData!.cartItems.indexWhere(
// //               (i) => i.itemId == json['itemId'],
// //         );
// //
// //         if (idx != -1) {
// //           final old = cartData!.cartItems[idx];
// //           // ✅ Create a NEW object so Flutter detects the change
// //           return CartItem(
// //             itemId: old.itemId,
// //             dishName: old.dishName,
// //             dishId: old.dishId,
// //             chefType: old.chefType,
// //             dishImage: old.dishImage,
// //             actualPrice: (json['actualPrice'] ?? old.actualPrice).toDouble(),
// //             gst: (json['gst'] ?? old.gst).toDouble(),
// //             quantity: json['quantity'] ?? old.quantity,
// //             price: (json['price'] ?? old.price).toDouble(),
// //             totalPrice: (json['totalPrice'] ?? old.totalPrice).toDouble(),
// //             packingCharges: (json['packingCharges'] ?? old.packingCharges)
// //                 .toDouble(),
// //             balanceQuantity: json['balanceQuantity'] ?? old.balanceQuantity,
// //             available: json['available'] ?? old.available,
// //             shedule: json.containsKey('shedule')
// //                 ? json['shedule'] == true
// //                 : old.shedule,
// //           );
// //         }
// //
// //         return CartItem.fromJson(json);
// //       }).toList();
// //
// //       final rawCoupon = data['couponCode'];
// //
// //       cartData!.subtotal = (data['subtotal'] ?? 0).toDouble();
// //       cartData!.gstTotal = (data['gstTotal'] ?? 0).toDouble();
// //       cartData!.packingTotal = (data['packingTotal'] ?? 0).toDouble();
// //       cartData!.platformCharges = (data['platformCharges'] ?? 0).toDouble();
// //       cartData!.deliveryCharges = (data['deliveryCharges'] ?? 0).toDouble();
// //       cartData!.discountAmount = (data['discountAmount'] ?? 0).toDouble();
// //       cartData!.grandTotal = (data['grandTotal'] ?? 0).toDouble();
// //       cartData!.cgst = (data['cgst'] ?? 0).toDouble();
// //       cartData!.sgst = (data['sgst'] ?? 0).toDouble();
// //       cartData!.deliveryAddress =
// //           data['deliveryAddress'] ?? cartData!.deliveryAddress;
// //       cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
// //       cartData!.name = data['name'] ?? cartData!.name;
// //       // cartData!.couponCode = data['couponCode'];
// //
// //       cartData!.couponCode = rawCoupon is String
// //           ? rawCoupon
// //           : rawCoupon is Map
// //           ? rawCoupon['code']
// //           : null;
// //     });
// //   }
// //
// //   void _updateCartFromSocket(Map<String, dynamic> data) {
// //     print("🟡 RAW SOCKET DATA: $data");
// //
// //     if (cartData == null) {
// //       print("❌ cartData is NULL → skipping update");
// //       return;
// //     }
// //
// //     final List items = data['cartItems'] ?? [];
// //     print("📦 Incoming cart items count: ${items.length}");
// //
// //     setState(() {
// //       cartData!.cartItems = items.map((json) {
// //         print("➡️ Processing item: $json");
// //
// //         final idx = cartData!.cartItems.indexWhere(
// //               (i) => i.itemId == json['itemId'],
// //         );
// //
// //         if (idx != -1) {
// //           final item = cartData!.cartItems[idx];
// //
// //           print("🔁 Updating existing item: ${item.itemId}");
// //           print(
// //             "   OLD -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
// //           );
// //
// //           item.quantity = json['quantity'] ?? item.quantity;
// //           item.totalPrice = (json['totalPrice'] ?? item.totalPrice).toDouble();
// //           item.price = (json['price'] ?? item.price).toDouble();
// //           item.packingCharges = (json['packingCharges'] ?? item.packingCharges)
// //               .toDouble();
// //
// //           if (json.containsKey('shedule')) {
// //             item.shedule = json['shedule'] == true;
// //           } else {
// //             print("⚠️shedule missing from socket, keeping old value");
// //           }
// //
// //           print("UPDATED isScheduled: ${item.shedule}");
// //           print(
// //             "NEW -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
// //           );
// //
// //           return item;
// //         }
// //
// //         print("🆕 New item added: ${json['itemId']}");
// //         return CartItem.fromJson(json);
// //       }).toList();
// //
// //       final rawCoupon = data['couponCode'];
// //
// //       // prices ...
// //       cartData!.subtotal = (data['subtotal'] ?? 0).toDouble();
// //       cartData!.gstTotal = (data['gstTotal'] ?? 0).toDouble();
// //       cartData!.packingTotal = (data['packingTotal'] ?? 0).toDouble();
// //       cartData!.platformCharges = (data['platformCharges'] ?? 0).toDouble();
// //       cartData!.deliveryCharges = (data['deliveryCharges'] ?? 0).toDouble();
// //       cartData!.discountAmount = (data['discountAmount'] ?? 0).toDouble();
// //       cartData!.grandTotal = (data['grandTotal'] ?? 0).toDouble();
// //       cartData!.cgst = (data['cgst'] ?? 0).toDouble();
// //       cartData!.sgst = (data['sgst'] ?? 0).toDouble();
// //
// //       // cartData!.deliveryAddress =
// //       //     data['deliveryAddress'] ?? cartData!.deliveryAddress;
// //       // cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
// //       // cartData!.name = data['name'] ?? cartData!.name;
// //       // cartData!.couponCode = data['couponCode'];
// //
// //       cartData!.deliveryAddress = _safeStrOr(data['deliveryAddress']).isNotEmpty
// //           ? _safeStrOr(data['deliveryAddress'])
// //           : cartData!.deliveryAddress;
// //       cartData!.mobileNo = _safeStrOr(data['mobileNo']).isNotEmpty
// //           ? _safeStrOr(data['mobileNo'])
// //           : cartData!.mobileNo;
// //       cartData!.name = _safeStrOr(data['name']).isNotEmpty
// //           ? _safeStrOr(data['name'])
// //           : cartData!.name;
// //       cartData!.couponCode = rawCoupon is String
// //           ? rawCoupon
// //           : rawCoupon is Map
// //           ? rawCoupon['code']
// //           : null;
// //
// //       // // ✅ FIX: Re-sync _orderType after items update
// //       // if (cartData!.hasAnyScheduledItem) {
// //       //   _orderType = 'schedule';
// //       //   print("🚨 Socket update: orderType set to schedule");
// //       // } else if (_orderType == 'schedule') {
// //       //   // All scheduled items removed — revert to default
// //       //   _orderType = cartData!.orderType.toLowerCase(); // e.g. 'delivery'
// //       //   print("🔄 Socket update: no scheduled items, reverting orderType");
// //       // }
// //     });
// //
// //     // print("✅ Cart UI updated successfully\n");
// //     // _loadCart();
// //   }
// //
// //   Future<void> _loadCart() async {
// //     setState(() => isLoading = true);
// //     try {
// //       final c = await food_Authservice.fetchCart();
// //       if (mounted) {
// //         setState(() {
// //           cartData = c;
// //
// //           print("📦 Cart Loaded:");
// //           print("   Total Items: ${cartData?.cartItems.length}");
// //
// //           for (var item in cartData!.cartItems) {
// //             print("   👉 ${item.dishName} → isScheduled: ${item.shedule}");
// //           }
// //
// //           print("🔥 hasAnyScheduledItem: ${cartData?.hasAnyScheduledItem}");
// //
// //           // ✅ Sync orderType from loaded cart
// //           if (cartData?.hasAnyScheduledItem ?? false) {
// //             _orderType = 'schedule';
// //             print("🚨 _loadCart: orderType set to schedule");
// //           }
// //
// //           isLoading = false;
// //         });
// //         _flushPendingSocketUpdates();
// //       }
// //     } catch (_) {
// //       if (mounted) setState(() => isLoading = false);
// //     }
// //   }
// //
// //   double getSelectedWalletBalance() {
// //     if (wallet == null) return 0;
// //     double t = 0;
// //     if (selectedSubWallets.contains("Company Loaded")) {
// //       t += wallet!.companyLoadedAmount;
// //     }
// //     if (selectedSubWallets.contains("Self Loaded")) {
// //       t += wallet!.selfLoadedAmount;
// //     }
// //     if (selectedSubWallets.contains("Cashbacks")) t += wallet!.cashbackAmount;
// //     if (selectedSubWallets.contains("Postpaid used amount")) {
// //       t += wallet!.postPaidUsage;
// //     }
// //     return t;
// //   }
// //
// //   Future<void> placeOrder() async {
// //     final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
// //     if (hasScheduledItems && (_selectedDate == null || _selectedTime == null)) {
// //       AppAlert.error(
// //         context,
// //         "📅 Please select date & time to schedule your order",
// //       );
// //       return;
// //     }
// //
// //     if ((cartData?.orderType ?? '').trim().toLowerCase() == 'delivery') {
// //       if ((cartData?.deliveryAddress ?? '').trim().isEmpty) {
// //         AppAlert.error(context, "⚠️ Please select delivery address");
// //         return;
// //       }
// //     }
// //     if (selectedPaymentMethod == "Maamaas_Wallet") {
// //       final wb = getSelectedWalletBalance();
// //       final gt = (cartData?.grandTotal ?? 0).toDouble();
// //       if (wb < gt) {
// //         AppAlert.error(
// //           context,
// //           "❌ Insufficient wallet balance\nWallet: ₹${wb.toStringAsFixed(2)}\nOrder Total: ₹${gt.toStringAsFixed(2)}",
// //         );
// //         return;
// //       }
// //     }
// //     if (selectedPaymentMethod.isEmpty) {
// //       AppAlert.error(context, "⚠️ Please select a payment method");
// //       return;
// //     }
// //
// //     setState(() => isPlacingOrder = true);
// //     try {
// //       final bool isUserScheduled =
// //           _selectedDate != null || _selectedTime != null;
// //
// //       if (selectedPaymentMethod == "Online_Payment") {
// //         final amount = (cartData?.grandTotal ?? 0).toDouble();
// //
// //         // ── Show "opening gateway" overlay while createOrder API runs ────
// //         if (mounted) setState(() => _isRazorpayLoading = true);
// //         final orderId = await food_Authservice.createOrder(amount);
// //         if (mounted) setState(() => _isRazorpayLoading = false);
// //
// //         if (orderId == null) {
// //           AppAlert.error(context, "❌ Failed to create payment order");
// //           return;
// //         }
// //         final rp = RazorpayService();
// //         rp.onSuccess = (res) async {
// //           final pid = res.paymentId!;
// //           final oid = res.orderId!;
// //           // ── Show "confirming payment" overlay while order API runs ──────
// //           if (mounted) setState(() => _isProcessingPayment = true);
// //           final ok = isUserScheduled
// //               ? await _placeScheduledOrder(
// //             paymentMethod: "Online_Payment",
// //             razorpayPaymentId: pid,
// //             razorpayOrderId: oid,
// //             amount: amount,
// //           )
// //               : await _placeDirectOrder(
// //             paymentMethod: "Online_Payment",
// //             razorpayPaymentId: pid,
// //             razorpayOrderId: oid,
// //             amount: amount,
// //           );
// //           // FIX: hide processing overlay only after order result is known
// //           // (_showOrderSuccess takes over visually, so hide _isProcessingPayment
// //           //  only when ok==false so there's no blank-flash gap)
// //           if (!ok && mounted) setState(() => _isProcessingPayment = false);
// //
// //           if (ok) {
// //             // capturePayment runs in background — navigation already happened
// //             // inside _placeDirectOrder/_placeScheduledOrder
// //             food_Authservice.capturePayment(
// //               paymentId: pid,
// //               amount: amount,
// //             ).catchError((_) {
// //               // Silently catch — capture failure does not reverse the order
// //             });
// //           } else {
// //             AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
// //           }
// //         };
// //         rp.onError = (res) {
// //           if (mounted) {
// //             setState(() {
// //               _isRazorpayLoading = false;
// //               isPlacingOrder = false;
// //             });
// //           }
// //           AppAlert.error(context, "Payment failed: ${res.message}");
// //         };
// //         rp.startPayment(
// //           orderId: orderId,
// //           amount: amount,
// //           description: "Online Payment via Razorpay",
// //         );
// //         // FIX: do NOT return early — let finally reset isPlacingOrder
// //         //      (Razorpay sheet is already open; button spinner can stop)
// //         return;
// //       }
// //
// //       final amt = cartData!.grandTotal.toDouble();
// //       if (isUserScheduled) {
// //         await _placeScheduledOrder(
// //           paymentMethod: selectedPaymentMethod,
// //           razorpayPaymentId: "",
// //           razorpayOrderId: "",
// //           amount: amt,
// //         );
// //       } else {
// //         await _placeDirectOrder(
// //           paymentMethod: selectedPaymentMethod,
// //           razorpayPaymentId: "",
// //           razorpayOrderId: "",
// //           amount: amt,
// //         );
// //       }
// //     } catch (e) {
// //       debugPrint("❌ Place Order Error: $e");
// //
// //       String message = "Error placing order";
// //
// //       if (e.toString().contains("Exception:")) {
// //         message = e.toString().replaceFirst("Exception: ", "");
// //       } else {
// //         message = e.toString();
// //       }
// //
// //       // FIX: clear all overlay flags on any error so nothing gets stuck
// //       if (mounted) {
// //         setState(() {
// //           _isRazorpayLoading = false;
// //           _isProcessingPayment = false;
// //           _showOrderSuccess = false;
// //         });
// //       }
// //
// //       AppAlert.error(context, message);
// //     } finally {
// //       // FIX: always reset the Place Order button spinner
// //       if (mounted) setState(() => isPlacingOrder = false);
// //     }
// //   }
// //
// //   Future<bool> _placeScheduledOrder({
// //     required String paymentMethod,
// //     required String razorpayPaymentId,
// //     required String razorpayOrderId,
// //     required double amount,
// //   }) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final cartId = prefs.getInt('cartId');
// //     if (cartId == null) return false;
// //     final result = await food_Authservice.scheduleOrder(
// //       cartId: cartId,
// //       date: _selectedDate ?? DateTime.now(),
// //       time: _selectedTime ?? TimeOfDay.now(),
// //       paymentMethod: paymentMethod,
// //       razorpayPaymentId: razorpayPaymentId,
// //       razorpayOrderId: razorpayOrderId,
// //       walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
// //       amount: amount,
// //     );
// //     if (result.containsKey('orderId')) {
// //       final oid = result['orderId'];
// //       await prefs.setInt('orderId', oid);
// //       if (mounted) {
// //         // FIX: flip both flags in one setState to avoid a single-frame blank flash
// //         setState(() {
// //           _isProcessingPayment = false;
// //           _showOrderSuccess = true;
// //         });
// //         await Future.delayed(const Duration(milliseconds: 2200));
// //         if (mounted) {
// //           Navigator.pushReplacement(
// //             context,
// //             MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
// //           );
// //         }
// //       }
// //       return true;
// //     }
// //     return false;
// //   }
// //
// //   Future<bool> _placeDirectOrder({
// //     required String paymentMethod,
// //     required String razorpayPaymentId,
// //     required String razorpayOrderId,
// //     required double amount,
// //   }) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final cartId = prefs.getInt('cartId');
// //     if (cartId == null) return false;
// //     final result = await food_Authservice.placeDirectOrder(
// //       cartId: cartId,
// //       paymentMethod: paymentMethod,
// //       razorpayPaymentId: razorpayPaymentId,
// //       razorpayOrderId: razorpayOrderId,
// //       walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
// //       amount: amount,
// //     );
// //     if (result.containsKey('orderId')) {
// //       final oid = result['orderId'];
// //       await prefs.setInt('orderId', oid);
// //       if (mounted) {
// //         // FIX: flip both flags in one setState to avoid a single-frame blank flash
// //         setState(() {
// //           _isProcessingPayment = false;
// //           _showOrderSuccess = true;
// //         });
// //         await Future.delayed(const Duration(milliseconds: 2200));
// //         if (mounted) {
// //           Navigator.pushReplacement(
// //             context,
// //             MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
// //           );
// //         }
// //       }
// //       return true;
// //     }
// //     return false;
// //   }
// //
// //   Future<void> changeQuantity(CartItem item, int newQty) async {
// //     final old = item.quantity;
// //     setState(() => item.quantity = newQty);
// //     final ok = await food_Authservice.updateCartQuantity(item.itemId, newQty);
// //     if (!ok) {
// //       setState(() {
// //         item.quantity = old;
// //         item.totalPrice = item.price * old;
// //       });
// //     }
// //   }
// //
// //   Future<void> _onRefresh() async {
// //     final c = await food_Authservice.fetchCart();
// //     final w = await subscription_AuthService.fetchWallet();
// //     if (!mounted) return;
// //     setState(() {
// //       cartData = c;
// //       wallet = w;
// //     });
// //   }
// //
// //   Future<void> _loadAds() async {
// //     try {
// //       final result = await promotion_Authservice.fetchcampaign();
// //       setState(
// //             () => homepageAds = result
// //             .where(
// //               (c) =>
// //           c.status == Status.ACTIVE &&
// //               c.approvalStatus == ApprovalStatus.APPROVED &&
// //               c.addDisplayPosition == AddDisplayPosition.CHECKOUT_PAGE,
// //         )
// //             .toList(),
// //       );
// //     } catch (_) {}
// //   }
// //
// //   String _fmt(num? v) => (v ?? 0).toStringAsFixed(2);
// //
// //   // ═══════════════════════════════════════════════════════════════════════════
// //   @override
// //   Widget build(BuildContext context) {
// //     ScreenUtil.init(context);
// //     return Stack(
// //       children: [
// //         Scaffold(
// //           backgroundColor: _C.bg,
// //           appBar: _buildAppBar(),
// //           body: AuthGuard(
// //             child: SafeArea(
// //               child: RefreshIndicator(
// //                 onRefresh: _onRefresh,
// //                 color: _C.violet,
// //                 backgroundColor: _C.surface,
// //                 child: isLoading
// //                     ? SingleChildScrollView(
// //                   physics: const AlwaysScrollableScrollPhysics(),
// //                   padding: EdgeInsets.all(16.w),
// //                   child: const CartSkeleton(
// //                     type: CartSkeletonType.fullCart,
// //                   ),
// //                 )
// //                     : SingleChildScrollView(
// //                   controller: _scrollController,
// //                   physics: const AlwaysScrollableScrollPhysics(),
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: 16.w,
// //                     vertical: 12.h,
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       if (cartData == null || cartData!.cartItems.isEmpty)
// //                         _buildEmptyCart()
// //                       else ...[
// //                         _buildCartItems(),
// //                         SizedBox(height: 10.h),
// //                         _buildAddMoreText(),
// //                         SizedBox(height: 12.h),
// //
// //                         OrderCartFooter(
// //                           onOrderTypeChanged: () async {
// //                             final c = await food_Authservice.fetchCart();
// //                             setState(() => cartData = c);
// //                           },
// //                         ),
// //
// //                         // ── Ads banner ───────────────────────────
// //                         if (homepageAds.isNotEmpty) ...[
// //                           SizedBox(height: 12.h),
// //                           _sectionLabel('Recommended for you'),
// //                           SizedBox(height: 8.h),
// //                           ClipRRect(
// //                             borderRadius: BorderRadius.circular(16.r),
// //                             child: BannerAdvertisement(
// //                               ads: homepageAds,
// //                               height: 160,
// //                             ),
// //                           ),
// //                         ],
// //
// //                         SizedBox(height: 12.h),
// //                         _buildCouponRow(),
// //                         SizedBox(height: 10.h),
// //
// //                         if ((cartData?.orderType ?? '')
// //                             .trim()
// //                             .toLowerCase() ==
// //                             'delivery')
// //                           _buildDeliveryAddress(),
// //
// //                         SizedBox(height: 10.h),
// //                         _buildSummaryCard(),
// //                         SizedBox(height: 12.h),
// //                         _buildScheduleOrder(),
// //                         SizedBox(height: 12.h),
// //                         _buildPaymentToggle(),
// //                         if (isExpanded) ...[
// //                           SizedBox(height: 12.h),
// //                           _buildCheckoutDetails(),
// //                         ],
// //                         SizedBox(height: 24.h),
// //                       ],
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //         // ── Razorpay opening overlay ──────────────────────────────────────
// //         if (_isRazorpayLoading)
// //           Positioned.fill(
// //             child: AbsorbPointer(
// //               child: _RazorpayLoadingOverlay(),
// //             ),
// //           ),
// //
// //         // ── Payment processing overlay ────────────────────────────────────
// //         if (_isProcessingPayment)
// //           Positioned.fill(
// //             child: AbsorbPointer(
// //               child: _PaymentProcessingOverlay(),
// //             ),
// //           ),
// //
// //         // ── Order success overlay ─────────────────────────────────────────
// //         if (_showOrderSuccess)
// //           Positioned.fill(
// //             child: AbsorbPointer(
// //               child: _OrderSuccessOverlay(
// //                 grandTotal: cartData?.grandTotal ?? 0,
// //               ),
// //             ),
// //           ),
// //       ],
// //     );
// //   }
// //
// //   // ── AppBar ──────────────────────────────────────────────────────────────
// //   PreferredSizeWidget _buildAppBar() {
// //     return AppBar(
// //       backgroundColor: _C.surface,
// //       elevation: 0,
// //       centerTitle: true,
// //       title: Text(
// //         'Review Your Cart',
// //         style: TextStyle(
// //           fontSize: 17.sp,
// //           fontWeight: FontWeight.w700,
// //           color: _C.textPrimary,
// //         ),
// //       ),
// //       iconTheme: const IconThemeData(color: _C.textPrimary),
// //       actions: [
// //         GestureDetector(
// //           onTap: () async {
// //             final ok = await food_Authservice.deleteCart();
// //             if (!mounted) return;
// //             if (ok) {
// //               Navigator.pushReplacement(
// //                 context,
// //                 MaterialPageRoute(builder: (_) => MainScreenfood()),
// //               );
// //               AppAlert.success(context, 'Cart cleared');
// //             } else {
// //               AppAlert.error(context, 'Failed to clear cart');
// //             }
// //           },
// //           child: Container(
// //             margin: EdgeInsets.only(right: 12.w),
// //             padding: EdgeInsets.all(8.w),
// //             decoration: BoxDecoration(
// //               color: _C.red.withOpacity(0.08),
// //               shape: BoxShape.circle,
// //               border: Border.all(color: _C.red.withOpacity(0.2)),
// //             ),
// //             child: Icon(
// //               Icons.delete_outline_rounded,
// //               size: 18.sp,
// //               color: _C.red,
// //             ),
// //           ),
// //         ),
// //       ],
// //       bottom: PreferredSize(
// //         preferredSize: const Size.fromHeight(1),
// //         child: Container(height: 1, color: _C.border),
// //       ),
// //     );
// //   }
// //
// //   // ── Section label ───────────────────────────────────────────────────────
// //   Widget _sectionLabel(String text) {
// //     return Text(
// //       text,
// //       style: TextStyle(
// //         fontSize: 14.sp,
// //         fontWeight: FontWeight.w700,
// //         color: _C.textPrimary,
// //       ),
// //     );
// //   }
// //
// //   // ── Cart items card ─────────────────────────────────────────────────────
// //   Widget _buildCartItems() {
// //     if (cartData == null || cartData!.cartItems.isEmpty) {
// //       return const SizedBox.shrink();
// //     }
// //
// //     return _card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           ...cartData!.cartItems.map((item) {
// //             final isLast = item == cartData!.cartItems.last;
// //             return Column(
// //               key: ValueKey(item.itemId),
// //               children: [
// //                 Padding(
// //                   padding: EdgeInsets.symmetric(vertical: 10.h),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         child: Text(
// //                           item.dishName,
// //                           maxLines: 2,
// //                           overflow: TextOverflow.ellipsis,
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             fontWeight: FontWeight.w600,
// //                             color: _C.textPrimary,
// //                           ),
// //                         ),
// //                       ),
// //
// //                       SizedBox(width: 8.w),
// //
// //                       _buildQtyControl(item),
// //
// //                       SizedBox(width: 12.w),
// //
// //                       SizedBox(
// //                         width: 80.w, // ✅ FIXED WIDTH
// //                         child: Text(
// //                           '₹${item.totalPrice.toStringAsFixed(2)}',
// //                           textAlign: TextAlign.right, // ✅ ALIGN RIGHT
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             fontWeight: FontWeight.w700,
// //                             color: _C.violet,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 if (!isLast) Divider(height: 1, color: _C.border),
// //               ],
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildQtyControl(CartItem item) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: _C.bg,
// //         borderRadius: BorderRadius.circular(10.r),
// //         border: Border.all(color: _C.border),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           _qtyBtn(
// //             Icons.remove_rounded,
// //             _C.red,
// //                 () => changeQuantity(item, item.quantity - 1),
// //           ),
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 10.w),
// //             child: Text(
// //               '${item.quantity}',
// //               style: TextStyle(
// //                 fontSize: 13.sp,
// //                 fontWeight: FontWeight.w700,
// //                 color: _C.textPrimary,
// //               ),
// //             ),
// //           ),
// //           _qtyBtn(
// //             Icons.add_rounded,
// //             _C.green,
// //                 () => changeQuantity(item, item.quantity + 1),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _qtyBtn(IconData icon, Color color, VoidCallback onTap) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: EdgeInsets.all(6.w),
// //         decoration: BoxDecoration(
// //           color: color.withOpacity(0.10),
// //           borderRadius: BorderRadius.circular(8.r),
// //         ),
// //         child: Icon(icon, size: 14.sp, color: color),
// //       ),
// //     );
// //   }
// //
// //   // ── "Add more items" text ───────────────────────────────────────────────
// //   Widget _buildAddMoreText() {
// //     return Center(
// //       child: RichText(
// //         text: TextSpan(
// //           text: 'Missed something? ',
// //           style: TextStyle(fontSize: 13.sp, color: _C.textSecondary),
// //           children: [
// //             TextSpan(
// //               text: 'Add more items',
// //               style: TextStyle(
// //                 fontSize: 13.sp,
// //                 fontWeight: FontWeight.w700,
// //                 color: _C.violet,
// //                 decoration: TextDecoration.underline,
// //               ),
// //               recognizer: TapGestureRecognizer()
// //                 ..onTap = () => Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (_) => MenuScreen(vendorId: cartData!.vendorId),
// //                   ),
// //                 ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Coupon row ──────────────────────────────────────────────────────────
// //   Widget _buildCouponRow() {
// //     final applied = (cartData?.couponCode ?? '').isNotEmpty;
// //
// //     return GestureDetector(
// //       onTap: applied ? null : _showCouponBottomSheet,
// //       child: _card(
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 36.r,
// //               height: 36.r,
// //               decoration: BoxDecoration(
// //                 color: applied ? _C.green.withOpacity(0.10) : _C.violetDim,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 applied
// //                     ? Icons.check_circle_rounded
// //                     : Icons.local_offer_rounded,
// //                 size: 18.sp,
// //                 color: applied ? _C.green : _C.violet,
// //               ),
// //             ),
// //             SizedBox(width: 12.w),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     applied ? 'Coupon Applied' : 'Apply Coupon',
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: applied ? _C.green : _C.textPrimary,
// //                     ),
// //                   ),
// //                   if (applied)
// //                     Text(
// //                       appliedCouponCode ?? '',
// //                       style: TextStyle(
// //                         fontSize: 11.sp,
// //                         color: _C.textSecondary,
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //             if (applied)
// //               GestureDetector(
// //                 onTap: () async {
// //                   if (cartData?.cartId == null) return;
// //                   final result = await food_Authservice.updateCartSettings(
// //                     cartId: cartData!.cartId,
// //                     couponId: cartData!.couponId,
// //                     applyCoupon: "NOT_APPLIED",
// //                   );
// //                   if (!result.success) {
// //                     AppAlert.error(context, "Failed to remove coupon");
// //                     return;
// //                   }
// //                   setState(() {
// //                     appliedCouponCode = null;
// //                     appliedCouponId = null;
// //                   });
// //                   AppAlert.success(context, "Coupon removed");
// //                 },
// //                 child: Container(
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: 10.w,
// //                     vertical: 5.h,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: _C.red.withOpacity(0.08),
// //                     borderRadius: BorderRadius.circular(20.r),
// //                     border: Border.all(color: _C.red.withOpacity(0.2)),
// //                   ),
// //                   child: Text(
// //                     'Remove',
// //                     style: TextStyle(
// //                       fontSize: 11.sp,
// //                       color: _C.red,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //               )
// //             else
// //               Icon(
// //                 Icons.chevron_right_rounded,
// //                 size: 20.sp,
// //                 color: _C.textMuted,
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _showCouponBottomSheet() async {
// //     setState(() => isCouponLoading = true);
// //     final coupons = await food_Authservice.fetchCoupons();
// //     final cartVendor = cartData?.vendorId;
// //     setState(() => isCouponLoading = false);
// //
// //     coupons.sort((a, b) {
// //       if (a.isExpired != b.isExpired) return a.isExpired ? 1 : -1;
// //       final am = !a.isApplicableForVendor(cartVendor);
// //       final bm = !b.isApplicableForVendor(cartVendor);
// //       if (am != bm) return am ? 1 : -1;
// //       return 0;
// //     });
// //
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (ctx) => Scaffold(
// //         backgroundColor: Colors.transparent,
// //         body: SafeArea(
// //           top: false,
// //           child: Container(
// //             height: MediaQuery.of(ctx).size.height * 1,
// //             decoration: BoxDecoration(
// //               color: _C.bg,
// //               borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
// //             ),
// //             child: Column(
// //               children: [
// //                 _couponHeader(),
// //                 coupons.isEmpty
// //                     ? Expanded(child: _emptyCouponView())
// //                     : Expanded(
// //                   child: ListView.builder(
// //                     padding: EdgeInsets.all(16.w),
// //                     itemCount: coupons.length,
// //                     itemBuilder: (_, i) {
// //                       final c = coupons[i];
// //                       return _couponTile(
// //                         coupon: c,
// //                         isExpired: c.isExpired,
// //                         isMismatch: !c.isApplicableForVendor(cartVendor),
// //                         isDisabled:
// //                         c.isExpired ||
// //                             !c.isApplicableForVendor(cartVendor),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _couponHeader() {
// //     return Container(
// //       padding: EdgeInsets.fromLTRB(30.w, 20.h, 16.w, 16.h),
// //       decoration: BoxDecoration(
// //         color: _C.surface,
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
// //         border: Border(bottom: BorderSide(color: _C.border)),
// //       ),
// //       child: Row(
// //         children: [
// //           Text(
// //             'Available Coupons',
// //             style: TextStyle(
// //               fontSize: 16.sp,
// //               fontWeight: FontWeight.w800,
// //               color: _C.textPrimary,
// //             ),
// //           ),
// //           const Spacer(),
// //           GestureDetector(
// //             onTap: () => Navigator.pop(context),
// //             child: Container(
// //               padding: EdgeInsets.all(6.w),
// //               decoration: BoxDecoration(
// //                 color: _C.border,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 Icons.close_rounded,
// //                 size: 16.sp,
// //                 color: _C.textSecondary,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _couponTile({
// //     required CouponModel coupon,
// //     required bool isExpired,
// //     required bool isMismatch,
// //     required bool isDisabled,
// //   }) {
// //     final color = isExpired
// //         ? _C.red
// //         : isMismatch
// //         ? _C.amber
// //         : _C.green;
// //
// //     return Container(
// //       margin: EdgeInsets.only(bottom: 10.h),
// //       decoration: BoxDecoration(
// //         color: _C.surface,
// //         borderRadius: BorderRadius.circular(14.r),
// //         border: Border.all(color: color.withOpacity(0.3)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: ListTile(
// //         contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
// //         leading: Container(
// //           width: 38.r,
// //           height: 38.r,
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.10),
// //             shape: BoxShape.circle,
// //           ),
// //           child: Icon(Icons.local_offer_rounded, color: color, size: 18.sp),
// //         ),
// //         title: Row(
// //           children: [
// //             Text(
// //               coupon.code,
// //               style: TextStyle(
// //                 fontWeight: FontWeight.w700,
// //                 fontSize: 13.sp,
// //                 color: _C.textPrimary,
// //               ),
// //             ),
// //             SizedBox(width: 8.w),
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
// //               decoration: BoxDecoration(
// //                 color: _C.violet.withOpacity(0.08),
// //                 borderRadius: BorderRadius.circular(6.r),
// //               ),
// //               child: Text(
// //                 coupon.couponType,
// //                 style: TextStyle(
// //                   fontSize: 10.sp,
// //                   color: _C.violet,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //         subtitle: Padding(
// //           padding: EdgeInsets.only(top: 4.h),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 isExpired
// //                     ? 'Expired'
// //                     : isMismatch
// //                     ? 'Not applicable for this restaurant'
// //                     : coupon.discountType == "PERCENTAGE"
// //                     ? 'Get ${coupon.discountPercentage.toStringAsFixed(0)}% off'
// //                     : 'Get ₹${coupon.discountPercentage.toStringAsFixed(0)} off',
// //                 style: TextStyle(fontSize: 12.sp, color: color),
// //               ),
// //               if (!isExpired && !isMismatch)
// //                 Text(
// //                   coupon.minimumOrderValue <= 0
// //                       ? 'Applicable on any order'
// //                       : 'Min order ₹${coupon.minimumOrderValue.toInt()}',
// //                   style: TextStyle(fontSize: 11.sp, color: _C.textMuted),
// //                 ),
// //             ],
// //           ),
// //         ),
// //         trailing: isDisabled
// //             ? Icon(Icons.block_rounded, color: color, size: 18.sp)
// //             : Icon(
// //           Icons.arrow_forward_ios_rounded,
// //           size: 14.sp,
// //           color: _C.textMuted,
// //         ),
// //         onTap: isDisabled
// //             ? () => AppAlert.error(
// //           context,
// //           isExpired
// //               ? 'Coupon expired'
// //               : 'Not applicable for this restaurant',
// //         )
// //             : () => _applyCoupon(coupon),
// //       ),
// //     );
// //   }
// //
// //   Widget _emptyCouponView() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.confirmation_number_outlined,
// //             size: 48.sp,
// //             color: _C.textMuted,
// //           ),
// //           SizedBox(height: 12.h),
// //           Text(
// //             'No coupons available',
// //             style: TextStyle(
// //               fontSize: 15.sp,
// //               fontWeight: FontWeight.w700,
// //               color: _C.textSecondary,
// //             ),
// //           ),
// //           SizedBox(height: 4.h),
// //           Text(
// //             'Check back later for new offers',
// //             style: TextStyle(fontSize: 12.sp, color: _C.textMuted),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<void> _applyCoupon(CouponModel coupon) async {
// //     if (cartData?.cartId == null) {
// //       AppAlert.error(context, "Cart is empty");
// //       return;
// //     }
// //     final result = await food_Authservice.updateCartSettings(
// //       cartId: cartData!.cartId,
// //       couponId: coupon.id,
// //       applyCoupon: "APPLIED",
// //     );
// //     if (!result.success) {
// //       AppAlert.error(context, result.error ?? "Failed to apply coupon");
// //       return;
// //     }
// //     await _loadCart();
// //     setState(() {
// //       appliedCouponCode = coupon.code;
// //       appliedCouponId = coupon.id;
// //     });
// //     AppAlert.success(context, "Coupon ${coupon.code} applied!");
// //     Navigator.pop(context);
// //   }
// //
// //   // ── Delivery address ────────────────────────────────────────────────────
// //   Widget _buildDeliveryAddress() {
// //     ref.watch(addressProvider);
// //     final hasAddr = (cartData?.deliveryAddress ?? '').trim().isNotEmpty;
// //
// //     return GestureDetector(
// //       onTap: () => Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (_) => SavedAddress(
// //             hideExtraWidgets: true,
// //             onAddressSelected: (address) async {
// //               // ✅ Update local state
// //               await ref
// //                   .read(addressProvider.notifier)
// //                   .updateLocalAddress(
// //                 city: address.city,
// //                 stateName: address.state,
// //                 pincode: address.pincode,
// //                 latitude: address.latitude,
// //                 longitude: address.longitude,
// //                 fullAddress: address.fullAddress,
// //                 category: address.category, // 🔥 important
// //               );
// //
// //               // ✅ Update cart address (only for saved addresses)
// //               if (address.addressId != 0) {
// //                 final ok = await AddressNotifier.updateDeliveryAddress(
// //                   cartId: cartData!.cartId,
// //                   addressId: address.addressId,
// //                 );
// //
// //                 if (!ok && mounted) {
// //                   AppAlert.error(context, "Failed to update cart address");
// //                 }
// //               }
// //             },
// //           ),
// //         ),
// //       ),
// //       child: _card(
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 40.r,
// //               height: 40.r,
// //               decoration: BoxDecoration(
// //                 color: hasAddr
// //                     ? _C.violet.withOpacity(0.08)
// //                     : _C.red.withOpacity(0.08),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 Icons.location_on_rounded,
// //                 size: 20.sp,
// //                 color: hasAddr ? _C.violet : _C.red,
// //               ),
// //             ),
// //             SizedBox(width: 12.w),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     hasAddr ? 'Delivery Address' : 'Select Delivery Address',
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: _C.textPrimary,
// //                     ),
// //                   ),
// //                   if (hasAddr) ...[
// //                     SizedBox(height: 2.h),
// //                     Text(
// //                       [
// //                         cartData!.deliveryAddress,
// //                         cartData!.name,
// //                         cartData!.mobileNo,
// //                       ].where((e) => e.toString().trim().isNotEmpty).join(', '),
// //                       style: TextStyle(
// //                         fontSize: 11.sp,
// //                         color: _C.textSecondary,
// //                       ),
// //                       maxLines: 2,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     SizedBox(height: 2.h),
// //                     Text(
// //                       'Tap to change',
// //                       style: TextStyle(
// //                         fontSize: 11.sp,
// //                         color: _C.violet,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //             Icon(Icons.chevron_right_rounded, size: 20.sp, color: _C.textMuted),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Order summary card ──────────────────────────────────────────────────
// //   Widget _buildSummaryCard() {
// //     if (cartData == null || isLoading) {
// //       return CartSkeleton(type: CartSkeletonType.summary);
// //     }
// //
// //     final orderType = cartData?.orderType ?? '';
// //     final subtotal = cartData?.subtotal ?? 0;
// //     final packing = cartData?.packingTotal ?? 0;
// //     final delivery = cartData?.deliveryCharges ?? 0;
// //     final platform = cartData?.platformCharges ?? 0;
// //     final discount = cartData?.discountAmount ?? 0;
// //     final gst = cartData?.gstTotal ?? 0;
// //     final grandTotal = cartData?.grandTotal ?? 0;
// //     final type = orderType.toUpperCase();
// //
// //     return _card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Header
// //           GestureDetector(
// //             onTap: () =>
// //                 setState(() => _isSummaryExpanded = !_isSummaryExpanded),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 36.r,
// //                   height: 36.r,
// //                   decoration: BoxDecoration(
// //                     color: _C.violetDim,
// //                     borderRadius: BorderRadius.circular(10.r),
// //                   ),
// //                   child: Icon(
// //                     Icons.receipt_long_rounded,
// //                     size: 18.sp,
// //                     color: _C.violet,
// //                   ),
// //                 ),
// //                 SizedBox(width: 10.w),
// //                 Expanded(
// //                   child: Text(
// //                     'Order Summary',
// //                     style: TextStyle(
// //                       fontSize: 14.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: _C.textPrimary,
// //                     ),
// //                   ),
// //                 ),
// //                 AnimatedRotation(
// //                   turns: _isSummaryExpanded ? 0.5 : 0,
// //                   duration: const Duration(milliseconds: 200),
// //                   child: Icon(
// //                     Icons.keyboard_arrow_down_rounded,
// //                     color: _C.textSecondary,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           // Expandable details
// //           AnimatedCrossFade(
// //             duration: const Duration(milliseconds: 200),
// //             crossFadeState: _isSummaryExpanded
// //                 ? CrossFadeState.showFirst
// //                 : CrossFadeState.showSecond,
// //
// //             firstChild: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 SizedBox(height: 12.h),
// //                 Divider(height: 1, color: _C.border),
// //                 SizedBox(height: 10.h),
// //
// //                 _summaryRow('Subtotal', subtotal),
// //
// //                 if (platform > 0) _summaryRow('Platform Charges', platform),
// //
// //                 if ((type == 'DELIVERY' || type == 'TAKEAWAY') && packing > 0)
// //                   _summaryRow('Packing Charges', packing),
// //
// //                 if (orderType.toUpperCase() == 'DELIVERY')
// //                   _summaryRow('Delivery Charges', delivery),
// //
// //                 if (discount > 0)
// //                   _summaryRow('Discount', -discount, color: _C.green),
// //
// //                 if ((gst / 2) > 0) ...[
// //                   _summaryRow('SGST', gst / 2),
// //                   _summaryRow('CGST', gst / 2),
// //                 ],
// //
// //                 SizedBox(height: 4.h),
// //               ],
// //             ),
// //
// //             secondChild: const SizedBox.shrink(),
// //           ),
// //
// //           Divider(height: 16.h, color: _C.border),
// //
// //           // Grand total
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'Grand Total',
// //                 style: TextStyle(
// //                   fontSize: 15.sp,
// //                   fontWeight: FontWeight.w800,
// //                   color: _C.textPrimary,
// //                 ),
// //               ),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.end,
// //                 children: [
// //                   Text(
// //                     '₹${_fmt(grandTotal)}',
// //                     style: TextStyle(
// //                       fontSize: 15.sp,
// //                       fontWeight: FontWeight.w800,
// //                       color: _C.violet,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _summaryRow(String label, num value, {Color? color}) {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(vertical: 3.h),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(
// //             label,
// //             style: TextStyle(fontSize: 12.sp, color: _C.textSecondary),
// //           ),
// //           Text(
// //             value < 0 ? '-₹${_fmt(-value)}' : '₹${_fmt(value)}',
// //             style: TextStyle(
// //               fontSize: 12.sp,
// //               fontWeight: FontWeight.w600,
// //               color: color ?? _C.textPrimary,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Schedule order ──────────────────────────────────────────────────────
// //   Widget _buildScheduleOrder() {
// //     // bool hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
// //     final isUserScheduled =
// //         _orderType == "schedule" &&
// //             _selectedDate != null &&
// //             _selectedTime != null;
// //
// //     final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
// //
// //     return _card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           /// Header
// //           Text(
// //             "If you want Schedule your order!",
// //             style: TextStyle(
// //               fontSize: 14.sp,
// //               fontWeight: FontWeight.w700,
// //               color: _C.textPrimary,
// //             ),
// //           ),
// //           SizedBox(height: 6.h),
// //           Text(
// //             "Pick a convenient date & time",
// //             style: TextStyle(fontSize: 12.sp, color: _C.textSecondary),
// //           ),
// //
// //           SizedBox(height: 14.h),
// //
// //           if (hasScheduledItems) ...[
// //             Container(
// //               margin: EdgeInsets.only(bottom: 12.h),
// //               padding: EdgeInsets.all(12.w),
// //               decoration: BoxDecoration(
// //                 color: Colors.orange.withOpacity(0.08),
// //                 borderRadius: BorderRadius.circular(10.r),
// //                 border: Border.all(color: Colors.orange.withOpacity(0.3)),
// //               ),
// //               child: Row(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Icon(Icons.info_outline, color: Colors.orange, size: 18.sp),
// //                   SizedBox(width: 8.w),
// //                   Expanded(
// //                     child: Text(
// //                       "Some items in your cart are not available right now. Please schedule your order to continue.",
// //                       style: TextStyle(
// //                         fontSize: 12.sp,
// //                         color: _C.textPrimary,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //
// //           /// CTA Button (when not scheduled)
// //           if (!isUserScheduled)
// //             GestureDetector(
// //               onTap: () async {
// //                 setState(() {
// //                   _orderType = 'schedule';
// //                 });
// //                 await _pickScheduleDateTime();
// //               },
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(vertical: 14.h),
// //                 decoration: BoxDecoration(
// //                   color: _C.violet.withOpacity(0.08),
// //                   borderRadius: BorderRadius.circular(12.r),
// //                   border: Border.all(color: _C.violet.withOpacity(0.3)),
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Icon(Icons.access_time, color: _C.violet, size: 18.sp),
// //                     SizedBox(width: 8.w),
// //
// //                     Text(
// //                       hasScheduledItems && !isUserScheduled
// //                           ? "Schedule to Continue"
// //                           : "Choose Date & Time",
// //                       style: TextStyle(
// //                         fontSize: 13.sp,
// //                         fontWeight: FontWeight.w600,
// //                         color: _C.violet,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //
// //           /// Scheduled State UI
// //           if (isUserScheduled) ...[
// //             SizedBox(height: 12.h),
// //             Container(
// //               padding: EdgeInsets.all(14.w),
// //               decoration: BoxDecoration(
// //                 color: _C.green.withOpacity(0.06),
// //                 borderRadius: BorderRadius.circular(12.r),
// //                 border: Border.all(color: _C.green.withOpacity(0.3)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(
// //                     Icons.check_circle_rounded,
// //                     color: _C.green,
// //                     size: 20.sp,
// //                   ),
// //                   SizedBox(width: 10.w),
// //
// //                   /// Date + Time
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           "Order Scheduled 🎉",
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             fontWeight: FontWeight.w700,
// //                             color: _C.green,
// //                           ),
// //                         ),
// //                         SizedBox(height: 2.h),
// //                         Text(
// //                           '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  •  ${_selectedTime!.format(context)}',
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             color: _C.textSecondary,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //
// //                   /// Edit Button
// //                   GestureDetector(
// //                     onTap: _pickScheduleDateTime,
// //                     child: Container(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: 10.w,
// //                         vertical: 6.h,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: _C.violet.withOpacity(0.08),
// //                         borderRadius: BorderRadius.circular(8.r),
// //                         border: Border.all(color: _C.violet.withOpacity(0.2)),
// //                       ),
// //                       child: Text(
// //                         "Edit",
// //                         style: TextStyle(
// //                           fontSize: 11.sp,
// //                           fontWeight: FontWeight.w600,
// //                           color: _C.violet,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<void> _pickScheduleDateTime() async {
// //     final now = DateTime.now();
// //     final first = now.add(const Duration(minutes: 25));
// //
// //     final date = await showDatePicker(
// //       context: context,
// //       initialDate: first,
// //       firstDate: first,
// //       lastDate: now.add(const Duration(days: 365)),
// //       builder: (ctx, child) => Theme(
// //         data: Theme.of(ctx).copyWith(
// //           colorScheme: const ColorScheme.light(
// //             primary: _C.violet,
// //             onPrimary: Colors.white,
// //             onSurface: Colors.black,
// //           ),
// //           textButtonTheme: TextButtonThemeData(
// //             style: TextButton.styleFrom(foregroundColor: _C.violet),
// //           ),
// //         ),
// //         child: child!,
// //       ),
// //     );
// //     if (date == null) return;
// //
// //     while (true) {
// //       final time = await showTimePicker(
// //         context: context,
// //         initialTime: TimeOfDay.now(),
// //         builder: (ctx, child) => Theme(
// //           data: Theme.of(ctx).copyWith(
// //             timePickerTheme: TimePickerThemeData(
// //               backgroundColor: Colors.white,
// //               dialHandColor: _C.violet,
// //               dialBackgroundColor: _C.bg,
// //             ),
// //             colorScheme: const ColorScheme.light(
// //               primary: _C.violet,
// //               onPrimary: Colors.white,
// //               onSurface: Colors.black,
// //             ),
// //             textButtonTheme: TextButtonThemeData(
// //               style: TextButton.styleFrom(foregroundColor: _C.violet),
// //             ),
// //           ),
// //           child: child!,
// //         ),
// //       );
// //       if (time == null) return;
// //
// //       final selected = DateTime(
// //         date.year,
// //         date.month,
// //         date.day,
// //         time.hour,
// //         time.minute,
// //       );
// //       if (selected.isBefore(now.add(const Duration(minutes: 25)))) {
// //         AppAlert.error(context, "Select a time at least 25 minutes from now");
// //         continue;
// //       }
// //       setState(() {
// //         _selectedDate = date;
// //         _selectedTime = time;
// //       });
// //       break;
// //     }
// //   }
// //
// //   // ── Payment toggle button ───────────────────────────────────────────────
// //   Widget _buildPaymentToggle() {
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() => isExpanded = !isExpanded);
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           if (isExpanded) {
// //             _scrollController.animateTo(
// //               _scrollController.position.maxScrollExtent,
// //               duration: const Duration(milliseconds: 400),
// //               curve: Curves.easeOut,
// //             );
// //           }
// //         });
// //       },
// //       child: Container(
// //         width: double.infinity,
// //         padding: EdgeInsets.symmetric(vertical: 14.h),
// //         decoration: BoxDecoration(
// //           gradient: const LinearGradient(
// //             colors: [Color(0xFF6C63FF), Color(0xFF4A43C9)],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //           ),
// //           borderRadius: BorderRadius.circular(16.r),
// //           boxShadow: [
// //             BoxShadow(
// //               color: _C.violet.withOpacity(0.30),
// //               blurRadius: 16,
// //               offset: const Offset(0, 6),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               isExpanded
// //                   ? Icons.keyboard_arrow_up_rounded
// //                   : Icons.payment_rounded,
// //               color: Colors.white,
// //               size: 20.sp,
// //             ),
// //             SizedBox(width: 8.w),
// //             Text(
// //               isExpanded ? 'Hide Payment Options' : 'Choose Payment Method',
// //               style: TextStyle(
// //                 fontSize: 15.sp,
// //                 fontWeight: FontWeight.w700,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCheckoutDetails() {
// //     return Column(
// //       children: [
// //         cartwallet(
// //           wallet: wallet,
// //           onSelectionChanged: (method, subWallets) {
// //             setState(() {
// //               selectedPaymentMethod = method;
// //               selectedSubWallets = subWallets;
// //             });
// //           },
// //         ),
// //         SizedBox(height: 14.h),
// //         _buildPlaceOrderButton(),
// //       ],
// //     );
// //   }
// //
// //   // ── Place order button ──────────────────────────────────────────────────
// //   Widget _buildPlaceOrderButton() {
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 54.h,
// //       child: ElevatedButton(
// //         onPressed: isPlacingOrder ? null : placeOrder,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: _C.green,
// //           foregroundColor: Colors.white,
// //           elevation: 0,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16.r),
// //           ),
// //           shadowColor: _C.green.withOpacity(0.3),
// //         ),
// //         child: isPlacingOrder
// //             ? SizedBox(
// //           width: 20.r,
// //           height: 20.r,
// //           child: const CircularProgressIndicator(
// //             color: Colors.white,
// //             strokeWidth: 2.5,
// //           ),
// //         )
// //             : Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.check_circle_rounded, size: 18.sp),
// //             SizedBox(width: 8.w),
// //             Text(
// //               'Place Order',
// //               style: TextStyle(
// //                 fontSize: 15.sp,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //             SizedBox(width: 8.w),
// //             Container(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: 10.w,
// //                 vertical: 4.h,
// //               ),
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.15),
// //                 borderRadius: BorderRadius.circular(20.r),
// //               ),
// //               child: Text(
// //                 '₹${(cartData?.grandTotal ?? 0).toStringAsFixed(2)}',
// //                 style: TextStyle(
// //                   fontSize: 13.sp,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Empty cart ──────────────────────────────────────────────────────────
// //   Widget _buildEmptyCart() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           SizedBox(height: 40.h),
// //           Container(
// //             width: 90.r,
// //             height: 90.r,
// //             decoration: BoxDecoration(
// //               color: _C.violetDim,
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(
// //               Icons.shopping_bag_outlined,
// //               size: 40.sp,
// //               color: _C.violet,
// //             ),
// //           ),
// //           SizedBox(height: 20.h),
// //           Text(
// //             'Your cart is empty',
// //             style: TextStyle(
// //               fontSize: 18.sp,
// //               fontWeight: FontWeight.w800,
// //               color: _C.textPrimary,
// //             ),
// //           ),
// //           SizedBox(height: 6.h),
// //           Text(
// //             'Add some delicious items to get started',
// //             style: TextStyle(fontSize: 13.sp, color: _C.textSecondary),
// //           ),
// //           SizedBox(height: 24.h),
// //           GestureDetector(
// //             onTap: () => Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(builder: (_) => MainScreenfood()),
// //             ),
// //             child: Container(
// //               padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
// //               decoration: BoxDecoration(
// //                 color: _C.violet,
// //                 borderRadius: BorderRadius.circular(14.r),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: _C.violet.withOpacity(0.3),
// //                     blurRadius: 16,
// //                     offset: const Offset(0, 6),
// //                   ),
// //                 ],
// //               ),
// //               child: Text(
// //                 'Browse Menu',
// //                 style: TextStyle(
// //                   fontSize: 14.sp,
// //                   fontWeight: FontWeight.w700,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           SizedBox(height: 24.h),
// //           if (homepageAds.isNotEmpty)
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(16.r),
// //               child: BannerAdvertisement(ads: homepageAds, height: 200),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Shared card shell ───────────────────────────────────────────────────
// //   Widget _card({required Widget child, EdgeInsets? padding}) {
// //     return Container(
// //       width: double.infinity,
// //       padding: padding ?? EdgeInsets.all(16.w),
// //       decoration: BoxDecoration(
// //         color: _C.surface,
// //         borderRadius: BorderRadius.circular(16.r),
// //         border: Border.all(color: _C.border),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: child,
// //     );
// //   }
// // }
// //
// // // ═══════════════════════════════════════════════════════════════════════════════
// // // 1. Razorpay "Opening Gateway" overlay
// // // ═══════════════════════════════════════════════════════════════════════════════
// // class _RazorpayLoadingOverlay extends StatefulWidget {
// //   @override
// //   State<_RazorpayLoadingOverlay> createState() =>
// //       _RazorpayLoadingOverlayState();
// // }
// //
// // class _RazorpayLoadingOverlayState extends State<_RazorpayLoadingOverlay>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _ctrl;
// //   late Animation<double> _fade;
// //   late Animation<double> _scale;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _ctrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 450),
// //     )..forward();
// //     _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
// //     _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
// //       CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _ctrl.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FadeTransition(
// //       opacity: _fade,
// //       child: Container(
// //         color: Colors.black.withOpacity(0.60),
// //         child: Center(
// //           child: ScaleTransition(
// //             scale: _scale,
// //             child: Container(
// //               margin: EdgeInsets.symmetric(horizontal: 40.w),
// //               padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 28.w),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(24.r),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: const Color(0xFF6C63FF).withOpacity(0.18),
// //                     blurRadius: 40,
// //                     offset: const Offset(0, 12),
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   // Razorpay-like logo badge
// //                   Container(
// //                     width: 64.r,
// //                     height: 64.r,
// //                     decoration: BoxDecoration(
// //                       gradient: const LinearGradient(
// //                         colors: [Color(0xFF072654), Color(0xFF3395FF)],
// //                         begin: Alignment.topLeft,
// //                         end: Alignment.bottomRight,
// //                       ),
// //                       borderRadius: BorderRadius.circular(18.r),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: const Color(0xFF3395FF).withOpacity(0.35),
// //                           blurRadius: 16,
// //                           offset: const Offset(0, 6),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Icon(
// //                       Icons.payment_rounded,
// //                       color: Colors.white,
// //                       size: 30.sp,
// //                     ),
// //                   ),
// //                   SizedBox(height: 20.h),
// //                   Text(
// //                     'Opening Payment Gateway',
// //                     style: TextStyle(
// //                       fontSize: 16.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: const Color(0xFF1A1D2E),
// //                     ),
// //                   ),
// //                   SizedBox(height: 6.h),
// //                   Text(
// //                     'Redirecting to Razorpay…',
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       color: const Color(0xFF64748B),
// //                     ),
// //                   ),
// //                   SizedBox(height: 24.h),
// //                   SizedBox(
// //                     width: 28.r,
// //                     height: 28.r,
// //                     child: const CircularProgressIndicator(
// //                       color: Color(0xFF3395FF),
// //                       strokeWidth: 3,
// //                     ),
// //                   ),
// //                   SizedBox(height: 18.h),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.lock_outline_rounded,
// //                           size: 13.sp, color: const Color(0xFF10B981)),
// //                       SizedBox(width: 4.w),
// //                       Text(
// //                         '256-bit SSL secured',
// //                         style: TextStyle(
// //                           fontSize: 11.sp,
// //                           color: const Color(0xFF10B981),
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ═══════════════════════════════════════════════════════════════════════════════
// // // 2. Payment Processing overlay (after Razorpay success, before order API)
// // // ═══════════════════════════════════════════════════════════════════════════════
// // class _PaymentProcessingOverlay extends StatefulWidget {
// //   @override
// //   State<_PaymentProcessingOverlay> createState() =>
// //       _PaymentProcessingOverlayState();
// // }
// //
// // class _PaymentProcessingOverlayState extends State<_PaymentProcessingOverlay>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _ctrl;
// //   late Animation<double> _fade;
// //   late Animation<double> _scale;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _ctrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 400),
// //     )..forward();
// //     _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
// //     _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
// //       CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _ctrl.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FadeTransition(
// //       opacity: _fade,
// //       child: Container(
// //         color: Colors.black.withOpacity(0.65),
// //         child: Center(
// //           child: ScaleTransition(
// //             scale: _scale,
// //             child: Container(
// //               margin: EdgeInsets.symmetric(horizontal: 40.w),
// //               padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 28.w),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(24.r),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: const Color(0xFF6C63FF).withOpacity(0.2),
// //                     blurRadius: 40,
// //                     offset: const Offset(0, 12),
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Container(
// //                     width: 64.r,
// //                     height: 64.r,
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFF0FDF4),
// //                       shape: BoxShape.circle,
// //                       border: Border.all(
// //                         color: const Color(0xFF10B981).withOpacity(0.3),
// //                         width: 2,
// //                       ),
// //                     ),
// //                     child: Icon(
// //                       Icons.sync_rounded,
// //                       color: const Color(0xFF10B981),
// //                       size: 30.sp,
// //                     ),
// //                   ),
// //                   SizedBox(height: 20.h),
// //                   Text(
// //                     'Confirming Payment',
// //                     style: TextStyle(
// //                       fontSize: 16.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: const Color(0xFF1A1D2E),
// //                     ),
// //                   ),
// //                   SizedBox(height: 6.h),
// //                   Text(
// //                     'Please wait while we confirm\nyour payment and place your order…',
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       color: const Color(0xFF64748B),
// //                       height: 1.5,
// //                     ),
// //                   ),
// //                   SizedBox(height: 24.h),
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(8.r),
// //                     child: SizedBox(
// //                       height: 5.h,
// //                       child: LinearProgressIndicator(
// //                         backgroundColor: const Color(0xFFE8ECF4),
// //                         valueColor: const AlwaysStoppedAnimation<Color>(
// //                           Color(0xFF10B981),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 14.h),
// //                   Text(
// //                     'Do not press back or close the app',
// //                     style: TextStyle(
// //                       fontSize: 11.sp,
// //                       color: const Color(0xFFF59E0B),
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ═══════════════════════════════════════════════════════════════════════════════
// // // 3. Order Success overlay (before navigating to invoice)
// // // ═══════════════════════════════════════════════════════════════════════════════
// // class _OrderSuccessOverlay extends StatefulWidget {
// //   final double grandTotal;
// //   const _OrderSuccessOverlay({required this.grandTotal});
// //
// //   @override
// //   State<_OrderSuccessOverlay> createState() => _OrderSuccessOverlayState();
// // }
// //
// // class _OrderSuccessOverlayState extends State<_OrderSuccessOverlay>
// //     with TickerProviderStateMixin {
// //   late AnimationController _bgCtrl;
// //   late AnimationController _checkCtrl;
// //   late AnimationController _textCtrl;
// //   late AnimationController _pulseCtrl;
// //
// //   late Animation<double> _bgFade;
// //   late Animation<double> _circleFade;
// //   late Animation<double> _circleScale;
// //   late Animation<double> _checkDraw;
// //   late Animation<double> _textFade;
// //   late Animation<Offset> _textSlide;
// //   late Animation<double> _pulse;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     _bgCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 350),
// //     );
// //     _checkCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 550),
// //     );
// //     _textCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 400),
// //     );
// //     _pulseCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 900),
// //     )..repeat(reverse: true);
// //
// //     _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);
// //     _circleFade = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut);
// //     _circleScale = Tween<double>(begin: 0.4, end: 1.0).animate(
// //       CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut),
// //     );
// //     _checkDraw = CurvedAnimation(
// //       parent: _checkCtrl,
// //       curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
// //     );
// //     _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
// //     _textSlide = Tween<Offset>(
// //       begin: const Offset(0, 0.3),
// //       end: Offset.zero,
// //     ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
// //     _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(_pulseCtrl);
// //
// //     _bgCtrl.forward().then((_) {
// //       _checkCtrl.forward().then((_) {
// //         _textCtrl.forward();
// //       });
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _bgCtrl.dispose();
// //     _checkCtrl.dispose();
// //     _textCtrl.dispose();
// //     _pulseCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FadeTransition(
// //       opacity: _bgFade,
// //       child: Container(
// //         color: Colors.black.withOpacity(0.70),
// //         child: Center(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               // ── Animated check circle ─────────────────────────────────
// //               ScaleTransition(
// //                 scale: _circleScale,
// //                 child: FadeTransition(
// //                   opacity: _circleFade,
// //                   child: ScaleTransition(
// //                     scale: _pulse,
// //                     child: Stack(
// //                       alignment: Alignment.center,
// //                       children: [
// //                         // Outer glow ring
// //                         Container(
// //                           width: 110.r,
// //                           height: 110.r,
// //                           decoration: BoxDecoration(
// //                             shape: BoxShape.circle,
// //                             color: const Color(0xFF10B981).withOpacity(0.15),
// //                           ),
// //                         ),
// //                         // Inner circle
// //                         Container(
// //                           width: 80.r,
// //                           height: 80.r,
// //                           decoration: const BoxDecoration(
// //                             shape: BoxShape.circle,
// //                             gradient: LinearGradient(
// //                               colors: [Color(0xFF10B981), Color(0xFF059669)],
// //                               begin: Alignment.topLeft,
// //                               end: Alignment.bottomRight,
// //                             ),
// //                           ),
// //                         ),
// //                         // Check icon drawn with animation
// //                         FadeTransition(
// //                           opacity: _checkDraw,
// //                           child: Icon(
// //                             Icons.check_rounded,
// //                             color: Colors.white,
// //                             size: 40.sp,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //
// //               SizedBox(height: 28.h),
// //
// //               // ── Animated text ─────────────────────────────────────────
// //               SlideTransition(
// //                 position: _textSlide,
// //                 child: FadeTransition(
// //                   opacity: _textFade,
// //                   child: Column(
// //                     children: [
// //                       Text(
// //                         'Order Placed! 🎉',
// //                         style: TextStyle(
// //                           fontSize: 24.sp,
// //                           fontWeight: FontWeight.w800,
// //                           color: Colors.white,
// //                           letterSpacing: -0.5,
// //                         ),
// //                       ),
// //                       SizedBox(height: 8.h),
// //                       Text(
// //                         '₹${widget.grandTotal.toStringAsFixed(2)} paid successfully',
// //                         style: TextStyle(
// //                           fontSize: 15.sp,
// //                           color: Colors.white.withOpacity(0.80),
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                       SizedBox(height: 6.h),
// //                       Text(
// //                         'Redirecting to your invoice…',
// //                         style: TextStyle(
// //                           fontSize: 12.sp,
// //                           color: Colors.white.withOpacity(0.55),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
//
// import '../../Models/promotions_model/promotions_model.dart';
// import '../../Services/Auth_service/Subscription_authservice.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Services/Auth_service/food_authservice.dart';
// import '../../Services/Auth_service/promotion_services_Authservice.dart';
// import '../../Services/paymentservice/razorpayservice.dart';
// import '../../Services/websockets/web_socket_manager.dart';
// import '../../widgets/widgets/skeleton/cart_skeleton.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../Services/scaffoldmessenger/messenger.dart';
// import 'package:maamaas/screens/foodmainscreen.dart';
// import 'package:maamaas/widgets/signinrequired.dart';
// import '../../Models/subscrptions/coupon_model.dart';
// import '../../Models/subscrptions/wallet_model.dart';
// import '../../providers/addressmodel_provider.dart';
// import '../../widgets/widgets/cart wallet.dart';
// import '../../Models/food/cart_model.dart';
// import '../screens/advertisements/banneradvertisement.dart';
// import '../screens/ordertypebutton.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import '../screens/saved_address.dart';
// // import 'FOODCARTDUMMY.dart';
// import 'Menu/menu_screen.dart';
// import 'food_invoice.dart';
//
// // ── Design tokens ─────────────────────────────────────────────────────────────
// class _C {
//   static const bg = Color(0xFFF5F6FA);
//   static const surface = Color(0xFFFFFFFF);
//   static const border = Color(0xFFE8ECF4);
//
//   static const violet = Color(0xFF6C63FF);
//   static const violetDim = Color(0x1A6C63FF);
//
//   static const textPrimary = Color(0xFF1A1D2E);
//   static const textSecondary = Color(0xFF64748B);
//   static const textMuted = Color(0xFFB0B8CC);
//
//   static const green = Color(0xFF10B981);
//   static const red = Color(0xFFEF4444);
//   static const amber = Color(0xFFF59E0B);
// }
//
// // Add inside _food_cartScreenState class
// String? _safeStr(dynamic v) {
//   if (v == null) return null;
//   if (v is String) return v;
//   if (v is num || v is bool) return v.toString();
//   if (v is Map) {
//     return v['url']?.toString() ?? v['path']?.toString() ?? v.toString();
//   }
//   return null;
// }
//
// String _safeStrOr(dynamic v, [String fallback = '']) => _safeStr(v) ?? fallback;
//
// // ignore: camel_case_types
// class food_cartScreen extends ConsumerStatefulWidget {
//   final int? vendorId;
//   final int? cartId;
//   final double? savedAmount;
//   final bool showSavedPopup;
//
//   const food_cartScreen({
//     super.key,
//     this.vendorId,
//     this.cartId,
//     this.savedAmount,
//     this.showSavedPopup = false,
//   });
//
//   @override
//   ConsumerState<food_cartScreen> createState() => _food_cartScreenState();
// }
//
// // ignore: camel_case_types
// class _food_cartScreenState extends ConsumerState<food_cartScreen> {
//   CartModel? cartData;
//   bool isLoading = true;
//   bool isPlacingOrder = false;
//   bool couponApplied = false;
//   String selectedPaymentMethod = "";
//   String couponCode = "";
//   bool isExpanded = false;
//   Wallet? wallet;
//   int? appliedCouponId;
//   String? appliedCouponCode;
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   late ScrollController _scrollController;
//   String _orderType = "";
//   bool isCouponLoading = false;
//   Set<String> selectedSubWallets = {};
//   int userId = 0;
//   List<Campaign> homepageAds = [];
//   bool _isSummaryExpanded = false;
//   final List<Map<String, dynamic>> _pendingSocketUpdates = [];
//
//   // ── Payment UI overlay states ──────────────────────────────────────────
//   bool _isRazorpayLoading = false; // "Opening payment gateway…"
//   bool _isProcessingPayment = false; // "Confirming your payment…"
//   bool _showOrderSuccess = false; // animated success before invoice nav
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _loadWallet();
//     _loadCart();
//     _initCartSocket();
//     _loadAds();
//     if (cartData?.hasAnyScheduledItem ?? false) {
//       _orderType = 'schedule';
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     WebSocketManager().unsubscribeUserCart(userId);
//     super.dispose();
//   }
//
//   Future<void> _loadWallet() async {
//     try {
//       final w = await subscription_AuthService.fetchWallet();
//       if (!mounted) return;
//       setState(() => wallet = w);
//     } catch (_) {
//       if (!mounted) return;
//       AppAlert.error(context, "❌ Failed to load wallet");
//     }
//   }
//
//   List<String> mapWalletsToEnum(List<String> s) => s.map((w) {
//     switch (w) {
//       case "Cashbacks":
//         return "CASHBACK";
//       case "Self Loaded":
//         return "SELF_LOADED";
//       case "Postpaid used amount":
//         return "POST_PAID";
//       case "Company Loaded":
//         return "COMPANY_LOADED";
//       case "Earned Amount":
//         return "EARNED_AMOUNT";
//       default:
//         return w.toUpperCase().replaceAll(' ', '_');
//     }
//   }).toList();
//
//   void _initCartSocket() async {
//     final prefs = await SharedPreferences.getInstance();
//     userId = prefs.getInt('userId') ?? 0;
//     WebSocketManager().subscribeUserCart(userId, _updateCartFromSocket);
//   }
//
//   // void _updateCartFromSocket(Map<String, dynamic> data) {
//   //   if (cartData == null) {
//   //     print("⏳ cartData not ready → queuing socket update");
//   //     _pendingSocketUpdates.add(data);
//   //     return;
//   //   }
//   //   _applySocketUpdate(data);
//   // }
//
//   void _flushPendingSocketUpdates() {
//     for (final update in _pendingSocketUpdates) {
//       _applySocketUpdate(update);
//     }
//     _pendingSocketUpdates.clear();
//   }
//
//   void _applySocketUpdate(Map<String, dynamic> data) {
//     print("🟡 RAW SOCKET DATA: $data");
//     final List items = data['cartItems'] ?? [];
//
//     if (!mounted) return;
//
//     setState(() {
//       cartData!.cartItems = items.map((json) {
//         final idx = cartData!.cartItems.indexWhere(
//           (i) => i.itemId == json['itemId'],
//         );
//
//         if (idx != -1) {
//           final old = cartData!.cartItems[idx];
//           // ✅ Create a NEW object so Flutter detects the change
//           return CartItem(
//             itemId: old.itemId,
//             dishName: old.dishName,
//             dishId: old.dishId,
//             chefType: old.chefType,
//             dishImage: old.dishImage,
//             actualPrice: (json['actualPrice'] ?? old.actualPrice).toDouble(),
//             gst: (json['gst'] ?? old.gst).toDouble(),
//             quantity: json['quantity'] ?? old.quantity,
//             price: (json['price'] ?? old.price).toDouble(),
//             totalPrice: (json['totalPrice'] ?? old.totalPrice).toDouble(),
//             packingCharges: (json['packingCharges'] ?? old.packingCharges)
//                 .toDouble(),
//             balanceQuantity: json['balanceQuantity'] ?? old.balanceQuantity,
//             available: json['available'] ?? old.available,
//             shedule: json.containsKey('shedule')
//                 ? json['shedule'] == true
//                 : old.shedule,
//           );
//         }
//
//         return CartItem.fromJson(json);
//       }).toList();
//
//       final rawCoupon = data['couponCode'];
//
//       cartData!.subtotal = (data['subtotal'] ?? 0).toDouble();
//       cartData!.gstTotal = (data['gstTotal'] ?? 0).toDouble();
//       cartData!.packingTotal = (data['packingTotal'] ?? 0).toDouble();
//       cartData!.platformCharges = (data['platformCharges'] ?? 0).toDouble();
//       cartData!.deliveryCharges = (data['deliveryCharges'] ?? 0).toDouble();
//       cartData!.discountAmount = (data['discountAmount'] ?? 0).toDouble();
//       cartData!.grandTotal = (data['grandTotal'] ?? 0).toDouble();
//       cartData!.cgst = (data['cgst'] ?? 0).toDouble();
//       cartData!.sgst = (data['sgst'] ?? 0).toDouble();
//       cartData!.deliveryAddress =
//           data['deliveryAddress'] ?? cartData!.deliveryAddress;
//       cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
//       cartData!.name = data['name'] ?? cartData!.name;
//       // cartData!.couponCode = data['couponCode'];
//
//       cartData!.couponCode = rawCoupon is String
//           ? rawCoupon
//           : rawCoupon is Map
//           ? rawCoupon['code']
//           : null;
//     });
//   }
//
//   void _updateCartFromSocket(Map<String, dynamic> data) {
//     print("🟡 RAW SOCKET DATA: $data");
//
//     if (cartData == null) {
//       // ✅ FIXED: buffer it instead of dropping it
//       print("⏳ cartData not ready → buffering socket update");
//       _pendingSocketUpdates.add(data);
//       return;
//     }
//
//     _applySocketUpdate(data);
//
//     final List items = data['cartItems'] ?? [];
//     print("📦 Incoming cart items count: ${items.length}");
//
//     setState(() {
//       cartData!.cartItems = items.map((json) {
//         print("➡️ Processing item: $json");
//
//         final idx = cartData!.cartItems.indexWhere(
//           (i) => i.itemId == json['itemId'],
//         );
//
//         if (idx != -1) {
//           final item = cartData!.cartItems[idx];
//
//           print("🔁 Updating existing item: ${item.itemId}");
//           print(
//             "   OLD -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
//           );
//
//           item.quantity = json['quantity'] ?? item.quantity;
//           item.totalPrice = (json['totalPrice'] ?? item.totalPrice).toDouble();
//           item.price = (json['price'] ?? item.price).toDouble();
//           item.packingCharges = (json['packingCharges'] ?? item.packingCharges)
//               .toDouble();
//
//           if (json.containsKey('shedule')) {
//             item.shedule = json['shedule'] == true;
//           } else {
//             print("⚠️shedule missing from socket, keeping old value");
//           }
//
//           print("UPDATED isScheduled: ${item.shedule}");
//           print(
//             "NEW -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
//           );
//
//           return item;
//         }
//
//         print("🆕 New item added: ${json['itemId']}");
//         return CartItem.fromJson(json);
//       }).toList();
//
//       final rawCoupon = data['couponCode'];
//
//       // prices ...
//       cartData!.subtotal = (data['subtotal'] ?? 0).toDouble();
//       cartData!.gstTotal = (data['gstTotal'] ?? 0).toDouble();
//       cartData!.packingTotal = (data['packingTotal'] ?? 0).toDouble();
//       cartData!.platformCharges = (data['platformCharges'] ?? 0).toDouble();
//       cartData!.deliveryCharges = (data['deliveryCharges'] ?? 0).toDouble();
//       cartData!.discountAmount = (data['discountAmount'] ?? 0).toDouble();
//       cartData!.grandTotal = (data['grandTotal'] ?? 0).toDouble();
//       cartData!.cgst = (data['cgst'] ?? 0).toDouble();
//       cartData!.sgst = (data['sgst'] ?? 0).toDouble();
//
//       // cartData!.deliveryAddress =
//       //     data['deliveryAddress'] ?? cartData!.deliveryAddress;
//       // cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
//       // cartData!.name = data['name'] ?? cartData!.name;
//       // cartData!.couponCode = data['couponCode'];
//
//       cartData!.deliveryAddress = _safeStrOr(data['deliveryAddress']).isNotEmpty
//           ? _safeStrOr(data['deliveryAddress'])
//           : cartData!.deliveryAddress;
//       cartData!.mobileNo = _safeStrOr(data['mobileNo']).isNotEmpty
//           ? _safeStrOr(data['mobileNo'])
//           : cartData!.mobileNo;
//       cartData!.name = _safeStrOr(data['name']).isNotEmpty
//           ? _safeStrOr(data['name'])
//           : cartData!.name;
//       cartData!.couponCode = rawCoupon is String
//           ? rawCoupon
//           : rawCoupon is Map
//           ? rawCoupon['code']
//           : null;
//
//       // // ✅ FIX: Re-sync _orderType after items update
//       // if (cartData!.hasAnyScheduledItem) {
//       //   _orderType = 'schedule';
//       //   print("🚨 Socket update: orderType set to schedule");
//       // } else if (_orderType == 'schedule') {
//       //   // All scheduled items removed — revert to default
//       //   _orderType = cartData!.orderType.toLowerCase(); // e.g. 'delivery'
//       //   print("🔄 Socket update: no scheduled items, reverting orderType");
//       // }
//     });
//
//     // print("✅ Cart UI updated successfully\n");
//     // _loadCart();
//   }
//
//   Future<void> _loadCart() async {
//     setState(() => isLoading = true);
//     try {
//       final c = await food_Authservice.fetchCart();
//       if (mounted) {
//         setState(() {
//           cartData = c;
//
//           print("📦 Cart Loaded:");
//           print("   Total Items: ${cartData?.cartItems.length}");
//
//           for (var item in cartData!.cartItems) {
//             print("   👉 ${item.dishName} → isScheduled: ${item.shedule}");
//           }
//
//           print("🔥 hasAnyScheduledItem: ${cartData?.hasAnyScheduledItem}");
//
//           // ✅ Sync orderType from loaded cart
//           if (cartData?.hasAnyScheduledItem ?? false) {
//             _orderType = 'schedule';
//             print("🚨 _loadCart: orderType set to schedule");
//           }
//
//           isLoading = false;
//         });
//         _flushPendingSocketUpdates();
//       }
//     } catch (_) {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   double getSelectedWalletBalance() {
//     if (wallet == null) return 0;
//     double t = 0;
//     if (selectedSubWallets.contains("Company Loaded")) {
//       t += wallet!.companyLoadedAmount;
//     }
//     if (selectedSubWallets.contains("Self Loaded")) {
//       t += wallet!.selfLoadedAmount;
//     }
//     if (selectedSubWallets.contains("Cashbacks")) t += wallet!.cashbackAmount;
//     if (selectedSubWallets.contains("Postpaid used amount")) {
//       t += wallet!.postPaidUsage;
//     }
//     return t;
//   }
//
//   Future<void> placeOrder() async {
//     final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
//     if (hasScheduledItems && (_selectedDate == null || _selectedTime == null)) {
//       AppAlert.error(
//         context,
//         "📅 Please select date & time to schedule your order",
//       );
//       return;
//     }
//
//     if ((cartData?.orderType ?? '').trim().toLowerCase() == 'delivery') {
//       if ((cartData?.deliveryAddress ?? '').trim().isEmpty) {
//         AppAlert.error(context, "⚠️ Please select delivery address");
//         return;
//       }
//     }
//     if (selectedPaymentMethod == "Maamaas_Wallet") {
//       final wb = getSelectedWalletBalance();
//       final gt = (cartData?.grandTotal ?? 0).toDouble();
//       if (wb < gt) {
//         AppAlert.error(
//           context,
//           "❌ Insufficient wallet balance\nWallet: ₹${wb.toStringAsFixed(2)}\nOrder Total: ₹${gt.toStringAsFixed(2)}",
//         );
//         return;
//       }
//     }
//     if (selectedPaymentMethod.isEmpty) {
//       AppAlert.error(context, "⚠️ Please select a payment method");
//       return;
//     }
//
//     setState(() => isPlacingOrder = true);
//     try {
//       final bool isUserScheduled =
//           _selectedDate != null || _selectedTime != null;
//
//       if (selectedPaymentMethod == "Online_Payment") {
//         final amount = (cartData?.grandTotal ?? 0).toDouble();
//
//         // ── Show "opening gateway" overlay while createOrder API runs ────
//         if (mounted) setState(() => _isRazorpayLoading = true);
//         final orderId = await food_Authservice.createOrder(amount);
//         if (mounted) setState(() => _isRazorpayLoading = false);
//
//         if (orderId == null) {
//           AppAlert.error(context, "❌ Failed to create payment order");
//           return;
//         }
//         final rp = RazorpayService();
//         rp.onSuccess = (res) async {
//           final pid = res.paymentId!;
//           final oid = res.orderId!;
//           // ── Show "confirming payment" overlay while order API runs ──────
//           if (mounted) setState(() => _isProcessingPayment = true);
//           final ok = isUserScheduled
//               ? await _placeScheduledOrder(
//                   paymentMethod: "Online_Payment",
//                   razorpayPaymentId: pid,
//                   razorpayOrderId: oid,
//                   amount: amount,
//                 )
//               : await _placeDirectOrder(
//                   paymentMethod: "Online_Payment",
//                   razorpayPaymentId: pid,
//                   razorpayOrderId: oid,
//                   amount: amount,
//                 );
//           // FIX: hide processing overlay only after order result is known
//           // (_showOrderSuccess takes over visually, so hide _isProcessingPayment
//           //  only when ok==false so there's no blank-flash gap)
//           if (!ok && mounted) setState(() => _isProcessingPayment = false);
//
//           if (ok) {
//             // capturePayment runs in background — navigation already happened
//             // inside _placeDirectOrder/_placeScheduledOrder
//             food_Authservice
//                 .capturePayment(paymentId: pid, amount: amount)
//                 .catchError((_) {
//                   // Silently catch — capture failure does not reverse the order
//                 });
//           } else {
//             AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
//           }
//         };
//         rp.onError = (res) {
//           if (mounted) {
//             setState(() {
//               _isRazorpayLoading = false;
//               isPlacingOrder = false;
//             });
//           }
//           AppAlert.error(context, "Payment failed: ${res.message}");
//         };
//         rp.startPayment(
//           orderId: orderId,
//           amount: amount,
//           description: "Online Payment via Razorpay",
//         );
//         // FIX: do NOT return early — let finally reset isPlacingOrder
//         //      (Razorpay sheet is already open; button spinner can stop)
//         return;
//       }
//
//       final amt = cartData!.grandTotal.toDouble();
//       if (isUserScheduled) {
//         await _placeScheduledOrder(
//           paymentMethod: selectedPaymentMethod,
//           razorpayPaymentId: "",
//           razorpayOrderId: "",
//           amount: amt,
//         );
//       } else {
//         await _placeDirectOrder(
//           paymentMethod: selectedPaymentMethod,
//           razorpayPaymentId: "",
//           razorpayOrderId: "",
//           amount: amt,
//         );
//       }
//     } catch (e) {
//       debugPrint("❌ Place Order Error: $e");
//
//       String message = "Error placing order";
//
//       if (e.toString().contains("Exception:")) {
//         message = e.toString().replaceFirst("Exception: ", "");
//       } else {
//         message = e.toString();
//       }
//
//       // FIX: clear all overlay flags on any error so nothing gets stuck
//       if (mounted) {
//         setState(() {
//           _isRazorpayLoading = false;
//           _isProcessingPayment = false;
//           _showOrderSuccess = false;
//         });
//       }
//
//       AppAlert.error(context, message);
//     } finally {
//       // FIX: always reset the Place Order button spinner
//       if (mounted) setState(() => isPlacingOrder = false);
//     }
//   }
//
//   Future<bool> _placeScheduledOrder({
//     required String paymentMethod,
//     required String razorpayPaymentId,
//     required String razorpayOrderId,
//     required double amount,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartId = prefs.getInt('cartId');
//     if (cartId == null) return false;
//     final result = await food_Authservice.scheduleOrder(
//       cartId: cartId,
//       date: _selectedDate ?? DateTime.now(),
//       time: _selectedTime ?? TimeOfDay.now(),
//       paymentMethod: paymentMethod,
//       razorpayPaymentId: razorpayPaymentId,
//       razorpayOrderId: razorpayOrderId,
//       walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
//       amount: amount,
//     );
//     if (result.containsKey('orderId')) {
//       final oid = result['orderId'];
//       await prefs.setInt('orderId', oid);
//       if (mounted) {
//         // FIX: flip both flags in one setState to avoid a single-frame blank flash
//         setState(() {
//           _isProcessingPayment = false;
//           _showOrderSuccess = true;
//         });
//         await Future.delayed(const Duration(milliseconds: 2200));
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
//           );
//         }
//       }
//       return true;
//     }
//     return false;
//   }
//
//   Future<bool> _placeDirectOrder({
//     required String paymentMethod,
//     required String razorpayPaymentId,
//     required String razorpayOrderId,
//     required double amount,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartId = prefs.getInt('cartId');
//     if (cartId == null) return false;
//     final result = await food_Authservice.placeDirectOrder(
//       cartId: cartId,
//       paymentMethod: paymentMethod,
//       razorpayPaymentId: razorpayPaymentId,
//       razorpayOrderId: razorpayOrderId,
//       walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
//       amount: amount,
//     );
//     if (result.containsKey('orderId')) {
//       final oid = result['orderId'];
//       await prefs.setInt('orderId', oid);
//       if (mounted) {
//         // FIX: flip both flags in one setState to avoid a single-frame blank flash
//         setState(() {
//           _isProcessingPayment = false;
//           _showOrderSuccess = true;
//         });
//         await Future.delayed(const Duration(milliseconds: 2200));
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
//           );
//         }
//       }
//       return true;
//     }
//     return false;
//   }
//
//   Future<void> changeQuantity(CartItem item, int newQty) async {
//     final old = item.quantity;
//     setState(() => item.quantity = newQty);
//     final ok = await food_Authservice.updateCartQuantity(item.itemId, newQty);
//     if (!ok) {
//       setState(() {
//         item.quantity = old;
//         item.totalPrice = item.price * old;
//       });
//     }
//   }
//
//   Future<void> _onRefresh() async {
//     final c = await food_Authservice.fetchCart();
//     final w = await subscription_AuthService.fetchWallet();
//     if (!mounted) return;
//     setState(() {
//       cartData = c;
//       wallet = w;
//     });
//   }
//
//   Future<void> _loadAds() async {
//     try {
//       final result = await promotion_Authservice.fetchcampaign();
//       setState(
//         () => homepageAds = result
//             .where(
//               (c) =>
//                   c.status == Status.ACTIVE &&
//                   c.approvalStatus == ApprovalStatus.APPROVED &&
//                   c.addDisplayPosition == AddDisplayPosition.CHECKOUT_PAGE,
//             )
//             .toList(),
//       );
//     } catch (_) {}
//   }
//
//   String _fmt(num? v) => (v ?? 0).toStringAsFixed(2);
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
//     return Stack(
//       children: [
//         Scaffold(
//           backgroundColor: _C.bg,
//           appBar: _buildAppBar(),
//           body: AuthGuard(
//             child: SafeArea(
//               child: RefreshIndicator(
//                 onRefresh: _onRefresh,
//                 color: _C.violet,
//                 backgroundColor: _C.surface,
//                 child: isLoading
//                     ? SingleChildScrollView(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         padding: EdgeInsets.all(16.w),
//                         child: const CartSkeleton(
//                           type: CartSkeletonType.fullCart,
//                         ),
//                       )
//                     : SingleChildScrollView(
//                         controller: _scrollController,
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 16.w,
//                           vertical: 12.h,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (cartData == null || cartData!.cartItems.isEmpty)
//                               _buildEmptyCart()
//                             else ...[
//                               _buildCartItems(),
//                               SizedBox(height: 10.h),
//                               _buildAddMoreText(),
//                               SizedBox(height: 12.h),
//
//                               OrderCartFooter(
//                                 onOrderTypeChanged: () async {
//                                   final c = await food_Authservice.fetchCart();
//                                   setState(() => cartData = c);
//                                 },
//                               ),
//
//                               // ── Ads banner ───────────────────────────
//                               if (homepageAds.isNotEmpty) ...[
//                                 SizedBox(height: 12.h),
//                                 _sectionLabel('Recommended for you'),
//                                 SizedBox(height: 8.h),
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(16.r),
//                                   child: BannerAdvertisement(
//                                     ads: homepageAds,
//                                     height: 160,
//                                   ),
//                                 ),
//                               ],
//
//                               SizedBox(height: 12.h),
//                               _buildCouponRow(),
//                               SizedBox(height: 10.h),
//
//                               if ((cartData?.orderType ?? '')
//                                       .trim()
//                                       .toLowerCase() ==
//                                   'delivery')
//                                 _buildDeliveryAddress(),
//
//                               SizedBox(height: 10.h),
//                               _buildSummaryCard(),
//                               SizedBox(height: 12.h),
//                               _buildScheduleOrder(),
//                               SizedBox(height: 12.h),
//                               _buildPaymentToggle(),
//                               if (isExpanded) ...[
//                                 SizedBox(height: 12.h),
//                                 _buildCheckoutDetails(),
//                               ],
//                               SizedBox(height: 24.h),
//                             ],
//                           ],
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         ),
//
//         // ── Razorpay opening overlay ──────────────────────────────────────
//         // if (_isPlacingOrder)
//         //   _overlayWrapper(
//         //     child: CircularProgressIndicator(color: _C.violet),
//         //   ),
//         if (_isRazorpayLoading)
//           _overlayWrapper(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(color: _C.violet),
//                 SizedBox(height: 12),
//                 Text("Opening payment gateway..."),
//               ],
//             ),
//           ),
//
//         if (_isProcessingPayment)
//           _overlayWrapper(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(color: _C.violet),
//                 SizedBox(height: 12),
//                 Text("Processing payment..."),
//               ],
//             ),
//           ),
//         if (_isProcessingPayment)
//           _overlayWrapper(
//             child: _OrderSuccessOverlay(
//               grandTotal: (cartData?.grandTotal ?? 0).toDouble(),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _overlayWrapper({required Widget child}) {
//     return Positioned.fill(
//       child: AbsorbPointer(
//         child: Container(
//           color: Colors.black.withOpacity(0.5), // stronger dim
//           child: Center(
//             child: Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: child,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── AppBar ──────────────────────────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: _C.surface,
//       elevation: 0,
//       centerTitle: true,
//       title: Text(
//         'Review Your Cart',
//         style: TextStyle(
//           fontSize: 17.sp,
//           fontWeight: FontWeight.w700,
//           color: _C.textPrimary,
//         ),
//       ),
//       iconTheme: const IconThemeData(color: _C.textPrimary),
//       actions: [
//         GestureDetector(
//           onTap: () async {
//             final ok = await food_Authservice.deleteCart();
//             if (!mounted) return;
//             if (ok) {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => MainScreenfood()),
//               );
//               AppAlert.success(context, 'Cart cleared');
//             } else {
//               AppAlert.error(context, 'Failed to clear cart');
//             }
//           },
//           child: Container(
//             margin: EdgeInsets.only(right: 12.w),
//             padding: EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               color: _C.red.withOpacity(0.08),
//               shape: BoxShape.circle,
//               border: Border.all(color: _C.red.withOpacity(0.2)),
//             ),
//             child: Icon(
//               Icons.delete_outline_rounded,
//               size: 18.sp,
//               color: _C.red,
//             ),
//           ),
//         ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(height: 1, color: _C.border),
//       ),
//     );
//   }
//
//   // ── Section label ───────────────────────────────────────────────────────
//   Widget _sectionLabel(String text) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: 14.sp,
//         fontWeight: FontWeight.w700,
//         color: _C.textPrimary,
//       ),
//     );
//   }
//
//   // ── Cart items card ─────────────────────────────────────────────────────
//   Widget _buildCartItems() {
//     if (cartData == null || cartData!.cartItems.isEmpty) {
//       return const SizedBox.shrink();
//     }
//
//     return _card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ...cartData!.cartItems.map((item) {
//             final isLast = item == cartData!.cartItems.last;
//             return Column(
//               key: ValueKey(item.itemId),
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 10.h),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           item.dishName,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w600,
//                             color: _C.textPrimary,
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(width: 8.w),
//
//                       _buildQtyControl(item),
//
//                       SizedBox(width: 12.w),
//
//                       SizedBox(
//                         width: 80.w, // ✅ FIXED WIDTH
//                         child: Text(
//                           '₹${item.totalPrice.toStringAsFixed(2)}',
//                           textAlign: TextAlign.right, // ✅ ALIGN RIGHT
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w700,
//                             color: _C.violet,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (!isLast) Divider(height: 1, color: _C.border),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQtyControl(CartItem item) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _C.bg,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: _C.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _qtyBtn(
//             Icons.remove_rounded,
//             _C.red,
//             () => changeQuantity(item, item.quantity - 1),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             child: Text(
//               '${item.quantity}',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w700,
//                 color: _C.textPrimary,
//               ),
//             ),
//           ),
//           _qtyBtn(
//             Icons.add_rounded,
//             _C.green,
//             () => changeQuantity(item, item.quantity + 1),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _qtyBtn(IconData icon, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(6.w),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.10),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Icon(icon, size: 14.sp, color: color),
//       ),
//     );
//   }
//
//   // ── "Add more items" text ───────────────────────────────────────────────
//   Widget _buildAddMoreText() {
//     return Center(
//       child: RichText(
//         text: TextSpan(
//           text: 'Missed something? ',
//           style: TextStyle(fontSize: 13.sp, color: _C.textSecondary),
//           children: [
//             TextSpan(
//               text: 'Add more items',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w700,
//                 color: _C.violet,
//                 decoration: TextDecoration.underline,
//               ),
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => MenuScreen(vendorId: cartData!.vendorId),
//                   ),
//                 ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Coupon row ──────────────────────────────────────────────────────────
//   Widget _buildCouponRow() {
//     final applied = (cartData?.couponCode ?? '').isNotEmpty;
//
//     return GestureDetector(
//       onTap: applied ? null : _showCouponBottomSheet,
//       child: _card(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//         child: Row(
//           children: [
//             Container(
//               width: 36.r,
//               height: 36.r,
//               decoration: BoxDecoration(
//                 color: applied ? _C.green.withOpacity(0.10) : _C.violetDim,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 applied
//                     ? Icons.check_circle_rounded
//                     : Icons.local_offer_rounded,
//                 size: 18.sp,
//                 color: applied ? _C.green : _C.violet,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     applied ? 'Coupon Applied' : 'Apply Coupon',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w700,
//                       color: applied ? _C.green : _C.textPrimary,
//                     ),
//                   ),
//                   if (applied)
//                     Text(
//                       appliedCouponCode ?? '',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: _C.textSecondary,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (applied)
//               GestureDetector(
//                 onTap: () async {
//                   if (cartData?.cartId == null) return;
//                   final result = await food_Authservice.updateCartSettings(
//                     cartId: cartData!.cartId,
//                     couponId: cartData!.couponId,
//                     applyCoupon: "NOT_APPLIED",
//                   );
//                   if (!result.success) {
//                     AppAlert.error(context, "Failed to remove coupon");
//                     return;
//                   }
//                   setState(() {
//                     appliedCouponCode = null;
//                     appliedCouponId = null;
//                   });
//                   AppAlert.success(context, "Coupon removed");
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10.w,
//                     vertical: 5.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _C.red.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(20.r),
//                     border: Border.all(color: _C.red.withOpacity(0.2)),
//                   ),
//                   child: Text(
//                     'Remove',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: _C.red,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               )
//             else
//               Icon(
//                 Icons.chevron_right_rounded,
//                 size: 20.sp,
//                 color: _C.textMuted,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showCouponBottomSheet() async {
//     setState(() => isCouponLoading = true);
//     final coupons = await food_Authservice.fetchCoupons();
//     final cartVendor = cartData?.vendorId;
//     setState(() => isCouponLoading = false);
//
//     coupons.sort((a, b) {
//       if (a.isExpired != b.isExpired) return a.isExpired ? 1 : -1;
//       final am = !a.isApplicableForVendor(cartVendor);
//       final bm = !b.isApplicableForVendor(cartVendor);
//       if (am != bm) return am ? 1 : -1;
//       return 0;
//     });
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Scaffold(
//         backgroundColor: Colors.transparent,
//         body: SafeArea(
//           top: false,
//           child: Container(
//             height: MediaQuery.of(ctx).size.height * 1,
//             decoration: BoxDecoration(
//               color: _C.bg,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//             ),
//             child: Column(
//               children: [
//                 _couponHeader(),
//                 coupons.isEmpty
//                     ? Expanded(child: _emptyCouponView())
//                     : Expanded(
//                         child: ListView.builder(
//                           padding: EdgeInsets.all(16.w),
//                           itemCount: coupons.length,
//                           itemBuilder: (_, i) {
//                             final c = coupons[i];
//                             return _couponTile(
//                               coupon: c,
//                               isExpired: c.isExpired,
//                               isMismatch: !c.isApplicableForVendor(cartVendor),
//                               isDisabled:
//                                   c.isExpired ||
//                                   !c.isApplicableForVendor(cartVendor),
//                             );
//                           },
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _couponHeader() {
//     return Container(
//       padding: EdgeInsets.fromLTRB(30.w, 20.h, 16.w, 16.h),
//       decoration: BoxDecoration(
//         color: _C.surface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//         border: Border(bottom: BorderSide(color: _C.border)),
//       ),
//       child: Row(
//         children: [
//           Text(
//             'Available Coupons',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w800,
//               color: _C.textPrimary,
//             ),
//           ),
//           const Spacer(),
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               padding: EdgeInsets.all(6.w),
//               decoration: BoxDecoration(
//                 color: _C.border,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.close_rounded,
//                 size: 16.sp,
//                 color: _C.textSecondary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _couponTile({
//     required CouponModel coupon,
//     required bool isExpired,
//     required bool isMismatch,
//     required bool isDisabled,
//   }) {
//     final color = isExpired
//         ? _C.red
//         : isMismatch
//         ? _C.amber
//         : _C.green;
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 10.h),
//       decoration: BoxDecoration(
//         color: _C.surface,
//         borderRadius: BorderRadius.circular(14.r),
//         border: Border.all(color: color.withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
//         leading: Container(
//           width: 38.r,
//           height: 38.r,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.10),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(Icons.local_offer_rounded, color: color, size: 18.sp),
//         ),
//         title: Row(
//           children: [
//             Text(
//               coupon.code,
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 fontSize: 13.sp,
//                 color: _C.textPrimary,
//               ),
//             ),
//             SizedBox(width: 8.w),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
//               decoration: BoxDecoration(
//                 color: _C.violet.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//               child: Text(
//                 coupon.couponType,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   color: _C.violet,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         subtitle: Padding(
//           padding: EdgeInsets.only(top: 4.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 isExpired
//                     ? 'Expired'
//                     : isMismatch
//                     ? 'Not applicable for this restaurant'
//                     : coupon.discountType == "PERCENTAGE"
//                     ? 'Get ${coupon.discountPercentage.toStringAsFixed(0)}% off'
//                     : 'Get ₹${coupon.discountPercentage.toStringAsFixed(0)} off',
//                 style: TextStyle(fontSize: 12.sp, color: color),
//               ),
//               if (!isExpired && !isMismatch)
//                 Text(
//                   coupon.minimumOrderValue <= 0
//                       ? 'Applicable on any order'
//                       : 'Min order ₹${coupon.minimumOrderValue.toInt()}',
//                   style: TextStyle(fontSize: 11.sp, color: _C.textMuted),
//                 ),
//             ],
//           ),
//         ),
//         trailing: isDisabled
//             ? Icon(Icons.block_rounded, color: color, size: 18.sp)
//             : Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 14.sp,
//                 color: _C.textMuted,
//               ),
//         onTap: isDisabled
//             ? () => AppAlert.error(
//                 context,
//                 isExpired
//                     ? 'Coupon expired'
//                     : 'Not applicable for this restaurant',
//               )
//             : () => _applyCoupon(coupon),
//       ),
//     );
//   }
//
//   Widget _emptyCouponView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.confirmation_number_outlined,
//             size: 48.sp,
//             color: _C.textMuted,
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             'No coupons available',
//             style: TextStyle(
//               fontSize: 15.sp,
//               fontWeight: FontWeight.w700,
//               color: _C.textSecondary,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             'Check back later for new offers',
//             style: TextStyle(fontSize: 12.sp, color: _C.textMuted),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _applyCoupon(CouponModel coupon) async {
//     if (cartData?.cartId == null) {
//       AppAlert.error(context, "Cart is empty");
//       return;
//     }
//     final result = await food_Authservice.updateCartSettings(
//       cartId: cartData!.cartId,
//       couponId: coupon.id,
//       applyCoupon: "APPLIED",
//     );
//     if (!result.success) {
//       AppAlert.error(context, result.error ?? "Failed to apply coupon");
//       return;
//     }
//     await _loadCart();
//     setState(() {
//       appliedCouponCode = coupon.code;
//       appliedCouponId = coupon.id;
//     });
//     AppAlert.success(context, "Coupon ${coupon.code} applied!");
//     Navigator.pop(context);
//   }
//
//   // ── Delivery address ────────────────────────────────────────────────────
//   Widget _buildDeliveryAddress() {
//     ref.watch(addressProvider);
//     final hasAddr = (cartData?.deliveryAddress ?? '').trim().isNotEmpty;
//
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => SavedAddress(
//             hideExtraWidgets: true,
//             onAddressSelected: (address) async {
//               // ✅ Update local state
//               await ref
//                   .read(addressProvider.notifier)
//                   .updateLocalAddress(
//                     city: address.city,
//                     stateName: address.state,
//                     pincode: address.pincode,
//                     latitude: address.latitude,
//                     longitude: address.longitude,
//                     fullAddress: address.fullAddress,
//                     category: address.category, // 🔥 important
//                   );
//
//               // ✅ Update cart address (only for saved addresses)
//               if (address.addressId != 0) {
//                 final ok = await AddressNotifier.updateDeliveryAddress(
//                   cartId: cartData!.cartId,
//                   addressId: address.addressId,
//                 );
//
//                 if (!ok && mounted) {
//                   AppAlert.error(context, "Failed to update cart address");
//                 }
//               }
//             },
//           ),
//         ),
//       ),
//       child: _card(
//         child: Row(
//           children: [
//             Container(
//               width: 40.r,
//               height: 40.r,
//               decoration: BoxDecoration(
//                 color: hasAddr
//                     ? _C.violet.withOpacity(0.08)
//                     : _C.red.withOpacity(0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.location_on_rounded,
//                 size: 20.sp,
//                 color: hasAddr ? _C.violet : _C.red,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     hasAddr ? 'Delivery Address' : 'Select Delivery Address',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.textPrimary,
//                     ),
//                   ),
//                   if (hasAddr) ...[
//                     SizedBox(height: 2.h),
//                     Text(
//                       [
//                         cartData!.deliveryAddress,
//                         cartData!.name,
//                         cartData!.mobileNo,
//                       ].where((e) => e.toString().trim().isNotEmpty).join(', '),
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: _C.textSecondary,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: 2.h),
//                     Text(
//                       'Tap to change',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: _C.violet,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             Icon(Icons.chevron_right_rounded, size: 20.sp, color: _C.textMuted),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Order summary card ──────────────────────────────────────────────────
//   Widget _buildSummaryCard() {
//     if (cartData == null || isLoading) {
//       return CartSkeleton(type: CartSkeletonType.summary);
//     }
//
//     final orderType = cartData?.orderType ?? '';
//     final subtotal = cartData?.subtotal ?? 0;
//     final packing = cartData?.packingTotal ?? 0;
//     final delivery = cartData?.deliveryCharges ?? 0;
//     final platform = cartData?.platformCharges ?? 0;
//     final discount = cartData?.discountAmount ?? 0;
//     final gst = cartData?.gstTotal ?? 0;
//     final grandTotal = cartData?.grandTotal ?? 0;
//     final type = orderType.toUpperCase();
//
//     return _card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           GestureDetector(
//             onTap: () =>
//                 setState(() => _isSummaryExpanded = !_isSummaryExpanded),
//             child: Row(
//               children: [
//                 Container(
//                   width: 36.r,
//                   height: 36.r,
//                   decoration: BoxDecoration(
//                     color: _C.violetDim,
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   child: Icon(
//                     Icons.receipt_long_rounded,
//                     size: 18.sp,
//                     color: _C.violet,
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: Text(
//                     'Order Summary',
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.textPrimary,
//                     ),
//                   ),
//                 ),
//                 AnimatedRotation(
//                   turns: _isSummaryExpanded ? 0.5 : 0,
//                   duration: const Duration(milliseconds: 200),
//                   child: Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     color: _C.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Expandable details
//           AnimatedCrossFade(
//             duration: const Duration(milliseconds: 200),
//             crossFadeState: _isSummaryExpanded
//                 ? CrossFadeState.showFirst
//                 : CrossFadeState.showSecond,
//
//             firstChild: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 12.h),
//                 Divider(height: 1, color: _C.border),
//                 SizedBox(height: 10.h),
//
//                 _summaryRow('Subtotal', subtotal),
//
//                 if (platform > 0) _summaryRow('Platform Charges', platform),
//
//                 if ((type == 'DELIVERY' || type == 'TAKEAWAY') && packing > 0)
//                   _summaryRow('Packing Charges', packing),
//
//                 if (orderType.toUpperCase() == 'DELIVERY')
//                   _summaryRow('Delivery Charges', delivery),
//
//                 if (discount > 0)
//                   _summaryRow('Discount', -discount, color: _C.green),
//
//                 if ((gst / 2) > 0) ...[
//                   _summaryRow('SGST', gst / 2),
//                   _summaryRow('CGST', gst / 2),
//                 ],
//
//                 SizedBox(height: 4.h),
//               ],
//             ),
//
//             secondChild: const SizedBox.shrink(),
//           ),
//
//           Divider(height: 16.h, color: _C.border),
//
//           // Grand total
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Grand Total',
//                 style: TextStyle(
//                   fontSize: 15.sp,
//                   fontWeight: FontWeight.w800,
//                   color: _C.textPrimary,
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     '₹${_fmt(grandTotal)}',
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w800,
//                       color: _C.violet,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _summaryRow(String label, num value, {Color? color}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 3.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontSize: 12.sp, color: _C.textSecondary),
//           ),
//           Text(
//             value < 0 ? '-₹${_fmt(-value)}' : '₹${_fmt(value)}',
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w600,
//               color: color ?? _C.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Schedule order ──────────────────────────────────────────────────────
//   Widget _buildScheduleOrder() {
//     // bool hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
//     final isUserScheduled =
//         _orderType == "schedule" &&
//         _selectedDate != null &&
//         _selectedTime != null;
//
//     final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
//
//     return _card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// Header
//           Text(
//             "If you want Schedule your order!",
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w700,
//               color: _C.textPrimary,
//             ),
//           ),
//           SizedBox(height: 6.h),
//           Text(
//             "Pick a convenient date & time",
//             style: TextStyle(fontSize: 12.sp, color: _C.textSecondary),
//           ),
//
//           SizedBox(height: 14.h),
//
//           if (hasScheduledItems) ...[
//             Container(
//               margin: EdgeInsets.only(bottom: 12.h),
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: Border.all(color: Colors.orange.withOpacity(0.3)),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.orange, size: 18.sp),
//                   SizedBox(width: 8.w),
//                   Expanded(
//                     child: Text(
//                       "Some items in your cart are not available right now. Please schedule your order to continue.",
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: _C.textPrimary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//
//           /// CTA Button (when not scheduled)
//           if (!isUserScheduled)
//             GestureDetector(
//               onTap: () async {
//                 setState(() {
//                   _orderType = 'schedule';
//                 });
//                 await _pickScheduleDateTime();
//               },
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 14.h),
//                 decoration: BoxDecoration(
//                   color: _C.violet.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(12.r),
//                   border: Border.all(color: _C.violet.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.access_time, color: _C.violet, size: 18.sp),
//                     SizedBox(width: 8.w),
//
//                     Text(
//                       hasScheduledItems && !isUserScheduled
//                           ? "Schedule to Continue"
//                           : "Choose Date & Time",
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w600,
//                         color: _C.violet,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           /// Scheduled State UI
//           if (isUserScheduled) ...[
//             SizedBox(height: 12.h),
//             Container(
//               padding: EdgeInsets.all(14.w),
//               decoration: BoxDecoration(
//                 color: _C.green.withOpacity(0.06),
//                 borderRadius: BorderRadius.circular(12.r),
//                 border: Border.all(color: _C.green.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.check_circle_rounded,
//                     color: _C.green,
//                     size: 20.sp,
//                   ),
//                   SizedBox(width: 10.w),
//
//                   /// Date + Time
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Order Scheduled 🎉",
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.w700,
//                             color: _C.green,
//                           ),
//                         ),
//                         SizedBox(height: 2.h),
//                         Text(
//                           '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  •  ${_selectedTime!.format(context)}',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: _C.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   /// Edit Button
//                   GestureDetector(
//                     onTap: _pickScheduleDateTime,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 10.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _C.violet.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(8.r),
//                         border: Border.all(color: _C.violet.withOpacity(0.2)),
//                       ),
//                       child: Text(
//                         "Edit",
//                         style: TextStyle(
//                           fontSize: 11.sp,
//                           fontWeight: FontWeight.w600,
//                           color: _C.violet,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Future<void> _pickScheduleDateTime() async {
//     final now = DateTime.now();
//     final first = now.add(const Duration(minutes: 25));
//
//     final date = await showDatePicker(
//       context: context,
//       initialDate: first,
//       firstDate: first,
//       lastDate: now.add(const Duration(days: 365)),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: _C.violet,
//             onPrimary: Colors.white,
//             onSurface: Colors.black,
//           ),
//           textButtonTheme: TextButtonThemeData(
//             style: TextButton.styleFrom(foregroundColor: _C.violet),
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (date == null) return;
//
//     while (true) {
//       final time = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//         builder: (ctx, child) => Theme(
//           data: Theme.of(ctx).copyWith(
//             timePickerTheme: TimePickerThemeData(
//               backgroundColor: Colors.white,
//               dialHandColor: _C.violet,
//               dialBackgroundColor: _C.bg,
//             ),
//             colorScheme: const ColorScheme.light(
//               primary: _C.violet,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: _C.violet),
//             ),
//           ),
//           child: child!,
//         ),
//       );
//       if (time == null) return;
//
//       final selected = DateTime(
//         date.year,
//         date.month,
//         date.day,
//         time.hour,
//         time.minute,
//       );
//       if (selected.isBefore(now.add(const Duration(minutes: 25)))) {
//         AppAlert.error(context, "Select a time at least 25 minutes from now");
//         continue;
//       }
//       setState(() {
//         _selectedDate = date;
//         _selectedTime = time;
//       });
//       break;
//     }
//   }
//
//   // ── Payment toggle button ───────────────────────────────────────────────
//   Widget _buildPaymentToggle() {
//     return GestureDetector(
//       onTap: () {
//         setState(() => isExpanded = !isExpanded);
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (isExpanded) {
//             _scrollController.animateTo(
//               _scrollController.position.maxScrollExtent,
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeOut,
//             );
//           }
//         });
//       },
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 14.h),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF6C63FF), Color(0xFF4A43C9)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: _C.violet.withOpacity(0.30),
//               blurRadius: 16,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               isExpanded
//                   ? Icons.keyboard_arrow_up_rounded
//                   : Icons.payment_rounded,
//               color: Colors.white,
//               size: 20.sp,
//             ),
//             SizedBox(width: 8.w),
//             Text(
//               isExpanded ? 'Hide Payment Options' : 'Choose Payment Method',
//               style: TextStyle(
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCheckoutDetails() {
//     return Column(
//       children: [
//         cartwallet(
//           wallet: wallet,
//           onSelectionChanged: (method, subWallets) {
//             setState(() {
//               selectedPaymentMethod = method;
//               selectedSubWallets = subWallets;
//             });
//           },
//         ),
//         SizedBox(height: 14.h),
//         _buildPlaceOrderButton(),
//       ],
//     );
//   }
//
//   // ── Place order button ──────────────────────────────────────────────────
//   Widget _buildPlaceOrderButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 54.h,
//       child: ElevatedButton(
//         onPressed: isPlacingOrder ? null : placeOrder,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _C.green,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//           shadowColor: _C.green.withOpacity(0.3),
//         ),
//         child: isPlacingOrder
//             ? SizedBox(
//                 width: 20.r,
//                 height: 20.r,
//                 child: const CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2.5,
//                 ),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.check_circle_rounded, size: 18.sp),
//                   SizedBox(width: 8.w),
//                   Text(
//                     'Place Order',
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   SizedBox(width: 8.w),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 10.w,
//                       vertical: 4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     child: Text(
//                       '₹${(cartData?.grandTotal ?? 0).toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
//
//   // ── Empty cart ──────────────────────────────────────────────────────────
//   Widget _buildEmptyCart() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(height: 40.h),
//           Container(
//             width: 90.r,
//             height: 90.r,
//             decoration: BoxDecoration(
//               color: _C.violetDim,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.shopping_bag_outlined,
//               size: 40.sp,
//               color: _C.violet,
//             ),
//           ),
//           SizedBox(height: 20.h),
//           Text(
//             'Your cart is empty',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w800,
//               color: _C.textPrimary,
//             ),
//           ),
//           SizedBox(height: 6.h),
//           Text(
//             'Add some delicious items to get started',
//             style: TextStyle(fontSize: 13.sp, color: _C.textSecondary),
//           ),
//           SizedBox(height: 24.h),
//           GestureDetector(
//             onTap: () => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => MainScreenfood()),
//             ),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
//               decoration: BoxDecoration(
//                 color: _C.violet,
//                 borderRadius: BorderRadius.circular(14.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _C.violet.withOpacity(0.3),
//                     blurRadius: 16,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 'Browse Menu',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 24.h),
//           if (homepageAds.isNotEmpty)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(16.r),
//               child: BannerAdvertisement(ads: homepageAds, height: 200),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ── Shared card shell ───────────────────────────────────────────────────
//   Widget _card({required Widget child, EdgeInsets? padding}) {
//     return Container(
//       width: double.infinity,
//       padding: padding ?? EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: _C.surface,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: _C.border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════════
// // 1. Razorpay "Opening Gateway" overlay
// // ═══════════════════════════════════════════════════════════════════════════════
// class _RazorpayLoadingOverlay extends StatefulWidget {
//   @override
//   State<_RazorpayLoadingOverlay> createState() =>
//       _RazorpayLoadingOverlayState();
// }
//
// class _RazorpayLoadingOverlayState extends State<_RazorpayLoadingOverlay>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _fade;
//   late Animation<double> _scale;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 450),
//     )..forward();
//     _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
//     _scale = Tween<double>(
//       begin: 0.88,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fade,
//       child: Container(
//         color: Colors.black.withOpacity(0.60),
//         child: Center(
//           child: ScaleTransition(
//             scale: _scale,
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 40.w),
//               padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 28.w),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF6C63FF).withOpacity(0.18),
//                     blurRadius: 40,
//                     offset: const Offset(0, 12),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Razorpay-like logo badge
//                   Container(
//                     width: 64.r,
//                     height: 64.r,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF072654), Color(0xFF3395FF)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(18.r),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF3395FF).withOpacity(0.35),
//                           blurRadius: 16,
//                           offset: const Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       Icons.payment_rounded,
//                       color: Colors.white,
//                       size: 30.sp,
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//                   Text(
//                     'Opening Payment Gateway',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w700,
//                       color: const Color(0xFF1A1D2E),
//                     ),
//                   ),
//                   SizedBox(height: 6.h),
//                   Text(
//                     'Redirecting to Razorpay…',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       color: const Color(0xFF64748B),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   SizedBox(
//                     width: 28.r,
//                     height: 28.r,
//                     child: const CircularProgressIndicator(
//                       color: Color(0xFF3395FF),
//                       strokeWidth: 3,
//                     ),
//                   ),
//                   SizedBox(height: 18.h),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.lock_outline_rounded,
//                         size: 13.sp,
//                         color: const Color(0xFF10B981),
//                       ),
//                       SizedBox(width: 4.w),
//                       Text(
//                         '256-bit SSL secured',
//                         style: TextStyle(
//                           fontSize: 11.sp,
//                           color: const Color(0xFF10B981),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════════
// // 2. Payment Processing overlay (after Razorpay success, before order API)
// // ═══════════════════════════════════════════════════════════════════════════════
// class _PaymentProcessingOverlay extends StatefulWidget {
//   @override
//   State<_PaymentProcessingOverlay> createState() =>
//       _PaymentProcessingOverlayState();
// }
//
// class _PaymentProcessingOverlayState extends State<_PaymentProcessingOverlay>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _fade;
//   late Animation<double> _scale;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     )..forward();
//     _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
//     _scale = Tween<double>(
//       begin: 0.88,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fade,
//       child: Container(
//         color: Colors.black.withOpacity(0.65),
//         child: Center(
//           child: ScaleTransition(
//             scale: _scale,
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 40.w),
//               padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 28.w),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF6C63FF).withOpacity(0.2),
//                     blurRadius: 40,
//                     offset: const Offset(0, 12),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 64.r,
//                     height: 64.r,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF0FDF4),
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFF10B981).withOpacity(0.3),
//                         width: 2,
//                       ),
//                     ),
//                     child: Icon(
//                       Icons.sync_rounded,
//                       color: const Color(0xFF10B981),
//                       size: 30.sp,
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//                   Text(
//                     'Confirming Payment',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w700,
//                       color: const Color(0xFF1A1D2E),
//                     ),
//                   ),
//                   SizedBox(height: 6.h),
//                   Text(
//                     'Please wait while we confirm\nyour payment and place your order…',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       color: const Color(0xFF64748B),
//                       height: 1.5,
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8.r),
//                     child: SizedBox(
//                       height: 5.h,
//                       child: LinearProgressIndicator(
//                         backgroundColor: const Color(0xFFE8ECF4),
//                         valueColor: const AlwaysStoppedAnimation<Color>(
//                           Color(0xFF10B981),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 14.h),
//                   Text(
//                     'Do not press back or close the app',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: const Color(0xFFF59E0B),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════════
// // 3. Order Success overlay (before navigating to invoice)
// // ═══════════════════════════════════════════════════════════════════════════════
// class _OrderSuccessOverlay extends StatefulWidget {
//   final double grandTotal;
//   const _OrderSuccessOverlay({required this.grandTotal});
//
//   @override
//   State<_OrderSuccessOverlay> createState() => _OrderSuccessOverlayState();
// }
//
// class _OrderSuccessOverlayState extends State<_OrderSuccessOverlay>
//     with TickerProviderStateMixin {
//   late AnimationController _bgCtrl;
//   late AnimationController _checkCtrl;
//   late AnimationController _textCtrl;
//   late AnimationController _pulseCtrl;
//
//   late Animation<double> _bgFade;
//   late Animation<double> _circleFade;
//   late Animation<double> _circleScale;
//   late Animation<double> _checkDraw;
//   late Animation<double> _textFade;
//   late Animation<Offset> _textSlide;
//   late Animation<double> _pulse;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _bgCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 350),
//     );
//     _checkCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 550),
//     );
//     _textCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..repeat(reverse: true);
//
//     _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);
//     _circleFade = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut);
//     _circleScale = Tween<double>(
//       begin: 0.4,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));
//     _checkDraw = CurvedAnimation(
//       parent: _checkCtrl,
//       curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
//     );
//     _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
//     _textSlide = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
//     _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(_pulseCtrl);
//
//     _bgCtrl.forward().then((_) {
//       _checkCtrl.forward().then((_) {
//         _textCtrl.forward();
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _bgCtrl.dispose();
//     _checkCtrl.dispose();
//     _textCtrl.dispose();
//     _pulseCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _bgFade,
//       child: Container(
//         color: Colors.black.withOpacity(0.70),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ── Animated check circle ─────────────────────────────────
//               ScaleTransition(
//                 scale: _circleScale,
//                 child: FadeTransition(
//                   opacity: _circleFade,
//                   child: ScaleTransition(
//                     scale: _pulse,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // Outer glow ring
//                         Container(
//                           width: 110.r,
//                           height: 110.r,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: const Color(0xFF10B981).withOpacity(0.15),
//                           ),
//                         ),
//                         // Inner circle
//                         Container(
//                           width: 80.r,
//                           height: 80.r,
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               colors: [Color(0xFF10B981), Color(0xFF059669)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                         ),
//                         // Check icon drawn with animation
//                         FadeTransition(
//                           opacity: _checkDraw,
//                           child: Icon(
//                             Icons.check_rounded,
//                             color: Colors.white,
//                             size: 40.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 28.h),
//
//               // ── Animated text ─────────────────────────────────────────
//               SlideTransition(
//                 position: _textSlide,
//                 child: FadeTransition(
//                   opacity: _textFade,
//                   child: Column(
//                     children: [
//                       Text(
//                         'Order Placed! 🎉',
//                         style: TextStyle(
//                           fontSize: 24.sp,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white,
//                           letterSpacing: -0.5,
//                         ),
//                       ),
//                       SizedBox(height: 8.h),
//                       Text(
//                         '₹${widget.grandTotal.toStringAsFixed(2)} paid successfully',
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           color: Colors.white.withOpacity(0.80),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 6.h),
//                       Text(
//                         'Redirecting to your invoice…',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.white.withOpacity(0.55),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import '../../Models/promotions_model/promotions_model.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/Auth_service/food_authservice.dart';
import '../../Services/Auth_service/promotion_services_Authservice.dart';
import '../../Services/paymentservice/razorpayservice.dart';
import '../../Services/websockets/web_socket_manager.dart';
import '../../widgets/widgets/skeleton/cart_skeleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Services/scaffoldmessenger/messenger.dart';
import 'package:maamaas/screens/foodmainscreen.dart';
import 'package:maamaas/widgets/signinrequired.dart';
import '../../Models/subscrptions/coupon_model.dart';
import '../../Models/subscrptions/wallet_model.dart';
import '../../providers/addressmodel_provider.dart';
import '../../widgets/widgets/cart wallet.dart';
import '../../Models/food/cart_model.dart';
import '../screens/advertisements/banneradvertisement.dart';
import '../screens/ordertypebutton.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../screens/saved_address.dart';
import 'Menu/menu_screen.dart';
import 'food_invoice.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF5F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8ECF4);

  static const violet = Color(0xFF6C63FF);
  static const violetDim = Color(0x1A6C63FF);

  static const textPrimary = Color(0xFF1A1D2E);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFFB0B8CC);

  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const amber = Color(0xFFF59E0B);
}

enum PaymentOverlayState {
  none,
  placingOrder,
  openingGateway,
  processing,
  success,
}

// ignore: camel_case_types
class food_cartScreen extends ConsumerStatefulWidget {
  final int? vendorId;
  final int? cartId;
  final double? savedAmount;
  final bool showSavedPopup;

  const food_cartScreen({
    super.key,
    this.vendorId,
    this.cartId,
    this.savedAmount,
    this.showSavedPopup = false,
  });

  @override
  ConsumerState<food_cartScreen> createState() => _food_cartScreenState();
}

// ignore: camel_case_types
class _food_cartScreenState extends ConsumerState<food_cartScreen> {
  CartModel? cartData;
  bool isLoading = true;
  bool isPlacingOrder = false;
  bool couponApplied = false;
  String selectedPaymentMethod = "";
  String couponCode = "";
  bool isExpanded = false;
  Wallet? wallet;
  int? appliedCouponId;
  String? appliedCouponCode;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late ScrollController _scrollController;
  String _orderType = "";
  bool isCouponLoading = false;
  Set<String> selectedSubWallets = {};
  int userId = 0;
  List<Campaign> homepageAds = [];
  bool _isSummaryExpanded = false;
  final List<Map<String, dynamic>> _pendingSocketUpdates = [];

  PaymentOverlayState _overlayState = PaymentOverlayState.none;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _loadAllData();
    // _loadWallet();
    // _loadCart();
    _initCartSocket();
    // _loadAds();
    if (cartData?.hasAnyScheduledItem ?? false) {
      _orderType = 'schedule';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WebSocketManager().unsubscribeUserCart(userId);
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        food_Authservice.fetchCart(),
        subscription_AuthService.fetchWallet(),
        promotion_Authservice.fetchcampaign(),
        subscription_AuthService.fetchWallet(),
      ]);

      final cart = results[0] as CartModel;
      final walletData = results[1] as Wallet;
      final ads = results[2] as List<Campaign>;

      if (!mounted) return;

      setState(() {
        cartData = cart;
        wallet = walletData;
        homepageAds = ads
            .where(
              (c) =>
                  c.status == Status.ACTIVE &&
                  c.approvalStatus == ApprovalStatus.APPROVED &&
                  c.addDisplayPosition == AddDisplayPosition.CHECKOUT_PAGE,
            )
            .toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Load error: $e");
    }
  }

  Future<void> _loadWallet() async {
    try {
      final w = await subscription_AuthService.fetchWallet();
      if (!mounted) return;
      setState(() => wallet = w);
    } catch (_) {
      if (!mounted) return;
      AppAlert.error(context, "❌ Failed to load wallet");
    }
  }

  List<String> mapWalletsToEnum(List<String> s) => s.map((w) {
    switch (w) {
      case "Cashbacks":
        return "CASHBACK";
      case "Self Loaded":
        return "SELF_LOADED";
      case "Postpaid used amount":
        return "POST_PAID";
      case "Company Loaded":
        return "COMPANY_LOADED";
      case "Earned Amount":
        return "EARNED_AMOUNT";
      default:
        return w.toUpperCase().replaceAll(' ', '_');
    }
  }).toList();

  void _initCartSocket() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? 0;
    WebSocketManager().subscribeUserCart(userId, _updateCartFromSocket);
  }

  // ✅ FIX: Buffer socket updates whenever _loadCart is in-flight (not just
  // when cartData==null). This prevents the race where a second _loadCart call
  // overwrites socket-applied data. Also deduplicates the server's double-fire.
  bool _isLoadingCart = false;
  String? _lastSocketEventKey;

  void _updateCartFromSocket(Map<String, dynamic> data) {
    // Deduplicate: server sends each event twice. Drop the second identical fire.
    final eventKey =
        '${data['cartId']}_${(data['cartItems'] as List?)?.length}_${data['grandTotal']}';
    if (eventKey == _lastSocketEventKey) {
      print("🔁 Duplicate socket event ignored");
      return;
    }
    _lastSocketEventKey = eventKey;
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _lastSocketEventKey = null,
    );

    print(
      "🟡 SOCKET UPDATE: cartItems=${(data['cartItems'] as List?)?.length}",
    );

    // Buffer while _loadCart is in-flight — it will flush after it settles.
    // Keep only the LATEST buffered update (older ones are stale).
    if (_isLoadingCart || cartData == null) {
      print("⏳ _loadCart in-flight → buffering (replacing stale buffer)");
      _pendingSocketUpdates.clear();
      _pendingSocketUpdates.add(data);
      return;
    }

    _applySocketUpdate(data);
  }

  void _flushPendingSocketUpdates() {
    if (_pendingSocketUpdates.isEmpty) return;
    final latest = _pendingSocketUpdates.last; // latest wins
    _pendingSocketUpdates.clear();
    _applySocketUpdate(latest);
  }

  void _applySocketUpdate(Map<String, dynamic> data) {
    print("🟡 RAW SOCKET DATA: $data");
    final List items = data['cartItems'] ?? [];

    if (!mounted) return;

    setState(() {
      cartData!.cartItems = items.map((json) {
        final idx = cartData!.cartItems.indexWhere(
          (i) => i.itemId == json['itemId'],
        );

        if (idx != -1) {
          final old = cartData!.cartItems[idx];
          // ✅ Create a NEW object so Flutter detects the change
          return CartItem(
            itemId: old.itemId,
            dishName: old.dishName,
            dishId: old.dishId,
            chefType: old.chefType,
            dishImage: old.dishImage,
            actualPrice: (json['actualPrice'] ?? old.actualPrice).toDouble(),
            gst: (json['gst'] ?? old.gst).toDouble(),
            quantity: json['quantity'] ?? old.quantity,
            price: (json['price'] ?? old.price).toDouble(),
            totalPrice: (json['totalPrice'] ?? old.totalPrice).toDouble(),
            packingCharges: (json['packingCharges'] ?? old.packingCharges)
                .toDouble(),
            balanceQuantity: json['balanceQuantity'] ?? old.balanceQuantity,
            available: json['available'] ?? old.available,
            shedule: json.containsKey('shedule')
                ? json['shedule'] == true
                : old.shedule,
          );
        }

        return CartItem.fromJson(json);
      }).toList();

      final rawCoupon = data['couponCode'];

      cartData!.subtotal = (data['subtotal'] ?? 0).toDouble();
      cartData!.gstTotal = (data['gstTotal'] ?? 0).toDouble();
      cartData!.packingTotal = (data['packingTotal'] ?? 0).toDouble();
      cartData!.platformCharges = (data['platformCharges'] ?? 0).toDouble();
      cartData!.deliveryCharges = (data['deliveryCharges'] ?? 0).toDouble();
      cartData!.discountAmount = (data['discountAmount'] ?? 0).toDouble();
      cartData!.grandTotal = (data['grandTotal'] ?? 0).toDouble();
      cartData!.cgst = (data['cgst'] ?? 0).toDouble();
      cartData!.sgst = (data['sgst'] ?? 0).toDouble();
      cartData!.deliveryAddress =
          data['deliveryAddress'] ?? cartData!.deliveryAddress;
      cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
      cartData!.name = data['name'] ?? cartData!.name;
      // cartData!.couponCode = data['couponCode'];

      cartData!.couponCode = rawCoupon is String
          ? rawCoupon
          : rawCoupon is Map
          ? rawCoupon['code']
          : null;
    });
  }

  Future<void> _loadCart() async {
    _isLoadingCart = true; // ✅ block socket updates from applying mid-load
    setState(() => isLoading = true);
    try {
      final c = await food_Authservice.fetchCart();
      if (mounted) {
        setState(() {
          cartData = c;

          print("📦 Cart Loaded:");
          print("   Total Items: ${cartData?.cartItems.length}");

          for (var item in cartData!.cartItems) {
            print("   👉 ${item.dishName} → isScheduled: ${item.shedule}");
          }

          print("🔥 hasAnyScheduledItem: ${cartData?.hasAnyScheduledItem}");

          if (cartData?.hasAnyScheduledItem ?? false) {
            _orderType = 'schedule';
            print("🚨 _loadCart: orderType set to schedule");
          }

          isLoading = false;
        });
        _isLoadingCart = false; // ✅ release the gate
        _flushPendingSocketUpdates(); // ✅ apply any update that arrived during load
      }
    } catch (_) {
      _isLoadingCart = false;
      if (mounted) setState(() => isLoading = false);
    }
  }

  double getSelectedWalletBalance() {
    if (wallet == null) return 0;
    double t = 0;
    if (selectedSubWallets.contains("Company Loaded")) {
      t += wallet!.companyLoadedAmount;
    }
    if (selectedSubWallets.contains("Self Loaded")) {
      t += wallet!.selfLoadedAmount;
    }
    if (selectedSubWallets.contains("Cashbacks")) t += wallet!.cashbackAmount;
    if (selectedSubWallets.contains("Postpaid used amount")) {
      t += wallet!.postPaidUsage;
    }
    return t;
  }

  Future<void> placeOrder() async {
    final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
    if (hasScheduledItems && (_selectedDate == null || _selectedTime == null)) {
      AppAlert.error(
        context,
        "📅 Please select date & time to schedule your order",
      );
      return;
    }

    if ((cartData?.orderType ?? '').trim().toLowerCase() == 'delivery') {
      if ((cartData?.deliveryAddress ?? '').trim().isEmpty) {
        AppAlert.error(context, "⚠️ Please select delivery address");
        return;
      }
    }
    if (selectedPaymentMethod == "Maamaas_Wallet") {
      final wb = getSelectedWalletBalance();
      final gt = (cartData?.grandTotal ?? 0).toDouble();
      if (wb < gt) {
        AppAlert.error(
          context,
          "❌ Insufficient wallet balance\nWallet: ₹${wb.toStringAsFixed(2)}\nOrder Total: ₹${gt.toStringAsFixed(2)}",
        );
        return;
      }
    }
    if (selectedPaymentMethod.isEmpty) {
      AppAlert.error(context, "⚠️ Please select a payment method");
      return;
    }

    setState(() => isPlacingOrder = true);
    try {
      final bool isUserScheduled =
          _selectedDate != null || _selectedTime != null;

      if (selectedPaymentMethod == "Online_Payment") {
        final amount = (cartData?.grandTotal ?? 0).toDouble();

        // ── Show "opening gateway" overlay while createOrder API runs ────
        if (mounted)
          setState(() => _overlayState = PaymentOverlayState.openingGateway);
        final orderId = await food_Authservice.createOrder(amount);
        if (mounted)
          setState(() => _overlayState = PaymentOverlayState.openingGateway);

        if (orderId == null) {
          AppAlert.error(context, "❌ Failed to create payment order");
          return;
        }
        final rp = RazorpayService();
        rp.onSuccess = (res) async {
          final pid = res.paymentId!;
          final oid = res.orderId!;
          // ── Show "confirming payment" overlay while order API runs ──────
          if (mounted)
            setState(() => _overlayState = PaymentOverlayState.processing);
          final ok = isUserScheduled
              ? await _placeScheduledOrder(
                  paymentMethod: "Online_Payment",
                  razorpayPaymentId: pid,
                  razorpayOrderId: oid,
                  amount: amount,
                )
              : await _placeDirectOrder(
                  paymentMethod: "Online_Payment",
                  razorpayPaymentId: pid,
                  razorpayOrderId: oid,
                  amount: amount,
                );
          // FIX: hide processing overlay only after order result is known
          // (_showOrderSuccess takes over visually, so hide _isProcessingPayment
          //  only when ok==false so there's no blank-flash gap)
          if (!ok && mounted) {
            setState(() => _overlayState = PaymentOverlayState.processing);
          }
          ;

          if (ok) {
            // capturePayment runs in background — navigation already happened
            // inside _placeDirectOrder/_placeScheduledOrder
            food_Authservice
                .capturePayment(paymentId: pid, amount: amount)
                .catchError((_) {
                  // Silently catch — capture failure does not reverse the order
                });
          } else {
            AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
          }
        };
        rp.onError = (res) {
          if (mounted) {
            setState(() {
              _overlayState = PaymentOverlayState.openingGateway;
              isPlacingOrder = false;
            });
          }
          AppAlert.error(context, "Payment failed: ${res.message}");
        };
        rp.startPayment(
          orderId: orderId,
          amount: amount,
          description: "Online Payment via Razorpay",
        );
        // FIX: do NOT return early — let finally reset isPlacingOrder
        //      (Razorpay sheet is already open; button spinner can stop)
        return;
      }

      final amt = cartData!.grandTotal.toDouble();
      if (isUserScheduled) {
        await _placeScheduledOrder(
          paymentMethod: selectedPaymentMethod,
          razorpayPaymentId: "",
          razorpayOrderId: "",
          amount: amt,
        );
      } else {
        await _placeDirectOrder(
          paymentMethod: selectedPaymentMethod,
          razorpayPaymentId: "",
          razorpayOrderId: "",
          amount: amt,
        );
      }
    } catch (e) {
      debugPrint("❌ Place Order Error: $e");

      String message = "Error placing order";

      if (e.toString().contains("Exception:")) {
        message = e.toString().replaceFirst("Exception: ", "");
      } else {
        message = e.toString();
      }

      // FIX: clear all overlay flags on any error so nothing gets stuck
      if (mounted) {
        setState(() {
          _overlayState = PaymentOverlayState.openingGateway;
          _overlayState = PaymentOverlayState.processing;
        });
      }

      AppAlert.error(context, message);
    } finally {
      // FIX: always reset the Place Order button spinner
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }

  Future<bool> _placeScheduledOrder({
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');
    if (cartId == null) return false;
    final result = await food_Authservice.scheduleOrder(
      cartId: cartId,
      date: _selectedDate ?? DateTime.now(),
      time: _selectedTime ?? TimeOfDay.now(),
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
      amount: amount,
    );
    if (result.containsKey('orderId')) {
      final oid = result['orderId'];
      await prefs.setInt('orderId', oid);
      if (mounted) {
        // FIX: flip both flags in one setState to avoid a single-frame blank flash
        setState(() => _overlayState = PaymentOverlayState.processing);

        await Future.delayed(const Duration(milliseconds: 2200));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
          );
        }
      }
      return true;
    }
    return false;
  }

  Future<bool> _placeDirectOrder({
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');
    if (cartId == null) return false;
    final result = await food_Authservice.placeDirectOrder(
      cartId: cartId,
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
      amount: amount,
    );
    if (result.containsKey('orderId')) {
      final oid = result['orderId'];
      await prefs.setInt('orderId', oid);
      if (mounted) {
        // FIX: flip both flags in one setState to avoid a single-frame blank flash
        setState(() => _overlayState = PaymentOverlayState.processing);

        await Future.delayed(const Duration(milliseconds: 2200));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
          );
        }
      }
      return true;
    }
    return false;
  }

  Future<void> changeQuantity(CartItem item, int newQty) async {
    final old = item.quantity;
    setState(() => item.quantity = newQty);
    final ok = await food_Authservice.updateCartQuantity(item.itemId, newQty);
    if (!ok) {
      setState(() {
        item.quantity = old;
        item.totalPrice = item.price * old;
      });
    }
  }

  // Future<void> _onRefresh() async {
  //   final c = await food_Authservice.fetchCart();
  //   final w = await subscription_AuthService.fetchWallet();
  //   if (!mounted) return;
  //   setState(() {
  //     cartData = c;
  //     wallet = w;
  //   });
  // }
  Future<void> _onRefresh() async {
    await _loadAllData();
  }

  Future<void> _loadAds() async {
    try {
      final result = await promotion_Authservice.fetchcampaign();
      setState(
        () => homepageAds = result
            .where(
              (c) =>
                  c.status == Status.ACTIVE &&
                  c.approvalStatus == ApprovalStatus.APPROVED &&
                  c.addDisplayPosition == AddDisplayPosition.CHECKOUT_PAGE,
            )
            .toList(),
      );
    } catch (_) {}
  }

  String _fmt(num? v) => (v ?? 0).toStringAsFixed(2);

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: _C.bg,
          appBar: _buildAppBar(),
          body: AuthGuard(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: _C.violet,
                backgroundColor: _C.surface,
                child: isLoading
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.w),
                        child: const CartSkeleton(
                          type: CartSkeletonType.fullCart,
                        ),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (cartData == null || cartData!.cartItems.isEmpty)
                              _buildEmptyCart()
                            else ...[
                              _buildCartItems(),
                              SizedBox(height: 10.h),
                              _buildAddMoreText(),
                              SizedBox(height: 12.h),

                              OrderCartFooter(
                                onOrderTypeChanged: () async {
                                  final c = await food_Authservice.fetchCart();
                                  setState(() => cartData = c);
                                },
                              ),

                              // ── Ads banner ───────────────────────────
                              if (homepageAds.isNotEmpty) ...[
                                SizedBox(height: 12.h),
                                _sectionLabel('Recommended for you'),
                                SizedBox(height: 8.h),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: BannerAdvertisement(
                                    ads: homepageAds,
                                    height: 200,
                                  ),
                                ),
                              ],

                              SizedBox(height: 12.h),
                              _buildCouponRow(),
                              SizedBox(height: 10.h),

                              if ((cartData?.orderType ?? '')
                                      .trim()
                                      .toLowerCase() ==
                                  'delivery')
                                _buildDeliveryAddress(),

                              SizedBox(height: 10.h),
                              _buildSummaryCard(),
                              SizedBox(height: 12.h),
                              _buildScheduleOrder(),
                              SizedBox(height: 12.h),
                              _buildPaymentToggle(),
                              if (isExpanded) ...[
                                SizedBox(height: 12.h),
                                _buildCheckoutDetails(),
                              ],
                              SizedBox(height: 24.h),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),

        if (_overlayState != PaymentOverlayState.none)
          Positioned.fill(
            child: AbsorbPointer(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  color: Colors.black.withOpacity(0.7), // stronger block
                  child: Center(child: _overlayContent()),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _overlayContent() {
    switch (_overlayState) {
      case PaymentOverlayState.placingOrder:
        return _dialogLoader("Placing your order...");
      case PaymentOverlayState.openingGateway:
        return _dialogLoader("Opening payment gateway...");
      case PaymentOverlayState.processing:
        return _dialogLoader("Processing payment...");
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _dialogLoader(String text) {
    return Material(
      color: Colors.transparent,
      child: Container(
        key: ValueKey(text), // ✅ VERY IMPORTANT (forces rebuild)
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            DefaultTextStyle(
              // ✅ FIXES TEXT RENDER BUG
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
              child: Text(text),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Review Your Cart',
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: _C.textPrimary,
        ),
      ),
      iconTheme: const IconThemeData(color: _C.textPrimary),
      actions: [
        GestureDetector(
          onTap: () async {
            final ok = await food_Authservice.deleteCart();
            if (!mounted) return;
            if (ok) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainScreenfood()),
              );
              AppAlert.success(context, 'Cart cleared');
            } else {
              AppAlert.error(context, 'Failed to clear cart');
            }
          },
          child: Container(
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _C.red.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: _C.red.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              size: 18.sp,
              color: _C.red,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _C.border),
      ),
    );
  }

  // ── Section label ───────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: _C.textPrimary,
      ),
    );
  }

  // ── Cart items card ─────────────────────────────────────────────────────
  Widget _buildCartItems() {
    if (cartData == null || cartData!.cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cartData!.cartItems.map((item) {
            final isLast = item == cartData!.cartItems.last;
            return Column(
              key: ValueKey(item.itemId),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.dishName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _C.textPrimary,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      _buildQtyControl(item),

                      SizedBox(width: 12.w),

                      SizedBox(
                        width: 80.w, // ✅ FIXED WIDTH
                        child: Text(
                          '₹${item.totalPrice.toStringAsFixed(2)}',
                          textAlign: TextAlign.right, // ✅ ALIGN RIGHT
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: _C.violet,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) Divider(height: 1, color: _C.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQtyControl(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            Icons.remove_rounded,
            _C.red,
            () => changeQuantity(item, item.quantity - 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
          ),
          _qtyBtn(
            Icons.add_rounded,
            _C.green,
            () => changeQuantity(item, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 14.sp, color: color),
      ),
    );
  }

  // ── "Add more items" text ───────────────────────────────────────────────
  Widget _buildAddMoreText() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Missed something? ',
          style: TextStyle(fontSize: 13.sp, color: _C.textSecondary),
          children: [
            TextSpan(
              text: 'Add more items',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _C.violet,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MenuScreen(vendorId: cartData!.vendorId),
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Coupon row ──────────────────────────────────────────────────────────
  Widget _buildCouponRow() {
    final applied = (cartData?.couponCode ?? '').isNotEmpty;

    return GestureDetector(
      onTap: applied ? null : _showCouponBottomSheet,
      child: _card(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: applied ? _C.green.withOpacity(0.10) : _C.violetDim,
                shape: BoxShape.circle,
              ),
              child: Icon(
                applied
                    ? Icons.check_circle_rounded
                    : Icons.local_offer_rounded,
                size: 18.sp,
                color: applied ? _C.green : _C.violet,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applied ? 'Coupon Applied' : 'Apply Coupon',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: applied ? _C.green : _C.textPrimary,
                    ),
                  ),
                  if (applied)
                    Text(
                      appliedCouponCode ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _C.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (applied)
              GestureDetector(
                onTap: () async {
                  if (cartData?.cartId == null) return;
                  final result = await food_Authservice.updateCartSettings(
                    cartId: cartData!.cartId,
                    couponId: cartData!.couponId,
                    applyCoupon: "NOT_APPLIED",
                  );
                  if (!result.success) {
                    AppAlert.error(context, "Failed to remove coupon");
                    return;
                  }
                  setState(() {
                    appliedCouponCode = null;
                    appliedCouponId = null;
                  });
                  AppAlert.success(context, "Coupon removed");
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _C.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _C.red.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _C.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: _C.textMuted,
              ),
          ],
        ),
      ),
    );
  }

  void _showCouponBottomSheet() async {
    setState(() => isCouponLoading = true);
    final coupons = await food_Authservice.fetchCoupons();
    final cartVendor = cartData?.vendorId;
    setState(() => isCouponLoading = false);

    coupons.sort((a, b) {
      if (a.isExpired != b.isExpired) return a.isExpired ? 1 : -1;
      final am = !a.isApplicableForVendor(cartVendor);
      final bm = !b.isApplicableForVendor(cartVendor);
      if (am != bm) return am ? 1 : -1;
      return 0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: false,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 1,
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                _couponHeader(),
                coupons.isEmpty
                    ? Expanded(child: _emptyCouponView())
                    : Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: coupons.length,
                          itemBuilder: (_, i) {
                            final c = coupons[i];
                            return _couponTile(
                              coupon: c,
                              isExpired: c.isExpired,
                              isMismatch: !c.isApplicableForVendor(cartVendor),
                              isDisabled:
                                  c.isExpired ||
                                  !c.isApplicableForVendor(cartVendor),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _couponHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(30.w, 20.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          Text(
            'Available Coupons',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: _C.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: _C.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _couponTile({
    required CouponModel coupon,
    required bool isExpired,
    required bool isMismatch,
    required bool isDisabled,
  }) {
    final color = isExpired
        ? _C.red
        : isMismatch
        ? _C.amber
        : _C.green;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        leading: Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.local_offer_rounded, color: color, size: 18.sp),
        ),
        title: Row(
          children: [
            Text(
              coupon.code,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: _C.textPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _C.violet.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                coupon.couponType,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _C.violet,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpired
                    ? 'Expired'
                    : isMismatch
                    ? 'Not applicable for this restaurant'
                    : coupon.discountType == "PERCENTAGE"
                    ? 'Get ${coupon.discountPercentage.toStringAsFixed(0)}% off'
                    : 'Get ₹${coupon.discountPercentage.toStringAsFixed(0)} off',
                style: TextStyle(fontSize: 12.sp, color: color),
              ),
              if (!isExpired && !isMismatch)
                Text(
                  coupon.minimumOrderValue <= 0
                      ? 'Applicable on any order'
                      : 'Min order ₹${coupon.minimumOrderValue.toInt()}',
                  style: TextStyle(fontSize: 11.sp, color: _C.textMuted),
                ),
            ],
          ),
        ),
        trailing: isDisabled
            ? Icon(Icons.block_rounded, color: color, size: 18.sp)
            : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: _C.textMuted,
              ),
        onTap: isDisabled
            ? () => AppAlert.error(
                context,
                isExpired
                    ? 'Coupon expired'
                    : 'Not applicable for this restaurant',
              )
            : () => _applyCoupon(coupon),
      ),
    );
  }

  Widget _emptyCouponView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 48.sp,
            color: _C.textMuted,
          ),
          SizedBox(height: 12.h),
          Text(
            'No coupons available',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: _C.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Check back later for new offers',
            style: TextStyle(fontSize: 12.sp, color: _C.textMuted),
          ),
        ],
      ),
    );
  }

  Future<void> _applyCoupon(CouponModel coupon) async {
    if (cartData?.cartId == null) {
      AppAlert.error(context, "Cart is empty");
      return;
    }
    final result = await food_Authservice.updateCartSettings(
      cartId: cartData!.cartId,
      couponId: coupon.id,
      applyCoupon: "APPLIED",
    );
    if (!result.success) {
      AppAlert.error(context, result.error ?? "Failed to apply coupon");
      return;
    }
    await _loadCart();
    setState(() {
      appliedCouponCode = coupon.code;
      appliedCouponId = coupon.id;
    });
    AppAlert.success(context, "Coupon ${coupon.code} applied!");
    Navigator.pop(context);
  }

  // ── Delivery address ────────────────────────────────────────────────────
  Widget _buildDeliveryAddress() {
    ref.watch(addressProvider);
    final hasAddr = (cartData?.deliveryAddress ?? '').trim().isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SavedAddress(
            hideExtraWidgets: true,
            onAddressSelected: (address) async {
              // ✅ Update local state
              await ref
                  .read(addressProvider.notifier)
                  .updateLocalAddress(
                    city: address.city,
                    stateName: address.state,
                    pincode: address.pincode,
                    latitude: address.latitude,
                    longitude: address.longitude,
                    fullAddress: address.fullAddress,
                    category: address.category, // 🔥 important
                  );

              // ✅ Update cart address (only for saved addresses)
              if (address.addressId != 0) {
                final ok = await AddressNotifier.updateDeliveryAddress(
                  cartId: cartData!.cartId,
                  addressId: address.addressId,
                );

                if (!ok && mounted) {
                  AppAlert.error(context, "Failed to update cart address");
                }
              }
            },
          ),
        ),
      ),
      child: _card(
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: hasAddr
                    ? _C.violet.withOpacity(0.08)
                    : _C.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 20.sp,
                color: hasAddr ? _C.violet : _C.red,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAddr ? 'Delivery Address' : 'Select Delivery Address',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                  if (hasAddr) ...[
                    SizedBox(height: 2.h),
                    Text(
                      [
                        cartData!.deliveryAddress,
                        cartData!.name,
                        cartData!.mobileNo,
                      ].where((e) => e.toString().trim().isNotEmpty).join(', '),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _C.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Tap to change',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _C.violet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: _C.textMuted),
          ],
        ),
      ),
    );
  }

  // ── Order summary card ──────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    if (cartData == null || isLoading) {
      return CartSkeleton(type: CartSkeletonType.summary);
    }

    final orderType = cartData?.orderType ?? '';
    final subtotal = cartData?.subtotal ?? 0;
    final packing = cartData?.packingTotal ?? 0;
    final delivery = cartData?.deliveryCharges ?? 0;
    final platform = cartData?.platformCharges ?? 0;
    final discount = cartData?.discountAmount ?? 0;
    final gst = cartData?.gstTotal ?? 0;
    final grandTotal = cartData?.grandTotal ?? 0;
    final type = orderType.toUpperCase();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () =>
                setState(() => _isSummaryExpanded = !_isSummaryExpanded),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: _C.violetDim,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 18.sp,
                    color: _C.violet,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isSummaryExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _C.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Expandable details
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isSummaryExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,

            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                Divider(height: 1, color: _C.border),
                SizedBox(height: 10.h),

                _summaryRow('Subtotal', subtotal),

                if (platform > 0) _summaryRow('Platform Charges', platform),

                if ((type == 'DELIVERY' || type == 'TAKEAWAY') && packing > 0)
                  _summaryRow('Packing Charges', packing),

                if (orderType.toUpperCase() == 'DELIVERY')
                  _summaryRow('Delivery Charges', delivery),

                if (discount > 0)
                  _summaryRow('Discount', -discount, color: _C.green),

                if ((gst / 2) > 0) ...[
                  _summaryRow('SGST', gst / 2),
                  _summaryRow('CGST', gst / 2),
                ],

                SizedBox(height: 4.h),
              ],
            ),

            secondChild: const SizedBox.shrink(),
          ),

          Divider(height: 16.h, color: _C.border),

          // Grand total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${_fmt(grandTotal)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: _C.violet,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, num value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: _C.textSecondary),
          ),
          Text(
            value < 0 ? '-₹${_fmt(-value)}' : '₹${_fmt(value)}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color ?? _C.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Schedule order ──────────────────────────────────────────────────────
  Widget _buildScheduleOrder() {
    // bool hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
    final isUserScheduled =
        _orderType == "schedule" &&
        _selectedDate != null &&
        _selectedTime != null;

    final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          ///
          Text(
            "If you want Schedule your order!",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Pick a convenient date & time",
            style: TextStyle(fontSize: 12.sp, color: _C.textSecondary),
          ),

          SizedBox(height: 14.h),

          if (hasScheduledItems) ...[
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Some items in your cart are not available right now. Please schedule your order to continue.",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _C.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          /// CTA Button (when not scheduled)
          if (!isUserScheduled)
            GestureDetector(
              onTap: () async {
                setState(() {
                  _orderType = 'schedule';
                });
                await _pickScheduleDateTime();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: _C.violet.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _C.violet.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, color: _C.violet, size: 18.sp),
                    SizedBox(width: 8.w),

                    Text(
                      hasScheduledItems && !isUserScheduled
                          ? "Schedule to Continue"
                          : "Choose Date & Time",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.violet,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// Scheduled State UI
          if (isUserScheduled) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: _C.green.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _C.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: _C.green,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),

                  /// Date + Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Scheduled 🎉",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: _C.green,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  •  ${_selectedTime!.format(context)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Edit Button
                  GestureDetector(
                    onTap: _pickScheduleDateTime,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: _C.violet.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: _C.violet.withOpacity(0.2)),
                      ),
                      child: Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: _C.violet,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickScheduleDateTime() async {
    final now = DateTime.now();
    final first = now.add(const Duration(minutes: 25));

    final date = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.violet,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _C.violet),
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    while (true) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dialHandColor: _C.violet,
              dialBackgroundColor: _C.bg,
            ),
            colorScheme: const ColorScheme.light(
              primary: _C.violet,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _C.violet),
            ),
          ),
          child: child!,
        ),
      );
      if (time == null) return;

      final selected = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (selected.isBefore(now.add(const Duration(minutes: 25)))) {
        AppAlert.error(context, "Select a time at least 25 minutes from now");
        continue;
      }
      setState(() {
        _selectedDate = date;
        _selectedTime = time;
      });
      break;
    }
  }

  // ── Payment toggle button ───────────────────────────────────────────────
  Widget _buildPaymentToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => isExpanded = !isExpanded);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isExpanded) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4A43C9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _C.violet.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.payment_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              isExpanded ? 'Hide Payment Options' : 'Choose Payment Method',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutDetails() {
    return Column(
      children: [
        cartwallet(
          wallet: wallet,
          onSelectionChanged: (method, subWallets) {
            setState(() {
              selectedPaymentMethod = method;
              selectedSubWallets = subWallets;
            });
          },
        ),
        SizedBox(height: 14.h),
        _buildPlaceOrderButton(),
      ],
    );
  }

  // ── Place order button ──────────────────────────────────────────────────
  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: isPlacingOrder ? null : placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          shadowColor: _C.green.withOpacity(0.3),
        ),
        child: isPlacingOrder
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '₹${(cartData?.grandTotal ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Empty cart ──────────────────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          Container(
            width: 90.r,
            height: 90.r,
            decoration: BoxDecoration(
              color: _C.violetDim,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 40.sp,
              color: _C.violet,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Add some delicious items to get started',
            style: TextStyle(fontSize: 13.sp, color: _C.textSecondary),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreenfood()),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.violet,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: _C.violet.withOpacity(0.3),
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
          SizedBox(height: 24.h),
          if (homepageAds.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BannerAdvertisement(ads: homepageAds, height: 200),
            ),
        ],
      ),
    );
  }

  // ── Shared card shell ───────────────────────────────────────────────────
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
