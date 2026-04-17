// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import '../../Services/Auth_service/Subscription_authservice.dart';
// import '../../Services/Auth_service/catering_authservice.dart';
// import '../../Services/Auth_service/food_authservice.dart';
// import '../../Services/paymentservice/razorpayservice.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../widgets/widgets/skeleton/cart_skeleton.dart';
// import '../../Models/caterings/catering_cart_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../Models/subscrptions/wallet_model.dart';
// import '../../providers/addressmodel_provider.dart';
// import 'package:flutter/material.dart';
// import '../foodmainscreen.dart';
// import '../screens/saved_address.dart';
// import 'package:intl/intl.dart';
// import 'cartpayment.dart';
// import 'catering_invoice.dart';
// import 'package:maamaas/Services/App_color_service/app_colours.dart';
//
// // ignore: camel_case_types
// class catering_cart extends ConsumerStatefulWidget {
//   const catering_cart({super.key});
//
//   @override
//   ConsumerState<catering_cart> createState() => _catering_cartState();
// }
//
// // ignore: camel_case_types
// class _catering_cartState extends ConsumerState<catering_cart> {
//   catering_Cart? cart;
//   String? appliedCouponCode;
//   bool isExpanded = false;
//   String selectedPaymentMethod = " ";
//   String selectedSubWallet = " ";
//   bool isPlacingOrder = false;
//   DateTime? selectedDate;
//   DateTime? selectedDateTime;
//   String? selectedAddress;
//   bool isLoading = false;
//   Map<String, dynamic>? checkoutData;
//   late List<CartPackage> items = [];
//   Wallet? wallet;
//   int? cartId;
//   bool _isCateringSummaryExpanded = false;
//   // late ScrollController _scrollController;
//   Set<String> selectedSubWallets = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _loadCartData();
//     _loadWallet();
//     refreshCart();
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   ScrollController _scrollController = ScrollController();
//
//   // Only scroll on button click
//   void scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   Future<void> _loadWallet() async {
//     try {
//       final fetchedWallet = await subscription_AuthService
//           .fetchWallet(); // API call
//       if (!mounted) return; // safety
//       setState(() {
//         wallet = fetchedWallet;
//       });
//     } catch (e) {
//       debugPrint("⚠️ _loadWallet failed: $e");
//       if (!mounted) return;
//       AppAlert.error(context, "❌ Failed to load wallet");
//     }
//   }
//
//   Future<void> _onRefresh() async {
//     final updatedCart = await catering_authservice.fetchUserCart();
//     final updatedwallet = await subscription_AuthService.fetchWallet();
//
//     if (!mounted) return;
//
//     setState(() {
//       cart = updatedCart;
//       wallet = updatedwallet;
//     });
//   }
//
//   Future<void> _loadCartData() async {
//     setState(() => isLoading = true);
//
//     try {
//       final catering_Cart? cart = await catering_authservice.fetchUserCart();
//       debugPrint("🛒 cart from API: $cart");
//
//       if (cart == null) {
//         debugPrint("❌ Cart is null (no cart for user)");
//         items = [];
//       } else {
//         items = cart.items;
//         debugPrint("🛍️ Cart items: $items");
//       }
//     } catch (e) {
//       debugPrint("❌ Error fetching cart: $e");
//     }
//
//     setState(() => isLoading = false);
//   }
//
//   Future<void> placeOrder() async {
//     final prefs = await SharedPreferences.getInstance();
//     final int userId = prefs.getInt('userId') ?? 0;
//     final double grandTotal = cart?.total ?? 0.0;
//
//     if (selectedPaymentMethod.isEmpty) {
//       AppAlert.error(context, "⚠️ Please select a payment method");
//       return;
//     }
//
//     setState(() => isPlacingOrder = true);
//
//     final razorpay = RazorpayService();
//
//     try {
//       final String paymentMethod = selectedPaymentMethod;
//
//       final String? walletType = paymentMethod == "Maamaas_Wallet"
//           ? _mapSubWalletToBackend(selectedSubWallet)
//           : null;
//
//       /// 🪙 WALLET VALIDATION
//       /// 🪙 WALLET VALIDATION (FIXED)
//       if (paymentMethod == "Maamaas_Wallet") {
//         if (selectedSubWallets.isEmpty) {
//           AppAlert.error(context, "⚠️ Please select at least one sub wallet");
//           setState(() => isPlacingOrder = false);
//           return;
//         }
//
//         double required = grandTotal;
//         double available = 0;
//
//         if (selectedSubWallets.contains("Company Loaded")) {
//           available += wallet!.companyLoadedAmount;
//         }
//
//         if (selectedSubWallets.contains("Self Loaded")) {
//           available += wallet!.selfLoadedAmount;
//         }
//
//         if (selectedSubWallets.contains("Cashbacks")) {
//           available += wallet!.cashbackAmount;
//         }
//
//         if (selectedSubWallets.contains("Postpaid used amount")) {
//           available += wallet!.postPaidUsage;
//         }
//
//         debugPrint("💰 Available: $available");
//         debugPrint("💳 Required: $required");
//         debugPrint("🏦 Selected Wallets: $selectedSubWallets");
//
//         if (available < required) {
//           AppAlert.error(
//             context,
//             "Insufficient wallet balance! Available ₹${available.toStringAsFixed(2)}, Required ₹${required.toStringAsFixed(2)}",
//           );
//           setState(() => isPlacingOrder = false);
//           return;
//         }
//       }
//
//       /// 🌐 ONLINE PAYMENT
//       if (paymentMethod == "Online_Payment") {
//         final orderId = await catering_authservice.createOrder(grandTotal);
//
//         if (orderId == null) {
//           AppAlert.error(context, "Failed to create Razorpay order ❌");
//           return;
//         }
//
//         /// HANDLE SUCCESS
//         razorpay.onSuccess = (response) async {
//           /// CAPTURE PAYMENT
//           final bool captured = await catering_authservice.capturePayment(
//             paymentId: response.paymentId!,
//             amount: grandTotal,
//           );
//
//           if (!captured) {
//             AppAlert.error(context, "Payment capture failed ❌");
//             return;
//           }
//
//           /// CALL ORDER API AFTER SUCCESS
//           await _callOrderApi(
//             userId: userId,
//             paymentMethod: paymentMethod,
//             razorpayPaymentId: response.paymentId!,
//             razorpayOrderId: response.orderId ?? "",
//             grandTotal: grandTotal,
//             walletTypes: mapWalletsToEnum(
//               selectedSubWallets.toList(),
//             ), // 🔥 ADD THIS
//           );
//         };
//
//         /// HANDLE FAILURE
//         // razorpay.onError = (error) {
//         //   AppAlert.error(context, "Payment Failed ❌");
//         // };
//
//         razorpay.startPayment(
//           orderId: orderId,
//           amount: grandTotal,
//           // name: "Food Order Payment",
//           description: "Online Payment via Razorpay",
//         );
//
//         return;
//       }
//
//       /// 🧾 COD / WALLET ORDER
//       await _callOrderApi(
//         userId: userId,
//         paymentMethod: paymentMethod,
//         razorpayPaymentId: "",
//         razorpayOrderId: "",
//         grandTotal: grandTotal,
//         walletTypes: mapWalletsToEnum(
//           selectedSubWallets.toList(),
//         ), // 🔥 ADD THIS
//       );
//     } catch (e) {
//       AppAlert.error(context, "Error placing order: $e");
//     } finally {
//       setState(() => isPlacingOrder = false);
//     }
//   }
//
//   String? _mapSubWalletToBackend(String? subWallet) {
//     switch (subWallet) {
//       case "Company Credited Amount":
//         return "COMPANY_LOADED";
//       case "Self Credited Amount":
//         return "SELF_LOADED";
//       case "Cashbacks":
//         return "CASHBACK";
//       case "Earned Amount":
//         return "EARNED_AMOUNT";
//       default:
//         return null;
//     }
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
//   double getSelectedWalletBalance() {
//     if (wallet == null) return 0;
//
//     double total = 0;
//
//     if (selectedSubWallets.contains("Company Loaded")) {
//       total += wallet!.companyLoadedAmount;
//     }
//     if (selectedSubWallets.contains("Self Loaded")) {
//       total += wallet!.selfLoadedAmount;
//     }
//     if (selectedSubWallets.contains("Cashbacks")) {
//       total += wallet!.cashbackAmount;
//     }
//     if (selectedSubWallets.contains("Postpaid used amount")) {
//       total += wallet!.postPaidUsage;
//     }
//
//     return total;
//   }
//
//   Future<void> _callOrderApi({
//     required int userId,
//     required String paymentMethod,
//     required String razorpayPaymentId,
//     required String razorpayOrderId,
//     required double grandTotal,
//     // String? walletType,
//     List<String>? walletTypes,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartId = prefs.getInt('cartId');
//
//     if (cartId == null || cartId <= 0) {
//       AppAlert.error(context, "❌ Cart ID missing or invalid");
//       return;
//     }
//
//     debugPrint("📦 [Order API] cartId: $cartId, userId: $userId");
//     debugPrint("💳 paymentMethod: $paymentMethod");
//     debugPrint("💰 grandTotal: $grandTotal");
//     debugPrint("🏦 walletType: $walletTypes");
//
//     final result = await catering_authservice.placeOrder(
//       userId: userId,
//       cartId: cartId,
//       paymentMethod: paymentMethod,
//       razorpayPaymentId: razorpayPaymentId,
//       razorpayOrderId: razorpayOrderId,
//       // walletType: walletType,
//       // walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
//       walletTypes: walletTypes,
//       grandTotal: grandTotal,
//     );
//     debugPrint(
//       "🧪 walletType FINAL: ${mapWalletsToEnum(selectedSubWallets.toList()).join(",")}",
//     );
//     // 🔥 FIX HERE
//     final int? orderId = result?['orderId'];
//
//     if (orderId != null && orderId > 0) {
//       await prefs.setInt('cateringorderId', orderId);
//
//       debugPrint("✅ Order placed successfully → Order ID: $orderId");
//
//       // Optional: clear cart after successful order
//       await prefs.remove('cartId');
//       AppAlert.success(context, "✅ Order placed successfully");
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => catering_invoice(orderId: orderId),
//         ),
//       );
//     } else {
//       debugPrint("❌ Failed to place order → Response: $result");
//       AppAlert.error(context, "❌ Failed to place order");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Center(child: Text("Catering Cart")),
//         actions: [
//           GestureDetector(
//             onTap: () async {
//               final ok = await catering_authservice.deleteCart();
//               if (!mounted) return;
//               if (ok) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => MainScreenfood()),
//                 );
//                 AppAlert.success(context, 'Cart cleared');
//               } else {
//                 AppAlert.error(context, 'Failed to clear cart');
//               }
//             },
//             child: Container(
//               margin: EdgeInsets.only(right: 12.w),
//               padding: EdgeInsets.all(8.w),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.08),
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.red.withOpacity(0.2)),
//               ),
//               child: Icon(
//                 Icons.delete_outline_rounded,
//                 size: 18.sp,
//                 color: Colors.red,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _onRefresh,
//         color: Colors.white,
//         backgroundColor: Colors.blueAccent,
//         displacement: 40,
//         strokeWidth: 3,
//
//         /// 👇 THIS IS REQUIRED
//         child: isLoading
//             ? CartSkeleton(type: CartSkeletonType.fullCart)
//             : SingleChildScrollView(
//                 controller: _scrollController,
//                 physics:
//                     const AlwaysScrollableScrollPhysics(), // 🔥 IMPORTANT for RefreshIndicator
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     items.isEmpty ? _buildEmptyCart() : _buildCartItems(),
//
//                     const SizedBox(height: 16),
//
//                     if (cart != null)
//                       buildCateringSummaryCard(
//                         cart!,
//                         Theme.of(context),
//                         Theme.of(context).colorScheme,
//                       ),
//
//                     const SizedBox(height: 16),
//
//                     _buildDateAndTime(),
//
//                     const SizedBox(height: 16),
//
//                     _buildDeliveryAddress(),
//
//                     const SizedBox(height: 16),
//
//                     _buildCheckoutCard(),
//
//                     if (isExpanded) _buildCheckoutDetails(theme, colorScheme),
//
//                     const SizedBox(height: 30), // bottom spacing
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
//
//   Future<void> _pickDateTime() async {
//     DateTime today = DateTime.now();
//     DateTime firstAllowedDate = today.add(
//       Duration(days: 2),
//     ); // Only after 2 days
//     DateTime lastAllowedDate = today.add(Duration(days: 365));
//     final DateTime? date = await showDatePicker(
//       context: context,
//       initialDate: firstAllowedDate, // Start picker from allowed date
//       firstDate: firstAllowedDate, // Disable all before this
//       lastDate: lastAllowedDate,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Colors.deepPurple, // header background color
//               onPrimary: Colors.white, // header text color
//               onSurface: Colors.black, // body text color
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.black, // buttons color
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (date == null) return;
//
//     // ⏰ Pick Time
//     final TimeOfDay? time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Colors.deepPurple, // header background color
//               onPrimary: Colors.white, // header text color
//               onSurface: Colors.black, // body text color
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.black, // buttons color
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (time == null) return;
//
//     // Combine date & time
//     final combined = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       time.hour,
//       time.minute,
//     );
//
//     setState(() => selectedDateTime = combined);
//
//     // 🔄 Call API to update backend
//     await _updateDateTimeOnServer(combined);
//   }
//
//   Future<void> _updateDateTimeOnServer(DateTime dateTime) async {
//     final success = await catering_authservice.updateDateTime(
//       context,
//       selectedDateTime!,
//     );
//
//     if (!mounted) return;
//     if (success) {
//       AppAlert.success(context, "Date & Time updated successfully!");
//     } else {
//       AppAlert.error(context, "Failed to update date & time.");
//     }
//   }
//
//   Widget _buildDateAndTime() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Date & Time *",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: _pickDateTime,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 8,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.access_time, color: AppColors.of(context).primary),
//                 const SizedBox(width: 12),
//                 Text(
//                   selectedDateTime == null
//                       ? "Select Date & Time"
//                       : DateFormat(
//                           'MMM dd, yyyy - hh:mm a',
//                         ).format(selectedDateTime!),
//                   style: TextStyle(
//                     color: selectedDateTime == null
//                         ? Colors.grey[500]
//                         : Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDeliveryAddress() {
//     ref.watch(addressProvider);
//
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => SavedAddress(
//               hideExtraWidgets: true,
//               onAddressSelected: (address) async {
//                 // 1️⃣ Update local provider
//                 await ref
//                     .read(addressProvider.notifier)
//                     .updateLocalAddress(
//                       city: address.city,
//                       stateName: address.state,
//                       pincode: address.pincode,
//                       latitude: address.latitude,
//                       longitude: address.longitude,
//                       fullAddress: address.fullAddress,
//                       category: address.category, // ✅ important
//                     );
//
//                 // 2️⃣ Update catering cart address
//                 if (address.addressId != 0) {
//                   final success =
//                       await AddressNotifier.updatecateringDeliveryAddress(
//                         cartId: cart!.id,
//                         addressId: address.addressId,
//                       );
//
//                   if (success && mounted) {
//                     // 🔥 REFRESH CART IMMEDIATELY
//                     final updatedCart = await catering_authservice
//                         .fetchUserCart();
//
//                     if (mounted) {
//                       setState(() {
//                         cart = updatedCart;
//                       });
//                     }
//                   }
//                 }
//
//                 // 3️⃣ Close screen
//                 // if (mounted) Navigator.pop(context);
//               },
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           // border: Border.all(color: Colors.grey.shade300),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.location_on, color: Colors.red),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// ✅ SHOW ONLY IF ADDRESS EXISTS
//                   if ((cart?.deliveryAddress ?? '').trim().isNotEmpty) ...[
//                     Text(
//                       [
//                         cart!.deliveryAddress,
//                         cart!.name,
//                         cart!.mobileNo,
//                       ].where((e) => e.toString().trim().isNotEmpty).join(", "),
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         // fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       "Change location",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.blue,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ] else
//                     const Text(
//                       "Select delivery address",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.keyboard_arrow_down),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyCart() {
//     return Center(
//       child: Column(
//         children: [
//           Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'Your catering cart is empty',
//             style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Add some delicious items',
//             style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCartItems() {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: items.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         return _buildCartItemCard(items[index], index);
//       },
//     );
//   }
//
//   Future<void> refreshCart() async {
//     final catering_Cart? updatedCart = await catering_authservice
//         .fetchUserCart();
//
//     if (updatedCart != null) {
//       setState(() {
//         cart = updatedCart;
//       });
//     }
//   }
//
//   Widget _buildCartItemCard(CartPackage item, int index) {
//     return StatefulBuilder(
//       builder: (context, setInnerState) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             // border: Border.all(color: Colors.grey, width: 1),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color.fromARGB(
//                   13,
//                   0,
//                   0,
//                   0,
//                 ), // 13 ≈ 5% opacity (0.05 * 255)
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Title Row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         item.packageName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         item.isExpanded
//                             ? Icons.keyboard_arrow_up
//                             : Icons.keyboard_arrow_down,
//                       ),
//                       onPressed: () {
//                         setInnerState(() {
//                           item.isExpanded = !item.isExpanded;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//
//                 // Expandable items
//                 if (item.isExpanded) ...[
//                   const SizedBox(height: 6),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: item.packageItems
//                         .map(
//                           (i) => Text(
//                             "• ${i.itemName}",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ],
//
//                 const Divider(),
//
//                 // Price + Quantity Selector
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "₹${(item.packagePrice * item.quantity).toStringAsFixed(0)}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.green,
//                       ),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         children: [
//                           // Decrement Button
//                           IconButton(
//                             icon: const Icon(Icons.remove, size: 18),
//                             onPressed: () async {
//                               final prefs =
//                                   await SharedPreferences.getInstance();
//                               final userId = prefs.getInt('userId') ?? 0;
//                               final cartId = prefs.getInt('cartId') ?? 0;
//
//                               if (item.quantity > 1) {
//                                 // Reduce quantity
//                                 setInnerState(() => item.quantity--);
//
//                                 final success = await catering_authservice
//                                     .updateCartQuantity(
//                                       cartId: cartId,
//                                       userId: userId,
//                                       packageId: item.packageId,
//                                       quantity: item.quantity,
//                                     );
//
//                                 if (success) {
//                                   await refreshCart(); // 🔥 Fetch updated cart
//                                 }
//                               } else {
//                                 // Remove item if quantity becomes 0
//                                 final success = await catering_authservice
//                                     .deletePackageFromCart(
//                                       cartId: cartId,
//                                       packageId: item.packageId,
//                                     );
//
//                                 if (success) {
//                                   setState(() {
//                                     items.remove(item); // remove from UI list
//                                   });
//                                   await refreshCart();
//                                 }
//                               }
//                             },
//                           ),
//
//                           // Quantity Text
//                           Text(
//                             item.quantity.toString(),
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//
//                           // Increment Button
//                           IconButton(
//                             icon: const Icon(Icons.add, size: 18),
//                             onPressed: () async {
//                               setInnerState(() => item.quantity++);
//
//                               final prefs =
//                                   await SharedPreferences.getInstance();
//                               final userId = prefs.getInt('userId') ?? 0;
//                               final cartId = prefs.getInt('cartId') ?? 0;
//
//                               final success = await catering_authservice
//                                   .updateCartQuantity(
//                                     cartId: cartId,
//                                     userId: userId,
//                                     packageId: item.packageId,
//                                     quantity: item.quantity,
//                                   );
//
//                               if (success) {
//                                 await refreshCart(); // 🔥 Fetch updated cart
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Dynamic Bill Summary Widget
//   Widget buildCateringSummaryCard(
//     catering_Cart cart,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     final subtotal = cart.subtotal;
//     final gstAmount = cart.gstAmount;
//     final platformFee = cart.platformFeeAmount;
//     final deliveryFee = cart.deliveryFee;
//     final total = cart.total;
//
//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       shadowColor: Colors.black26,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🔽 Header with expand/collapse
//             InkWell(
//               onTap: () {
//                 setState(() {
//                   _isCateringSummaryExpanded = !_isCateringSummaryExpanded;
//                 });
//               },
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.receipt_long,
//                     color: colorScheme.primary,
//                     size: 22,
//                   ),
//                   const SizedBox(width: 8),
//                   const Expanded(
//                     child: Text(
//                       "Order Summary",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                   AnimatedRotation(
//                     turns: _isCateringSummaryExpanded ? 0.5 : 0,
//                     duration: const Duration(milliseconds: 200),
//                     child: const Icon(Icons.keyboard_arrow_down),
//                   ),
//                 ],
//               ),
//             ),
//
//             /// 🔹 Expandable section
//             AnimatedCrossFade(
//               duration: const Duration(milliseconds: 250),
//               crossFadeState: _isCateringSummaryExpanded
//                   ? CrossFadeState.showFirst
//                   : CrossFadeState.showSecond,
//               firstChild: Column(
//                 children: [
//                   const Divider(height: 24),
//
//                   _buildBillRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
//
//                   _buildBillRow("GST", "₹${gstAmount.toStringAsFixed(2)}"),
//
//                   _buildBillRow(
//                     "Platform Fee",
//                     "₹${platformFee.toStringAsFixed(2)}",
//                   ),
//
//                   if (deliveryFee > 0)
//                     _buildBillRow(
//                       "Delivery Fee",
//                       "₹${deliveryFee.toStringAsFixed(2)}",
//                     ),
//                 ],
//               ),
//               secondChild: const SizedBox.shrink(),
//             ),
//
//             const Divider(height: 24),
//
//             /// 💰 Total (ALWAYS visible)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Total",
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                 ),
//                 Text(
//                   "₹${total.toStringAsFixed(2)}",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBillRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(color: Colors.grey[600])),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCheckoutCard() {
//     return ElevatedButton(
//       onPressed: () {
//         setState(() => isExpanded = !isExpanded);
//         debugPrint("isExpanded: $isExpanded");
//         WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.of(context).primary,
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       child: Text(
//         isExpanded ? 'Hide payment options' : 'Show payment options',
//         style: const TextStyle(color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildCheckoutDetails(ThemeData theme, ColorScheme colorScheme) {
//     return Column(
//       children: [
//         cartpayment(
//           wallet: wallet,
//           onSelectionChanged: (method, subWallets) {
//             setState(() {
//               selectedPaymentMethod = method;
//               selectedSubWallets = subWallets;
//             });
//
//             debugPrint("Payment: $selectedPaymentMethod");
//             debugPrint("Sub-wallets: $selectedSubWallets");
//           },
//         ),
//         const SizedBox(height: 16),
//         _buildPlaceOrderButton(theme, colorScheme),
//       ],
//     );
//   }
//
//   Widget _buildPlaceOrderButton(ThemeData theme, ColorScheme colorScheme) {
//     double total = cart?.total ?? 0.0;
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: (cart == null || isPlacingOrder)
//             ? null
//             : () {
//                 if (selectedDateTime == null) {
//                   AppAlert.error(
//                     context,
//                     "⚠️ Please select a date and time before placing the order.",
//                   );
//                   return; // ⛔ Stop here
//                 }
//                 placeOrder();
//               },
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
//                       "₹${total.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: Colors.white,
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
// Widget buildCartSkeleton() {
//   return ListView.builder(
//     padding: const EdgeInsets.all(16),
//     shrinkWrap: true,
//     itemCount: 3,
//     itemBuilder: (context, index) {
//       return Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         height: 100,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(12),
//         ),
//       );
//     },
//   );
// }

import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/Auth_service/catering_authservice.dart';
import '../../Services/Auth_service/food_authservice.dart';
import '../../Services/paymentservice/razorpayservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/widgets/food/currentcart_notifier.dart';
import '../../widgets/widgets/skeleton/cart_skeleton.dart';
import '../../Models/caterings/catering_cart_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/subscrptions/wallet_model.dart';
import '../../providers/addressmodel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foodmainscreen.dart';
import '../screens/saved_address.dart';
import 'package:intl/intl.dart';
import 'cartpayment.dart';
import 'catering_invoice.dart';
import 'package:maamaas/Services/App_color_service/app_colours.dart';

// ignore: camel_case_types
class catering_cart extends ConsumerStatefulWidget {
  const catering_cart({super.key});

  @override
  ConsumerState<catering_cart> createState() => _catering_cartState();
}

// ignore: camel_case_types
class _catering_cartState extends ConsumerState<catering_cart>
    with SingleTickerProviderStateMixin {
  catering_Cart? cart;
  String? appliedCouponCode;
  bool isExpanded = false;
  String selectedPaymentMethod = " ";
  String selectedSubWallet = " ";
  bool isPlacingOrder = false;
  DateTime? selectedDate;
  DateTime? selectedDateTime;
  String? selectedAddress;
  bool isLoading = false;
  Map<String, dynamic>? checkoutData;
  late List<CartPackage> items = [];
  Wallet? wallet;
  int? cartId;
  bool _isCateringSummaryExpanded = false;
  Set<String> selectedSubWallets = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _scrollController = ScrollController();
    _loadCartData();
    _loadWallet();
    refreshCart();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _loadWallet() async {
    try {
      final fetchedWallet = await subscription_AuthService.fetchWallet();
      if (!mounted) return;
      setState(() => wallet = fetchedWallet);
    } catch (e) {
      debugPrint("⚠️ _loadWallet failed: $e");
      if (!mounted) return;
      AppAlert.error(context, "❌ Failed to load wallet");
    }
  }

  Future<void> _onRefresh() async {
    final updatedCart = await catering_authservice.fetchUserCart();
    final updatedwallet = await subscription_AuthService.fetchWallet();
    if (!mounted) return;
    setState(() {
      cart = updatedCart;
      wallet = updatedwallet;
    });
  }

  Future<void> _loadCartData() async {
    setState(() => isLoading = true);
    try {
      final catering_Cart? cart = await catering_authservice.fetchUserCart();
      if (cart == null) {
        items = [];
      } else {
        items = cart.items;
      }
    } catch (e) {
      debugPrint("❌ Error fetching cart: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> placeOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final double grandTotal = cart?.total ?? 0.0;

    if (selectedPaymentMethod.isEmpty) {
      AppAlert.error(context, "⚠️ Please select a payment method");
      return;
    }

    setState(() => isPlacingOrder = true);
    final razorpay = RazorpayService();

    try {
      final String paymentMethod = selectedPaymentMethod;
      final String? walletType = paymentMethod == "Maamaas_Wallet"
          ? _mapSubWalletToBackend(selectedSubWallet)
          : null;

      if (paymentMethod == "Maamaas_Wallet") {
        if (selectedSubWallets.isEmpty) {
          AppAlert.error(context, "⚠️ Please select at least one sub wallet");
          setState(() => isPlacingOrder = false);
          return;
        }

        double required = grandTotal;
        double available = 0;
        if (selectedSubWallets.contains("Company Loaded")) {
          available += wallet!.companyLoadedAmount;
        }
        if (selectedSubWallets.contains("Self Loaded")) {
          available += wallet!.selfLoadedAmount;
        }
        if (selectedSubWallets.contains("Cashbacks")) {
          available += wallet!.cashbackAmount;
        }
        if (selectedSubWallets.contains("Postpaid used amount")) {
          available += wallet!.postPaidUsage;
        }

        if (available < required) {
          AppAlert.error(
            context,
            "Insufficient wallet balance! Available ₹${available.toStringAsFixed(2)}, Required ₹${required.toStringAsFixed(2)}",
          );
          setState(() => isPlacingOrder = false);
          return;
        }
      }

      if (paymentMethod == "Online_Payment") {
        final orderId = await catering_authservice.createOrder(grandTotal);
        if (orderId == null) {
          AppAlert.error(context, "Failed to create Razorpay order ❌");
          return;
        }

        razorpay.onSuccess = (response) async {
          final bool captured = await catering_authservice.capturePayment(
            paymentId: response.paymentId!,
            amount: grandTotal,
          );
          if (!captured) {
            AppAlert.error(context, "Payment capture failed ❌");
            return;
          }
          await _callOrderApi(
            userId: userId,
            paymentMethod: paymentMethod,
            razorpayPaymentId: response.paymentId!,
            razorpayOrderId: response.orderId ?? "",
            grandTotal: grandTotal,
            walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
          );
        };

        razorpay.startPayment(
          orderId: orderId,
          amount: grandTotal,
          description: "Online Payment via Razorpay",
        );
        return;
      }

      await _callOrderApi(
        userId: userId,
        paymentMethod: paymentMethod,
        razorpayPaymentId: "",
        razorpayOrderId: "",
        grandTotal: grandTotal,
        walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
      );
    } catch (e) {
      AppAlert.error(context, "Error placing order: $e");
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  String? _mapSubWalletToBackend(String? subWallet) {
    switch (subWallet) {
      case "Company Credited Amount":
        return "COMPANY_LOADED";
      case "Self Credited Amount":
        return "SELF_LOADED";
      case "Cashbacks":
        return "CASHBACK";
      case "Earned Amount":
        return "EARNED_AMOUNT";
      default:
        return null;
    }
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

  double getSelectedWalletBalance() {
    if (wallet == null) return 0;
    double total = 0;
    if (selectedSubWallets.contains("Company Loaded")) {
      total += wallet!.companyLoadedAmount;
    }
    if (selectedSubWallets.contains("Self Loaded")) {
      total += wallet!.selfLoadedAmount;
    }
    if (selectedSubWallets.contains("Cashbacks")) {
      total += wallet!.cashbackAmount;
    }
    if (selectedSubWallets.contains("Postpaid used amount")) {
      total += wallet!.postPaidUsage;
    }
    return total;
  }

  Future<void> _callOrderApi({
    required int userId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double grandTotal,
    List<String>? walletTypes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');

    if (cartId == null || cartId <= 0) {
      AppAlert.error(context, "❌ Cart ID missing or invalid");
      return;
    }

    final result = await catering_authservice.placeOrder(
      userId: userId,
      cartId: cartId,
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      walletTypes: walletTypes,
      grandTotal: grandTotal,
    );

    final int? orderId = result?['orderId'];

    if (orderId != null && orderId > 0) {
      await prefs.setInt('cateringorderId', orderId);
      await prefs.remove('cartId');
      AppAlert.success(context, "✅ Order placed successfully");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => catering_invoice(orderId: orderId),
        ),
      );
    } else {
      AppAlert.error(context, "❌ Failed to place order");
    }
  }

  Future<void> refreshCart() async {
    final catering_Cart? updatedCart = await catering_authservice
        .fetchUserCart();
    if (updatedCart != null) {
      setState(() => cart = updatedCart);
    }
  }

  // ─── PICK DATE & TIME ────────────────────────────────────────────
  Future<void> _pickDateTime() async {
    DateTime today = DateTime.now();
    DateTime firstAllowedDate = today.add(const Duration(days: 2));
    DateTime lastAllowedDate = today.add(const Duration(days: 365));

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: firstAllowedDate,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.of(context).primary,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(context).primary,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.of(context).primary,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(context).primary,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() => selectedDateTime = combined);
    await _updateDateTimeOnServer(combined);
  }

  Future<void> _updateDateTimeOnServer(DateTime dateTime) async {
    final success = await catering_authservice.updateDateTime(
      context,
      selectedDateTime!,
    );
    if (!mounted) return;
    if (success) {
      AppAlert.success(context, "Date & Time updated successfully!");
    } else {
      AppAlert.error(context, "Failed to update date & time.");
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final primary = AppColors.of(context).primary;
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────────────
              _buildAppBar(primary),

              // ── Body ────────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: primary,
                  strokeWidth: 2.5,
                  child: isLoading
                      ? CartSkeleton(type: CartSkeletonType.fullCart)
                      : items.isEmpty
                      ? _buildEmptyCart() // ✅ FULL SCREEN EMPTY
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildCartItems(),

                                SizedBox(height: 16.h),

                                if (cart != null) _buildOrderSummaryCard(cart!),

                                SizedBox(height: 16.h),

                                _buildSectionLabel("Event Date & Time"),
                                SizedBox(height: 8.h),
                                _buildDateTimePicker(primary),

                                SizedBox(height: 16.h),

                                _buildSectionLabel("Delivery Address"),
                                SizedBox(height: 8.h),
                                _buildDeliveryAddress(primary),

                                SizedBox(height: 20.h),

                                _buildPaymentToggle(primary),

                                if (isExpanded) _buildCheckoutDetails(primary),

                                SizedBox(height: 32.h),
                              ],
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

  // ── APPBAR ──────────────────────────────────────────────────────
  Widget _buildAppBar(Color primary) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F7),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              "Catering Cart",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          // 🗑 Clear Cart Button
          GestureDetector(
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: Text(
                    "Clear Cart",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: Text(
                    "Remove all items from your cart?",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Clear",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed != true || !mounted) return;

              final ok = await catering_authservice.deleteCart();

              if (!mounted) return;

              if (ok) {
                // 🔥 IMPORTANT: RESET GLOBAL CART STATE
                CartNotifier.count.value = 0;

                AppAlert.success(context, 'Cart cleared');

                // 🔥 safer navigation
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                AppAlert.error(context, 'Failed to clear cart');
              }
            },
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 18.sp,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION LABEL ───────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: 0.1,
      ),
    );
  }

  // ── EMPTY CART ──────────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 42.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Add catering packages to get started",
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ── CART ITEMS ──────────────────────────────────────────────────
  Widget _buildCartItems() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) => _buildCartItemCard(items[index], index),
    );
  }

  Widget _buildCartItemCard(CartPackage item, int index) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.packageName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.sp,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            "${item.packageItems.length} item${item.packageItems.length > 1 ? 's' : ''}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setInnerState(() => item.isExpanded = !item.isExpanded);
                      },
                      child: AnimatedRotation(
                        turns: item.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F3F7),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Expandable Items ──
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: item.isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: item.packageItems
                              .map(
                                (i) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 3.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6.w,
                                        height: 6.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.of(
                                            context,
                                          ).primary.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        i.itemName,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  secondChild: const SizedBox.shrink(),
                ),

                SizedBox(height: 14.h),

                // ── Price + Quantity ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${(item.packagePrice * item.quantity).toStringAsFixed(0)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    // Quantity Control
                    Container(
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F7),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _quantityButton(
                            icon: Icons.remove_rounded,
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getInt('userId') ?? 0;
                              final cartId = prefs.getInt('cartId') ?? 0;

                              if (item.quantity > 1) {
                                setInnerState(() => item.quantity--);
                                final success = await catering_authservice
                                    .updateCartQuantity(
                                      cartId: cartId,
                                      userId: userId,
                                      packageId: item.packageId,
                                      quantity: item.quantity,
                                    );
                                if (success) await refreshCart();
                              } else {
                                final success = await catering_authservice
                                    .deletePackageFromCart(
                                      cartId: cartId,
                                      packageId: item.packageId,
                                    );
                                if (success) {
                                  setState(() => items.remove(item));
                                  await refreshCart();
                                }
                              }
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              item.quantity.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          _quantityButton(
                            icon: Icons.add_rounded,
                            onTap: () async {
                              setInnerState(() => item.quantity++);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getInt('userId') ?? 0;
                              final cartId = prefs.getInt('cartId') ?? 0;
                              final success = await catering_authservice
                                  .updateCartQuantity(
                                    cartId: cartId,
                                    userId: userId,
                                    packageId: item.packageId,
                                    quantity: item.quantity,
                                  );
                              if (success) await refreshCart();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 16.sp, color: Colors.black87),
      ),
    );
  }

  // Widget _quantityButton({
  //   required IconData icon,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 34.w,
  //       height: 34.w,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(8.r), // 🔥 square rounded corners
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.06),
  //             blurRadius: 4,
  //             offset: const Offset(0, 1),
  //           ),
  //         ],
  //       ),
  //       child: Icon(
  //         icon,
  //         size: 16.sp,
  //         color: Colors.black87,
  //       ),
  //     ),
  //   );
  // }

  // ── ORDER SUMMARY ────────────────────────────────────────────────
  Widget _buildOrderSummaryCard(catering_Cart cart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(
              () => _isCateringSummaryExpanded = !_isCateringSummaryExpanded,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.of(context).primary,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      "Order Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isCateringSummaryExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable rows
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isCateringSummaryExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Column(
                children: [
                  Divider(color: Colors.grey[100], height: 1),
                  SizedBox(height: 12.h),
                  _summaryRow(
                    "Subtotal",
                    "₹${cart.subtotal.toStringAsFixed(2)}",
                  ),
                  _summaryRow("GST", "₹${cart.gstAmount.toStringAsFixed(2)}"),
                  _summaryRow(
                    "Platform Fee",
                    "₹${cart.platformFeeAmount.toStringAsFixed(2)}",
                  ),
                  if (cart.deliveryFee > 0)
                    _summaryRow(
                      "Delivery Fee",
                      "₹${cart.deliveryFee.toStringAsFixed(2)}",
                    ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),

          // Total — always visible
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16.r),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "₹${cart.total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                    color: AppColors.of(context).primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── DATE & TIME ──────────────────────────────────────────────────
  Widget _buildDateTimePicker(Color primary) {
    final bool hasDate = selectedDateTime != null;
    return GestureDetector(
      onTap: _pickDateTime,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasDate ? primary.withOpacity(0.3) : Colors.grey[200]!,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: hasDate
                    ? primary.withOpacity(0.1)
                    : const Color(0xFFF2F3F7),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                hasDate
                    ? Icons.calendar_today_rounded
                    : Icons.calendar_today_outlined,
                color: hasDate ? primary : Colors.grey[400],
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasDate)
                    Text(
                      DateFormat('EEEE, MMM dd yyyy').format(selectedDateTime!),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  Text(
                    hasDate
                        ? DateFormat('hh:mm a').format(selectedDateTime!)
                        : "Tap to select date & time",
                    style: TextStyle(
                      fontSize: hasDate ? 12.sp : 14.sp,
                      color: hasDate ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ── DELIVERY ADDRESS ─────────────────────────────────────────────
  Widget _buildDeliveryAddress(Color primary) {
    ref.watch(addressProvider);
    final bool hasAddress = (cart?.deliveryAddress ?? '').trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavedAddress(
              hideExtraWidgets: true,
              onAddressSelected: (address) async {
                await ref
                    .read(addressProvider.notifier)
                    .updateLocalAddress(
                      city: address.city,
                      stateName: address.state,
                      pincode: address.pincode,
                      latitude: address.latitude,
                      longitude: address.longitude,
                      fullAddress: address.fullAddress,
                      category: address.category,
                    );

                if (address.addressId != 0) {
                  final success =
                      await AddressNotifier.updatecateringDeliveryAddress(
                        cartId: cart!.id,
                        addressId: address.addressId,
                      );
                  if (success && mounted) {
                    final updatedCart = await catering_authservice
                        .fetchUserCart();
                    if (mounted) setState(() => cart = updatedCart);
                  }
                }
              },
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasAddress ? primary.withOpacity(0.3) : Colors.grey[200]!,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: hasAddress
                    ? Colors.redAccent.withOpacity(0.1)
                    : const Color(0xFFF2F3F7),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                hasAddress
                    ? Icons.location_on_rounded
                    : Icons.location_on_outlined,
                color: hasAddress ? Colors.redAccent : Colors.grey[400],
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: hasAddress
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [cart!.name, cart!.mobileNo]
                              .where((e) => e.toString().trim().isNotEmpty)
                              .join("  ·  "),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          cart!.deliveryAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Change address",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      "Select delivery address",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ── PAYMENT ──────────────────────────────────────────────────────
  Widget _buildPaymentToggle(Color primary) {
    return GestureDetector(
      onTap: () {
        setState(() => isExpanded = !isExpanded);
        if (!isExpanded) return;
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isExpanded ? primary : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? primary.withOpacity(0.25)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.payment_rounded,
              color: isExpanded ? Colors.white : primary,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                isExpanded ? "Hide Payment Options" : "Choose Payment Method",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isExpanded ? Colors.white : Colors.black87,
                ),
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isExpanded ? Colors.white : Colors.grey[500],
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutDetails(Color primary) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        cartpayment(
          wallet: wallet,
          onSelectionChanged: (method, subWallets) {
            setState(() {
              selectedPaymentMethod = method;
              selectedSubWallets = subWallets;
            });
          },
        ),
        SizedBox(height: 16.h),
        _buildPlaceOrderButton(primary),
      ],
    );
  }

  Widget _buildPlaceOrderButton(Color primary) {
    final double total = cart?.total ?? 0.0;
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: (cart == null || isPlacingOrder)
            ? null
            : () {
                if (selectedDateTime == null) {
                  AppAlert.error(
                    context,
                    "⚠️ Please select a date and time before placing the order.",
                  );
                  return;
                }
                placeOrder();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: Colors.grey[300],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: isPlacingOrder
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Place Order",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Text(
                      "₹${total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── SKELETON (standalone helper) ────────────────────────────────────
Widget buildCartSkeleton() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 3,
    itemBuilder: (context, index) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
