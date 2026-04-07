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
// // import 'food_invoice.dart';
// // import 'Menu/menu_screen.dart';
// //
// // class Cart {
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
// //   final bool _isPlacingOrder = false;
// //   bool isCouponLoading = false;
// //   Set<String> selectedSubWallets = {};
// //   int userId = 0;
// //   List<Campaign> homepageAds = [];
// //   bool _isSummaryExpanded = false;
// //
// //   bool hasUserSelectedOrderType = false;
// //
// //   String _orderType = "";
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _scrollController = ScrollController();
// //     _loadWallet();
// //     _loadCart();
// //     _initCartSocket();
// //     _loadAds();
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
// //           print(
// //             "   NEW -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
// //           );
// //
// //           return item;
// //         }
// //
// //         print("🆕 New item added: ${json['itemId']}");
// //         return CartItem.fromJson(json);
// //       }).toList();
// //
// //       // --------------------------
// //       // 💰 PRICE SUMMARY DEBUG
// //       // --------------------------
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
// //       print("💰 PRICE SUMMARY:");
// //       print("   Subtotal: ${cartData!.subtotal}");
// //       print("   GST: ${cartData!.gstTotal}");
// //       print("   Packing: ${cartData!.packingTotal}");
// //       print("   Platform: ${cartData!.platformCharges}");
// //       print("   Delivery: ${cartData!.deliveryCharges}");
// //       print("   Discount: ${cartData!.discountAmount}");
// //       print("   Grand Total: ${cartData!.grandTotal}");
// //
// //       // --------------------------
// //       // 👤 USER INFO DEBUG
// //       // --------------------------
// //       cartData!.deliveryAddress =
// //           data['deliveryAddress'] ?? cartData!.deliveryAddress;
// //       cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
// //       cartData!.name = data['name'] ?? cartData!.name;
// //       cartData!.couponCode = data['couponCode'];
// //
// //       print("👤 USER INFO:");
// //       print("   Name: ${cartData!.name}");
// //       print("   Mobile: ${cartData!.mobileNo}");
// //       print("   Address: ${cartData!.deliveryAddress}");
// //       print("   Coupon: ${cartData!.couponCode}");
// //
// //       // --------------------------
// //       // ⏰ ORDER TYPE DEBUG
// //       // --------------------------
// //       if (hasScheduledItem) {
// //         _orderType = "schedule";
// //         hasUserSelectedOrderType = true;
// //         print("⏰ Scheduled item detected → orderType = schedule");
// //       }
// //     });
// //
// //     print("✅ Cart UI updated successfully\n");
// //   }
// //
// //   bool get hasScheduledItem {
// //     if (cartData == null || cartData!.cartItems.isEmpty) return false;
// //
// //     return cartData!.cartItems.any((item) => item.shedule == true);
// //   }
// //
// //   bool get mustSchedule {
// //     return cartData?.cartItems.any((e) => e.shedule == true) ?? false;
// //   }
// //
// //   Future<void> _loadCart() async {
// //     setState(() => isLoading = true);
// //     try {
// //       final fetchedCart = await food_Authservice.fetchCart();
// //       if (mounted) {
// //         setState(() {
// //           cartData = fetchedCart;
// //           appliedCouponCode = fetchedCart?.couponCode;
// //           isLoading = false;
// //
// //           /// 🔥 AUTO SWITCH TO SCHEDULE
// //           if (hasScheduledItem) {
// //             _orderType = "schedule";
// //             hasUserSelectedOrderType = true;
// //           }
// //         });
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() => isLoading = false);
// //         AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
// //       }
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
// //     final mustSchedule = cartData!.cartItems.any((i) => i.shedule);
// //     final effectiveOrderType = _orderType;
// //
// //     // ✅ Block if schedule required but no date/time picked
// //     if ((mustSchedule || effectiveOrderType == "schedule") &&
// //         (_selectedDate == null || _selectedTime == null)) {
// //       AppAlert.error(
// //         context,
// //         "⚠️ Please select a date & time to schedule your order",
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
// //       final bool isScheduled = _selectedDate != null || _selectedTime != null;
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
// //           final ok = isScheduled
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
// //         rp.onError = (res) =>
// //             AppAlert.error(context, "Payment failed: ${res.message}");
// //         rp.startPayment(
// //           orderId: orderId,
// //           amount: amount,
// //           description: "Online Payment via Razorpay",
// //         );
// //         return;
// //       }
// //
// //       final amt = cartData!.grandTotal.toDouble();
// //       if (isScheduled) {
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
// //     } catch (_) {
// //       AppAlert.error(context, "Error placing order");
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
// //     if (cartId == null) {
// //       AppAlert.error(context, "Cart session expired. Please try again.");
// //       return false;
// //     }
// //     try {
// //       final result = await food_Authservice.scheduleOrder(
// //         cartId: cartId,
// //         date: _selectedDate ?? DateTime.now(),
// //         time: _selectedTime ?? TimeOfDay.now(),
// //         paymentMethod: paymentMethod,
// //         razorpayPaymentId: razorpayPaymentId,
// //         razorpayOrderId: razorpayOrderId,
// //         walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
// //         amount: amount,
// //       );
// //       if (result.containsKey('orderId')) {
// //         final oid = result['orderId'];
// //         await prefs.setInt('orderId', oid);
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
// //         );
// //         return true;
// //       }
// //       // ✅ backend returned 200 but no orderId — show whatever message came back
// //       final msg =
// //           result['message'] ??
// //           result['error'] ??
// //           "Order could not be confirmed";
// //       AppAlert.error(context, msg.toString());
// //       return false;
// //     } catch (e) {
// //       // ✅ backend non-200 error message lands here
// //       AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
// //       return false;
// //     }
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
// //     if (cartId == null) {
// //       AppAlert.error(context, "Cart session expired. Please try again.");
// //       return false;
// //     }
// //     try {
// //       final result = await food_Authservice.placeDirectOrder(
// //         cartId: cartId,
// //         paymentMethod: paymentMethod,
// //         razorpayPaymentId: razorpayPaymentId,
// //         razorpayOrderId: razorpayOrderId,
// //         walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
// //         amount: amount,
// //       );
// //       if (result.containsKey('orderId')) {
// //         final oid = result['orderId'];
// //         await prefs.setInt('orderId', oid);
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
// //         );
// //         return true;
// //       }
// //       // ✅ backend returned 200 but no orderId
// //       final msg =
// //           result['message'] ??
// //           result['error'] ??
// //           "Order could not be confirmed";
// //       AppAlert.error(context, msg.toString());
// //       return false;
// //     } catch (e) {
// //       // ✅ backend non-200 error message lands here
// //       AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
// //       return false;
// //     }
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
// //     try {
// //       final c = await food_Authservice.fetchCart();
// //       final w = await subscription_AuthService.fetchWallet();
// //       if (!mounted) return;
// //       setState(() {
// //         cartData = c;
// //         wallet = w;
// //       });
// //     } catch (e) {
// //       if (mounted) {
// //         AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
// //       }
// //     }
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
// //     ScreenUtil.init(context);
// //     return Stack(
// //       children: [
// //         Scaffold(
// //           backgroundColor: Cart.bg,
// //           appBar: _buildAppBar(),
// //           body: AuthGuard(
// //             child: SafeArea(
// //               child: RefreshIndicator(
// //                 onRefresh: _onRefresh,
// //                 color: Cart.violet,
// //                 backgroundColor: Cart.surface,
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
// //                   child: CircularProgressIndicator(color: Cart.violet),
// //                 ),
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
// //       backgroundColor: Cart.surface,
// //       elevation: 0,
// //       centerTitle: true,
// //       title: Text(
// //         'Review Your Cart',
// //         style: TextStyle(
// //           fontSize: 17.sp,
// //           fontWeight: FontWeight.w700,
// //           color: Cart.textPrimary,
// //         ),
// //       ),
// //       leading: IconButton(
// //         icon: const Icon(
// //           Icons.arrow_back_ios_new_rounded,
// //         ), // iOS-style back arrow
// //         color: Cart.textPrimary,
// //         onPressed: () => Navigator.of(context).pop(),
// //       ),
// //       iconTheme: const IconThemeData(color: Cart.textPrimary),
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
// //               color: Cart.red.withOpacity(0.08),
// //               shape: BoxShape.circle,
// //               border: Border.all(color: Cart.red.withOpacity(0.2)),
// //             ),
// //             child: Icon(
// //               Icons.delete_outline_rounded,
// //               size: 18.sp,
// //               color: Cart.red,
// //             ),
// //           ),
// //         ),
// //       ],
// //       bottom: PreferredSize(
// //         preferredSize: const Size.fromHeight(1),
// //         child: Container(height: 1, color: Cart.border),
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
// //         color: Cart.textPrimary,
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
// //               children: [
// //                 Padding(
// //                   padding: EdgeInsets.symmetric(vertical: 10.h),
// //                   child: Row(
// //                     crossAxisAlignment: CrossAxisAlignment.center,
// //                     children: [
// //                       // 🟢 ITEM NAME (Flexible)
// //                       Expanded(
// //                         child: Text(
// //                           item.dishName,
// //                           maxLines: 2,
// //                           overflow: TextOverflow.ellipsis,
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             fontWeight: FontWeight.w600,
// //                             color: Cart.textPrimary,
// //                           ),
// //                         ),
// //                       ),
// //
// //                       SizedBox(width: 8.w),
// //
// //                       _buildQtyControl(item),
// //
// //                       SizedBox(width: 8.w),
// //
// //                       // 🔴 PRICE (fixed width + right aligned)
// //                       SizedBox(
// //                         width: 70.w, // 🔥 important
// //                         child: Text(
// //                           '₹${item.totalPrice.toStringAsFixed(2)}',
// //                           textAlign: TextAlign.right, // 🔥 align right
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             fontWeight: FontWeight.w700,
// //                             color: Cart.violet,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 if (!isLast) Divider(height: 1, color: Cart.border),
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
// //         color: Cart.bg,
// //         borderRadius: BorderRadius.circular(10.r),
// //         border: Border.all(color: Cart.border),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           _qtyBtn(
// //             Icons.remove_rounded,
// //             Cart.red,
// //             () => changeQuantity(item, item.quantity - 1),
// //           ),
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 10.w),
// //             child: Text(
// //               '${item.quantity}',
// //               style: TextStyle(
// //                 fontSize: 13.sp,
// //                 fontWeight: FontWeight.w700,
// //                 color: Cart.textPrimary,
// //               ),
// //             ),
// //           ),
// //           _qtyBtn(
// //             Icons.add_rounded,
// //             Cart.green,
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
// //           style: TextStyle(fontSize: 13.sp, color: Cart.textSecondary),
// //           children: [
// //             TextSpan(
// //               text: 'Add more items',
// //               style: TextStyle(
// //                 fontSize: 13.sp,
// //                 fontWeight: FontWeight.w700,
// //                 color: Cart.violet,
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
// //                 color: applied ? Cart.green.withOpacity(0.10) : Cart.violetDim,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 applied
// //                     ? Icons.check_circle_rounded
// //                     : Icons.local_offer_rounded,
// //                 size: 18.sp,
// //                 color: applied ? Cart.green : Cart.violet,
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
// //                       color: applied ? Cart.green : Cart.textPrimary,
// //                     ),
// //                   ),
// //                   if (applied)
// //                     Text(
// //                       appliedCouponCode ?? '',
// //                       style: TextStyle(
// //                         fontSize: 11.sp,
// //                         color: Cart.textSecondary,
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
// //                     color: Cart.red.withOpacity(0.08),
// //                     borderRadius: BorderRadius.circular(20.r),
// //                     border: Border.all(color: Cart.red.withOpacity(0.2)),
// //                   ),
// //                   child: Text(
// //                     'Remove',
// //                     style: TextStyle(
// //                       fontSize: 11.sp,
// //                       color: Cart.red,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //               )
// //             else
// //               Icon(
// //                 Icons.chevron_right_rounded,
// //                 size: 20.sp,
// //                 color: Cart.textMuted,
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _showCouponBottomSheet() async {
// //     setState(() => isCouponLoading = true);
// //     final coupons = await subscription_AuthService.fetchCoupons();
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
// //             height: MediaQuery.of(ctx).size.height,
// //             decoration: BoxDecoration(
// //               color: Cart.bg,
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
// //       padding: EdgeInsets.fromLTRB(20.w, 20.h, 16.w, 16.h),
// //       decoration: BoxDecoration(
// //         color: Cart.surface,
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
// //         border: Border(bottom: BorderSide(color: Cart.border)),
// //       ),
// //       child: Row(
// //         children: [
// //           Text(
// //             'Available Coupons',
// //             style: TextStyle(
// //               fontSize: 16.sp,
// //               fontWeight: FontWeight.w800,
// //               color: Cart.textPrimary,
// //             ),
// //           ),
// //           const Spacer(),
// //           GestureDetector(
// //             onTap: () => Navigator.pop(context),
// //             child: Container(
// //               padding: EdgeInsets.all(6.w),
// //               decoration: BoxDecoration(
// //                 color: Cart.border,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 Icons.close_rounded,
// //                 size: 16.sp,
// //                 color: Cart.textSecondary,
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
// //         ? Cart.red
// //         : isMismatch
// //         ? Cart.amber
// //         : Cart.green;
// //
// //     return Container(
// //       margin: EdgeInsets.only(bottom: 10.h),
// //       decoration: BoxDecoration(
// //         color: Cart.surface,
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
// //                 color: Cart.textPrimary,
// //               ),
// //             ),
// //             SizedBox(width: 8.w),
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
// //               decoration: BoxDecoration(
// //                 color: Cart.violet.withOpacity(0.08),
// //                 borderRadius: BorderRadius.circular(6.r),
// //               ),
// //               child: Text(
// //                 coupon.couponType,
// //                 style: TextStyle(
// //                   fontSize: 10.sp,
// //                   color: Cart.violet,
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
// //                   style: TextStyle(fontSize: 11.sp, color: Cart.textMuted),
// //                 ),
// //             ],
// //           ),
// //         ),
// //         trailing: isDisabled
// //             ? Icon(Icons.block_rounded, color: color, size: 18.sp)
// //             : Icon(
// //                 Icons.arrow_forward_ios_rounded,
// //                 size: 14.sp,
// //                 color: Cart.textMuted,
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
// //             color: Cart.textMuted,
// //           ),
// //           SizedBox(height: 12.h),
// //           Text(
// //             'No coupons available',
// //             style: TextStyle(
// //               fontSize: 15.sp,
// //               fontWeight: FontWeight.w700,
// //               color: Cart.textSecondary,
// //             ),
// //           ),
// //           SizedBox(height: 4.h),
// //           Text(
// //             'Check back later for new offers',
// //             style: TextStyle(fontSize: 12.sp, color: Cart.textMuted),
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
// //     final addressState = ref.watch(addressProvider);
// //
// //     final displayAddress = (addressState.fullAddress).trim().isNotEmpty
// //         ? addressState.fullAddress
// //         : (cartData?.deliveryAddress ?? '');
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
// //                     ? Cart.violet.withOpacity(0.08)
// //                     : Cart.red.withOpacity(0.08),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 Icons.location_on_rounded,
// //                 size: 20.sp,
// //                 color: hasAddr ? Cart.violet : Cart.red,
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
// //                       color: Cart.textPrimary,
// //                     ),
// //                   ),
// //                   if (hasAddr) ...[
// //                     SizedBox(height: 2.h),
// //                     Text(
// //                       [
// //                         displayAddress,
// //                         cartData?.name,
// //                         cartData?.mobileNo,
// //                       ].where((e) => e.toString().trim().isNotEmpty).join(', '),
// //                       maxLines: 2,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     SizedBox(height: 2.h),
// //                     Text(
// //                       'Tap to change',
// //                       style: TextStyle(
// //                         fontSize: 11.sp,
// //                         color: Cart.violet,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //             Icon(
// //               Icons.chevron_right_rounded,
// //               size: 20.sp,
// //               color: Cart.textMuted,
// //             ),
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
// //     final saved = cartData?.savedAmount ?? 0;
// //     double.parse((saved + grandTotal).toStringAsFixed(2));
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
// //                     color: Cart.violetDim,
// //                     borderRadius: BorderRadius.circular(10.r),
// //                   ),
// //                   child: Icon(
// //                     Icons.receipt_long_rounded,
// //                     size: 18.sp,
// //                     color: Cart.violet,
// //                   ),
// //                 ),
// //                 SizedBox(width: 10.w),
// //                 Expanded(
// //                   child: Text(
// //                     'Order Summary',
// //                     style: TextStyle(
// //                       fontSize: 14.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: Cart.textPrimary,
// //                     ),
// //                   ),
// //                 ),
// //                 AnimatedRotation(
// //                   turns: _isSummaryExpanded ? 0.5 : 0,
// //                   duration: const Duration(milliseconds: 200),
// //                   child: Icon(
// //                     Icons.keyboard_arrow_down_rounded,
// //                     color: Cart.textSecondary,
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
// //             firstChild: Column(
// //               children: [
// //                 SizedBox(height: 12.h),
// //                 Divider(height: 1, color: Cart.border),
// //                 SizedBox(height: 10.h),
// //                 _summaryRow('Subtotal', subtotal),
// //                 _summaryRow('Platform Charges', platform),
// //                 if (orderType.toUpperCase() == 'DELIVERY' ||
// //                     orderType.toUpperCase() == 'TAKEAWAY')
// //                   _summaryRow('Packing Charges', packing),
// //                 if (orderType.toUpperCase() == 'DELIVERY')
// //                   _summaryRow('Delivery Charges', delivery),
// //                 if (discount > 0)
// //                   _summaryRow('Discount', -discount, color: Cart.green),
// //                 _summaryRow('SGST', gst / 2),
// //                 _summaryRow('CGST', gst / 2),
// //                 SizedBox(height: 4.h),
// //               ],
// //             ),
// //             secondChild: const SizedBox.shrink(),
// //           ),
// //
// //           Divider(height: 16.h, color: Cart.border),
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
// //                   color: Cart.textPrimary,
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
// //                       color: Cart.violet,
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
// //             style: TextStyle(fontSize: 12.sp, color: Cart.textSecondary),
// //           ),
// //           Text(
// //             value < 0 ? '-₹${_fmt(-value)}' : '₹${_fmt(value)}',
// //             style: TextStyle(
// //               fontSize: 12.sp,
// //               fontWeight: FontWeight.w600,
// //               color: color ?? Cart.textPrimary,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Schedule order ──────────────────────────────────────────────────────
// //   Widget _buildScheduleOrder() {
// //     final showNow = cartData!.cartItems.every((i) => !i.shedule);
// //     final isScheduled =
// //         _orderType == "schedule" &&
// //         _selectedDate != null &&
// //         _selectedTime != null;
// //
// //     return _card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(Icons.schedule_rounded, size: 18.sp, color: Cart.violet),
// //               SizedBox(width: 8.w),
// //               Text(
// //                 'Order Timing',
// //                 style: TextStyle(
// //                   fontSize: 14.sp,
// //                   fontWeight: FontWeight.w700,
// //                   color: Cart.textPrimary,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 12.h),
// //           Row(
// //             children: [
// //               if (showNow) ...[
// //                 _timingChip('Order Now', _orderType == 'now', () {
// //                   setState(() {
// //                     _orderType = 'now';
// //                     _selectedDate = null;
// //                     _selectedTime = null;
// //                   });
// //                 }),
// //                 SizedBox(width: 10.w),
// //               ],
// //               _timingChip('Schedule', _orderType == 'schedule', () async {
// //                 setState(() {
// //                   _orderType = 'schedule';
// //                   _selectedDate = null;
// //                   _selectedTime = null;
// //                 });
// //                 await _pickScheduleDateTime();
// //               }),
// //             ],
// //           ),
// //
// //           if (isScheduled) ...[
// //             SizedBox(height: 12.h),
// //             Container(
// //               padding: EdgeInsets.all(14.w),
// //               decoration: BoxDecoration(
// //                 color: Cart.green.withOpacity(0.06),
// //                 borderRadius: BorderRadius.circular(12.r),
// //                 border: Border.all(color: Cart.green.withOpacity(0.3)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(
// //                     Icons.check_circle_rounded,
// //                     color: Cart.green,
// //                     size: 18.sp,
// //                   ),
// //                   SizedBox(width: 10.w),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'Scheduled',
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             fontWeight: FontWeight.w700,
// //                             color: Cart.green,
// //                           ),
// //                         ),
// //                         Text(
// //                           '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  •  ${_selectedTime!.format(context)}',
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             color: Cart.textSecondary,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   GestureDetector(
// //                     onTap: _pickScheduleDateTime,
// //                     child: Container(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: 10.w,
// //                         vertical: 5.h,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Cart.violet.withOpacity(0.08),
// //                         borderRadius: BorderRadius.circular(8.r),
// //                         border: Border.all(color: Cart.violet.withOpacity(0.2)),
// //                       ),
// //                       child: Text(
// //                         'Edit',
// //                         style: TextStyle(
// //                           fontSize: 11.sp,
// //                           color: Cart.violet,
// //                           fontWeight: FontWeight.w600,
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
// //   Widget _timingChip(String label, bool selected, VoidCallback onTap) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 180),
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
// //         decoration: BoxDecoration(
// //           color: selected ? Cart.violet : Cart.bg,
// //           borderRadius: BorderRadius.circular(10.r),
// //           border: Border.all(color: selected ? Cart.violet : Cart.border),
// //         ),
// //         child: Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 12.sp,
// //             fontWeight: FontWeight.w600,
// //             color: selected ? Colors.white : Cart.textSecondary,
// //           ),
// //         ),
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
// //             primary: Cart.violet,
// //             onPrimary: Colors.white,
// //             onSurface: Colors.black,
// //           ),
// //           textButtonTheme: TextButtonThemeData(
// //             style: TextButton.styleFrom(foregroundColor: Cart.violet),
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
// //               dialHandColor: Cart.violet,
// //               dialBackgroundColor: Cart.bg,
// //             ),
// //             colorScheme: const ColorScheme.light(
// //               primary: Cart.violet,
// //               onPrimary: Colors.white,
// //               onSurface: Colors.black,
// //             ),
// //             textButtonTheme: TextButtonThemeData(
// //               style: TextButton.styleFrom(foregroundColor: Cart.violet),
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
// //               color: Cart.violet.withOpacity(0.30),
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
// //           backgroundColor: Cart.green,
// //           foregroundColor: Colors.white,
// //           elevation: 0,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16.r),
// //           ),
// //           shadowColor: Cart.green.withOpacity(0.3),
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
// //               color: Cart.violetDim,
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(
// //               Icons.shopping_bag_outlined,
// //               size: 40.sp,
// //               color: Cart.violet,
// //             ),
// //           ),
// //           SizedBox(height: 20.h),
// //           Text(
// //             'Your cart is empty',
// //             style: TextStyle(
// //               fontSize: 18.sp,
// //               fontWeight: FontWeight.w800,
// //               color: Cart.textPrimary,
// //             ),
// //           ),
// //           SizedBox(height: 6.h),
// //           Text(
// //             'Add some delicious items to get started',
// //             style: TextStyle(fontSize: 13.sp, color: Cart.textSecondary),
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
// //                 color: Cart.violet,
// //                 borderRadius: BorderRadius.circular(14.r),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Cart.violet.withOpacity(0.3),
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
// //         color: Cart.surface,
// //         borderRadius: BorderRadius.circular(16.r),
// //         border: Border.all(color: Cart.border),
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
// import 'food_invoice.dart';
// import 'Menu/menu_screen.dart';
//
// class Cart {
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
//   final bool _isPlacingOrder = false;
//   bool isCouponLoading = false;
//   Set<String> selectedSubWallets = {};
//   int userId = 0;
//   List<Campaign> homepageAds = [];
//   bool _isSummaryExpanded = false;
//
//   String _orderType = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _loadWallet();
//     _loadCart();
//     _initCartSocket();
//     _loadAds();
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
//   void _updateCartFromSocket(Map<String, dynamic> data) {
//     print("🟡 RAW SOCKET DATA: $data");
//
//     if (cartData == null) {
//       print("❌ cartData is NULL → skipping update");
//       return;
//     }
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
//           print(
//             "   NEW -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
//           );
//
//           return item;
//         }
//
//         print("🆕 New item added: ${json['itemId']}");
//         return CartItem.fromJson(json);
//       }).toList();
//
//       // --------------------------
//       // 💰 PRICE SUMMARY DEBUG
//       // --------------------------
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
//       print("💰 PRICE SUMMARY:");
//       print("   Subtotal: ${cartData!.subtotal}");
//       print("   GST: ${cartData!.gstTotal}");
//       print("   Packing: ${cartData!.packingTotal}");
//       print("   Platform: ${cartData!.platformCharges}");
//       print("   Delivery: ${cartData!.deliveryCharges}");
//       print("   Discount: ${cartData!.discountAmount}");
//       print("   Grand Total: ${cartData!.grandTotal}");
//
//       // --------------------------
//       // 👤 USER INFO DEBUG
//       // --------------------------
//       cartData!.deliveryAddress =
//           data['deliveryAddress'] ?? cartData!.deliveryAddress;
//       cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
//       cartData!.name = data['name'] ?? cartData!.name;
//       cartData!.couponCode = data['couponCode'];
//
//       print("👤 USER INFO:");
//       print("   Name: ${cartData!.name}");
//       print("   Mobile: ${cartData!.mobileNo}");
//       print("   Address: ${cartData!.deliveryAddress}");
//       print("   Coupon: ${cartData!.couponCode}");
//
//       // --------------------------
//       // ⏰ ORDER TYPE DEBUG
//       // --------------------------
//     });
//
//     print("✅ Cart UI updated successfully\n");
//   }
//
//   bool get hasScheduledItem {
//     if (cartData == null || cartData!.cartItems.isEmpty) return false;
//
//     return cartData!.cartItems.any((item) => item.shedule == true);
//   }
//
//   bool get mustSchedule {
//     return cartData?.cartItems.any((e) => e.shedule == true) ?? false;
//   }
//
//   Future<void> _loadCart() async {
//     setState(() => isLoading = true);
//     try {
//       final fetchedCart = await food_Authservice.fetchCart();
//       if (mounted) {
//         setState(() {
//           cartData = fetchedCart;
//           appliedCouponCode = fetchedCart?.couponCode;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => isLoading = false);
//         AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
//       }
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
//     final mustSchedule = cartData!.cartItems.any((i) => i.shedule);
//     final effectiveOrderType = _orderType;
//
//     // ✅ Block if schedule required but no date/time picked
//     if ((mustSchedule || effectiveOrderType == "schedule") &&
//         (_selectedDate == null || _selectedTime == null)) {
//       AppAlert.error(
//         context,
//         "⚠️ Please select a date & time to schedule your order",
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
//       final bool isScheduled = _selectedDate != null || _selectedTime != null;
//
//       if (selectedPaymentMethod == "Online_Payment") {
//         final amount = (cartData?.grandTotal ?? 0).toDouble();
//         final orderId = await food_Authservice.createOrder(amount);
//         if (orderId == null) {
//           AppAlert.error(context, "❌ Failed to create payment order");
//           return;
//         }
//         final rp = RazorpayService();
//         rp.onSuccess = (res) async {
//           final pid = res.paymentId!;
//           final oid = res.orderId!;
//           final ok = isScheduled
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
//           if (ok) {
//             final captured = await food_Authservice.capturePayment(
//               paymentId: pid,
//               amount: amount,
//             );
//             if (!captured) {
//               AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
//             }
//           } else {
//             AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
//           }
//         };
//         rp.onError = (res) =>
//             AppAlert.error(context, "Payment failed: ${res.message}");
//         rp.startPayment(
//           orderId: orderId,
//           amount: amount,
//           description: "Online Payment via Razorpay",
//         );
//         return;
//       }
//
//       final amt = cartData!.grandTotal.toDouble();
//       if (isScheduled) {
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
//     } catch (_) {
//       AppAlert.error(context, "Error placing order");
//     } finally {
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
//     if (cartId == null) {
//       AppAlert.error(context, "Cart session expired. Please try again.");
//       return false;
//     }
//     try {
//       final result = await food_Authservice.scheduleOrder(
//         cartId: cartId,
//         date: _selectedDate ?? DateTime.now(),
//         time: _selectedTime ?? TimeOfDay.now(),
//         paymentMethod: paymentMethod,
//         razorpayPaymentId: razorpayPaymentId,
//         razorpayOrderId: razorpayOrderId,
//         walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
//         amount: amount,
//       );
//       if (result.containsKey('orderId')) {
//         final oid = result['orderId'];
//         await prefs.setInt('orderId', oid);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
//         );
//         return true;
//       }
//       // ✅ backend returned 200 but no orderId — show whatever message came back
//       final msg =
//           result['message'] ??
//           result['error'] ??
//           "Order could not be confirmed";
//       AppAlert.error(context, msg.toString());
//       return false;
//     } catch (e) {
//       // ✅ backend non-200 error message lands here
//       AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
//       return false;
//     }
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
//     if (cartId == null) {
//       AppAlert.error(context, "Cart session expired. Please try again.");
//       return false;
//     }
//     try {
//       final result = await food_Authservice.placeDirectOrder(
//         cartId: cartId,
//         paymentMethod: paymentMethod,
//         razorpayPaymentId: razorpayPaymentId,
//         razorpayOrderId: razorpayOrderId,
//         walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
//         amount: amount,
//       );
//       if (result.containsKey('orderId')) {
//         final oid = result['orderId'];
//         await prefs.setInt('orderId', oid);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
//         );
//         return true;
//       }
//       // ✅ backend returned 200 but no orderId
//       final msg =
//           result['message'] ??
//           result['error'] ??
//           "Order could not be confirmed";
//       AppAlert.error(context, msg.toString());
//       return false;
//     } catch (e) {
//       // ✅ backend non-200 error message lands here
//       AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
//       return false;
//     }
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
//     try {
//       final c = await food_Authservice.fetchCart();
//       final w = await subscription_AuthService.fetchWallet();
//       if (!mounted) return;
//       setState(() {
//         cartData = c;
//         wallet = w;
//       });
//     } catch (e) {
//       if (mounted) {
//         AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
//       }
//     }
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
//           backgroundColor: Cart.bg,
//           appBar: _buildAppBar(),
//           body: AuthGuard(
//             child: SafeArea(
//               child: RefreshIndicator(
//                 onRefresh: _onRefresh,
//                 color: Cart.violet,
//                 backgroundColor: Cart.surface,
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
//         if (_isPlacingOrder)
//           Positioned.fill(
//             child: AbsorbPointer(
//               child: Container(
//                 color: Colors.black.withOpacity(0.35),
//                 child: const Center(
//                   child: CircularProgressIndicator(color: Cart.violet),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   // ── AppBar ──────────────────────────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Cart.surface,
//       elevation: 0,
//       centerTitle: true,
//       title: Text(
//         'Review Your Cart',
//         style: TextStyle(
//           fontSize: 17.sp,
//           fontWeight: FontWeight.w700,
//           color: Cart.textPrimary,
//         ),
//       ),
//       leading: IconButton(
//         icon: const Icon(
//           Icons.arrow_back_ios_new_rounded,
//         ), // iOS-style back arrow
//         color: Cart.textPrimary,
//         onPressed: () => Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => MainScreenfood()),
//           (r) => false,
//         ),
//       ),
//       iconTheme: const IconThemeData(color: Cart.textPrimary),
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
//               color: Cart.red.withOpacity(0.08),
//               shape: BoxShape.circle,
//               border: Border.all(color: Cart.red.withOpacity(0.2)),
//             ),
//             child: Icon(
//               Icons.delete_outline_rounded,
//               size: 18.sp,
//               color: Cart.red,
//             ),
//           ),
//         ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(height: 1, color: Cart.border),
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
//         color: Cart.textPrimary,
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
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 10.h),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // 🟢 ITEM NAME (Flexible)
//                       Expanded(
//                         child: Text(
//                           item.dishName,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Cart.textPrimary,
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(width: 8.w),
//
//                       _buildQtyControl(item),
//
//                       SizedBox(width: 8.w),
//
//                       // 🔴 PRICE (fixed width + right aligned)
//                       SizedBox(
//                         width: 70.w, // 🔥 important
//                         child: Text(
//                           '₹${item.totalPrice.toStringAsFixed(2)}',
//                           textAlign: TextAlign.right, // 🔥 align right
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w700,
//                             color: Cart.violet,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (!isLast) Divider(height: 1, color: Cart.border),
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
//         color: Cart.bg,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: Cart.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _qtyBtn(
//             Icons.remove_rounded,
//             Cart.red,
//             () => changeQuantity(item, item.quantity - 1),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             child: Text(
//               '${item.quantity}',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w700,
//                 color: Cart.textPrimary,
//               ),
//             ),
//           ),
//           _qtyBtn(
//             Icons.add_rounded,
//             Cart.green,
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
//           style: TextStyle(fontSize: 13.sp, color: Cart.textSecondary),
//           children: [
//             TextSpan(
//               text: 'Add more items',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w700,
//                 color: Cart.violet,
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
//                 color: applied ? Cart.green.withOpacity(0.10) : Cart.violetDim,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 applied
//                     ? Icons.check_circle_rounded
//                     : Icons.local_offer_rounded,
//                 size: 18.sp,
//                 color: applied ? Cart.green : Cart.violet,
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
//                       color: applied ? Cart.green : Cart.textPrimary,
//                     ),
//                   ),
//                   if (applied)
//                     Text(
//                       appliedCouponCode ?? '',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: Cart.textSecondary,
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
//                     color: Cart.red.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(20.r),
//                     border: Border.all(color: Cart.red.withOpacity(0.2)),
//                   ),
//                   child: Text(
//                     'Remove',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: Cart.red,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               )
//             else
//               Icon(
//                 Icons.chevron_right_rounded,
//                 size: 20.sp,
//                 color: Cart.textMuted,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showCouponBottomSheet() async {
//     setState(() => isCouponLoading = true);
//     final coupons = await subscription_AuthService.fetchCoupons();
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
//             height: MediaQuery.of(ctx).size.height,
//             decoration: BoxDecoration(
//               color: Cart.bg,
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
//       padding: EdgeInsets.fromLTRB(20.w, 20.h, 16.w, 16.h),
//       decoration: BoxDecoration(
//         color: Cart.surface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//         border: Border(bottom: BorderSide(color: Cart.border)),
//       ),
//       child: Row(
//         children: [
//           Text(
//             'Available Coupons',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w800,
//               color: Cart.textPrimary,
//             ),
//           ),
//           const Spacer(),
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               padding: EdgeInsets.all(6.w),
//               decoration: BoxDecoration(
//                 color: Cart.border,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.close_rounded,
//                 size: 16.sp,
//                 color: Cart.textSecondary,
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
//         ? Cart.red
//         : isMismatch
//         ? Cart.amber
//         : Cart.green;
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 10.h),
//       decoration: BoxDecoration(
//         color: Cart.surface,
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
//                 color: Cart.textPrimary,
//               ),
//             ),
//             SizedBox(width: 8.w),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
//               decoration: BoxDecoration(
//                 color: Cart.violet.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//               child: Text(
//                 coupon.couponType,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   color: Cart.violet,
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
//                   style: TextStyle(fontSize: 11.sp, color: Cart.textMuted),
//                 ),
//             ],
//           ),
//         ),
//         trailing: isDisabled
//             ? Icon(Icons.block_rounded, color: color, size: 18.sp)
//             : Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 14.sp,
//                 color: Cart.textMuted,
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
//             color: Cart.textMuted,
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             'No coupons available',
//             style: TextStyle(
//               fontSize: 15.sp,
//               fontWeight: FontWeight.w700,
//               color: Cart.textSecondary,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             'Check back later for new offers',
//             style: TextStyle(fontSize: 12.sp, color: Cart.textMuted),
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
//     final addressState = ref.watch(addressProvider);
//
//     final displayAddress = (addressState.fullAddress).trim().isNotEmpty
//         ? addressState.fullAddress
//         : (cartData?.deliveryAddress ?? '');
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
//                     ? Cart.violet.withOpacity(0.08)
//                     : Cart.red.withOpacity(0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.location_on_rounded,
//                 size: 20.sp,
//                 color: hasAddr ? Cart.violet : Cart.red,
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
//                       color: Cart.textPrimary,
//                     ),
//                   ),
//                   if (hasAddr) ...[
//                     SizedBox(height: 2.h),
//                     Text(
//                       [
//                         displayAddress,
//                         cartData?.name,
//                         cartData?.mobileNo,
//                       ].where((e) => e.toString().trim().isNotEmpty).join(', '),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: 2.h),
//                     Text(
//                       'Tap to change',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: Cart.violet,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.chevron_right_rounded,
//               size: 20.sp,
//               color: Cart.textMuted,
//             ),
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
//     final saved = cartData?.savedAmount ?? 0;
//     double.parse((saved + grandTotal).toStringAsFixed(2));
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
//                     color: Cart.violetDim,
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   child: Icon(
//                     Icons.receipt_long_rounded,
//                     size: 18.sp,
//                     color: Cart.violet,
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: Text(
//                     'Order Summary',
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w700,
//                       color: Cart.textPrimary,
//                     ),
//                   ),
//                 ),
//                 AnimatedRotation(
//                   turns: _isSummaryExpanded ? 0.5 : 0,
//                   duration: const Duration(milliseconds: 200),
//                   child: Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     color: Cart.textSecondary,
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
//             firstChild: Column(
//               children: [
//                 SizedBox(height: 12.h),
//                 Divider(height: 1, color: Cart.border),
//                 SizedBox(height: 10.h),
//                 _summaryRow('Subtotal', subtotal),
//                 _summaryRow('Platform Charges', platform),
//                 if (orderType.toUpperCase() == 'DELIVERY' ||
//                     orderType.toUpperCase() == 'TAKEAWAY')
//                   _summaryRow('Packing Charges', packing),
//                 if (orderType.toUpperCase() == 'DELIVERY')
//                   _summaryRow('Delivery Charges', delivery),
//                 if (discount > 0)
//                   _summaryRow('Discount', -discount, color: Cart.green),
//                 _summaryRow('SGST', gst / 2),
//                 _summaryRow('CGST', gst / 2),
//                 SizedBox(height: 4.h),
//               ],
//             ),
//             secondChild: const SizedBox.shrink(),
//           ),
//
//           Divider(height: 16.h, color: Cart.border),
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
//                   color: Cart.textPrimary,
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
//                       color: Cart.violet,
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
//             style: TextStyle(fontSize: 12.sp, color: Cart.textSecondary),
//           ),
//           Text(
//             value < 0 ? '-₹${_fmt(-value)}' : '₹${_fmt(value)}',
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w600,
//               color: color ?? Cart.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Schedule order ──────────────────────────────────────────────────────
//   Widget _buildScheduleOrder() {
//     final effectiveOrderType = mustSchedule ? "schedule" : _orderType;
//     final isScheduled =
//         effectiveOrderType == "schedule" &&
//         _selectedDate != null &&
//         _selectedTime != null;
//
//     // Highlight the whole card amber when mustSchedule=true and no date picked yet
//     final needsAttention = mustSchedule && !isScheduled;
//
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: needsAttention ? Cart.amber.withOpacity(0.06) : Cart.surface,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: needsAttention ? Cart.amber.withOpacity(0.7) : Cart.border,
//           width: needsAttention ? 1.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: needsAttention
//                 ? Cart.amber.withOpacity(0.15)
//                 : Colors.black.withOpacity(0.04),
//             blurRadius: needsAttention ? 12 : 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header ────────────────────────────────────────────────────
//           Row(
//             children: [
//               Icon(
//                 Icons.schedule_rounded,
//                 size: 18.sp,
//                 color: needsAttention ? Cart.amber : Cart.violet,
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 'Order Timing',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w700,
//                   color: Cart.textPrimary,
//                 ),
//               ),
//               if (needsAttention) ...[
//                 const Spacer(),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
//                   decoration: BoxDecoration(
//                     color: Cart.amber.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(20.r),
//                   ),
//                   child: Text(
//                     'Action required',
//                     style: TextStyle(
//                       fontSize: 10.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Cart.amber,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//           SizedBox(height: 10.h),
//
//           // ── Out-of-stock notice ───────────────────────────────────────
//           if (mustSchedule) ...[
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//               decoration: BoxDecoration(
//                 color: Cart.amber.withOpacity(0.10),
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: Border.all(color: Cart.amber.withOpacity(0.30)),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.info_outline_rounded,
//                     size: 15.sp,
//                     color: Cart.amber,
//                   ),
//                   SizedBox(width: 8.w),
//                   Expanded(
//                     child: Text(
//                       'Some items in your cart are out of stock. You can only place this as a scheduled order.',
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: const Color(0xFF92580A),
//                         height: 1.45,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 12.h),
//           ],
//
//           // ── Schedule chip only (no Order Now) ────────────────────────
//           _timingChip(
//             'Schedule Order',
//             effectiveOrderType == 'schedule',
//             () async {
//               setState(() {
//                 _orderType = 'schedule';
//                 _selectedDate = null;
//                 _selectedTime = null;
//               });
//               await _pickScheduleDateTime();
//             },
//             highlight: needsAttention,
//           ),
//
//           // ── Confirmed schedule display ────────────────────────────────
//           if (isScheduled) ...[
//             SizedBox(height: 12.h),
//             Container(
//               padding: EdgeInsets.all(14.w),
//               decoration: BoxDecoration(
//                 color: Cart.green.withOpacity(0.06),
//                 borderRadius: BorderRadius.circular(12.r),
//                 border: Border.all(color: Cart.green.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.check_circle_rounded,
//                     color: Cart.green,
//                     size: 18.sp,
//                   ),
//                   SizedBox(width: 10.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Scheduled',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.w700,
//                             color: Cart.green,
//                           ),
//                         ),
//                         Text(
//                           '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  •  ${_selectedTime!.format(context)}',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Cart.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: _pickScheduleDateTime,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 10.w,
//                         vertical: 5.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Cart.violet.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(8.r),
//                         border: Border.all(color: Cart.violet.withOpacity(0.2)),
//                       ),
//                       child: Text(
//                         'Edit',
//                         style: TextStyle(
//                           fontSize: 11.sp,
//                           color: Cart.violet,
//                           fontWeight: FontWeight.w600,
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
//   Widget _timingChip(
//     String label,
//     bool selected,
//     VoidCallback onTap, {
//     bool highlight = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
//         decoration: BoxDecoration(
//           color: selected
//               ? Cart.violet
//               : highlight
//               ? Cart.amber.withOpacity(0.12)
//               : Cart.bg,
//           borderRadius: BorderRadius.circular(10.r),
//           border: Border.all(
//             color: selected
//                 ? Cart.violet
//                 : highlight
//                 ? Cart.amber
//                 : Cart.border,
//             width: highlight && !selected ? 1.5 : 1,
//           ),
//           boxShadow: highlight && !selected
//               ? [
//                   BoxShadow(
//                     color: Cart.amber.withOpacity(0.25),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (highlight && !selected) ...[
//               Icon(Icons.touch_app_rounded, size: 13.sp, color: Cart.amber),
//               SizedBox(width: 5.w),
//             ],
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w600,
//                 color: selected
//                     ? Colors.white
//                     : highlight
//                     ? Cart.amber
//                     : Cart.textSecondary,
//               ),
//             ),
//           ],
//         ),
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
//             primary: Cart.violet,
//             onPrimary: Colors.white,
//             onSurface: Colors.black,
//           ),
//           textButtonTheme: TextButtonThemeData(
//             style: TextButton.styleFrom(foregroundColor: Cart.violet),
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
//               dialHandColor: Cart.violet,
//               dialBackgroundColor: Cart.bg,
//             ),
//             colorScheme: const ColorScheme.light(
//               primary: Cart.violet,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: Cart.violet),
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
//               color: Cart.violet.withOpacity(0.30),
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
//     // When items require scheduling, block the button until date & time are set
//     final scheduleRequired = mustSchedule;
//     final schedulePending =
//         scheduleRequired && (_selectedDate == null || _selectedTime == null);
//
//     return Column(
//       children: [
//         // Hint shown only when schedule is required but not yet selected
//         if (schedulePending) ...[
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               color: Cart.amber.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: Cart.amber.withOpacity(0.3)),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.lock_clock_outlined, size: 15.sp, color: Cart.amber),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     'Select a schedule date & time above to place your order.',
//                     style: TextStyle(fontSize: 12.sp, color: Color(0xFF92580A)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 10.h),
//         ],
//         SizedBox(
//           width: double.infinity,
//           height: 54.h,
//           child: ElevatedButton(
//             onPressed: (isPlacingOrder || schedulePending) ? null : placeOrder,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: schedulePending ? Cart.textMuted : Cart.green,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//               shadowColor: schedulePending
//                   ? Colors.transparent
//                   : Cart.green.withOpacity(0.3),
//               disabledBackgroundColor: Cart.textMuted,
//               disabledForegroundColor: Colors.white70,
//             ),
//             child: isPlacingOrder
//                 ? SizedBox(
//                     width: 20.r,
//                     height: 20.r,
//                     child: const CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2.5,
//                     ),
//                   )
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         schedulePending
//                             ? Icons.lock_outline_rounded
//                             : Icons.check_circle_rounded,
//                         size: 18.sp,
//                       ),
//                       SizedBox(width: 8.w),
//                       Text(
//                         schedulePending
//                             ? 'Schedule to Place Order'
//                             : 'Place Order',
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       SizedBox(width: 8.w),
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 10.w,
//                           vertical: 4.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(20.r),
//                         ),
//                         child: Text(
//                           '₹${(cartData?.grandTotal ?? 0).toStringAsFixed(2)}',
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ],
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
//               color: Cart.violetDim,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.shopping_bag_outlined,
//               size: 40.sp,
//               color: Cart.violet,
//             ),
//           ),
//           SizedBox(height: 20.h),
//           Text(
//             'Your cart is empty',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w800,
//               color: Cart.textPrimary,
//             ),
//           ),
//           SizedBox(height: 6.h),
//           Text(
//             'Add some delicious items to get started',
//             style: TextStyle(fontSize: 13.sp, color: Cart.textSecondary),
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
//                 color: Cart.violet,
//                 borderRadius: BorderRadius.circular(14.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Cart.violet.withOpacity(0.3),
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
//         color: Cart.surface,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: Cart.border),
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
import 'food_invoice.dart';
import 'Menu/menu_screen.dart';

