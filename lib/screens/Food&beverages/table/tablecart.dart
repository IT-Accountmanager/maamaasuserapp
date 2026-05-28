// import 'package:maamaas/screens/Food&beverages/table/tablecartpayment.dart';
// import '../../../Services/Auth_service/Subscription_authservice.dart';
// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import '../../../widgets/widgets/food/currentcart_notifier.dart';
// import '../../../Services/paymentservice/razorpayservice.dart';
// import '../../../Services/websockets/web_socket_manager.dart';
// import '../../../Services/App_color_service/app_colours.dart';
// import '../../../Services/Auth_service/food_authservice.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../Models/subscrptions/coupon_model.dart';
// import '../../../Models/subscrptions/wallet_model.dart';
// import '../../../Models/food/tablecartmodel.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
// import '../food_invoice.dart';
// import 'table_menu.dart';
// import 'dart:async';
//
// enum PaymentOverlayState {
//   none,
//   placingOrder,
//   openingGateway,
//   processing,
//   success,
// }
//
// class cartuser {
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
// class tablecart extends StatefulWidget {
//   final int seatingId;
//   const tablecart({super.key, required this.seatingId});
//
//   @override
//   State<tablecart> createState() => _tablecartState();
// }
//
// // ignore: camel_case_types
// class _tablecartState extends State<tablecart> {
//   TableCartModel? tableCartData;
//   String selectedPaymentMethod = "";
//   String selectedSubWallet = "";
//   bool isPlacingOrder = false;
//   Map<String, dynamic>? checkoutData;
//   List<CartItem> _cartItems = [];
//   bool _isLoading = true;
//   String? _error;
//   bool isSent = false;
//   bool isExpanded = false;
//   bool isServiceChargeApplied = true;
//   Wallet? wallet;
//   int? appliedCouponId;
//   String? appliedCouponCode;
//   bool send = false;
//   final Map<int, bool> _isSendingMap = {};
//   late ScrollController _scrollController;
//   bool isCouponLoading = false;
//   final Map<int, TextEditingController> _noteControllers = {};
//   Set<String> selectedSubWallets = {};
//   PaymentOverlayState _overlayState = PaymentOverlayState.none;
//   // Timer? _statusTimer;
//   int selectedQuantity = 0;
//
//   final WebSocketManager _wsManager = WebSocketManager();
//   int? _userId;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _loadWallet();
//     _loadCartItems();
//     _initializeData();
//
//     _initializeRealtimeCart();
//   }
//
//   @override
//   void dispose() {
//     if (_userId != null) {
//       _wsManager.unsubscribeUserCart(_userId!);
//     }
//
//     _scrollController.dispose();
//
//     for (final controller in _noteControllers.values) {
//       controller.dispose();
//     }
//
//     super.dispose();
//   }
//
//   Future<void> _initializeRealtimeCart() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final userId = prefs.getInt('userId');
//
//     if (userId == null) {
//       debugPrint('❌ userId not found for cart websocket');
//       return;
//     }
//
//     _userId = userId;
//
//     debugPrint('🚀 Initializing realtime cart for userId: $userId');
//
//     _wsManager.subscribeUserCart(userId, (data) async {
//       debugPrint('📦 LIVE CART UPDATE: $data');
//
//       if (!mounted) return;
//
//       try {
//         final updatedCart = TableCartModel.fromJson(data);
//
//         setState(() {
//           tableCartData = updatedCart;
//           // _cartItems = updatedCart.cartItems;
//           _cartItems = List<CartItem>.from(updatedCart.cartItems);
//
//           final delivered =
//               updatedCart.cartItems.isNotEmpty &&
//               updatedCart.cartItems
//                   .where((i) => i.orderStatus != "CANCELLED")
//                   .every((i) => i.orderStatus == "DELIVERED");
//
//           if (!delivered) {
//             isExpanded = false;
//           }
//
//           _isLoading = false;
//         });
//
//         debugPrint('✅ UI updated from websocket');
//       } catch (e) {
//         debugPrint('❌ WebSocket cart parse error: $e');
//       }
//     });
//   }
//
//   void scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: Duration(milliseconds: 400),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void scrollToTop() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           0,
//           duration: Duration(milliseconds: 400),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   Future<void> _loadWallet() async {
//     final fetchedWallet = await subscription_AuthService.fetchWallet();
//     setState(() {
//       wallet = fetchedWallet;
//     });
//   }
//
//   // Future<void> _onRefresh() async {
//   //   final updatedCarts = await food_Authservice.fetchTableCart(
//   //     // widget.seatingId,
//   //   );
//   //   final updatedWallet = await subscription_AuthService.fetchWallet();
//   //
//   //   if (!mounted) return;
//   //
//   //   setState(() {
//   //     tableCartData = updatedCarts.isNotEmpty ? updatedCarts.first : null;
//   //     wallet = updatedWallet;
//   //   });
//   // }
//   Future<void> _onRefresh() async {
//     try {
//       final updatedCarts = await food_Authservice.fetchTableCart();
//       final updatedWallet = await subscription_AuthService.fetchWallet();
//
//       if (!mounted) return;
//
//       setState(() {
//         if (updatedCarts.isNotEmpty) {
//           final freshCart = updatedCarts.first;
//
//           tableCartData = freshCart;
//
//           // ✅ IMPORTANT
//           _cartItems = List<CartItem>.from(freshCart.cartItems);
//
//           // ✅ Update generated bill state instantly
//           final delivered =
//               freshCart.cartItems.isNotEmpty &&
//               freshCart.cartItems
//                   .where((i) => i.orderStatus != "CANCELLED")
//                   .every((i) => i.orderStatus == "DELIVERED");
//
//           if (!delivered) {
//             isExpanded = false;
//           }
//         } else {
//           tableCartData = null;
//           _cartItems = [];
//         }
//
//         wallet = updatedWallet;
//       });
//     } catch (e) {
//       debugPrint("❌ Refresh Error: $e");
//     }
//   }
//
//   Future<void> _initializeData() async {
//     try {
//       final data = await food_Authservice.fetchTableCart();
//       if (data.isEmpty) {
//         return;
//       }
//       if (!mounted) return;
//       setState(() {
//         tableCartData = data.first;
//       });
//       // ignore: empty_catches
//     } catch (e) {}
//   }
//
//   Future<bool> _deleteCart() async {
//     try {
//       final success = await food_Authservice.deleteTableDineInCart();
//
//       if (!mounted) return false;
//
//       if (success) {
//         CartNotifier.count.value = 0;
//
//         AppAlert.success(context, "🗑 Cart deleted successfully");
//
//         setState(() {
//           tableCartData = null;
//           _cartItems.clear();
//         });
//
//         return true;
//       }
//
//       return false;
//     } catch (e) {
//       if (!mounted) return false;
//
//       AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
//
//       return false;
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
//     if (selectedPaymentMethod.isEmpty) {
//       AppAlert.error(context, "⚠️ Please select a payment method");
//       return;
//     }
//
//     // ❌ Wallet selected but no sub-wallet chosen
//     if (selectedPaymentMethod == "Maamaas_Wallet" &&
//         selectedSubWallets.isEmpty) {
//       AppAlert.error(context, "⚠️ Please select at least one wallet type");
//       return;
//     }
//
//     // ❌ Wallet balance check
//     if (selectedPaymentMethod == "Maamaas_Wallet") {
//       final wb = getSelectedWalletBalance();
//       final gt = (tableCartData?.grandTotal ?? 0).toDouble();
//
//       if (wb < gt) {
//         AppAlert.error(
//           context,
//           "❌ Insufficient wallet balance\nWallet: ₹${wb.toStringAsFixed(2)}\nOrder Total: ₹${gt.toStringAsFixed(2)}",
//         );
//         return;
//       }
//     }
//
//     setState(() => isPlacingOrder = true);
//     try {
//       if (selectedPaymentMethod == "Online_Payment") {
//         final amount = (tableCartData?.grandTotal ?? 0).toDouble();
//
//         // ── Show "opening gateway" overlay while createOrder API runs ────
//         if (mounted) {
//           setState(() => _overlayState = PaymentOverlayState.openingGateway);
//         }
//         final orderId = await food_Authservice.createOrder(amount);
//         if (mounted) {
//           setState(() => _overlayState = PaymentOverlayState.openingGateway);
//         }
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
//           if (mounted) {
//             setState(() => _overlayState = PaymentOverlayState.processing);
//           }
//           await _callOrderApi(
//             paymentMethod: "Online_Payment",
//             razorpayPaymentId: pid,
//             razorpayOrderId: oid,
//             amount: amount,
//           );
//
//           // Reset overlay after order API completes
//           if (mounted) {
//             setState(() => _overlayState = PaymentOverlayState.none);
//           }
//
//           if (mounted) {
//             food_Authservice
//                 .capturePayment(paymentId: pid, amount: amount)
//                 // ignore: body_might_complete_normally_catch_error
//                 .catchError((_) {});
//           } else {
//             AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
//           }
//         };
//         rp.onError = (res) {
//           if (mounted) {
//             setState(() {
//               _overlayState = PaymentOverlayState.none;
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
//       final amt = tableCartData!.grandTotal.toDouble();
//       {
//         await _callOrderApi(
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
//       // Reset overlay on any error so UI never gets stuck
//       if (mounted) {
//         setState(() {
//           _overlayState = PaymentOverlayState.none;
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
//   /*when items are cancelled or delivered
//   * this condition is used to show generated bill button*/
//
//   bool get allItemsDelivered {
//     if (tableCartData == null) return false;
//
//     return tableCartData!.cartItems.isNotEmpty &&
//         tableCartData!.cartItems
//             .where((i) => i.orderStatus != "CANCELLED")
//             .every((i) => i.orderStatus == "DELIVERED");
//   }
//
//   /*this condtion is used when items are sent to confirmed then user can not clear the cart fully*/
//
//   bool get canDeleteCart {
//     if (tableCartData == null) return false;
//
//     // Show delete only when ALL orderStatus are null
//     return tableCartData!.cartItems.isNotEmpty &&
//         tableCartData!.cartItems.every((item) => item.orderStatus == null);
//   }
//
//   List<String> mapWalletsToEnum(List<String> selectedWallets) {
//     return selectedWallets.map((wallet) {
//       switch (wallet) {
//         case "Cashbacks":
//           return "CASHBACK";
//         case "Self Loaded":
//           return "SELF_LOADED";
//         case "Postpaid used amount":
//           return "POST_PAID";
//         case "Company Loaded":
//           return "COMPANY_LOADED";
//         case "Earned Amount":
//           return "EARNED_AMOUNT";
//         default:
//           return wallet.toUpperCase().replaceAll(' ', '_');
//       }
//     }).toList();
//   }
//
//   Future<void> _callOrderApi({
//     required String paymentMethod,
//     required String razorpayPaymentId,
//     required String razorpayOrderId,
//     required double amount,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartId = prefs.getInt('cartId');
//
//     if (cartId == null) return;
//
//     final result = await food_Authservice.placeDirectOrder(
//       cartId: cartId,
//       paymentMethod: paymentMethod,
//       razorpayPaymentId: razorpayPaymentId,
//       razorpayOrderId: razorpayOrderId,
//       walletTypes: mapWalletsToEnum(selectedSubWallets.toList()), // <-- FIXED
//       amount: amount,
//     );
//
//     if (result['success'] == false) {
//       AppAlert.error(context, result['error'] ?? "Unknown error");
//       return;
//     }
//     final orderId = result['orderId'];
//     if (orderId == null || orderId is! int) {
//       AppAlert.error(context, "⚠️ Invalid Order ID returned");
//       return;
//     }
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => food_Invoice(orderId: orderId)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return Stack(
//       children: [
//         Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(50),
//             child: AppBar(
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               title: const Text("Review Your Cart"),
//               backgroundColor: Colors.white,
//               centerTitle: true,
//
//               actions: [
//                 // if (canDeleteCart)
//                 IconButton(
//                   icon: const Icon(
//                     Icons.delete_outline_rounded,
//                     color: Colors.red,
//                   ),
//                   onPressed: () async {
//                     final confirm = await showDialog<bool>(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text("Delete Cart"),
//                         content: const Text(
//                           "Are you sure you want to clear your cart?",
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context, false),
//                             child: const Text("Cancel"),
//                           ),
//                           TextButton(
//                             onPressed: () => Navigator.pop(context, true),
//                             child: const Text(
//                               "Clear",
//                               style: TextStyle(color: Colors.red),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//
//                     if (confirm == true) {
//                       final vendorId = tableCartData?.vendorId;
//                       final seatingId = tableCartData?.seatingId;
//
//                       final deleted = await _deleteCart();
//
//                       if (!mounted) return;
//
//                       // ✅ Navigate ONLY when delete succeeds
//                       if (deleted && vendorId != null && seatingId != null) {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => tablemneuScreen(
//                               vendorId: vendorId,
//                               seatingId: seatingId,
//                             ),
//                           ),
//                         );
//                       }
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//           body: SafeArea(
//             child: RefreshIndicator(
//               onRefresh: _onRefresh,
//               color: Colors.white,
//               backgroundColor: Colors.blueAccent,
//               displacement: 40,
//               strokeWidth: 3,
//               child: SingleChildScrollView(
//                 controller: _scrollController,
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (!_isLoading &&
//                         (tableCartData == null ||
//                             tableCartData!.cartItems.isEmpty))
//                       _buildEmptyCart()
//                     else ...[
//                       _buildCartItems(context),
//                       SizedBox(height: 5.h),
//                       _buildaddmoretext(context),
//                       SizedBox(height: 12.h),
//                       if (tableCartData != null &&
//                           tableCartData!.cartItems.isNotEmpty) ...[
//                         if (allItemsDelivered) _buildTableCheckoutCard(),
//                         SizedBox(height: 12.h),
//                         if (isExpanded) ...[
//                           _buildCouponRow(),
//                           SizedBox(height: 12.h),
//                           _buildsummaryCard(theme, colorScheme),
//                         ],
//                       ],
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         if (_overlayState != PaymentOverlayState.none)
//           Positioned.fill(
//             child: AbsorbPointer(
//               child: Material(
//                 type: MaterialType.transparency,
//                 child: Container(
//                   // ignore: deprecated_member_use
//                   color: Colors.black.withOpacity(0.7), // stronger block
//                   child: Center(child: _overlayContent()),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _overlayContent() {
//     switch (_overlayState) {
//       case PaymentOverlayState.placingOrder:
//         return _dialogLoader("Placing your order...");
//       case PaymentOverlayState.openingGateway:
//         return _dialogLoader("Opening payment gateway...");
//       case PaymentOverlayState.processing:
//         return _dialogLoader("Processing payment...");
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   Widget _dialogLoader(String text) {
//     return Material(
//       color: Colors.transparent,
//       child: Container(
//         key: ValueKey(text), // ✅ VERY IMPORTANT (forces rebuild)
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 14),
//             DefaultTextStyle(
//               // ✅ FIXES TEXT RENDER BUG
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 decoration: TextDecoration.none,
//               ),
//               child: Text(text),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyCart() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
//           SizedBox(height: 16.h),
//           Text(
//             'Your cart is empty',
//             style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Add some delicious items',
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // final Map<int, bool> _sentStatus = {};
//
//   Future<void> _loadCartItems({int? updatedItemId}) async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     try {
//       final result = await food_Authservice.fetchTableCart();
//       if (result.isNotEmpty) {
//         final freshCart = result.first;
//         final fetchedItems = freshCart.cartItems;
//         setState(() {
//           // Always sync tableCartData so totals (grandTotal, GST, etc.) update
//           tableCartData = freshCart;
//           final delivered =
//               freshCart.cartItems.isNotEmpty &&
//               freshCart.cartItems
//                   .where((i) => i.orderStatus != "CANCELLED")
//                   .every((i) => i.orderStatus == "DELIVERED");
//
//           if (!delivered) {
//             isExpanded = false;
//           }
//           if (updatedItemId != null) {
//             final updatedItem = fetchedItems.firstWhere(
//               (item) => item.itemId == updatedItemId,
//               orElse: () => CartItem.empty(),
//             );
//             final index = _cartItems.indexWhere(
//               (item) => item.itemId == updatedItemId,
//             );
//             if (index != -1 && updatedItem.itemId != 0) {
//               _cartItems[index] = updatedItem;
//             } else {
//               _cartItems = fetchedItems;
//             }
//           } else {
//             _cartItems = fetchedItems;
//           }
//           _isLoading = false;
//           // for (var item in _cartItems) {
//           //   _sentStatus[item.itemId] = item.orderStatus == 'PENDING';
//           // }
//         });
//       } else {
//         setState(() {
//           _cartItems = [];
//           tableCartData = null;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   Widget _buildCartItems(BuildContext context) {
//     if (_isLoading) {
//       return Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(
//             AppColors.of(context).primary,
//           ),
//         ),
//       );
//     }
//
//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 48, color: Colors.red),
//             SizedBox(height: 16),
//             Text(
//               "Error loading cart",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             SizedBox(height: 8),
//             Text(
//               _error!,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadCartItems,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.of(context).primary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: Text("Try Again", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_cartItems.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.shopping_cart_outlined,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//             SizedBox(height: 16),
//             Text(
//               "Your cart is empty",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Add some delicious items to get started",
//               style: TextStyle(color: Colors.grey[500]),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final subtotal = _cartItems.fold<double>(
//       0.0,
//       (sum, item) => sum + item.totalPrice,
//     );
//
//     final orderedItems = _cartItems
//         .where((item) => item.orderStatus != null)
//         .toList();
//
//     final pendingItems = _cartItems
//         .where((item) => item.orderStatus == null)
//         .toList();
//
//     final displayItems = [...orderedItems, ...pendingItems];
//
//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//       shadowColor: Colors.black,
//       child: Padding(
//         padding: EdgeInsets.all(12.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   "Table No: ${tableCartData?.tableCode ?? ''}", // null-safe
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.of(context).primary,
//                   ),
//                 ),
//               ],
//             ),
//             // ),
//             Divider(height: 24, thickness: 1, color: Colors.grey[200]),
//
//             ...displayItems.map((item) {
//               final bool isLastItem = item == _cartItems.last;
//
//               return Container(
//                 key: ValueKey(
//                   '${item.itemId}_${item.orderStatus}_${item.quantity}',
//                 ),
//                 margin: EdgeInsets.only(bottom: isLastItem ? 0 : 12),
//                 child: Column(
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               /// LEFT SIDE
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       item.dishName,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 10,
//                                             vertical: 6,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: const Color(0xFFE8F5E9),
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                           child: Text(
//                                             "₹${item.price}",
//                                             style: const TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                               color: Color(0xFF2E7D32),
//                                             ),
//                                           ),
//                                         ),
//                                         if (item.orderStatus != null) ...[
//                                           Text(
//                                             "Quantity: ${item.quantity}",
//                                             style: const TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                               color: Color(0xFF2E7D32),
//                                             ),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//
//                               const SizedBox(width: 12),
//
//                               if (item.orderStatus == null) ...[
//                                 QuantityControl(
//                                   key: ValueKey(
//                                     '${item.itemId}_${item.orderStatus}_${item.quantity}',
//                                   ),
//                                   item: item,
//                                   onQuantityChanged: () {
//                                     setState(() {});
//                                   },
//                                 ),
//
//                                 const SizedBox(width: 10),
//
//                                 SendButton(
//                                   item: item,
//                                   isSending: _isSendingMap[item.itemId] == true,
//                                   onSend: () async {
//                                     if (_isSendingMap[item.itemId] == true)
//                                       return;
//
//                                     final note = _getNoteController(
//                                       item,
//                                     ).text.trim();
//
//                                     setState(
//                                       () => _isSendingMap[item.itemId] = true,
//                                     );
//
//                                     try {
//                                       final success = await food_Authservice
//                                           .updateCartItemStatus(
//                                             itemId: item.itemId,
//                                             quantity: item.quantity,
//                                             status: 'CONFIRMED',
//                                             note: note.isNotEmpty ? note : null,
//                                           );
//
//                                       if (success) {
//                                         setState(() {
//                                           item.previousQuantity = item.quantity;
//                                           item.orderStatus = 'CONFIRMED';
//                                         });
//
//                                         // await _loadCartItems(
//                                         //   updatedItemId: item.itemId,
//                                         // );
//
//                                         scrollToBottom();
//
//                                         if (!mounted) return;
//
//                                         AppAlert.success(
//                                           context,
//                                           '✅ Order placed for ${item.dishName}',
//                                         );
//                                       } else {
//                                         if (!mounted) return;
//
//                                         AppAlert.error(
//                                           context,
//                                           '❌ Failed to place order for ${item.dishName}',
//                                         );
//                                       }
//                                     } finally {
//                                       if (mounted) {
//                                         setState(() {
//                                           _isSendingMap[item.itemId] = false;
//                                         });
//                                       }
//                                     }
//                                   },
//                                 ),
//                               ] else ...[
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: item.orderStatus == "DELIVERED"
//                                         ? Colors.green.shade100
//                                         : Colors.orange.shade100,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     (item.orderStatus ?? '').replaceAll(
//                                       '_',
//                                       ' ',
//                                     ),
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                       color: item.orderStatus == "DELIVERED"
//                                           ? Colors.green.shade800
//                                           : Colors.orange.shade800,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 12),
//                     if (item.orderStatus == null) ...[
//                       TextField(
//                         controller: _getNoteController(item),
//                         maxLines: 1,
//                         textInputAction: TextInputAction.done,
//                         decoration: InputDecoration(
//                           hintText: "Add cooking instructions / note",
//                           hintStyle: TextStyle(fontSize: 13),
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 10,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: Colors.grey.shade300),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: Colors.grey.shade300),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                         ),
//                         onChanged: (value) {
//                           item.note = value; // store locally
//                         },
//                       ),
//                     ],
//
//                     if (!isLastItem)
//                       Divider(
//                         height: 24,
//                         thickness: 1,
//                         color: Colors.grey[200],
//                       ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   TextEditingController _getNoteController(CartItem item) {
//     return _noteControllers.putIfAbsent(
//       item.itemId,
//       () => TextEditingController(text: item.note ?? ''),
//     );
//   }
//
//   Widget _buildaddmoretext(BuildContext context) {
//     return Center(
//       child: RichText(
//         text: TextSpan(
//           text: "Missed Something? ",
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//           children: [
//             TextSpan(
//               text: "Add more items",
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue, // Highlight clickable text
//                 decoration: TextDecoration.underline, // Underline effect
//               ),
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () async {
//                   isExpanded = !isExpanded;
//                   // print(seatingId);
//
//                   await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => tablemneuScreen(
//                         vendorId: tableCartData!.vendorId,
//                         seatingId: tableCartData!.seatingId,
//                       ),
//                     ),
//                   );
//
//                   // Reload cart after coming back
//                   await _loadCartItems();
//                   await _initializeData();
//
//                   if (mounted) {
//                     setState(() {});
//                   }
//                 },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTableCheckoutCard() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: EdgeInsets.only(bottom: 12.h),
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () {
//           _initializeData();
//           setState(() => isExpanded = !isExpanded);
//
//           if (!isExpanded) {
//             scrollToTop(); // expanding → go down
//           } else {
//             scrollToBottom();
//             // collapsing → go up
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.of(context).primary,
//           padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           elevation: 3,
//         ),
//         child: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 300),
//           transitionBuilder: (child, animation) =>
//               FadeTransition(opacity: animation, child: child),
//           child: isExpanded
//               ? Text(
//                   'Generated Bill',
//                   key: const ValueKey(1),
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 )
//               : Text(
//                   'Generated Bill',
//                   // 'Get Your Bill',
//                   key: const ValueKey(2),
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTotalRow(
//     String label,
//     num value, {
//     bool isBold = false,
//     VoidCallback? onInfoTap,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Row(
//               children: [
//                 Flexible(
//                   child: Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                       color: isBold ? Colors.black87 : Colors.grey[700],
//                     ),
//                   ),
//                 ),
//
//                 if (onInfoTap != null) ...[
//                   SizedBox(width: 4.w),
//
//                   GestureDetector(
//                     onTap: onInfoTap,
//                     child: Icon(
//                       Icons.info_outline,
//                       size: 16.sp,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//
//           Text(
//             "₹${value.toStringAsFixed(2)}",
//             textAlign: TextAlign.end,
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: isBold ? Theme.of(context).primaryColor : Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCouponRow() {
//     final applied = (tableCartData?.couponCode ?? '').isNotEmpty;
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
//                 color: applied
//                     ? cartuser.green.withOpacity(0.10)
//                     : cartuser.violetDim,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 applied
//                     ? Icons.check_circle_rounded
//                     : Icons.local_offer_rounded,
//                 size: 18.sp,
//                 color: applied ? cartuser.green : AppColors.primary,
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
//                       color: applied ? cartuser.green : cartuser.textPrimary,
//                     ),
//                   ),
//                   if (applied)
//                     Text(
//                       appliedCouponCode ?? '',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: cartuser.textSecondary,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (applied)
//               GestureDetector(
//                 onTap: () async {
//                   if (tableCartData?.cartId == null) return;
//                   final result = await food_Authservice.updateCartSettings(
//                     cartId: tableCartData!.cartId,
//                     couponId: tableCartData!.couponId,
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
//                     color: cartuser.red.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(20.r),
//                     border: Border.all(color: cartuser.red.withOpacity(0.2)),
//                   ),
//                   child: Text(
//                     'Remove',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: cartuser.red,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               )
//             else
//               Icon(
//                 Icons.chevron_right_rounded,
//                 size: 20.sp,
//                 color: cartuser.textMuted,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _card({required Widget child, EdgeInsets? padding}) {
//     return Container(
//       width: double.infinity,
//       padding: padding ?? EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: cartuser.surface,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: cartuser.border),
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
//
//   void _showCouponBottomSheet() async {
//     setState(() => isCouponLoading = true);
//     final List<CouponModel> coupons = await food_Authservice.fetchCoupons();
//
//     final int? cartVendor = tableCartData?.vendorId;
//
//     setState(() => isCouponLoading = false);
//
//     coupons.sort((a, b) {
//       final aExpired = a.isExpired;
//       final bExpired = b.isExpired;
//
//       final aMismatch = !a.isApplicableForVendor(cartVendor);
//       final bMismatch = !b.isApplicableForVendor(cartVendor);
//
//       if (aExpired != bExpired) return aExpired ? 1 : -1;
//       if (aMismatch != bMismatch) return aMismatch ? 1 : -1;
//       return 0;
//     });
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (sheetContext) {
//         if (coupons.isEmpty) {
//           return _emptyCouponView();
//         }
//
//         return Scaffold(
//           // ✅ ADD THIS
//           backgroundColor: Colors.transparent,
//           body: SafeArea(
//             top: false,
//             child: Container(
//               height: MediaQuery.of(sheetContext).size.height * 1,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   _couponHeader(),
//                   Expanded(
//                     child: isCouponLoading
//                         ? _couponSkeletonList()
//                         : ListView.builder(
//                             padding: const EdgeInsets.all(16),
//                             itemCount: coupons.length,
//                             itemBuilder: (context, index) {
//                               final coupon = coupons[index];
//
//                               final bool isExpired = coupon.isExpired;
//                               final bool isMismatch = !coupon
//                                   .isApplicableForVendor(cartVendor);
//
//                               return _couponTile(
//                                 coupon: coupon,
//                                 isExpired: isExpired,
//                                 isMismatch: isMismatch,
//                                 isDisabled: isExpired || isMismatch,
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _emptyCouponView() {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.3,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.confirmation_number_outlined,
//               size: 50,
//               color: Colors.grey,
//             ),
//             SizedBox(height: 16),
//             Text(
//               "No coupons available",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Check back later for new offers",
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _couponHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 3,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             "Available Coupons",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => Navigator.pop(context),
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
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(
//           color: isExpired
//               // ignore: deprecated_member_use
//               ? Colors.red.withOpacity(0.4)
//               : isMismatch
//               // ignore: deprecated_member_use
//               ? Colors.orange.withOpacity(0.4)
//               // ignore: deprecated_member_use
//               : Colors.green.withOpacity(0.4),
//         ),
//       ),
//       child: ListTile(
//         leading: Icon(
//           Icons.local_offer,
//           color: isExpired
//               ? Colors.red
//               : isMismatch
//               ? Colors.orange
//               : Colors.green,
//         ),
//
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: coupon.couponType == "PERCENTAGE"
//                     // ignore: deprecated_member_use
//                     ? Colors.blue.withOpacity(0.1)
//                     // ignore: deprecated_member_use
//                     : Colors.purple.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 coupon.couponType,
//
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   color: coupon.couponType == "PERCENTAGE"
//                       ? Colors.blue
//                       : Colors.purple,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               coupon.code,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isExpired ? Colors.red : Colors.black,
//               ),
//             ),
//
//             /// COUPON TYPE BADGE
//           ],
//         ),
//
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               isExpired
//                   ? "Expired"
//                   : isMismatch
//                   ? "Not applicable for this restaurant"
//                   : coupon.discountType == "PERCENTAGE"
//                   ? "Get ${coupon.discountPercentage.toStringAsFixed(0)}% off"
//                   : "Get ₹${coupon.discountPercentage.toStringAsFixed(0)} off",
//               style: TextStyle(
//                 color: isExpired
//                     ? Colors.red
//                     : isMismatch
//                     ? Colors.orange
//                     : Colors.black,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               coupon.minimumOrderValue <= 0
//                   ? "Applicable on any order"
//                   : "Min order ₹${coupon.minimumOrderValue.toInt()}",
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//             ),
//           ],
//         ),
//
//         trailing: isDisabled
//             ? Icon(Icons.block, color: isExpired ? Colors.red : Colors.orange)
//             : const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: Colors.green,
//               ),
//
//         onTap: isDisabled
//             ? () => _showCouponError(isExpired)
//             : () => _applyCoupon(coupon),
//       ),
//     );
//   }
//
//   void _showCouponError(bool isExpired) {
//     if (isExpired) {
//       AppAlert.error(context, "This coupon has expired");
//     } else {
//       AppAlert.error(
//         context,
//         "This coupon is not applicable for this restaurant",
//       );
//     }
//   }
//
//   Future<void> _applyCoupon(CouponModel coupon) async {
//     if (tableCartData?.cartId == null) {
//       AppAlert.error(context, "Cart is empty");
//       return;
//     }
//
//     final result = await food_Authservice.updateCartSettings(
//       cartId: tableCartData!.cartId,
//       couponId: coupon.id,
//       applyCoupon: "APPLIED",
//     );
//
//     if (!result.success) {
//       AppAlert.error(context, result.error ?? "Failed to apply coupon");
//       return;
//     }
//
//     await _initializeData();
//
//     setState(() {
//       appliedCouponCode = coupon.code;
//       appliedCouponId = coupon.id;
//     });
//
//     AppAlert.success(context, "Coupon ${coupon.code} applied!");
//
//     Navigator.pop(context);
//   }
//
//   Widget _buildsummaryCard(ThemeData theme, ColorScheme colorScheme) {
//     final cart = tableCartData;
//     if (cart == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     // default fallback
//     final subtotal = tableCartData!.subtotal;
//     final gstTotal = (tableCartData?.cgst ?? 0) + (tableCartData?.sgst ?? 0);
//     final grandTotal = tableCartData!.grandTotal;
//     final discountAmount = tableCartData?.discountAmount ?? 0;
//     final platformcharges = tableCartData?.platformCharges ?? 0;
//     final serviceCharges = tableCartData?.serviceCharges ?? 0;
//
//     return Column(
//       children: [
//         Card(
//           color: Colors.white,
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//             // ignore: deprecated_member_use
//             side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.receipt_outlined,
//                       color: colorScheme.primary,
//                       size: 22,
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       'Order Summary',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Divider(thickness: 1, color: Colors.grey),
//                 _buildTotalRow("Sub Total", subtotal),
//                 if (discountAmount > 0) ...[
//                   _builddiscountRow("Discount Amount", discountAmount),
//                 ],
//                 _buildTotalRow("Smart DineIn Fee", platformcharges),
//
//                 // if (orderType == "TABLE_DINE_IN" && serviceCharges > 0) ...[
//
//                 // ],
//                 if (gstTotal > 0) ...[
//                   _buildTotalRow(
//                     "GST",
//                     gstTotal,
//                     onInfoTap: () => _showGstDialog('GST'),
//                   ),
//                 ],
//                 if (serviceCharges > 0) ...[
//                   _buildServiceChargesRow(theme, colorScheme),
//                 ],
//                 // _buildTotalRow("CGST", gstTotal / 2),
//                 Divider(height: 24.h, thickness: 1, color: Colors.grey),
//                 _buildTotalRow("Grand Total", grandTotal, isBold: true),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(height: 12.h),
//         _buildCheckoutDetails(theme, colorScheme),
//       ],
//     );
//   }
//
//   void _showGstDialog(String type) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//
//           titlePadding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 0),
//           title: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   '$type Details',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14.sp,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: EdgeInsets.all(4.r),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: cartuser.border.withOpacity(0.3),
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     size: 16.sp,
//                     color: cartuser.textSecondary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if ((tableCartData?.platformChargeGst ?? 0) > 0)
//                 _dialogRow(
//                   'Platform $type',
//                   ((tableCartData?.platformChargeGst ?? 0)),
//                 ),
//               if ((tableCartData?.packingChargeGst ?? 0) > 0)
//                 _dialogRow(
//                   'Packing $type',
//                   ((tableCartData?.packingChargeGst ?? 0)),
//                 ),
//               if ((tableCartData?.serviceChargeGst ?? 0) > 0)
//                 _dialogRow(
//                   'Service $type',
//                   ((tableCartData?.serviceChargeGst ?? 0)),
//                 ),
//
//               SizedBox(height: 8),
//               Divider(),
//
//               _dialogRow('Total $type', (tableCartData?.gstTotal ?? 0)),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _dialogRow(String label, num value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [Text(label), Text('₹${_fmt(value)}')],
//       ),
//     );
//   }
//
//   String _fmt(num? v) => (v ?? 0).toStringAsFixed(2);
//
//   Widget _builddiscountRow(String label, num value, {bool isBold = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                 color: isBold ? Colors.black87 : Colors.grey[700],
//               ),
//             ),
//           ),
//
//           Text(
//             "-₹${value.toStringAsFixed(2)}",
//             textAlign: TextAlign.end,
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: isBold ? Theme.of(context).primaryColor : Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildServiceChargesRow(ThemeData theme, ColorScheme colorScheme) {
//     final serviceCharges = tableCartData?.serviceCharges ?? 0.0;
//
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 6.h),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceContainerHighest.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "Service Charges",
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurface.withOpacity(0.9),
//             ),
//           ),
//           Row(
//             children: [
//               // ✅ Only show button when charges exist
//               if (serviceCharges > 0) ...[
//                 // ✅ Show "Remove" only when applied, nothing when removed
//                 if (isServiceChargeApplied)
//                   GestureDetector(
//                     onTap: () async {
//                       if (tableCartData?.cartId == null) return;
//
//                       await food_Authservice.updateServiceCharges(
//                         cartId: tableCartData!.cartId,
//                         serviceCharge: "NOT_APPLICABLE",
//                       );
//
//                       await _initializeData();
//
//                       setState(() {
//                         isServiceChargeApplied = false;
//                       });
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: colorScheme.errorContainer,
//                         borderRadius: BorderRadius.circular(20.r),
//                       ),
//                       child: Text(
//                         "Remove",
//                         style: theme.textTheme.labelSmall?.copyWith(
//                           color: colorScheme.onErrorContainer,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 SizedBox(width: 10.w),
//               ],
//
//               // ✅ Amount display
//               Text(
//                 serviceCharges > 0
//                     ? (isServiceChargeApplied
//                           ? "₹${serviceCharges.toStringAsFixed(2)}"
//                           : "-₹${serviceCharges.toStringAsFixed(2)}") // removed state
//                     : "₹0.00",
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   // ✅ Red color hint when charge is waived
//                   color: isServiceChargeApplied
//                       ? colorScheme.onSurface
//                       : colorScheme.error,
//                   fontWeight: isServiceChargeApplied
//                       ? FontWeight.normal
//                       : FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCheckoutDetails(ThemeData theme, ColorScheme colorScheme) {
//     return Column(
//       children: [
//         tablecartwallet(
//           wallet: wallet,
//           onSelectionChanged: (method, subWallets) {
//             setState(() {
//               selectedPaymentMethod = method;
//               selectedSubWallets = subWallets;
//             });
//             scrollToBottom();
//           },
//         ),
//         SizedBox(height: 16.h),
//         _buildPlaceOrderButton(theme, colorScheme),
//       ],
//     );
//   }
//
//   Widget _buildPlaceOrderButton(ThemeData theme, ColorScheme colorScheme) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: isPlacingOrder ? null : placeOrder,
//         style: ElevatedButton.styleFrom(
//           padding: EdgeInsets.symmetric(vertical: 16.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           backgroundColor: colorScheme.primary,
//           foregroundColor: colorScheme.onPrimary,
//           elevation: 2,
//         ),
//         child: isPlacingOrder
//             ? SizedBox(
//                 width: 22.w,
//                 height: 22.w,
//                 child: CircularProgressIndicator(
//                   color: colorScheme.onPrimary,
//                   strokeWidth: 2,
//                 ),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Place Order',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(width: 8.w),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       // ignore: deprecated_member_use
//                       color: colorScheme.onPrimary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       '₹${(tableCartData?.grandTotal ?? 0).toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
//
// class QuantityControl extends StatefulWidget {
//   final CartItem item;
//   final VoidCallback onQuantityChanged;
//
//   const QuantityControl({
//     super.key,
//     required this.item,
//     required this.onQuantityChanged,
//   });
//
//   @override
//   State<QuantityControl> createState() => _QuantityControlState();
// }
//
// class _QuantityControlState extends State<QuantityControl> {
//   bool _isUpdating = false;
//
//   bool get _canDecrease {
//     if (widget.item.previousQuantity == 0) {
//       return widget.item.quantity > 0;
//     }
//
//     return widget.item.quantity > widget.item.previousQuantity;
//   }
//
//   void _updateQuantityUI(int newQty) {
//     setState(() {
//       widget.item.quantity = newQty;
//       widget.item.totalPrice = widget.item.price * newQty;
//     });
//
//     widget.onQuantityChanged();
//   }
//
//   Widget _qtyBtn(IconData icon, Color color, VoidCallback? onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(6.w),
//         decoration: BoxDecoration(
//           color: color.withOpacity(onTap == null ? 0.05 : 0.12),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Icon(
//           icon,
//           size: 14.sp,
//           color: onTap == null ? Colors.grey.shade300 : color,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: cartuser.bg,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: cartuser.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // MINUS
//           _qtyBtn(
//             Icons.remove_rounded,
//             cartuser.red,
//             !_canDecrease
//                 ? null
//                 : () {
//                     final newQty = widget.item.quantity - 1;
//
//                     if (newQty >= 0) {
//                       _updateQuantityUI(newQty);
//                     }
//                   },
//           ),
//
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             child: Text(
//               '${widget.item.quantity}',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w700,
//                 color: cartuser.textPrimary,
//               ),
//             ),
//           ),
//
//           // PLUS
//           _qtyBtn(Icons.add_rounded, cartuser.green, () {
//             // STOCK CHECK
//             if (!(widget.item.available ?? true)) {
//               AppAlert.error(context, 'Not enough stock for this dish');
//               return;
//             }
//
//             _updateQuantityUI(widget.item.quantity + 1);
//           }),
//         ],
//       ),
//     );
//   }
// }
//
// class SendButton extends StatelessWidget {
//   final CartItem item;
//   final bool isSending;
//   final VoidCallback onSend;
//
//   const SendButton({
//     super.key,
//     required this.item,
//     required this.isSending,
//     required this.onSend,
//   });
//
//   bool get _isActive => item.quantity > item.previousQuantity;
//
//   @override
//   Widget build(BuildContext context) {
//     final bool canTap = _isActive && !isSending;
//
//     return GestureDetector(
//       onTap: canTap ? onSend : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         decoration: BoxDecoration(
//           color: canTap
//               ? Theme.of(context).primaryColor
//               : Colors.grey.shade400, // greyed out when disabled
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.black12),
//         ),
//         child: Center(
//           child: isSending
//               ? const SizedBox(
//                   width: 18,
//                   height: 18,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 )
//               : const Text(
//                   'Send',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }
//
// Widget _couponSkeletonList() {
//   return ListView.builder(
//     padding: const EdgeInsets.all(16),
//     itemCount: 5,
//     itemBuilder: (_, __) {
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 16),
//         child: Shimmer.fromColors(
//           baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//           child: Container(
//             height: 90,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

import 'package:maamaas/screens/Food&beverages/table/tablecartpayment.dart';
import '../../../Services/Auth_service/Subscription_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../../widgets/widgets/food/currentcart_notifier.dart';
import '../../../Services/paymentservice/razorpayservice.dart';
import '../../../Services/websockets/web_socket_manager.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Models/subscrptions/coupon_model.dart';
import '../../../Models/subscrptions/wallet_model.dart';
import '../../../Models/food/tablecartmodel.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../Mainscreen.dart';
import '../food_invoice.dart';
import 'table_menu.dart';
import 'dart:async';

// ─── Design Tokens ───────────────────────────────────────────────────────────
class _C {
  // Backgrounds
  static const bg = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFBFCFE);

  // Brand
  static const brand = Color(0xFFFF6B35); // warm orange – food-app energy
  static const brandLight = Color(0xFFFFF0EB);
  static const brandDark = Color(0xFFE55A27);

  // Text
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFFB0B8C8);

  // Semantic
  static const green = Color(0xFF22C55E);
  static const greenLight = Color(0xFFDCFCE7);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFEFF6FF);

  // Border / shadow
  static const border = Color(0xFFEEF0F5);
  static const shadow = Color(0x0A000000);
}

// ─── Status Badge Helper ──────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    Color bg, fg;
    IconData icon;

    if (s == 'DELIVERED') {
      bg = _C.greenLight;
      fg = _C.green;
      icon = Icons.check_circle_rounded;
    } else if (s == 'CANCELLED') {
      bg = _C.redLight;
      fg = _C.red;
      icon = Icons.cancel_rounded;
    } else if (s == 'CONFIRMED' || s == 'PENDING') {
      bg = _C.amberLight;
      fg = _C.amber;
      icon = Icons.schedule_rounded;
    } else {
      bg = _C.blueLight;
      fg = _C.blue;
      icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            s.replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Enums ────────────────────────────────────────────────────────────────────
enum PaymentOverlayState {
  none,
  placingOrder,
  openingGateway,
  processing,
  success,
}

// ─── Main Widget ──────────────────────────────────────────────────────────────
class tablecart extends StatefulWidget {
  final int seatingId;
  const tablecart({super.key, required this.seatingId});

  @override
  State<tablecart> createState() => _tablecartState();
}

class _tablecartState extends State<tablecart>
    with SingleTickerProviderStateMixin {
  TableCartModel? tableCartData;
  String selectedPaymentMethod = "";
  String selectedSubWallet = "";
  bool isPlacingOrder = false;
  Map<String, dynamic>? checkoutData;
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _error;
  bool isSent = false;
  bool isExpanded = false;
  bool isServiceChargeApplied = true;
  Wallet? wallet;
  int? appliedCouponId;
  String? appliedCouponCode;
  bool send = false;
  final Map<int, bool> _isSendingMap = {};
  late ScrollController _scrollController;
  bool isCouponLoading = false;
  final Map<int, TextEditingController> _noteControllers = {};
  Set<String> selectedSubWallets = {};
  PaymentOverlayState _overlayState = PaymentOverlayState.none;
  int selectedQuantity = 0;

  final WebSocketManager _wsManager = WebSocketManager();
  int? _userId;
  Timer? _cartReloadDebounce;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadWallet();
    _loadCartItems();
    _initializeData();
    _initializeRealtimeCart();
  }

  @override
  void dispose() {
    if (_userId != null) _wsManager.unsubscribeUserCart(_userId!);
    _scrollController.dispose();
    for (final c in _noteControllers.values) c.dispose();
    _cartReloadDebounce?.cancel();

    super.dispose();
  }

  // ── WebSocket / data methods (unchanged logic) ────────────────────────────
  Future<void> _initializeRealtimeCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;
    _userId = userId;
    _wsManager.subscribeUserCart(userId, (data) async {
      if (!mounted) return;
      try {
        final updatedCart = TableCartModel.fromJson(data);
        setState(() {
          tableCartData = updatedCart;
          _cartItems = List<CartItem>.from(updatedCart.cartItems);
          final delivered =
              updatedCart.cartItems.isNotEmpty &&
              updatedCart.cartItems
                  .where((i) => i.orderStatus != "CANCELLED")
                  .every((i) => i.orderStatus == "DELIVERED");
          if (!delivered) isExpanded = false;
          _isLoading = false;
        });
      } catch (_) {}
    });
  }
  // Future<void> _initializeRealtimeCart() async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   final userId = prefs.getInt('userId');
  //
  //   if (userId == null) return;
  //
  //   _userId = userId;
  //
  //   _wsManager.subscribeUserCart(userId, (data) async {
  //     debugPrint('📦 CART WS EVENT RECEIVED');
  //
  //     if (!mounted) return;
  //
  //     // Prevent multiple rapid API calls
  //     _cartReloadDebounce?.cancel();
  //
  //     _cartReloadDebounce = Timer(
  //       const Duration(milliseconds: 500),
  //           () async {
  //         debugPrint('🔄 Reloading full cart from API');
  //
  //         await _loadCartItems();
  //       },
  //     );
  //   });
  //   // _wsManager.subscribeUserCart(userId, (data) async {
  //   //   if (!mounted) return;
  //   //
  //   //   _cartReloadDebounce?.cancel();
  //   //
  //   //   _cartReloadDebounce = Timer(const Duration(milliseconds: 500), () async {
  //   //     // Preserve current scroll position
  //   //     final currentOffset = _scrollController.hasClients
  //   //         ? _scrollController.offset
  //   //         : 0.0;
  //   //
  //   //     await _loadCartItems();
  //   //
  //   //     // Restore scroll position
  //   //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //   //       if (_scrollController.hasClients) {
  //   //         _scrollController.jumpTo(
  //   //           currentOffset.clamp(
  //   //             0,
  //   //             _scrollController.position.maxScrollExtent,
  //   //           ),
  //   //         );
  //   //       }
  //   //     });
  //   //   });
  //   // });
  // }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadWallet() async {
    final w = await subscription_AuthService.fetchWallet();
    setState(() => wallet = w);
  }

  Future<void> _onRefresh() async {
    try {
      final updatedCarts = await food_Authservice.fetchTableCart();
      final updatedWallet = await subscription_AuthService.fetchWallet();
      if (!mounted) return;
      setState(() {
        if (updatedCarts.isNotEmpty) {
          final freshCart = updatedCarts.first;
          tableCartData = freshCart;
          _cartItems = List<CartItem>.from(freshCart.cartItems);
          final delivered =
              freshCart.cartItems.isNotEmpty &&
              freshCart.cartItems
                  .where((i) => i.orderStatus != "CANCELLED")
                  .every((i) => i.orderStatus == "DELIVERED");
          if (!delivered) isExpanded = false;
        } else {
          tableCartData = null;
          _cartItems = [];
        }
        wallet = updatedWallet;
      });
    } catch (_) {}
  }

  Future<void> _initializeData() async {
    try {
      final data = await food_Authservice.fetchTableCart();
      if (data.isEmpty) return;
      if (!mounted) return;
      setState(() => tableCartData = data.first);
    } catch (_) {}
  }

  Future<bool> _deleteCart() async {
    try {
      final success = await food_Authservice.deleteTableDineInCart();
      if (!mounted) return false;
      if (success) {
        CartNotifier.count.value = 0;
        AppAlert.success(context, "Cart cleared");
        setState(() {
          tableCartData = null;
          _cartItems.clear();
        });
        return true;
      }
      return false;
    } catch (e) {
      if (!mounted) return false;
      AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
      return false;
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
    if (selectedPaymentMethod.isEmpty) {
      AppAlert.error(context, "Please select a payment method");
      return;
    }
    if (selectedPaymentMethod == "Maamaas_Wallet" &&
        selectedSubWallets.isEmpty) {
      AppAlert.error(context, "Please select at least one wallet type");
      return;
    }
    if (selectedPaymentMethod == "Maamaas_Wallet") {
      final wb = getSelectedWalletBalance();
      final gt = (tableCartData?.grandTotal ?? 0).toDouble();
      if (wb < gt) {
        AppAlert.error(
          context,
          "Insufficient wallet balance\nWallet: ₹${wb.toStringAsFixed(2)}\nOrder Total: ₹${gt.toStringAsFixed(2)}",
        );
        return;
      }
    }
    setState(() => isPlacingOrder = true);
    try {
      if (selectedPaymentMethod == "Online_Payment") {
        final amount = (tableCartData?.grandTotal ?? 0).toDouble();
        if (mounted) {
          setState(() => _overlayState = PaymentOverlayState.openingGateway);
        }
        final orderId = await food_Authservice.createOrder(amount);
        if (mounted) {
          setState(() => _overlayState = PaymentOverlayState.openingGateway);
        }
        if (orderId == null) {
          AppAlert.error(context, "Failed to create payment order");
          return;
        }
        final rp = RazorpayService();
        rp.onSuccess = (res) async {
          final pid = res.paymentId!;
          final oid = res.orderId!;
          if (mounted) {
            setState(() => _overlayState = PaymentOverlayState.processing);
          }
          await _callOrderApi(
            paymentMethod: "Online_Payment",
            razorpayPaymentId: pid,
            razorpayOrderId: oid,
            amount: amount,
          );
          if (mounted) setState(() => _overlayState = PaymentOverlayState.none);
          if (mounted) {
            food_Authservice
                .capturePayment(paymentId: pid, amount: amount)
                .catchError((_) {});
          } else {
            AppAlert.error(context, "Order failed. Refund in 3–5 days.");
          }
        };
        rp.onError = (res) {
          if (mounted) {
            setState(() {
              _overlayState = PaymentOverlayState.none;
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
        return;
      }
      final amt = tableCartData!.grandTotal.toDouble();
      await _callOrderApi(
        paymentMethod: selectedPaymentMethod,
        razorpayPaymentId: "",
        razorpayOrderId: "",
        amount: amt,
      );
    } catch (e) {
      String message = e.toString().contains("Exception:")
          ? e.toString().replaceFirst("Exception: ", "")
          : e.toString();
      if (mounted) setState(() => _overlayState = PaymentOverlayState.none);
      AppAlert.error(context, message);
    } finally {
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }

  bool get allItemsDelivered {
    if (tableCartData == null) return false;
    return tableCartData!.cartItems.isNotEmpty &&
        tableCartData!.cartItems
            .where((i) => i.orderStatus != "CANCELLED")
            .every((i) => i.orderStatus == "DELIVERED");
  }

  bool get canDeleteCart {
    if (tableCartData == null) return false;
    return tableCartData!.cartItems.isNotEmpty &&
        tableCartData!.cartItems.every((item) => item.orderStatus == null);
  }

  List<String> mapWalletsToEnum(List<String> selected) {
    return selected.map((w) {
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
  }

  Future<void> _callOrderApi({
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');
    if (cartId == null) return;
    final result = await food_Authservice.placeDirectOrder(
      cartId: cartId,
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
      amount: amount,
    );
    if (result['success'] == false) {
      AppAlert.error(context, result['error'] ?? "Unknown error");
      return;
    }
    final orderId = result['orderId'];
    if (orderId == null || orderId is! int) {
      AppAlert.error(context, "Invalid Order ID returned");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
    );
  }

  Future<void> _loadCartItems({int? updatedItemId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await food_Authservice.fetchTableCart();
      if (result.isNotEmpty) {
        final freshCart = result.first;
        final fetchedItems = freshCart.cartItems;
        setState(() {
          tableCartData = freshCart;
          final delivered =
              freshCart.cartItems.isNotEmpty &&
              freshCart.cartItems
                  .where((i) => i.orderStatus != "CANCELLED")
                  .every((i) => i.orderStatus == "DELIVERED");
          if (!delivered) isExpanded = false;
          if (updatedItemId != null) {
            final updatedItem = fetchedItems.firstWhere(
              (item) => item.itemId == updatedItemId,
              orElse: () => CartItem.empty(),
            );
            final index = _cartItems.indexWhere(
              (item) => item.itemId == updatedItemId,
            );
            if (index != -1 && updatedItem.itemId != 0) {
              _cartItems[index] = updatedItem;
            } else {
              _cartItems = fetchedItems;
            }
          } else {
            _cartItems = fetchedItems;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _cartItems = [];
          tableCartData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: _C.bg,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: _C.brand,
              backgroundColor: Colors.white,
              displacement: 40,
              strokeWidth: 2.5,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isLoading &&
                        (tableCartData == null ||
                            tableCartData!.cartItems.isEmpty))
                      _buildEmptyCart()
                    else ...[
                      _buildCartItems(context),
                      SizedBox(height: 8.h),
                      _buildAddMoreRow(context),
                      SizedBox(height: 16.h),
                      if (tableCartData != null &&
                          tableCartData!.cartItems.isNotEmpty) ...[
                        if (allItemsDelivered) _buildGenerateBillButton(),
                        SizedBox(height: 12.h),
                        if (isExpanded) ...[
                          _buildCouponRow(),
                          SizedBox(height: 12.h),
                          _buildSummaryCard(),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_overlayState != PaymentOverlayState.none)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(child: _overlayContent()),
              ),
            ),
          ),
      ],
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: _C.border, width: 1)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: _C.textPrimary,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreenfood()),
                    );
                  }
                },
              ),
              const Expanded(
                child: Text(
                  'Your Cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: _C.red,
                  size: 22,
                ),
                onPressed: _confirmDeleteCart,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Cart?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'All items will be removed from your cart.',
          style: TextStyle(color: _C.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _C.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: _C.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final vendorId = tableCartData?.vendorId;
      final seatingId = tableCartData?.seatingId;
      final deleted = await _deleteCart();
      if (!mounted) return;
      if (deleted && vendorId != null && seatingId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                tablemneuScreen(vendorId: vendorId, seatingId: seatingId),
          ),
        );
      }
    }
  }

  // ── Overlay ───────────────────────────────────────────────────────────────
  Widget _overlayContent() {
    switch (_overlayState) {
      case PaymentOverlayState.placingOrder:
        return _dialogLoader(
          "Placing your order...",
          Icons.shopping_bag_outlined,
        );
      case PaymentOverlayState.openingGateway:
        return _dialogLoader(
          "Redirecting To Razorpay...",
          Icons.lock_outline_rounded,
        );
      case PaymentOverlayState.processing:
        return _dialogLoader("Confirming payment...", Icons.verified_outlined);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _dialogLoader(String text, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _C.brandLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: _C.brand,
                  strokeWidth: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
                decoration: TextDecoration.none,
              ),
              child: Text(text),
            ),
            const SizedBox(height: 4),
            const DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color: _C.textSecondary,
                decoration: TextDecoration.none,
              ),
              child: Text('Please don\'t close this screen'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: _C.brandLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 44,
              color: _C.brand,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse the menu and add something delicious',
            style: TextStyle(fontSize: 14, color: _C.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Cart Items Card ───────────────────────────────────────────────────────
  Widget _buildCartItems(BuildContext context) {
    if (_isLoading) {
      return _buildCartSkeleton();
    }
    if (_error != null) {
      return _buildErrorState();
    }
    if (_cartItems.isEmpty) return _buildEmptyCart();

    final orderedItems = _cartItems
        .where((i) => i.orderStatus != null)
        .toList();
    final pendingItems = _cartItems
        .where((i) => i.orderStatus == null)
        .toList();
    final displayItems = [...orderedItems, ...pendingItems];

    return _surfaceCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _C.brandLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.table_restaurant_rounded,
                      size: 14,
                      color: _C.brand,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Table ${tableCartData?.tableCode ?? ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.brand,
                      ),
                    ),
                  ],
                ),
              ),
              // const Spacer(),
              // Text(
              //   '${_cartItems.length} ${_cartItems.length == 1 ? 'item' : 'items'}',
              //   style: const TextStyle(fontSize: 13, color: _C.textSecondary),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          ...displayItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isLast = idx == displayItems.length - 1;
            return _buildCartItemRow(item, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(CartItem item, bool isLast) {
    return Column(
      key: ValueKey('${item.itemId}_${item.orderStatus}_${item.quantity}'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.dishName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: item.orderStatus == "CANCELLED"
                            ? _C.textMuted
                            : _C.textPrimary,
                        decoration: item.orderStatus == "CANCELLED"
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),

                  if (item.orderStatus != null) ...[
                    Text(
                      "Qty: ${item.quantity}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 22), // align under name
                  Text(
                    '₹${item.price} each',
                    style: const TextStyle(fontSize: 12, color: _C.textMuted),
                  ),
                  const Spacer(),

                  QuantityControl(
                    item: item,
                    onQuantityChanged: () => setState(() {}),
                  ),
                  const SizedBox(width: 8),
                  if (item.orderStatus == null) ...[
                    SendButton(
                      item: item,
                      isSending: _isSendingMap[item.itemId] == true,
                      onSend: () => _sendItem(item),
                    ),
                  ] else
                    _StatusBadge(item.orderStatus ?? ''),
                ],
              ),
              // Note field
              if (item.orderStatus == null) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _getNoteController(item),
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cooking instructions or special request...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: _C.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      size: 18,
                      color: _C.textMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: _C.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _C.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _C.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _C.brand, width: 1.5),
                    ),
                  ),
                  onChanged: (v) => item.note = v,
                ),
              ],
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, thickness: 1, color: _C.border),
      ],
    );
  }

  Future<void> _sendItem(CartItem item) async {
    if (_isSendingMap[item.itemId] == true) return;

    final note = _getNoteController(item).text.trim();

    setState(() => _isSendingMap[item.itemId] = true);

    try {
      // 🔹 Get dynamic status from API
      final billingData = await food_Authservice.getBillingSettings(
        tableCartData!.vendorId,
      );
      print('billingData = $billingData');

      final initialStatus =
          (billingData['userInitialOrderStatus']?.toString() ?? 'PENDING')
              .trim();
      print('initialStatus = $initialStatus');

      final success = await food_Authservice.updateCartItemStatus(
        itemId: item.itemId,
        quantity: item.quantity,
        // status: 'PENDING',
        status: initialStatus,
        note: note.isNotEmpty ? note : null,
      );

      if (success) {
        setState(() {
          item.previousQuantity = item.quantity;

          // 🔹 Dynamic status
          item.orderStatus = initialStatus;
        });

        // scrollToBottom();

        if (!mounted) return;

        AppAlert.success(context, 'Order placed for ${item.dishName}');
      } else {
        if (!mounted) return;

        AppAlert.error(context, 'Failed to send order for ${item.dishName}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingMap[item.itemId] = false);
      }
    }
  }

  TextEditingController _getNoteController(CartItem item) {
    return _noteControllers.putIfAbsent(
      item.itemId,
      () => TextEditingController(text: item.note ?? ''),
    );
  }

  Widget _buildCartSkeleton() {
    return _surfaceCard(
      padding: EdgeInsets.all(16.w),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return _surfaceCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: _C.redLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: _C.red,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load cart',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _C.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadCartItems,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── "Add more" row ────────────────────────────────────────────────────────
  Widget _buildAddMoreRow(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => tablemneuScreen(
              vendorId: tableCartData!.vendorId,
              seatingId: tableCartData!.seatingId,
            ),
          ),
        );
        await _loadCartItems();
        await _initializeData();
        if (mounted) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.brand.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, size: 18, color: _C.brand),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                text: 'Missed something? ',
                style: const TextStyle(fontSize: 14, color: _C.textSecondary),
                children: [
                  TextSpan(
                    text: 'Add more items',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.brand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Generate Bill Button ──────────────────────────────────────────────────
  Widget _buildGenerateBillButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _initializeData();
          setState(() => isExpanded = !isExpanded);
          if (!isExpanded)
            scrollToTop();
          else
            scrollToBottom();
        },
        icon: Icon(
          isExpanded ? Icons.receipt_long_rounded : Icons.receipt_rounded,
          size: 18,
        ),
        label: Text(
          isExpanded ? 'Hide Bill' : 'View & Pay Bill',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.brand,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Coupon Row ────────────────────────────────────────────────────────────
  Widget _buildCouponRow() {
    final applied = (tableCartData?.couponCode ?? '').isNotEmpty;

    return GestureDetector(
      onTap: applied ? null : _showCouponBottomSheet,
      child: _surfaceCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: applied ? _C.greenLight : _C.brandLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                applied
                    ? Icons.check_circle_rounded
                    : Icons.local_offer_rounded,
                size: 20,
                color: applied ? _C.green : _C.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applied ? 'Coupon Applied' : 'Apply Coupon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: applied ? _C.green : _C.textPrimary,
                    ),
                  ),
                  if (applied)
                    Text(
                      appliedCouponCode ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _C.textSecondary,
                      ),
                    ),
                  if (!applied)
                    const Text(
                      'Save more on your order',
                      style: TextStyle(fontSize: 12, color: _C.textSecondary),
                    ),
                ],
              ),
            ),
            if (applied)
              GestureDetector(
                onTap: () async {
                  if (tableCartData?.cartId == null) return;
                  final result = await food_Authservice.updateCartSettings(
                    cartId: tableCartData!.cartId,
                    couponId: tableCartData!.couponId,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _C.redLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 12,
                      color: _C.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: _C.textMuted),
          ],
        ),
      ),
    );
  }

  // ── Summary Card ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    final cart = tableCartData;
    if (cart == null) return const SizedBox.shrink();

    final subtotal = cart.subtotal;
    final gstTotal = (cart.cgst ?? 0) + (cart.sgst ?? 0);
    final grandTotal = cart.grandTotal;
    final discountAmount = cart.discountAmount ?? 0;
    final platformCharges = cart.platformCharges ?? 0;
    final serviceCharges = cart.serviceCharges ?? 0;

    return Column(
      children: [
        _surfaceCard(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: _C.brandLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: _C.brand,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Bill Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _billRow('Subtotal', subtotal),
              if (discountAmount > 0)
                _billRow('Discount', discountAmount, isDiscount: true),
              _billRow('Smart DineIn Fee', platformCharges),
              if (gstTotal > 0)
                _billRow('GST', gstTotal, onInfo: () => _showGstDialog('GST')),
              if (serviceCharges > 0) _buildServiceChargeRow(serviceCharges),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(thickness: 1, color: _C.border),
              ),
              _billRow('Grand Total', grandTotal, isBold: true, isGrand: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCheckoutDetails(),
      ],
    );
  }

  Widget _billRow(
    String label,
    num value, {
    bool isBold = false,
    bool isDiscount = false,
    bool isGrand = false,
    VoidCallback? onInfo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isGrand ? 15 : 14,
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                    color: isBold ? _C.textPrimary : _C.textSecondary,
                  ),
                ),
                if (onInfo != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onInfo,
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: _C.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            isDiscount
                ? '-₹${value.toStringAsFixed(2)}'
                : '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isGrand ? 16 : 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isDiscount
                  ? _C.green
                  : (isGrand ? _C.brand : _C.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChargeRow(num serviceCharges) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Service Charges',
              style: TextStyle(fontSize: 14, color: _C.textSecondary),
            ),
          ),
          if (serviceCharges > 0 && isServiceChargeApplied)
            GestureDetector(
              onTap: () async {
                if (tableCartData?.cartId == null) return;
                await food_Authservice.updateServiceCharges(
                  cartId: tableCartData!.cartId,
                  serviceCharge: "NOT_APPLICABLE",
                );
                await _initializeData();
                setState(() => isServiceChargeApplied = false);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _C.redLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 11,
                    color: _C.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Text(
            serviceCharges > 0
                ? (isServiceChargeApplied
                      ? '₹${serviceCharges.toStringAsFixed(2)}'
                      : '-₹${serviceCharges.toStringAsFixed(2)}')
                : '₹0.00',
            style: TextStyle(
              fontSize: 14,
              color: isServiceChargeApplied ? _C.textSecondary : _C.red,
              fontWeight: isServiceChargeApplied
                  ? FontWeight.normal
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Checkout section ──────────────────────────────────────────────────────
  Widget _buildCheckoutDetails() {
    return Column(
      children: [
        tablecartwallet(
          wallet: wallet,
          onSelectionChanged: (method, subWallets) {
            setState(() {
              selectedPaymentMethod = method;
              selectedSubWallets = subWallets;
            });
            scrollToBottom();
          },
        ),
        SizedBox(height: 16.h),
        _buildPlaceOrderButton(),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isPlacingOrder ? null : placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _C.textMuted,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        child: isPlacingOrder
            ? SizedBox(
                width: 22,
                height: 22,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${(tableCartData?.grandTotal ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── GST Dialog ────────────────────────────────────────────────────────────
  void _showGstDialog(String type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'GST Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: _C.textSecondary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((tableCartData?.platformChargeGst ?? 0) > 0)
              _dialogRow('Platform GST', tableCartData?.platformChargeGst ?? 0),
            if ((tableCartData?.packingChargeGst ?? 0) > 0)
              _dialogRow('Packing GST', tableCartData?.packingChargeGst ?? 0),
            if ((tableCartData?.serviceChargeGst ?? 0) > 0)
              _dialogRow('Service GST', tableCartData?.serviceChargeGst ?? 0),
            const Divider(height: 20),
            _dialogRow('Total GST', tableCartData?.gstTotal ?? 0, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _dialogRow(String label, num value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _C.textSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            '₹${_fmt(value)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isBold ? _C.textPrimary : _C.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(num? v) => (v ?? 0).toStringAsFixed(2);

  // ── Coupon Bottom Sheet ───────────────────────────────────────────────────
  void _showCouponBottomSheet() async {
    setState(() => isCouponLoading = true);

    final coupons = await food_Authservice.fetchCoupons();
    final cartVendor = tableCartData?.vendorId;

    setState(() => isCouponLoading = false);

    coupons.sort((a, b) {
      final aE = a.isExpired, bE = b.isExpired;
      final aM = !a.isApplicableForVendor(cartVendor);
      final bM = !b.isApplicableForVendor(cartVendor);

      if (aE != bE) return aE ? 1 : -1;
      if (aM != bM) return aM ? 1 : -1;

      return 0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.width,
      ),
      builder: (sheetCtx) {
        if (coupons.isEmpty) {
          return SizedBox(width: double.infinity, child: _emptyCouponView());
        }

        return Container(
          width: double.infinity,
          height: MediaQuery.of(sheetCtx).size.height * 0.95,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: _C.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              _couponHeader(),

              Expanded(
                child: isCouponLoading
                    ? _couponSkeletonList()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: coupons.length,
                        itemBuilder: (_, index) {
                          final coupon = coupons[index];

                          final isExpired = coupon.isExpired;

                          final isMismatch = !coupon.isApplicableForVendor(
                            cartVendor,
                          );

                          return _couponTile(
                            coupon: coupon,
                            isExpired: isExpired,
                            isMismatch: isMismatch,
                            isDisabled: isExpired || isMismatch,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyCouponView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _C.bg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 32,
              color: _C.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No coupons available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back later for new offers',
            style: TextStyle(fontSize: 13, color: _C.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _couponHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          const Text(
            'Available Coupons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: _C.textSecondary),
            onPressed: () => Navigator.pop(context),
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
    Color accent = isExpired
        ? _C.red
        : isMismatch
        ? _C.amber
        : _C.green;
    Color accentLight = isExpired
        ? _C.redLight
        : isMismatch
        ? _C.amberLight
        : _C.greenLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isDisabled
              ? () => _showCouponError(isExpired)
              : () => _applyCoupon(coupon),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            coupon.code,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isExpired ? _C.textMuted : _C.textPrimary,
                              decoration: isExpired
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: coupon.couponType == "PERCENTAGE"
                                  ? _C.blueLight
                                  : _C.brandLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              coupon.couponType,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: coupon.couponType == "PERCENTAGE"
                                    ? _C.blue
                                    : _C.brand,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isExpired
                            ? 'Expired'
                            : isMismatch
                            ? 'Not applicable for this restaurant'
                            : coupon.discountType == "PERCENTAGE"
                            ? '${coupon.discountPercentage.toStringAsFixed(0)}% off your order'
                            : '₹${coupon.discountPercentage.toStringAsFixed(0)} off your order',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDisabled ? _C.textMuted : _C.textSecondary,
                        ),
                      ),
                      if (coupon.minimumOrderValue > 0)
                        Text(
                          'Min order ₹${coupon.minimumOrderValue.toInt()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _C.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  isDisabled
                      ? Icons.block_rounded
                      : Icons.chevron_right_rounded,
                  size: 18,
                  color: isDisabled ? _C.textMuted : accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCouponError(bool isExpired) {
    AppAlert.error(
      context,
      isExpired
          ? "This coupon has expired"
          : "This coupon is not applicable for this restaurant",
    );
  }

  Future<void> _applyCoupon(CouponModel coupon) async {
    if (tableCartData?.cartId == null) {
      AppAlert.error(context, "Cart is empty");
      return;
    }
    final result = await food_Authservice.updateCartSettings(
      cartId: tableCartData!.cartId,
      couponId: coupon.id,
      applyCoupon: "APPLIED",
    );
    if (!result.success) {
      AppAlert.error(context, result.error ?? "Failed to apply coupon");
      return;
    }
    await _initializeData();
    setState(() {
      appliedCouponCode = coupon.code;
      appliedCouponId = coupon.id;
    });
    AppAlert.success(context, "🎉 ${coupon.code} applied!");
    Navigator.pop(context);
  }

  // ── Shared card widget ────────────────────────────────────────────────────
  Widget _surfaceCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Quantity Control ─────────────────────────────────────────────────────────
// class QuantityControl extends StatefulWidget {
//   final CartItem item;
//   final VoidCallback onQuantityChanged;
//
//   const QuantityControl({
//     super.key,
//     required this.item,
//     required this.onQuantityChanged,
//   });
//
//   @override
//   State<QuantityControl> createState() => _QuantityControlState();
// }
//
// class _QuantityControlState extends State<QuantityControl> {
//   bool _isUpdating = false;
//
//   bool get _canDecrease {
//     if (widget.item.previousQuantity == 0) return widget.item.quantity > 0;
//     return widget.item.quantity > widget.item.previousQuantity;
//   }
//
//   void _updateQuantityUI(int newQty) {
//     setState(() {
//       widget.item.quantity = newQty;
//       widget.item.totalPrice = widget.item.price * newQty;
//     });
//     widget.onQuantityChanged();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _C.bg,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: _C.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _btn(
//             Icons.remove_rounded,
//             _canDecrease
//                 ? () {
//                     if (widget.item.quantity - 1 >= 0) {
//                       _updateQuantityUI(widget.item.quantity - 1);
//                     }
//                   }
//                 : null,
//           ),
//           // _btn(
//           //   Icons.remove_rounded,
//           //   _canDecrease
//           //       ? () async {
//           //           final newQty = widget.item.quantity - 1;
//           //
//           //           // Remove item when quantity becomes 0
//           //           if (newQty <= 0) {
//           //             setState(() => _isUpdating = true);
//           //
//           //             try {
//           //               final success = await food_Authservice.deleteCartItem(
//           //                 itemId: widget.item.itemId,
//           //               );
//           //
//           //               if (success) {
//           //                 widget.item.quantity = 0;
//           //
//           //                 widget.onQuantityChanged();
//           //
//           //                 if (mounted) {
//           //                   ScaffoldMessenger.of(context).showSnackBar(
//           //                     const SnackBar(
//           //                       content: Text('Item removed from cart'),
//           //                     ),
//           //                   );
//           //                 }
//           //               } else {
//           //                 if (mounted) {
//           //                   AppAlert.error(context, 'Failed to remove item');
//           //                 }
//           //               }
//           //             } catch (e) {
//           //               if (mounted) {
//           //                 AppAlert.error(context, 'Something went wrong');
//           //               }
//           //             } finally {
//           //               if (mounted) {
//           //                 setState(() => _isUpdating = false);
//           //               }
//           //             }
//           //
//           //             return;
//           //           }
//           //
//           //           // Normal decrease
//           //           _updateQuantityUI(newQty);
//           //         }
//           //       : null,
//           // ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             child: Text(
//               '${widget.item.quantity}',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w700,
//                 color: _C.textPrimary,
//               ),
//             ),
//           ),
//           _btn(Icons.add_rounded, () {
//             if (!(widget.item.available ?? true)) {
//               AppAlert.error(context, 'Not enough stock for this dish');
//               return;
//             }
//             _updateQuantityUI(widget.item.quantity + 1);
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _btn(IconData icon, VoidCallback? onTap) {
//     final active = onTap != null;
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(7.w),
//         child: Icon(icon, size: 14.sp, color: active ? _C.brand : _C.textMuted),
//       ),
//     );
//   }
// }
class QuantityControl extends StatefulWidget {
  final CartItem item;
  final VoidCallback onQuantityChanged;

  const QuantityControl({
    super.key,
    required this.item,
    required this.onQuantityChanged,
  });

  @override
  State<QuantityControl> createState() => _QuantityControlState();
}

class _QuantityControlState extends State<QuantityControl> {
  bool _isUpdating = false;

  // Minus is blocked at previousQuantity (what's already sent)
  // If nothing sent yet, minimum is 1
  int get _floor =>
      widget.item.previousQuantity > 0 ? widget.item.previousQuantity : 1;
  //
  // bool get _canDecrease => widget.item.quantity > _floor;

  bool get _canDecrease {
    // Not yet sent to API
    if (widget.item.previousQuantity == 0) {
      return widget.item.quantity > 0;
    }

    // Already sent to API
    return widget.item.quantity > widget.item.previousQuantity;
  }

  Future<void> _updateQuantity(int newQty) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    final success = await food_Authservice.updateCartItemQuantity(
      itemId: widget.item.itemId,
      quantity: newQty,
    );

    if (success) {
      setState(() {
        widget.item.quantity = newQty;
        widget.item.totalPrice = widget.item.price * newQty;
      });
      widget.onQuantityChanged();
    } else {
      if (mounted) AppAlert.error(context, '❌ Failed to update quantity');
    }

    if (mounted) setState(() => _isUpdating = false);
  }

  Widget _qtyBtn(IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(onTap == null ? 0.05 : 0.12),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 14.sp,
          color: onTap == null ? Colors.grey.shade300 : color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
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
            (_isUpdating || !_canDecrease)
                ? null
                : () async {
                    final newQty = widget.item.quantity - 1;

                    // Remove item completely if qty becomes 0
                    if (newQty == 0) {
                      final success = await food_Authservice.removeCartItem(
                        widget.item.itemId,
                      );

                      if (success) {
                        widget.onQuantityChanged();
                      }
                    } else {
                      _updateQuantity(newQty);
                    }
                  },
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: _isUpdating
                ? SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _C.green,
                    ),
                  )
                : Text(
                    '${widget.item.quantity}',
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
            _isUpdating
                ? null
                : () => _updateQuantity(widget.item.quantity + 1),
          ),
        ],
      ),
    );
  }
}

// ─── Send Button ──────────────────────────────────────────────────────────────
class SendButton extends StatelessWidget {
  final CartItem item;
  final bool isSending;
  final VoidCallback onSend;

  const SendButton({
    super.key,
    required this.item,
    required this.isSending,
    required this.onSend,
  });

  bool get _isActive => item.quantity > item.previousQuantity;

  @override
  Widget build(BuildContext context) {
    final canTap = _isActive && !isSending;

    return GestureDetector(
      onTap: canTap ? onSend : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: canTap ? _C.brand : _C.textMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isSending
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 5),
                  const Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Coupon Skeleton ──────────────────────────────────────────────────────────
Widget _couponSkeletonList() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (_, __) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
  );
}
