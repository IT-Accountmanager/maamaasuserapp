// import 'package:maamaas/screens/Food&beverages/table/tablecartpayment.dart';
// import '../../../Services/Auth_service/Subscription_authservice.dart';
// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../Services/Auth_service/food_authservice.dart';
// import '../../../Services/paymentservice/razorpayservice.dart';
// import '../../../Models/subscrptions/coupon_model.dart';
// import '../../../Models/subscrptions/wallet_model.dart';
// import '../../../Models/food/tablecartmodel.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
// import '../Menu/table_menu.dart';
// import '../food_invoice.dart';
// import 'package:maamaas/Services/App_color_service/app_colours.dart';
//
// enum PaymentOverlayState {
//   none,
//   placingOrder,
//   openingGateway,
//   processing,
//   success,
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
//   bool isLoading = true;
//   String selectedPaymentMethod = "Cash";
//   String selectedSubWallet = "";
//   bool isPlacingOrder = false;
//   Map<String, dynamic>? checkoutData;
//   late List<CartItem> _cartItems = [];
//   bool _isLoading = true;
//   String? _error;
//   bool isSent = false;
//   bool isExpanded = false;
//   bool isServiceChargeApplied = true;
//   Wallet? wallet;
//   int? appliedCouponId;
//   String? appliedCouponCode;
//   bool send = false;
//   bool isSending = false;
//   late ScrollController _scrollController;
//   bool isCouponLoading = false;
//   final Map<int, TextEditingController> _noteControllers = {};
//   Set<String> selectedSubWallets = {};
//   PaymentOverlayState _overlayState = PaymentOverlayState.none;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _loadWallet();
//     _loadCartItems();
//     _initializeData();
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadWallet() async {
//     final fetchedWallet = await subscription_AuthService.fetchWallet();
//     setState(() {
//       wallet = fetchedWallet;
//     });
//   }
//
//   Future<void> _onRefresh() async {
//     final updatedCarts = await food_Authservice.fetchTableCart(
//       // widget.seatingId,
//     );
//     final updatedWallet = await subscription_AuthService.fetchWallet();
//
//     if (!mounted) return;
//
//     setState(() {
//       tableCartData = updatedCarts.isNotEmpty ? updatedCarts.first : null;
//       wallet = updatedWallet;
//     });
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
//     if (selectedPaymentMethod == "Maamaas_Wallet") {
//       final wb = getSelectedWalletBalance();
//       final gt = (tableCartData?.grandTotal ?? 0).toDouble();
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
//           if (mounted) {
//             setState(() => _overlayState = PaymentOverlayState.processing);
//           }
//           ;
//
//           if (mounted) {
//             food_Authservice
//                 .capturePayment(paymentId: pid, amount: amount)
//                 .catchError((_) {});
//           } else {
//             AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
//           }
//         };
//         rp.onError = (res) {
//           if (mounted) {
//             setState(() {
//               _overlayState = PaymentOverlayState.openingGateway;
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
//       // FIX: clear all overlay flags on any error so nothing gets stuck
//       if (mounted) {
//         setState(() {
//           _overlayState = PaymentOverlayState.openingGateway;
//           _overlayState = PaymentOverlayState.processing;
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
//   bool get allItemsDelivered {
//     if (tableCartData == null) return false;
//
//     return tableCartData!.cartItems.isNotEmpty &&
//         tableCartData!.cartItems
//             .where((i) => i.orderStatus != "CANCELLED")
//             .every((i) => i.orderStatus == "DELIVERED");
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
//               title: const Text("Review Your Cart"),
//               backgroundColor: Colors.white,
//               centerTitle: true,
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
//                     if (!isLoading &&
//                         (tableCartData == null ||
//                             tableCartData!.cartItems.isEmpty))
//                       _buildEmptyCart()
//                     else ...[
//                       _buildCartItems(context),
//                       SizedBox(height: 5.h),
//                       _buildaddmoretext(context),
//                       SizedBox(height: 12.h),
//
//                       /// ✅ Use tableCartData, not _cartItems
//                       if (tableCartData != null &&
//                           tableCartData!.cartItems.isNotEmpty) ...[
//                         // if (send) _buildTableCheckoutCard(),
//                         if (allItemsDelivered) _buildTableCheckoutCard(),
//                         SizedBox(height: 12.h),
//                         if (isExpanded) ...[
//                           _buildCouponRow(theme, colorScheme),
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
//   final Map<int, bool> _sentStatus = {};
//
//   Future<void> _loadCartItems({int? updatedItemId}) async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     try {
//       final result = await food_Authservice.fetchTableCart();
//       if (result.isNotEmpty) {
//         final fetchedItems = result.first.cartItems;
//         setState(() {
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
//             } else {}
//           } else {
//             _cartItems = fetchedItems;
//           }
//           _isLoading = false;
//           for (var item in _cartItems) {
//             _sentStatus[item.itemId] = item.orderStatus == 'PENDING';
//           }
//         });
//       } else {
//         setState(() {
//           _cartItems = [];
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
//             // Cart Items List
//             ..._cartItems.map((item) {
//               final bool isLastItem = item == _cartItems.last;
//
//               return Container(
//                 margin: EdgeInsets.only(bottom: isLastItem ? 0 : 12),
//                 child: Column(
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       item.dishName,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   SizedBox(width: 8),
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Color(0xFFE8F5E9),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Text(
//                                       "₹${item.price}",
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: Color(0xFF2E7D32),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//
//                               SizedBox(height: 8),
//
//                               Row(
//                                 children: [
//                                   QuantityControl(
//                                     item: item,
//                                     onQuantityChanged: () {
//                                       setState(() {
//                                         tableCartData!.cartId;
//                                         item.itemId;
//                                         _sentStatus[item.itemId] = false;
//                                       });
//                                     },
//                                   ),
//
//                                   Spacer(),
//
//                                   SendButton(
//                                     item: item,
//                                     sent: _sentStatus[item.itemId] ?? false,
//                                     onSend: () async {
//                                       final noteController = _noteControllers
//                                           .putIfAbsent(
//                                             item.itemId,
//                                             () => TextEditingController(
//                                               text: item.note ?? '',
//                                             ),
//                                           );
//                                       final noteText = noteController.text
//                                           .trim();
//                                       if (isSending)
//                                         return; // prevent multiple taps
//                                       setState(() {
//                                         isSending = true;
//                                       });
//
//                                       isExpanded = !isExpanded;
//
//                                       try {
//                                         bool success = await food_Authservice
//                                             .updateCartItemStatus(
//                                               itemId: item.itemId,
//                                               status: 'PENDING',
//                                               note: noteText.isNotEmpty
//                                                   ? noteText
//                                                   : null,
//                                             );
//
//                                         if (success) {
//                                           await _loadCartItems();
//                                           setState(() {
//                                             _sentStatus[item.itemId] = true;
//                                             send = true;
//                                           });
//                                           AppAlert.success(
//                                             context,
//                                             "✅ Order placed for ${item.dishName}",
//                                           );
//                                         } else {
//                                           AppAlert.error(
//                                             context,
//                                             "❌ Failed to place order for ${item.dishName}",
//                                           );
//                                         }
//                                       } finally {
//                                         if (mounted) {
//                                           setState(() {
//                                             isSending = false;
//                                           });
//                                         }
//                                       }
//                                     },
//                                     child: isSending
//                                         ? SizedBox(
//                                             width: 20,
//                                             height: 20,
//                                             child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2,
//                                             ),
//                                           )
//                                         : Text(
//                                             _sentStatus[item.itemId] == true
//                                                 ? "Sent"
//                                                 : "Send",
//                                           ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 12),
//
//                     TextField(
//                       controller: _getNoteController(item),
//                       maxLines: 1,
//                       textInputAction: TextInputAction.done,
//                       decoration: InputDecoration(
//                         hintText: "Add cooking instructions / note",
//                         hintStyle: TextStyle(fontSize: 13),
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 10,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                       ),
//                       onChanged: (value) {
//                         item.note = value; // store locally
//                       },
//                     ),
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
//
//             // Subtotal Section
//             Container(
//               margin: EdgeInsets.only(top: 16),
//               padding: EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(width: 1, color: Colors.grey[200]!),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Sub Total",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                   Text(
//                     "₹${subtotal.toStringAsFixed(2)}",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: AppColors.of(context).primary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
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
//                 ..onTap = () {
//                   isExpanded = !isExpanded;
//                   // print(seatingId);
//
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => tablemneuScreen(
//                         vendorId: tableCartData!.vendorId,
//                         seatingId: tableCartData!.seatingId,
//                       ),
//                     ),
//                   );
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
//   Widget _buildTotalRow(String label, num value, {bool isBold = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: isBold ? Colors.black87 : Colors.grey[700],
//             ),
//           ),
//           Text(
//             "₹$value",
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
//   // Widget _buildCouponRow(ThemeData theme, ColorScheme colorScheme) {
//   //   final bool isCouponApplied =
//   //       appliedCouponCode != null && appliedCouponCode!.isNotEmpty;
//   //
//   //   return GestureDetector(
//   //     onTap: () {
//   //       if (!isCouponApplied) {
//   //         // _showCouponBottomSheet();
//   //       }
//   //     },
//   //     child: Container(
//   //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//   //       decoration: BoxDecoration(
//   //         color: isCouponApplied
//   //             // ignore: deprecated_member_use
//   //             ? colorScheme.primary.withOpacity(0.1)
//   //             : Colors.grey.shade100,
//   //         borderRadius: BorderRadius.circular(12.r),
//   //         border: Border.all(
//   //           color: isCouponApplied
//   //               // ignore: deprecated_member_use
//   //               ? colorScheme.primary.withOpacity(0.3)
//   //               : Colors.grey.shade300,
//   //           width: 1.0,
//   //         ),
//   //       ),
//   //       child: Row(
//   //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //         children: [
//   //           Row(
//   //             children: [
//   //               Icon(
//   //                 Icons.local_offer_outlined,
//   //                 size: 20.sp,
//   //                 color: isCouponApplied
//   //                     ? colorScheme.primary
//   //                     : Colors.grey.shade600,
//   //               ),
//   //               SizedBox(width: 12.w),
//   //               Text(
//   //                 isCouponApplied ? appliedCouponCode! : "Apply Coupon",
//   //                 style: theme.textTheme.bodyMedium?.copyWith(
//   //                   fontWeight: FontWeight.w500,
//   //                   color: isCouponApplied
//   //                       ? colorScheme.primary
//   //                       : Colors.grey.shade800,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //
//   //           // Show Remove button if coupon applied, else arrow
//   //           isCouponApplied
//   //               ? GestureDetector(
//   //                   onTap: () {
//   //                     // Remove coupon
//   //                     setState(() {
//   //                       appliedCouponCode = null;
//   //                       appliedCouponId = null;
//   //                       tableCartData?.couponCode = null;
//   //                     });
//   //                     ScaffoldMessenger.of(context).showSnackBar(
//   //                       const SnackBar(
//   //                         content: Text("Coupon removed"),
//   //                         backgroundColor: Colors.red,
//   //                       ),
//   //                     );
//   //                   },
//   //                   child: Text(
//   //                     "Remove",
//   //                     style: theme.textTheme.bodySmall?.copyWith(
//   //                       color: Colors.red,
//   //                       fontWeight: FontWeight.w600,
//   //                     ),
//   //                   ),
//   //                 )
//   //               : Icon(
//   //                   Icons.arrow_forward_ios_rounded,
//   //                   size: 16.sp,
//   //                   color: Colors.grey.shade600,
//   //                 ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Widget _buildCouponRow(ThemeData theme, ColorScheme colorScheme) {
//     final bool isCouponApplied =
//         appliedCouponCode != null && appliedCouponCode!.isNotEmpty;
//
//     return GestureDetector(
//       onTap: () {
//         if (!isCouponApplied) {
//           _showCouponBottomSheet();
//         }
//       },
//       child: Container(
//         padding: EdgeInsets.all(12.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12.r),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.local_offer_outlined,
//                   size: 20.sp,
//                   color: isCouponApplied
//                       ? colorScheme.primary
//                       : Colors.grey.shade600,
//                 ),
//                 SizedBox(width: 12.w),
//                 Text(
//                   isCouponApplied ? appliedCouponCode! : "Apply Coupon",
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w500,
//                     color: isCouponApplied
//                         ? colorScheme.primary
//                         : Colors.grey.shade800,
//                   ),
//                 ),
//               ],
//             ),
//
//             // REMOVE BUTTON
//             if (isCouponApplied)
//               GestureDetector(
//                 onTap: () async {
//                   if (tableCartData?.cartId == null) {
//                     AppAlert.error(context, "Invalid cart");
//                     return;
//                   }
//
//                   try {
//                     // ✅ REMOVE COUPON → SEND 0
//                     final result = await food_Authservice.updateCartSettings(
//                       cartId: tableCartData!.cartId,
//                       couponId: tableCartData!.couponId, // 🔥 IMPORTANT
//                       applyCoupon: "NOT_APPLIED",
//                     );
//
//                     if (!result.success) {
//                       AppAlert.error(context, "Failed to remove coupon.");
//                       return;
//                     }
//
//                     // Reload server cart FIRST
//                     await _initializeData();
//
//                     // Sync UI AFTER server success
//                     setState(() {
//                       appliedCouponCode = null;
//                       appliedCouponId = null;
//                     });
//                     AppAlert.success(context, "Coupon removed successfully");
//                   } catch (e) {
//                     // debugPrint("Coupon remove error: $e");
//                     AppAlert.error(context, "Network error. Try again.");
//                   }
//                 },
//                 child: Text(
//                   "Remove",
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: Colors.red,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               )
//             else
//               Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 16.sp,
//                 color: Colors.grey.shade600,
//               ),
//           ],
//         ),
//       ),
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
//     final orderType = tableCartData?.orderType ?? "DINE_IN"; // default fallback
//     final subtotal = tableCartData!.subtotal;
//     final gstTotal = tableCartData!.gstTotal;
//     final grandTotal = tableCartData!.grandTotal;
//     final discountAmount = tableCartData?.discountAmount ?? 0;
//     final platformcharges = tableCartData?.platformCharges ?? 0;
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
//                 _buildTotalRow("platform Charges", platformcharges),
//
//                 if (orderType == "TABLE_DINE_IN" && discountAmount > 0) ...[
//                   _buildServiceChargesRow(theme, colorScheme),
//                 ],
//
//                 _buildTotalRow("SGST", gstTotal / 2),
//                 _buildTotalRow("CGST", gstTotal / 2),
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
//   Widget _builddiscountRow(String label, num value, {bool isBold = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: isBold ? Colors.black87 : Colors.grey[700],
//             ),
//           ),
//           Text(
//             "-₹$value",
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
//     return Container(
//       decoration: BoxDecoration(
//         // ignore: deprecated_member_use
//         color: colorScheme.surfaceContainerHighest.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "Service Charges",
//             style: theme.textTheme.bodyMedium?.copyWith(
//               // ignore: deprecated_member_use
//               color: colorScheme.onSurface.withOpacity(0.9),
//             ),
//           ),
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () async {
//                   final newState = !isServiceChargeApplied;
//                   if (tableCartData?.cartId == null) {
//                     return;
//                   }
//                   await food_Authservice.updateServiceCharges(
//                     cartId: tableCartData!.cartId,
//                     serviceCharge: isServiceChargeApplied
//                         ? "NOT_APPLICABLE"
//                         : "APPLICABLE",
//                   );
//                   setState(() {
//                     isServiceChargeApplied = newState;
//                     _initializeData();
//                   });
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 12.w,
//                     vertical: 6.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isServiceChargeApplied
//                         ? colorScheme.errorContainer
//                         : colorScheme.primaryContainer,
//                     borderRadius: BorderRadius.circular(20.r),
//                   ),
//                   child: Text(
//                     isServiceChargeApplied ? "Remove" : "Apply",
//                     style: theme.textTheme.labelSmall?.copyWith(
//                       color: isServiceChargeApplied
//                           ? colorScheme.onErrorContainer
//                           : colorScheme.onPrimaryContainer,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Text(
//                 isServiceChargeApplied
//                     ? "-₹${serviceCharges.toStringAsFixed(2)}"
//                     : "₹${serviceCharges.toStringAsFixed(2)}",
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: colorScheme.onSurface,
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
//         // _buildPaymentSection(theme, colorScheme),
//         tablecartwallet(
//           wallet: wallet,
//           onSelectionChanged: (method, subWallets) {
//             setState(() {
//               selectedPaymentMethod = method;
//               selectedSubWallets = subWallets;
//             });
//           },
//         ),
//         SizedBox(height: 16.h),
//         _buildPlaceOrderButton(theme, colorScheme),
//       ],
//     );
//   }
//
//   Widget _buildPaymentSection(ThemeData theme, ColorScheme colorScheme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Row(
//         //   children: [
//         //     Icon(Icons.payment_outlined, color: colorScheme.primary, size: 22),
//         //     SizedBox(width: 8.w),
//         //     Text(
//         //       'Payment Method',
//         //       style: theme.textTheme.titleLarge?.copyWith(
//         //         fontWeight: FontWeight.bold,
//         //       ),
//         //     ),
//         //   ],
//         // ),
//         // SizedBox(height: 12.h),
//         Column(
//           children: [
//             _buildPaymentOption(
//               "Maamaas_Wallet",
//               Icons.account_balance_wallet_outlined,
//               "Maamaas_Wallet",
//               theme,
//               colorScheme,
//             ),
//             if (selectedPaymentMethod == "Maamaas_Wallet" &&
//                 wallet != null) ...[
//               SizedBox(height: 8.h),
//               Padding(
//                 padding: EdgeInsets.only(left: 32.w),
//                 child: Column(
//                   children: [
//                     _buildSubWalletOption(
//                       "Company Credited Amount",
//                       wallet!.companyLoadedAmount,
//                       theme,
//                       colorScheme,
//                     ),
//                     _buildSubWalletOption(
//                       "Self Credited Amount",
//                       wallet!.selfLoadedAmount,
//                       theme,
//                       colorScheme,
//                     ),
//                     _buildSubWalletOption(
//                       "Cashbacks",
//                       wallet!.cashbackAmount,
//                       theme,
//                       colorScheme,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//             _buildPaymentOption(
//               "Online Payment",
//               Icons.credit_card_outlined,
//               "Online_Payment",
//               theme,
//               colorScheme,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPaymentOption(
//     String title,
//     IconData icon,
//     String value,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     final isSelected = selectedPaymentMethod == value;
//
//     return Card(
//       elevation: 0,
//       margin: EdgeInsets.only(bottom: 8.h),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         side: BorderSide(
//           color: isSelected ? colorScheme.primary : Colors.grey.shade300,
//           width: isSelected ? 1.5 : 1,
//         ),
//       ),
//       // ignore: deprecated_member_use
//       color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.white,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12.r),
//         onTap: () {
//           setState(() {
//             selectedPaymentMethod = value;
//             if (checkoutData != null) checkoutData!['paymentMethod'] = value;
//             if (value != "Maamaas_Wallet") selectedSubWallet = "";
//           });
//         },
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 color: isSelected ? colorScheme.primary : Colors.grey[600],
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(title, style: theme.textTheme.titleMedium),
//                     if (value == "Maamaas_Wallet")
//                       Container(
//                         decoration: BoxDecoration(
//                           // ignore: deprecated_member_use
//                           color: colorScheme.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(10.r),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             wallet != null
//                                 ? "₹${wallet!.totalBalance.toStringAsFixed(2)}"
//                                 : "Loading...",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isSelected
//                                   ? colorScheme.primary
//                                   : Colors.grey[700],
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               if (isSelected)
//                 Icon(Icons.check_circle, color: colorScheme.primary),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSubWalletOption(
//     String title,
//     double amount,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     final isSelected = selectedSubWallet == title;
//
//     return Card(
//       elevation: 0,
//       margin: EdgeInsets.only(bottom: 8.h),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.r),
//         side: BorderSide(
//           color: isSelected ? colorScheme.primary : Colors.grey.shade200,
//           width: isSelected ? 1.5 : 1,
//         ),
//       ),
//       // ignore: deprecated_member_use
//       color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.white,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8.r),
//         onTap: () => setState(() => selectedSubWallet = title),
//         child: Padding(
//           padding: EdgeInsets.all(12.w),
//           child: Row(
//             children: [
//               Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
//               Container(
//                 decoration: BoxDecoration(
//                   // ignore: deprecated_member_use
//                   color: colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     "₹${amount.toStringAsFixed(2)}",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: isSelected
//                           ? colorScheme.primary
//                           : Colors.grey[700],
//                     ),
//                   ),
//                 ),
//               ),
//               if (isSelected)
//                 Icon(Icons.check, size: 18, color: colorScheme.primary),
//             ],
//           ),
//         ),
//       ),
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
//   late final List<CartItem> _cartItems = [];
//   final bool _isServiceChargeApplied = true;
//   TableCartModel? tableCartData;
//
//   void _updateTotalsLocally() {
//     double subtotal = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
//     double gstTotal = subtotal * 0.18; // example
//     double serviceCharges = _isServiceChargeApplied ? 20 : 0;
//
//     setState(() {
//       tableCartData?.subtotal = subtotal;
//       tableCartData?.gstTotal = gstTotal;
//       tableCartData?.serviceCharges = serviceCharges;
//       tableCartData?.grandTotal = subtotal + gstTotal + serviceCharges;
//     });
//   }
//
//   Future<void> _updateQuantity(int newQuantity) async {
//     setState(() {
//       _isUpdating = true;
//     });
//
//     bool success = await food_Authservice.updateCartItemQuantity(
//       itemId: widget.item.itemId,
//       quantity: newQuantity,
//     );
//
//     if (success) {
//       setState(() {
//         widget.item.quantity = newQuantity;
//         widget.item.totalPrice = widget.item.price * newQuantity;
//         _isUpdating = false;
//       });
//       widget.onQuantityChanged();
//       _updateTotalsLocally();
//     } else {
//       setState(() {
//         _isUpdating = false;
//       });
//       AppAlert.error(context, "❌ Failed to update quantity");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade400),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             icon: Icon(Icons.remove, size: 20),
//             onPressed: _isUpdating || widget.item.quantity <= 0
//                 ? null
//                 : () => _updateQuantity(widget.item.quantity - 1),
//           ),
//           _isUpdating
//               ? SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               : Text(
//                   "${widget.item.quantity}",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//           IconButton(
//             icon: Icon(Icons.add_circle_outline, size: 20),
//             onPressed: _isUpdating
//                 ? null
//                 : () => _updateQuantity(widget.item.quantity + 1),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class SendButton extends StatelessWidget {
//   final CartItem item;
//   final bool sent;
//   final VoidCallback onSend;
//   final Widget? child;
//
//   const SendButton({
//     super.key,
//     required this.item,
//     required this.sent,
//     required this.onSend,
//     this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onSend,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         decoration: BoxDecoration(
//           color: sent ? Colors.green : Theme.of(context).primaryColor,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.black12),
//         ),
//         child: Center(
//           child: Text(
//             sent ? "Sent" : "Send",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../Services/paymentservice/razorpayservice.dart';
import '../../../Models/subscrptions/coupon_model.dart';
import '../../../Models/subscrptions/wallet_model.dart';
import '../../../Models/food/tablecartmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../Menu/table_menu.dart';
import '../food_invoice.dart';
import 'package:maamaas/Services/App_color_service/app_colours.dart';

enum PaymentOverlayState {
  none,
  placingOrder,
  openingGateway,
  processing,
  success,
}

// ignore: camel_case_types
class tablecart extends StatefulWidget {
  final int seatingId;
  const tablecart({super.key, required this.seatingId});

  @override
  State<tablecart> createState() => _tablecartState();
}

// ignore: camel_case_types
class _tablecartState extends State<tablecart> {
  TableCartModel? tableCartData;
  // Single source-of-truth for loading — removed duplicate `isLoading`
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadWallet();
    _loadCartItems();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 400),
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
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadWallet() async {
    final fetchedWallet = await subscription_AuthService.fetchWallet();
    setState(() {
      wallet = fetchedWallet;
    });
  }

  Future<void> _onRefresh() async {
    final updatedCarts = await food_Authservice.fetchTableCart(
      // widget.seatingId,
    );
    final updatedWallet = await subscription_AuthService.fetchWallet();

    if (!mounted) return;

    setState(() {
      tableCartData = updatedCarts.isNotEmpty ? updatedCarts.first : null;
      wallet = updatedWallet;
    });
  }

  Future<void> _initializeData() async {
    try {
      final data = await food_Authservice.fetchTableCart();
      if (data.isEmpty) {
        return;
      }
      if (!mounted) return;
      setState(() {
        tableCartData = data.first;
      });
      // ignore: empty_catches
    } catch (e) {}
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
      AppAlert.error(context, "⚠️ Please select a payment method");
      return;
    }

    // ❌ Wallet selected but no sub-wallet chosen
    if (selectedPaymentMethod == "Maamaas_Wallet" &&
        selectedSubWallets.isEmpty) {
      AppAlert.error(context, "⚠️ Please select at least one wallet type");
      return;
    }

    // ❌ Wallet balance check
    if (selectedPaymentMethod == "Maamaas_Wallet") {
      final wb = getSelectedWalletBalance();
      final gt = (tableCartData?.grandTotal ?? 0).toDouble();

      if (wb < gt) {
        AppAlert.error(
          context,
          "❌ Insufficient wallet balance\nWallet: ₹${wb.toStringAsFixed(2)}\nOrder Total: ₹${gt.toStringAsFixed(2)}",
        );
        return;
      }
    }

    setState(() => isPlacingOrder = true);
    try {
      if (selectedPaymentMethod == "Online_Payment") {
        final amount = (tableCartData?.grandTotal ?? 0).toDouble();

        // ── Show "opening gateway" overlay while createOrder API runs ────
        if (mounted) {
          setState(() => _overlayState = PaymentOverlayState.openingGateway);
        }
        final orderId = await food_Authservice.createOrder(amount);
        if (mounted) {
          setState(() => _overlayState = PaymentOverlayState.openingGateway);
        }

        if (orderId == null) {
          AppAlert.error(context, "❌ Failed to create payment order");
          return;
        }
        final rp = RazorpayService();
        rp.onSuccess = (res) async {
          final pid = res.paymentId!;
          final oid = res.orderId!;
          // ── Show "confirming payment" overlay while order API runs ──────
          if (mounted) {
            setState(() => _overlayState = PaymentOverlayState.processing);
          }
          await _callOrderApi(
            paymentMethod: "Online_Payment",
            razorpayPaymentId: pid,
            razorpayOrderId: oid,
            amount: amount,
          );

          // Reset overlay after order API completes
          if (mounted) {
            setState(() => _overlayState = PaymentOverlayState.none);
          }

          if (mounted) {
            food_Authservice
                .capturePayment(paymentId: pid, amount: amount)
                .catchError((_) {});
          } else {
            AppAlert.error(context, "❌ Order failed. Refund in 3–5 days.");
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
        // FIX: do NOT return early — let finally reset isPlacingOrder
        //      (Razorpay sheet is already open; button spinner can stop)
        return;
      }

      final amt = tableCartData!.grandTotal.toDouble();
      {
        await _callOrderApi(
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

      // Reset overlay on any error so UI never gets stuck
      if (mounted) {
        setState(() {
          _overlayState = PaymentOverlayState.none;
        });
      }

      AppAlert.error(context, message);
    } finally {
      // FIX: always reset the Place Order button spinner
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

  List<String> mapWalletsToEnum(List<String> selectedWallets) {
    return selectedWallets.map((wallet) {
      switch (wallet) {
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
          return wallet.toUpperCase().replaceAll(' ', '_');
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
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()), // <-- FIXED
      amount: amount,
    );

    if (result['success'] == false) {
      AppAlert.error(context, result['error'] ?? "Unknown error");
      return;
    }
    final orderId = result['orderId'];
    if (orderId == null || orderId is! int) {
      AppAlert.error(context, "⚠️ Invalid Order ID returned");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => food_Invoice(orderId: orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              title: const Text("Review Your Cart"),
              backgroundColor: Colors.white,
              centerTitle: true,
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.white,
              backgroundColor: Colors.blueAccent,
              displacement: 40,
              strokeWidth: 3,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isLoading &&
                        (tableCartData == null ||
                            tableCartData!.cartItems.isEmpty))
                      _buildEmptyCart()
                    else ...[
                      _buildCartItems(context),
                      SizedBox(height: 5.h),
                      _buildaddmoretext(context),
                      SizedBox(height: 12.h),

                      /// ✅ Use tableCartData, not _cartItems
                      if (tableCartData != null &&
                          tableCartData!.cartItems.isNotEmpty) ...[
                        // if (send) _buildTableCheckoutCard(),
                        if (allItemsDelivered) _buildTableCheckoutCard(),
                        SizedBox(height: 12.h),
                        if (isExpanded) ...[
                          _buildCouponRow(theme, colorScheme),
                          SizedBox(height: 12.h),
                          _buildsummaryCard(theme, colorScheme),
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

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add some delicious items',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  final Map<int, bool> _sentStatus = {};

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
          // Always sync tableCartData so totals (grandTotal, GST, etc.) update
          tableCartData = freshCart;
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
          for (var item in _cartItems) {
            _sentStatus[item.itemId] = item.orderStatus == 'PENDING';
          }
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

  Widget _buildCartItems(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.of(context).primary,
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              "Error loading cart",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCartItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Try Again", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Add some delicious items to get started",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final subtotal = _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      shadowColor: Colors.black,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Table No: ${tableCartData?.tableCode ?? ''}", // null-safe
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.of(context).primary,
                  ),
                ),
              ],
            ),
            // ),
            Divider(height: 24, thickness: 1, color: Colors.grey[200]),

            // Cart Items List
            ..._cartItems.map((item) {
              final bool isLastItem = item == _cartItems.last;

              return Container(
                margin: EdgeInsets.only(bottom: isLastItem ? 0 : 12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "₹${item.price}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),

                              Row(
                                children: [
                                  QuantityControl(
                                    item: item,
                                    onQuantityChanged: () {
                                      // Reload full cart so grand total, GST, subtotal all refresh
                                      _loadCartItems(
                                        updatedItemId: item.itemId,
                                      );
                                    },
                                  ),

                                  Spacer(),

                                  SendButton(
                                    item: item,
                                    sent: _sentStatus[item.itemId] ?? false,
                                    onSend: () async {
                                      final noteController = _noteControllers
                                          .putIfAbsent(
                                            item.itemId,
                                            () => TextEditingController(
                                              text: item.note ?? '',
                                            ),
                                          );
                                      final noteText = noteController.text
                                          .trim();
                                      // Prevent double-tap for THIS item only
                                      if (_isSendingMap[item.itemId] == true)
                                        return;
                                      setState(() {
                                        _isSendingMap[item.itemId] = true;
                                      });

                                      try {
                                        bool success = await food_Authservice
                                            .updateCartItemStatus(
                                              itemId: item.itemId,
                                              status: 'PENDING',
                                              note: noteText.isNotEmpty
                                                  ? noteText
                                                  : null,
                                            );

                                        if (success) {
                                          await _loadCartItems();
                                          setState(() {
                                            _sentStatus[item.itemId] = true;
                                            send = true;
                                          });
                                          scrollToBottom();
                                          AppAlert.success(
                                            context,
                                            "✅ Order placed for ${item.dishName}",
                                          );
                                        } else {
                                          AppAlert.error(
                                            context,
                                            "❌ Failed to place order for ${item.dishName}",
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isSendingMap[item.itemId] = false;
                                          });
                                        }
                                      }
                                    },
                                    child: (_isSendingMap[item.itemId] == true)
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _sentStatus[item.itemId] == true
                                                ? "Sent"
                                                : "Send",
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _getNoteController(item),
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: "Add cooking instructions / note",
                        hintStyle: TextStyle(fontSize: 13),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        item.note = value; // store locally
                      },
                    ),

                    if (!isLastItem)
                      Divider(
                        height: 24,
                        thickness: 1,
                        color: Colors.grey[200],
                      ),
                  ],
                ),
              );
            }),

            // Subtotal Section
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1, color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sub Total",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    "₹${subtotal.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.of(context).primary,
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

  TextEditingController _getNoteController(CartItem item) {
    return _noteControllers.putIfAbsent(
      item.itemId,
      () => TextEditingController(text: item.note ?? ''),
    );
  }

  Widget _buildaddmoretext(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Missed Something? ",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: "Add more items",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Highlight clickable text
                decoration: TextDecoration.underline, // Underline effect
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  isExpanded = !isExpanded;
                  // print(seatingId);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => tablemneuScreen(
                        vendorId: tableCartData!.vendorId,
                        seatingId: tableCartData!.seatingId,
                      ),
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCheckoutCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 12.h),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _initializeData();
          setState(() => isExpanded = !isExpanded);

          if (!isExpanded) {
            scrollToTop(); // expanding → go down
          } else {
            scrollToBottom();
            // collapsing → go up
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.of(context).primary,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 3,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: isExpanded
              ? Text(
                  'Generated Bill',
                  key: const ValueKey(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Generated Bill',
                  // 'Get Your Bill',
                  key: const ValueKey(2),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, num value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.grey[700],
            ),
          ),
          Text(
            "₹$value",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Theme.of(context).primaryColor : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponRow(ThemeData theme, ColorScheme colorScheme) {
    final bool isCouponApplied =
        appliedCouponCode != null && appliedCouponCode!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (!isCouponApplied) {
          _showCouponBottomSheet();
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 20.sp,
                  color: isCouponApplied
                      ? colorScheme.primary
                      : Colors.grey.shade600,
                ),
                SizedBox(width: 12.w),
                Text(
                  isCouponApplied ? appliedCouponCode! : "Apply Coupon",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCouponApplied
                        ? colorScheme.primary
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),

            // REMOVE BUTTON
            if (isCouponApplied)
              GestureDetector(
                onTap: () async {
                  if (tableCartData?.cartId == null) {
                    AppAlert.error(context, "Invalid cart");
                    return;
                  }

                  try {
                    // ✅ REMOVE COUPON → SEND 0
                    final result = await food_Authservice.updateCartSettings(
                      cartId: tableCartData!.cartId,
                      couponId: tableCartData!.couponId, // 🔥 IMPORTANT
                      applyCoupon: "NOT_APPLIED",
                    );

                    if (!result.success) {
                      AppAlert.error(context, "Failed to remove coupon.");
                      return;
                    }

                    // Reload server cart FIRST
                    await _initializeData();

                    // Sync UI AFTER server success
                    setState(() {
                      appliedCouponCode = null;
                      appliedCouponId = null;
                    });
                    AppAlert.success(context, "Coupon removed successfully");
                  } catch (e) {
                    // debugPrint("Coupon remove error: $e");
                    AppAlert.error(context, "Network error. Try again.");
                  }
                },
                child: Text(
                  "Remove",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: Colors.grey.shade600,
              ),
          ],
        ),
      ),
    );
  }

  void _showCouponBottomSheet() async {
    setState(() => isCouponLoading = true);
    final List<CouponModel> coupons = await food_Authservice.fetchCoupons();

    final int? cartVendor = tableCartData?.vendorId;

    setState(() => isCouponLoading = false);

    coupons.sort((a, b) {
      final aExpired = a.isExpired;
      final bExpired = b.isExpired;

      final aMismatch = !a.isApplicableForVendor(cartVendor);
      final bMismatch = !b.isApplicableForVendor(cartVendor);

      if (aExpired != bExpired) return aExpired ? 1 : -1;
      if (aMismatch != bMismatch) return aMismatch ? 1 : -1;
      return 0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        if (coupons.isEmpty) {
          return _emptyCouponView();
        }

        return Scaffold(
          // ✅ ADD THIS
          backgroundColor: Colors.transparent,
          body: SafeArea(
            top: false,
            child: Container(
              height: MediaQuery.of(sheetContext).size.height * 1,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _couponHeader(),
                  Expanded(
                    child: isCouponLoading
                        ? _couponSkeletonList()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: coupons.length,
                            itemBuilder: (context, index) {
                              final coupon = coupons[index];

                              final bool isExpired = coupon.isExpired;
                              final bool isMismatch = !coupon
                                  .isApplicableForVendor(cartVendor);

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
            ),
          ),
        );
      },
    );
  }

  Widget _emptyCouponView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No coupons available",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Check back later for new offers",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _couponHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Available Coupons",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isExpired
              // ignore: deprecated_member_use
              ? Colors.red.withOpacity(0.4)
              : isMismatch
              // ignore: deprecated_member_use
              ? Colors.orange.withOpacity(0.4)
              // ignore: deprecated_member_use
              : Colors.green.withOpacity(0.4),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.local_offer,
          color: isExpired
              ? Colors.red
              : isMismatch
              ? Colors.orange
              : Colors.green,
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: coupon.couponType == "PERCENTAGE"
                    // ignore: deprecated_member_use
                    ? Colors.blue.withOpacity(0.1)
                    // ignore: deprecated_member_use
                    : Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                coupon.couponType,

                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: coupon.couponType == "PERCENTAGE"
                      ? Colors.blue
                      : Colors.purple,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              coupon.code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpired ? Colors.red : Colors.black,
              ),
            ),

            /// COUPON TYPE BADGE
          ],
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isExpired
                  ? "Expired"
                  : isMismatch
                  ? "Not applicable for this restaurant"
                  : coupon.discountType == "PERCENTAGE"
                  ? "Get ${coupon.discountPercentage.toStringAsFixed(0)}% off"
                  : "Get ₹${coupon.discountPercentage.toStringAsFixed(0)} off",
              style: TextStyle(
                color: isExpired
                    ? Colors.red
                    : isMismatch
                    ? Colors.orange
                    : Colors.black,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              coupon.minimumOrderValue <= 0
                  ? "Applicable on any order"
                  : "Min order ₹${coupon.minimumOrderValue.toInt()}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),

        trailing: isDisabled
            ? Icon(Icons.block, color: isExpired ? Colors.red : Colors.orange)
            : const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.green,
              ),

        onTap: isDisabled
            ? () => _showCouponError(isExpired)
            : () => _applyCoupon(coupon),
      ),
    );
  }

  void _showCouponError(bool isExpired) {
    if (isExpired) {
      AppAlert.error(context, "This coupon has expired");
    } else {
      AppAlert.error(
        context,
        "This coupon is not applicable for this restaurant",
      );
    }
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

    AppAlert.success(context, "Coupon ${coupon.code} applied!");

    Navigator.pop(context);
  }

  Widget _buildsummaryCard(ThemeData theme, ColorScheme colorScheme) {
    final cart = tableCartData;
    if (cart == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final orderType = tableCartData?.orderType ?? "DINE_IN"; // default fallback
    final subtotal = tableCartData!.subtotal;
    final gstTotal = tableCartData!.gstTotal;
    final grandTotal = tableCartData!.grandTotal;
    final discountAmount = tableCartData?.discountAmount ?? 0;
    final platformcharges = tableCartData?.platformCharges ?? 0;

    return Column(
      children: [
        Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            // ignore: deprecated_member_use
            side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Order Summary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1, color: Colors.grey),
                _buildTotalRow("Sub Total", subtotal),
                if (discountAmount > 0) ...[
                  _builddiscountRow("Discount Amount", discountAmount),
                ],
                _buildTotalRow("platform Charges", platformcharges),

                if (orderType == "TABLE_DINE_IN" && discountAmount > 0) ...[
                  _buildServiceChargesRow(theme, colorScheme),
                ],

                _buildTotalRow("SGST", gstTotal / 2),
                _buildTotalRow("CGST", gstTotal / 2),
                Divider(height: 24.h, thickness: 1, color: Colors.grey),
                _buildTotalRow("Grand Total", grandTotal, isBold: true),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _buildCheckoutDetails(theme, colorScheme),
      ],
    );
  }

  Widget _builddiscountRow(String label, num value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.grey[700],
            ),
          ),
          Text(
            "-₹$value",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Theme.of(context).primaryColor : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChargesRow(ThemeData theme, ColorScheme colorScheme) {
    final serviceCharges = tableCartData?.serviceCharges ?? 0.0;
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: colorScheme.surfaceContainerHighest.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Service Charges",
            style: theme.textTheme.bodyMedium?.copyWith(
              // ignore: deprecated_member_use
              color: colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final newState = !isServiceChargeApplied;
                  if (tableCartData?.cartId == null) {
                    return;
                  }
                  await food_Authservice.updateServiceCharges(
                    cartId: tableCartData!.cartId,
                    serviceCharge: isServiceChargeApplied
                        ? "NOT_APPLICABLE"
                        : "APPLICABLE",
                  );
                  setState(() {
                    isServiceChargeApplied = newState;
                    _initializeData();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isServiceChargeApplied
                        ? colorScheme.errorContainer
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isServiceChargeApplied ? "Remove" : "Apply",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isServiceChargeApplied
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                isServiceChargeApplied
                    ? "-₹${serviceCharges.toStringAsFixed(2)}"
                    : "₹${serviceCharges.toStringAsFixed(2)}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutDetails(ThemeData theme, ColorScheme colorScheme) {
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
        _buildPlaceOrderButton(theme, colorScheme),
      ],
    );
  }

  Widget _buildPlaceOrderButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isPlacingOrder ? null : placeOrder,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
        ),
        child: isPlacingOrder
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: colorScheme.onPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${(tableCartData?.grandTotal ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

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

  Future<void> _updateQuantity(int newQuantity) async {
    setState(() {
      _isUpdating = true;
    });

    bool success = await food_Authservice.updateCartItemQuantity(
      itemId: widget.item.itemId,
      quantity: newQuantity,
    );

    if (success) {
      setState(() {
        widget.item.quantity = newQuantity;
        widget.item.totalPrice = widget.item.price * newQuantity;
        _isUpdating = false;
      });
      // Notify parent to reload cart (totals, grandTotal, etc.)
      widget.onQuantityChanged();
    } else {
      setState(() {
        _isUpdating = false;
      });
      AppAlert.error(context, "❌ Failed to update quantity");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove, size: 20),
            onPressed: _isUpdating || widget.item.quantity <= 0
                ? null
                : () => _updateQuantity(widget.item.quantity - 1),
          ),
          _isUpdating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  "${widget.item.quantity}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, size: 20),
            onPressed: _isUpdating
                ? null
                : () => _updateQuantity(widget.item.quantity + 1),
          ),
        ],
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final CartItem item;
  final bool sent;
  final VoidCallback onSend;
  final Widget? child;

  const SendButton({
    super.key,
    required this.item,
    required this.sent,
    required this.onSend,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSend,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: sent ? Colors.green : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Text(
            sent ? "Sent" : "Send",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _couponSkeletonList() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (_, __) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    },
  );
}