class Cart {
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
  // String? _orderType;
  final bool _isPlacingOrder = false;
  bool isCouponLoading = false;
  Set<String> selectedSubWallets = {};
  int userId = 0;
  List<Campaign> homepageAds = [];
  bool _isSummaryExpanded = false;

  bool hasUserSelectedOrderType = false;

  String _orderType = "";

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadWallet();
    _loadCart();
    _initCartSocket();
    _loadAds();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WebSocketManager().unsubscribeUserCart(userId);
    super.dispose();
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

  void _updateCartFromSocket(Map<String, dynamic> data) {
    print("🟡 RAW SOCKET DATA: $data");

    if (cartData == null) {
      print("❌ cartData is NULL → skipping update");
      return;
    }

    final List items = data['cartItems'] ?? [];
    print("📦 Incoming cart items count: ${items.length}");

    setState(() {
      cartData!.cartItems = items.map((json) {
        print("➡️ Processing item: $json");

        final idx = cartData!.cartItems.indexWhere(
          (i) => i.itemId == json['itemId'],
        );

        if (idx != -1) {
          final item = cartData!.cartItems[idx];

          print("🔁 Updating existing item: ${item.itemId}");
          print(
            "   OLD -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
          );

          item.quantity = json['quantity'] ?? item.quantity;
          item.totalPrice = (json['totalPrice'] ?? item.totalPrice).toDouble();
          item.price = (json['price'] ?? item.price).toDouble();
          item.packingCharges = (json['packingCharges'] ?? item.packingCharges)
              .toDouble();

          print(
            "   NEW -> qty:${item.quantity}, price:${item.price}, total:${item.totalPrice}",
          );

          return item;
        }

        print("🆕 New item added: ${json['itemId']}");
        return CartItem.fromJson(json);
      }).toList();

      // --------------------------
      // 💰 PRICE SUMMARY DEBUG
      // --------------------------
      cartData!.subtotal = (data['subtotal'] ?? 0).toDouble();
      cartData!.gstTotal = (data['gstTotal'] ?? 0).toDouble();
      cartData!.packingTotal = (data['packingTotal'] ?? 0).toDouble();
      cartData!.platformCharges = (data['platformCharges'] ?? 0).toDouble();
      cartData!.deliveryCharges = (data['deliveryCharges'] ?? 0).toDouble();
      cartData!.discountAmount = (data['discountAmount'] ?? 0).toDouble();
      cartData!.grandTotal = (data['grandTotal'] ?? 0).toDouble();
      cartData!.cgst = (data['cgst'] ?? 0).toDouble();
      cartData!.sgst = (data['sgst'] ?? 0).toDouble();

      print("💰 PRICE SUMMARY:");
      print("   Subtotal: ${cartData!.subtotal}");
      print("   GST: ${cartData!.gstTotal}");
      print("   Packing: ${cartData!.packingTotal}");
      print("   Platform: ${cartData!.platformCharges}");
      print("   Delivery: ${cartData!.deliveryCharges}");
      print("   Discount: ${cartData!.discountAmount}");
      print("   Grand Total: ${cartData!.grandTotal}");

      // --------------------------
      // 👤 USER INFO DEBUG
      // --------------------------
      cartData!.deliveryAddress =
          data['deliveryAddress'] ?? cartData!.deliveryAddress;
      cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
      cartData!.name = data['name'] ?? cartData!.name;
      cartData!.couponCode = data['couponCode'];

      print("👤 USER INFO:");
      print("   Name: ${cartData!.name}");
      print("   Mobile: ${cartData!.mobileNo}");
      print("   Address: ${cartData!.deliveryAddress}");
      print("   Coupon: ${cartData!.couponCode}");

      // --------------------------
      // ⏰ ORDER TYPE DEBUG
      // --------------------------
      // if (hasScheduledItem) {
      //   _orderType = "schedule";
      //   hasUserSelectedOrderType = true;
      //   print("⏰ Scheduled item detected → orderType = schedule");
      // }
    });

    print("✅ Cart UI updated successfully\n");
  }

  // bool get hasScheduledItem {
  //   if (cartData == null || cartData!.cartItems.isEmpty) return false;
  //
  //   return cartData!.cartItems.any((item) => item.shedule == true);
  // }
  //
  // bool get mustSchedule {
  //   return cartData?.cartItems.any((e) => e.shedule == true) ?? false;
  // }

  // Future<void> _loadCart() async {
  //   setState(() => isLoading = true);
  //   try {
  //     final c = await food_Authservice.fetchCart();
  //     if (mounted) {
  //       setState(() {
  //         cartData = c;
  //         appliedCouponCode = c?.couponCode;
  //         isLoading = false;
  //       });
  //     }
  //   } catch (_) {
  //     if (mounted) setState(() => isLoading = false);
  //   }
  // }

  Future<void> _loadCart() async {
    setState(() => isLoading = true);
    try {
      final fetchedCart = await food_Authservice.fetchCart();
      if (mounted) {
        setState(() {
          cartData = fetchedCart;
          appliedCouponCode = fetchedCart?.couponCode;
          isLoading = false;

          /// 🔥 AUTO SWITCH TO SCHEDULE
          // if (hasScheduledItem) {
          //   _orderType = "schedule";
          //   hasUserSelectedOrderType = true;
          // }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
      }
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
    // final mustSchedule = cartData!.cartItems.any((i) => i.shedule);
    final effectiveOrderType = _orderType;

    // ✅ Block if schedule required but no date/time picked
    // if ((mustSchedule || effectiveOrderType == "schedule") &&
    //     (_selectedDate == null || _selectedTime == null)) {
    //   AppAlert.error(
    //     context,
    //     "⚠️ Please select a date & time to schedule your order",
    //   );
    //   return;
    // }

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
      final bool isScheduled = _selectedDate != null || _selectedTime != null;

      if (selectedPaymentMethod == "Online_Payment") {
        final amount = (cartData?.grandTotal ?? 0).toDouble();
        final orderId = await food_Authservice.createOrder(amount);
        if (orderId == null) {
          AppAlert.error(context, "❌ Failed to create payment order");
          return;
        }
        final rp = RazorpayService();
        rp.onSuccess = (res) async {
          final pid = res.paymentId!;
          final oid = res.orderId!;
          final ok = isScheduled
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
          if (ok) {
            final captured = await food_Authservice.capturePayment(
              paymentId: pid,
              amount: amount,
            );
            if (!captured) {
              AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
            }
          } else {
            AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
          }
        };
        rp.onError = (res) =>
            AppAlert.error(context, "Payment failed: ${res.message}");
        rp.startPayment(
          orderId: orderId,
          amount: amount,
          description: "Online Payment via Razorpay",
        );
        return;
      }

      final amt = cartData!.grandTotal.toDouble();
      if (isScheduled) {
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
    } catch (_) {
      AppAlert.error(context, "Error placing order");
    } finally {
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
    if (cartId == null) {
      AppAlert.error(context, "Cart session expired. Please try again.");
      return false;
    }
    try {
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
        );
        return true;
      }
      // ✅ backend returned 200 but no orderId — show whatever message came back
      final msg =
          result['message'] ??
          result['error'] ??
          "Order could not be confirmed";
      AppAlert.error(context, msg.toString());
      return false;
    } catch (e) {
      // ✅ backend non-200 error message lands here
      AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  Future<bool> _placeDirectOrder({
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');
    if (cartId == null) {
      AppAlert.error(context, "Cart session expired. Please try again.");
      return false;
    }
    try {
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
        );
        return true;
      }
      // ✅ backend returned 200 but no orderId
      final msg =
          result['message'] ??
          result['error'] ??
          "Order could not be confirmed";
      AppAlert.error(context, msg.toString());
      return false;
    } catch (e) {
      // ✅ backend non-200 error message lands here
      AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
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
    try {
      final c = await food_Authservice.fetchCart();
      final w = await subscription_AuthService.fetchWallet();
      if (!mounted) return;
      setState(() {
        cartData = c;
        wallet = w;
      });
    } catch (e) {
      if (mounted) {
        AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
      }
    }
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
          backgroundColor: Cart.bg,
          appBar: _buildAppBar(),
          body: AuthGuard(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: Cart.violet,
                backgroundColor: Cart.surface,
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
                                    height: 160,
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
        if (_isPlacingOrder)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: Cart.violet),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Cart.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Review Your Cart',
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: Cart.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
        ), // iOS-style back arrow
        color: Cart.textPrimary,
        onPressed: () => Navigator.of(context).pop(),
      ),
      iconTheme: const IconThemeData(color: Cart.textPrimary),
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
              color: Cart.red.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Cart.red.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              size: 18.sp,
              color: Cart.red,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Cart.border),
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
        color: Cart.textPrimary,
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
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🟢 ITEM NAME (fixed width)
                      SizedBox(
                        width: 140.w, // adjust based on UI
                        child: Text(
                          item.dishName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Cart.textPrimary,
                          ),
                        ),
                      ),

                      const Spacer(), // pushes everything nicely
                      // 🟡 QTY CONTROL (fixed width)
                      SizedBox(
                        width: 100.w, // ✅ fixed width for all rows
                        child: Center(
                          child: _buildQtyControl(item),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // 🔴 PRICE (fixed + right aligned)
                      SizedBox(
                        width: 90.w, // ✅ increase width
                        child: Text(
                          '₹${item.totalPrice.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis, // safety
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Cart.violet,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) Divider(height: 1, color: Cart.border),
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
        color: Cart.bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Cart.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            Icons.remove_rounded,
            Cart.red,
            () => changeQuantity(item, item.quantity - 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Cart.textPrimary,
              ),
            ),
          ),
          _qtyBtn(
            Icons.add_rounded,
            Cart.green,
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
          style: TextStyle(fontSize: 13.sp, color: Cart.textSecondary),
          children: [
            TextSpan(
              text: 'Add more items',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Cart.violet,
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
                color: applied ? Cart.green.withOpacity(0.10) : Cart.violetDim,
                shape: BoxShape.circle,
              ),
              child: Icon(
                applied
                    ? Icons.check_circle_rounded
                    : Icons.local_offer_rounded,
                size: 18.sp,
                color: applied ? Cart.green : Cart.violet,
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
                      color: applied ? Cart.green : Cart.textPrimary,
                    ),
                  ),
                  if (applied)
                    Text(
                      appliedCouponCode ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Cart.textSecondary,
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
                    color: Cart.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Cart.red.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Cart.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: Cart.textMuted,
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
            height: MediaQuery.of(ctx).size.height,
            decoration: BoxDecoration(
              color: Cart.bg,
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
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Cart.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(bottom: BorderSide(color: Cart.border)),
      ),
      child: Row(
        children: [
          Text(
            'Available Coupons',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Cart.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Cart.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: Cart.textSecondary,
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
        ? Cart.red
        : isMismatch
        ? Cart.amber
        : Cart.green;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Cart.surface,
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
                color: Cart.textPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Cart.violet.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                coupon.couponType,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Cart.violet,
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
                  style: TextStyle(fontSize: 11.sp, color: Cart.textMuted),
                ),
            ],
          ),
        ),
        trailing: isDisabled
            ? Icon(Icons.block_rounded, color: color, size: 18.sp)
            : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: Cart.textMuted,
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
            color: Cart.textMuted,
          ),
          SizedBox(height: 12.h),
          Text(
            'No coupons available',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Cart.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Check back later for new offers',
            style: TextStyle(fontSize: 12.sp, color: Cart.textMuted),
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

    final addressState = ref.watch(addressProvider);

    final displayAddress = (addressState.fullAddress).trim().isNotEmpty
        ? addressState.fullAddress
        : (cartData?.deliveryAddress ?? '');

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
                    ? Cart.violet.withOpacity(0.08)
                    : Cart.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 20.sp,
                color: hasAddr ? Cart.violet : Cart.red,
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
                      color: Cart.textPrimary,
                    ),
                  ),
                  if (hasAddr) ...[
                    SizedBox(height: 2.h),
                    Text(
                      [
                        displayAddress,
                        cartData?.name,
                        cartData?.mobileNo,
                      ].where((e) => e.toString().trim().isNotEmpty).join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Tap to change',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Cart.violet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: Cart.textMuted,
            ),
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
    final saved = cartData?.savedAmount ?? 0;
    double.parse((saved + grandTotal).toStringAsFixed(2));

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
                    color: Cart.violetDim,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 18.sp,
                    color: Cart.violet,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Cart.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isSummaryExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Cart.textSecondary,
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
              children: [
                SizedBox(height: 12.h),
                Divider(height: 1, color: Cart.border),
                SizedBox(height: 10.h),
                _summaryRow('Subtotal', subtotal),
                _summaryRow('Platform Charges', platform),
                if (orderType.toUpperCase() == 'DELIVERY' ||
                    orderType.toUpperCase() == 'TAKEAWAY')
                  _summaryRow('Packing Charges', packing),
                if (orderType.toUpperCase() == 'DELIVERY')
                  _summaryRow('Delivery Charges', delivery),
                if (discount > 0)
                  _summaryRow('Discount', -discount, color: Cart.green),
                _summaryRow('SGST', gst / 2),
                _summaryRow('CGST', gst / 2),
                SizedBox(height: 4.h),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),

          Divider(height: 16.h, color: Cart.border),

          // Grand total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: Cart.textPrimary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // if (saved > 0)
                  //   Text(
                  //     '₹${_fmt(actualGrand)}',
                  //     style: TextStyle(
                  //       fontSize: 11.sp,
                  //       color: Cart.red,
                  //       decoration: TextDecoration.lineThrough,
                  //     ),
                  //   ),
                  Text(
                    '₹${_fmt(grandTotal)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Cart.violet,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // if (saved > 0) ...[
          //   SizedBox(height: 6.h),
          //   Container(
          //     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          //     decoration: BoxDecoration(
          //       color: Cart.green.withOpacity(0.08),
          //       borderRadius: BorderRadius.circular(20.r),
          //     ),
          //     child: Text(
          //       '🎉 You saved ₹${_fmt(saved)}!',
          //       style: TextStyle(
          //         fontSize: 11.sp,
          //         color: Cart.green,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ],
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
            style: TextStyle(fontSize: 12.sp, color: Cart.textSecondary),
          ),
          Text(
            value < 0 ? '-₹${_fmt(-value)}' : '₹${_fmt(value)}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color ?? Cart.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Schedule order ──────────────────────────────────────────────────────
  Widget _buildScheduleOrder() {
    // final showNow = cartData!.cartItems.every((i) => !i.shedule);
    final isScheduled =
        _orderType == "schedule" &&
        _selectedDate != null &&
        _selectedTime != null;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 18.sp, color: Cart.violet),
              SizedBox(width: 8.w),
              Text(
                'Order Timing',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Cart.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // if (showNow) ...[
              //   _timingChip('Order Now', _orderType == 'now', () {
              //     setState(() {
              //       _orderType = 'now';
              //       _selectedDate = null;
              //       _selectedTime = null;
              //     });
              //   }),
              //   SizedBox(width: 10.w),
              // ],
              _timingChip('Schedule', _orderType == 'schedule', () async {
                setState(() {
                  _orderType = 'schedule';
                  _selectedDate = null;
                  _selectedTime = null;
                });
                await _pickScheduleDateTime();
              }),
            ],
          ),

          if (isScheduled) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Cart.green.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Cart.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Cart.green,
                    size: 18.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scheduled',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Cart.green,
                          ),
                        ),
                        Text(
                          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  •  ${_selectedTime!.format(context)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Cart.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickScheduleDateTime,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Cart.violet.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Cart.violet.withOpacity(0.2)),
                      ),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Cart.violet,
                          fontWeight: FontWeight.w600,
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

  // Widget _buildScheduleOrder() {
  //   // ✅ Read-only — never mutate _orderType here
  //   final mustSchedule =
  //       cartData?.cartItems.any((e) => e.shedule == true) ?? false;
  //   print("mustSchedule: ${cartData!.cartItems.any((e) => e.shedule == true)}");
  //   final effectiveOrderType = _orderType;
  //   final isScheduled =
  //       effectiveOrderType == "schedule" &&
  //       _selectedDate != null &&
  //       _selectedTime != null;
  //   if (mustSchedule && _orderType != "schedule") {
  //     _orderType = "schedule";
  //   }
  //
  //   print("mustSchedule: $mustSchedule");
  //
  //   return _card(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // ── Chips ───────────────────────────────────────────────
  //         Row(
  //           children: [
  //             // ❌ HIDE Order Now completely
  //             if (!mustSchedule) ...[
  //               _timingChip(
  //                 'Order Now',
  //                 _orderType == 'now',
  //                 onTap: () {
  //                   setState(() {
  //                     _orderType = 'now';
  //                     _selectedDate = null;
  //                     _selectedTime = null;
  //                   });
  //                 },
  //               ),
  //               SizedBox(width: 10),
  //             ],
  //
  //             // ✅ ALWAYS show Schedule
  //             _timingChip(
  //               'Schedule',
  //               _orderType == 'schedule',
  //               onTap: () async {
  //                 setState(() {
  //                   _orderType = 'schedule';
  //                 });
  //                 await _pickScheduleDateTime();
  //               },
  //             ),
  //           ],
  //         ),
  //
  //         // ── Amber warning ───────────────────────────────────────
  //         if (mustSchedule) ...[
  //           SizedBox(height: 8.h),
  //           Container(
  //             width: double.infinity,
  //             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //             decoration: BoxDecoration(
  //               color: Cart.amber.withOpacity(0.08),
  //               borderRadius: BorderRadius.circular(8.r),
  //               border: Border.all(color: Cart.amber.withOpacity(0.3)),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   Icons.info_outline_rounded,
  //                   size: 14.sp,
  //                   color: Cart.amber,
  //                 ),
  //                 SizedBox(width: 6.w),
  //                 Expanded(
  //                   child: Text(
  //                     'Some items in your cart require scheduling.',
  //                     style: TextStyle(fontSize: 11.sp, color: Cart.amber),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //
  //         // ── Scheduled confirmation ──────────────────────────────
  //         if (isScheduled) ...[
  //           SizedBox(height: 12.h),
  //           Container(
  //             padding: EdgeInsets.all(14.w),
  //             decoration: BoxDecoration(
  //               color: Cart.green.withOpacity(0.06),
  //               borderRadius: BorderRadius.circular(12.r),
  //               border: Border.all(color: Cart.green.withOpacity(0.3)),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   Icons.check_circle_rounded,
  //                   color: Cart.green,
  //                   size: 18.sp,
  //                 ),
  //                 SizedBox(width: 10.w),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Scheduled',
  //                         style: TextStyle(
  //                           fontSize: 12.sp,
  //                           fontWeight: FontWeight.w700,
  //                           color: Cart.green,
  //                         ),
  //                       ),
  //                       Text(
  //                         '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  •  ${_selectedTime!.format(context)}',
  //                         style: TextStyle(
  //                           fontSize: 12.sp,
  //                           color: Cart.textSecondary,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 GestureDetector(
  //                   onTap: _pickScheduleDateTime,
  //                   child: Container(
  //                     padding: EdgeInsets.symmetric(
  //                       horizontal: 10.w,
  //                       vertical: 5.h,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: Cart.violet.withOpacity(0.08),
  //                       borderRadius: BorderRadius.circular(8.r),
  //                       border: Border.all(color: Cart.violet.withOpacity(0.2)),
  //                     ),
  //                     child: Text(
  //                       'Edit',
  //                       style: TextStyle(
  //                         fontSize: 11.sp,
  //                         color: Cart.violet,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }
  Widget _timingChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? Cart.violet : Cart.bg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: selected ? Cart.violet : Cart.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Cart.textSecondary,
          ),
        ),
      ),
    );
  }

  // Widget _timingChip(
  //   String label,
  //   bool selected, {
  //   required VoidCallback? onTap,
  //   bool isDisabled = false,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 180),
  //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
  //       decoration: BoxDecoration(
  //         color: isDisabled
  //             ? Cart.border
  //             : selected
  //             ? Cart.violet
  //             : Cart.bg,
  //         borderRadius: BorderRadius.circular(10.r),
  //         border: Border.all(
  //           color: isDisabled
  //               ? Cart.textMuted
  //               : selected
  //               ? Cart.violet
  //               : Cart.border,
  //         ),
  //       ),
  //       child: Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 12.sp,
  //           fontWeight: FontWeight.w600,
  //           color: isDisabled
  //               ? Cart.textMuted
  //               : selected
  //               ? Colors.white
  //               : Cart.textSecondary,
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
            primary: Cart.violet,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Cart.violet),
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
              dialHandColor: Cart.violet,
              dialBackgroundColor: Cart.bg,
            ),
            colorScheme: const ColorScheme.light(
              primary: Cart.violet,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Cart.violet),
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
              color: Cart.violet.withOpacity(0.30),
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
          backgroundColor: Cart.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          shadowColor: Cart.green.withOpacity(0.3),
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
              color: Cart.violetDim,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 40.sp,
              color: Cart.violet,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Cart.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Add some delicious items to get started',
            style: TextStyle(fontSize: 13.sp, color: Cart.textSecondary),
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
                color: Cart.violet,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Cart.violet.withOpacity(0.3),
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
        color: Cart.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Cart.border),
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
