// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../Services/Auth_service/food_authservice.dart';
// import 'package:flutter/material.dart';
// import '../Invoices/food _pdf.dart';
// import '../foodmainscreen.dart';
//
// // ignore: camel_case_types
// class food_Invoice extends StatefulWidget {
//   final int orderId;
//   const food_Invoice({super.key, required this.orderId});
//   @override
//   // ignore: library_private_types_in_public_api
//   _InvoiceState createState() => _InvoiceState();
// }
//
// class _InvoiceState extends State<food_Invoice> with TickerProviderStateMixin {
//   late final int orderId;
//   String chargeLabel = "Service Charge";
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   late Future<Map<String, dynamic>?> _orderFuture;
//
//   @override
//   // void initState() {
//   //   super.initState();
//   //   orderId = widget.orderId;
//   //
//   //   _fadeController = AnimationController(
//   //     vsync: this,
//   //     duration: const Duration(milliseconds: 600),
//   //   );
//   //   _slideController = AnimationController(
//   //     vsync: this,
//   //     duration: const Duration(milliseconds: 700),
//   //   );
//   //   _fadeAnimation = CurvedAnimation(
//   //     parent: _fadeController,
//   //     curve: Curves.easeOut,
//   //   );
//   //   _slideAnimation = Tween<Offset>(
//   //     begin: const Offset(0, 0.08),
//   //     end: Offset.zero,
//   //   ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
//   //
//   //   _fadeController.forward();
//   //   _slideController.forward();
//   //   //
//   //   // Future.delayed(const Duration(seconds: 15), () {
//   //   //   if (mounted) {
//   //   //     Navigator.pushReplacement(
//   //   //       context,
//   //   //       MaterialPageRoute(builder: (context) => MainScreenfood()),
//   //   //     );
//   //   //   }
//   //   // });
//   // }
//   @override
//   void initState() {
//     super.initState();
//     orderId = widget.orderId;
//
//     _orderFuture = food_Authservice.fetchOrderById(orderId);
//
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//
//     _slideController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeOut,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.08),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
//
//     _fadeController.forward();
//     _slideController.forward();
//
//     // Future.delayed(const Duration(seconds: 15), () {
//     //   if (mounted) {
//     //     Navigator.pushReplacement(
//     //       context,
//     //       MaterialPageRoute(builder: (context) => MainScreenfood()),
//     //     );
//     //   }
//     // });
//   }
//
//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }
//
//   // ── Brand colors ──────────────────────────────────────────────────────────
//   static const Color _brandOrange = Color(0xFFFF6B35);
//   static const Color _accentGold = Color(0xFFF4A830);
//   static const Color _textPrimary = Color(0xFF1A1A2E);
//   static const Color _textMuted = Color(0xFF8E8E9A);
//   static const Color _divider = Color(0xFFEAE8E4);
//
//   @override
//   Widget build(BuildContext context) {
//     // ignore: deprecated_member_use
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => MainScreenfood()),
//           (route) => false,
//         );
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F3EF),
//         body: Column(
//           children: [
//             _buildHeader(context),
//
//             Expanded(
//               // ✅ IMPORTANT
//               child: FutureBuilder<Map<String, dynamic>?>(
//                 future: _orderFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return _buildLoader();
//                   } else if (snapshot.hasError) {
//                     return _buildError(snapshot.error.toString());
//                   } else if (!snapshot.hasData || snapshot.data == null) {
//                     return _buildEmpty();
//                   }
//
//                   final data = snapshot.data!;
//                   final List<dynamic> items =
//                       data['order'] as List<dynamic>? ?? [];
//
//                   return SafeArea(
//                     child: FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: SlideTransition(
//                         position: _slideAnimation,
//                         child: SingleChildScrollView(
//                           padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
//                           child: Column(
//                             children: [
//                               _buildOrderMeta(data),
//                               SizedBox(height: 12.h),
//                               _buildItemsCard(context, data, items),
//                               SizedBox(height: 12.h),
//                               _buildTotalsCard(context, data),
//                               SizedBox(height: 20.h),
//                               _buildDownloadButton(context),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Header ─────────────────────────────────────────────────────────────────
//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x28000000),
//             blurRadius: 16,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 20.h),
//           child: Row(
//             children: [
//               IconButton(
//                 icon: const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   color: Colors.black,
//                   size: 20,
//                 ),
//                 onPressed: () => Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => MainScreenfood()),
//                   (r) => false,
//                 ),
//               ),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Order Invoice",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Text(
//                       "Thank you for your order!",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: _brandOrange,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.receipt_long_rounded,
//                   color: Colors.white,
//                   size: 22,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Order Meta Pill Row ────────────────────────────────────────────────────
//   Widget _buildOrderMeta(Map<String, dynamic> data) {
//     final dateTimeStr = data['orderDateAndTime'];
//     final dateTime = dateTimeStr != null
//         ? DateTime.tryParse(dateTimeStr)
//         : null;
//     final orderId = data['orderId']?.toString() ?? 'N/A';
//     final orderType =
//         (data['orderType'] as String?)?.replaceAll('_', ' ') ?? 'N/A';
//     final payment =
//         (data['paymentMethod'] as String?)?.replaceAll('_', ' ') ?? 'N/A';
//     final timeStr = dateTime != null
//         ? "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}"
//         : 'N/A';
//     final dateStr = dateTime != null
//         ? "${dateTime.day}/${dateTime.month}/${dateTime.year}"
//         : 'N/A';
//
//     return Column(
//       children: [
//         // Order ID banner
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFFFF6B35), Color(0xFFF4A830)],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Row(
//             children: [
//               // const Icon(Icons.tag_rounded, color: Colors.white, size: 16),
//               // SizedBox(width: 6.w),
//               Text(
//                 "Order: #$orderId",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15,
//                   letterSpacing: 0.3,
//                 ),
//               ),
//               const Spacer(),
//               _statusPill(orderType),
//             ],
//           ),
//         ),
//         SizedBox(height: 8.h),
//         // Info chips row
//         Row(
//           children: [
//             _infoChip(Icons.calendar_today_rounded, dateStr),
//             SizedBox(width: 8.w),
//             _infoChip(Icons.access_time_rounded, timeStr),
//             SizedBox(width: 8.w),
//             Expanded(
//               child: _infoChip(Icons.payment_rounded, payment, expand: true),
//             ),
//           ],
//         ),
//         // Delivery info if applicable
//         if (data['orderType']?.toString() == "DELIVERY") ...[
//           SizedBox(height: 8.h),
//           _buildDeliveryCard(data),
//         ],
//         // Transaction ID
//         if (data['paymentMethod']?.toString() == "Online_Payment" &&
//             data['transactionId'] != null) ...[
//           SizedBox(height: 8.h),
//           _txnChip(data['transactionId']),
//         ],
//       ],
//     );
//   }
//
//   Widget _statusPill(String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.25),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.5)),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   Widget _infoChip(IconData icon, String label, {bool expand = false}) {
//     Widget chip = Container(
//       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x0F000000),
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: _brandOrange),
//           SizedBox(width: 5.w),
//           Text(
//             label,
//             style: const TextStyle(
//               color: _textPrimary,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//     return expand ? Expanded(child: chip) : chip;
//   }
//
//   Widget _txnChip(String txnId) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFFE8E4FF)),
//         boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6)],
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.verified_rounded,
//             size: 15,
//             color: Color(0xFF6C63FF),
//           ),
//           SizedBox(width: 8.w),
//           const Text(
//             "Txn ID: ",
//             style: TextStyle(color: _textMuted, fontSize: 12),
//           ),
//           Expanded(
//             child: Text(
//               txnId,
//               style: const TextStyle(
//                 color: _textPrimary,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDeliveryCard(Map<String, dynamic> data) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(14.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x0A000000),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: _brandOrange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.delivery_dining_rounded,
//                   color: _brandOrange,
//                   size: 16,
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               const Text(
//                 "Delivery Details",
//                 style: TextStyle(
//                   color: _textPrimary,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           _compactRow(
//             Icons.person_outline_rounded,
//             (data['deliveryUserName'] ?? 'N/A').toString().toUpperCase(),
//           ),
//           SizedBox(height: 5.h),
//           _compactRow(
//             Icons.phone_outlined,
//             data['mobileNo']?.toString() ?? 'N/A',
//           ),
//           SizedBox(height: 5.h),
//           _compactRow(
//             Icons.location_on_outlined,
//             (data['deliveryAddress'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _compactRow(IconData icon, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 14, color: _textMuted),
//         SizedBox(width: 6.w),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               color: _textPrimary,
//               fontSize: 12.5,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Items Card ─────────────────────────────────────────────────────────────
//   Widget _buildItemsCard(
//     BuildContext context,
//     Map<String, dynamic> data,
//     List<dynamic> items,
//   ) {
//     bool parseBool(dynamic value) =>
//         value == true ||
//         value == 1 ||
//         value == '1' ||
//         value.toString().toLowerCase() == 'true';
//
//     final bool isScheduled = parseBool(data['sheduled']);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x0D000000),
//             blurRadius: 12,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Card header
//           // Padding(
//           //   padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
//           //   child: Row(
//           //     children: [
//           //       Container(
//           //         padding: const EdgeInsets.all(7),
//           //         decoration: BoxDecoration(
//           //           color: _brandOrange.withOpacity(0.12),
//           //           borderRadius: BorderRadius.circular(9),
//           //         ),
//           //         child: const Icon(
//           //           Icons.restaurant_menu_rounded,
//           //           color: _brandOrange,
//           //           size: 17,
//           //         ),
//           //       ),
//           //       SizedBox(width: 10.w),
//           //       const Text(
//           //         "Ordered Items",
//           //         style: TextStyle(
//           //           color: _textPrimary,
//           //           fontSize: 15,
//           //           fontWeight: FontWeight.w700,
//           //         ),
//           //       ),
//           //       const Spacer(),
//           //       Container(
//           //         padding: const EdgeInsets.symmetric(
//           //           horizontal: 9,
//           //           vertical: 3,
//           //         ),
//           //         decoration: BoxDecoration(
//           //           color: const Color(0xFFF0F0F0),
//           //           borderRadius: BorderRadius.circular(20),
//           //         ),
//           //         child: Text(
//           //           "${items.length} item${items.length != 1 ? 's' : ''}",
//           //           style: const TextStyle(
//           //             color: _textMuted,
//           //             fontSize: 11,
//           //             fontWeight: FontWeight.w600,
//           //           ),
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           if (isScheduled) ...[
//             SizedBox(height: 10.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: Container(
//                 padding: EdgeInsets.all(10.w),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF8EC),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: const Color(0xFFFFDFA0)),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.schedule_rounded,
//                       size: 15,
//                       color: _accentGold,
//                     ),
//                     SizedBox(width: 6.w),
//                     Text(
//                       "Scheduled: ${data['date'] ?? ''} ${data['time'] ?? ''}",
//                       style: const TextStyle(
//                         color: Color(0xFF8B5E00),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//
//           SizedBox(height: 12.h),
//
//           // Table header
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF7F5F2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 26,
//                     child: Text(
//                       "#",
//                       style: _tableHeaderStyle,
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   Expanded(
//                     flex: 4,
//                     child: Text("Item", style: _tableHeaderStyle),
//                   ),
//                   SizedBox(
//                     width: 30,
//                     child: Text(
//                       "Qty",
//                       style: _tableHeaderStyle,
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 56,
//                     child: Text(
//                       "Price",
//                       style: _tableHeaderStyle,
//                       textAlign: TextAlign.right,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 60,
//                     child: Text(
//                       "Total",
//                       style: _tableHeaderStyle,
//                       textAlign: TextAlign.right,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 4.h),
//
//           // Item rows
//           ...items.asMap().entries.map((entry) {
//             final index = entry.key;
//             final item = entry.value as Map<String, dynamic>;
//             final isLast = index == items.length - 1;
//             return Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.w,
//                     vertical: 8.h,
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: 26,
//                         child: Text(
//                           "${index + 1}",
//                           style: const TextStyle(
//                             color: _textMuted,
//                             fontSize: 11.5,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       Expanded(
//                         flex: 4,
//                         child: Text(
//                           item['dishName']?.toString() ?? 'N/A',
//                           style: const TextStyle(
//                             color: _textPrimary,
//                             fontSize: 12.5,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 30,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 5,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _brandOrange.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Text(
//                             "${item['quantity'] ?? 0}",
//                             style: const TextStyle(
//                               color: _brandOrange,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 56,
//                         child: Text(
//                           "₹${(item['price'] as num?)?.toStringAsFixed(1) ?? '0.0'}",
//                           style: const TextStyle(
//                             color: _textMuted,
//                             fontSize: 12,
//                           ),
//                           textAlign: TextAlign.right,
//                         ),
//                       ),
//                       SizedBox(
//                         width: 60,
//                         child: Text(
//                           "₹${(item['totalPrice'] as num?)?.toStringAsFixed(1) ?? '0.0'}",
//                           style: const TextStyle(
//                             color: _textPrimary,
//                             fontSize: 12.5,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           textAlign: TextAlign.right,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (!isLast)
//                   Divider(
//                     height: 1,
//                     thickness: 1,
//                     indent: 16.w,
//                     endIndent: 16.w,
//                     color: _divider,
//                   ),
//               ],
//             );
//           }),
//
//           SizedBox(height: 12.h),
//         ],
//       ),
//     );
//   }
//
//   static const TextStyle _tableHeaderStyle = TextStyle(
//     color: _textMuted,
//     fontSize: 11,
//     fontWeight: FontWeight.w600,
//     letterSpacing: 0.3,
//   );
//
//   // ── Totals Card ────────────────────────────────────────────────────────────
//   Widget _buildTotalsCard(BuildContext context, Map<String, dynamic> data) {
//     final orderType = data['orderType']?.toString().toLowerCase() ?? '';
//     final num subTotal = data['subTotal'] ?? 0;
//     final num discount = data['discountAmount'] ?? 0;
//     final num sgst = data['sgst'] ?? 0;
//     final num cgst = data['cgst'] ?? 0;
//     final num platformCharges = data['platformCharges'] ?? 0;
//     final num packingCharges = data['packingCharges'] ?? 0;
//     final num deliveryCharges = data['deliveryCharges'] ?? 0;
//     final num grandTotal = data['grandTotal'] ?? 0;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x0D000000),
//             blurRadius: 12,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(7),
//                   decoration: BoxDecoration(
//                     color: _brandOrange.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(9),
//                   ),
//                   child: const Icon(
//                     Icons.summarize_rounded,
//                     color: _brandOrange,
//                     size: 17,
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 const Text(
//                   "Order Summary",
//                   style: TextStyle(
//                     color: _textPrimary,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: Column(
//               children: [
//                 _priceRow("Sub Total", "₹${subTotal.toStringAsFixed(2)}"),
//                 _priceRow("SGST", "₹${sgst.toStringAsFixed(2)}"),
//                 _priceRow("CGST", "₹${cgst.toStringAsFixed(2)}"),
//                 _priceRow(
//                   "Platform Charges",
//                   "₹${platformCharges.toStringAsFixed(2)}",
//                 ),
//                 if (orderType == 'delivery' || orderType == 'takeaway')
//                   _priceRow(
//                     "Packing Charges",
//                     "₹${packingCharges.toStringAsFixed(2)}",
//                   ),
//                 if (orderType == 'delivery')
//                   _priceRow(
//                     "Delivery Charges",
//                     "₹${deliveryCharges.toStringAsFixed(2)}",
//                   ),
//                 if (discount > 0)
//                   _priceRow(
//                     "Discount",
//                     "-₹${discount.toStringAsFixed(2)}",
//                     isDiscount: true,
//                   ),
//               ],
//             ),
//           ),
//
//           // Grand total
//           Container(
//             margin: EdgeInsets.all(12.w),
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFFF6B35), Color(0xFFF4A830)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Row(
//               children: [
//                 const Text(
//                   "Grand Total",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   "₹${grandTotal.toStringAsFixed(2)}",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _priceRow(String label, String value, {bool isDiscount = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6.h),
//       child: Row(
//         children: [
//           Text(label, style: const TextStyle(color: _textMuted, fontSize: 13)),
//           const Spacer(),
//           Text(
//             value,
//             style: TextStyle(
//               color: isDiscount ? const Color(0xFF2ECC71) : _textPrimary,
//               fontSize: 13.5,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Download Button ────────────────────────────────────────────────────────
//   Widget _buildDownloadButton(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 52.h,
//       child: ElevatedButton(
//         onPressed: () async {
//           AppAlert.info(context, "Generating invoice...");
//           await FoodPdf().downloadInvoice(widget.orderId);
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _brandOrange,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.download_rounded, size: 20),
//             SizedBox(width: 8.w),
//             const Text(
//               "Download PDF Invoice",
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildAutoRedirectNote() {
//   //   return SafeArea(
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       children: const [
//   //         Icon(Icons.info_outline_rounded, size: 13, color: _textMuted),
//   //         SizedBox(width: 4),
//   //         Text(
//   //           "Auto-redirecting to home in 15s",
//   //           style: TextStyle(color: _textMuted, fontSize: 11.5),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   // ── States ─────────────────────────────────────────────────────────────────
//   Widget _buildLoader() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 40,
//             height: 40,
//             child: CircularProgressIndicator(
//               strokeWidth: 3,
//               valueColor: const AlwaysStoppedAnimation<Color>(_brandOrange),
//             ),
//           ),
//           SizedBox(height: 16.h),
//           const Text(
//             "Fetching your invoice...",
//             style: TextStyle(color: _textMuted, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildError(String error) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(24.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFEEEE),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Icon(
//                 Icons.error_outline_rounded,
//                 color: Color(0xFFE53E3E),
//                 size: 40,
//               ),
//             ),
//             SizedBox(height: 16.h),
//             const Text(
//               "Couldn't load invoice",
//               style: TextStyle(
//                 color: _textPrimary,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             SizedBox(height: 6.h),
//             Text(
//               error,
//               style: const TextStyle(color: _textMuted, fontSize: 12.5),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.receipt_outlined, color: _textMuted, size: 48),
//           SizedBox(height: 12.h),
//           const Text(
//             "No invoice details found.",
//             style: TextStyle(color: _textMuted, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Services/Auth_service/food_authservice.dart';
import 'package:flutter/material.dart';
import '../Invoices/food _pdf.dart';
import '../foodmainscreen.dart';

// ignore: camel_case_types
class food_Invoice extends StatefulWidget {
  final int orderId;
  const food_Invoice({super.key, required this.orderId});
  @override
  // ignore: library_private_types_in_public_api
  _InvoiceState createState() => _InvoiceState();
}

class _InvoiceState extends State<food_Invoice> with TickerProviderStateMixin {
  late final int orderId;
  String chargeLabel = "Service Charge";
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late Future<Map<String, dynamic>?> _orderFuture;

  @override
  // void initState() {
  //   super.initState();
  //   orderId = widget.orderId;
  //
  //   _fadeController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 600),
  //   );
  //   _slideController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 700),
  //   );
  //   _fadeAnimation = CurvedAnimation(
  //     parent: _fadeController,
  //     curve: Curves.easeOut,
  //   );
  //   _slideAnimation = Tween<Offset>(
  //     begin: const Offset(0, 0.08),
  //     end: Offset.zero,
  //   ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  //
  //   _fadeController.forward();
  //   _slideController.forward();
  //   //
  //   // Future.delayed(const Duration(seconds: 15), () {
  //   //   if (mounted) {
  //   //     Navigator.pushReplacement(
  //   //       context,
  //   //       MaterialPageRoute(builder: (context) => MainScreenfood()),
  //   //     );
  //   //   }
  //   // });
  // }
  @override
  void initState() {
    super.initState();
    orderId = widget.orderId;

    _orderFuture = food_Authservice.fetchOrderById(orderId);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    // Future.delayed(const Duration(seconds: 15), () {
    //   if (mounted) {
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => MainScreenfood()),
    //     );
    //   }
    // });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ── Brand colors ──────────────────────────────────────────────────────────
  static const Color _brandOrange = Color(0xFFFF6B35);
  static const Color _accentGold = Color(0xFFF4A830);
  static const Color _textPrimary = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF8E8E9A);
  static const Color _divider = Color(0xFFEAE8E4);

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreenfood()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3EF),
        body: Column(
          children: [
            _buildHeader(context),

            Expanded(
              // ✅ IMPORTANT
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _orderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoader();
                  } else if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return _buildEmpty();
                  }

                  final data = snapshot.data!;
                  final List<dynamic> items =
                      data['order'] as List<dynamic>? ?? [];

                  return SafeArea(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                          child: Column(
                            children: [
                              _buildOrderMeta(data),
                              SizedBox(height: 12.h),
                              _buildItemsCard(context, data, items),
                              SizedBox(height: 12.h),
                              _buildTotalsCard(context, data),
                              SizedBox(height: 20.h),
                              _buildDownloadButton(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 20.h),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => MainScreenfood()),
                  (r) => false,
                ),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Invoice",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Thank you for your order!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _brandOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Order Meta Pill Row ────────────────────────────────────────────────────
  Widget _buildOrderMeta(Map<String, dynamic> data) {
    final dateTimeStr = data['orderDateAndTime'];
    final dateTime = dateTimeStr != null
        ? DateTime.tryParse(dateTimeStr)
        : null;
    final orderId = data['orderId']?.toString() ?? 'N/A';
    final orderType =
        (data['orderType'] as String?)?.replaceAll('_', ' ') ?? 'N/A';
    final payment =
        (data['paymentMethod'] as String?)?.replaceAll('_', ' ') ?? 'N/A';
    final timeStr = dateTime != null
        ? "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}"
        : 'N/A';
    final dateStr = dateTime != null
        ? "${dateTime.day}/${dateTime.month}/${dateTime.year}"
        : 'N/A';

    return Column(
      children: [
        // Order ID banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFF4A830)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // const Icon(Icons.tag_rounded, color: Colors.white, size: 16),
              // SizedBox(width: 6.w),
              Text(
                "Order: #$orderId",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              _statusPill(orderType),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        // Info chips row
        Row(
          children: [
            _infoChip(Icons.calendar_today_rounded, dateStr),
            SizedBox(width: 8.w),
            _infoChip(Icons.access_time_rounded, timeStr),
            SizedBox(width: 8.w),
            _infoChip(Icons.payment_rounded, payment, expand: true),
          ],
        ),
        // Delivery info if applicable
        if (data['orderType']?.toString() == "DELIVERY") ...[
          SizedBox(height: 8.h),
          _buildDeliveryCard(data),
        ],
        // Transaction ID
        if (data['paymentMethod']?.toString() == "Online_Payment" &&
            data['transactionId'] != null) ...[
          SizedBox(height: 8.h),
          _txnChip(data['transactionId']),
        ],
      ],
    );
  }

  Widget _statusPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {bool expand = false}) {
    Widget chip = Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _brandOrange),
          SizedBox(width: 5.w),
          Text(
            label,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
    return expand ? Expanded(child: chip) : chip;
  }

  Widget _txnChip(String txnId) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E4FF)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6)],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 15,
            color: Color(0xFF6C63FF),
          ),
          SizedBox(width: 8.w),
          const Text(
            "Txn ID: ",
            style: TextStyle(color: _textMuted, fontSize: 12),
          ),
          Expanded(
            child: Text(
              txnId,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _brandOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  color: _brandOrange,
                  size: 16,
                ),
              ),
              SizedBox(width: 8.w),
              const Text(
                "Delivery Details",
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _compactRow(
            Icons.person_outline_rounded,
            (data['deliveryUserName'] ?? 'N/A').toString().toUpperCase(),
          ),
          SizedBox(height: 5.h),
          _compactRow(
            Icons.phone_outlined,
            data['mobileNo']?.toString() ?? 'N/A',
          ),
          SizedBox(height: 5.h),
          _compactRow(
            Icons.location_on_outlined,
            (data['deliveryAddress'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _compactRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _textMuted),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Items Card ─────────────────────────────────────────────────────────────
  Widget _buildItemsCard(
    BuildContext context,
    Map<String, dynamic> data,
    List<dynamic> items,
  ) {
    bool parseBool(dynamic value) =>
        value == true ||
        value == 1 ||
        value == '1' ||
        value.toString().toLowerCase() == 'true';

    final bool isScheduled = parseBool(data['sheduled']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          // Padding(
          //   padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          //   child: Row(
          //     children: [
          //       Container(
          //         padding: const EdgeInsets.all(7),
          //         decoration: BoxDecoration(
          //           color: _brandOrange.withOpacity(0.12),
          //           borderRadius: BorderRadius.circular(9),
          //         ),
          //         child: const Icon(
          //           Icons.restaurant_menu_rounded,
          //           color: _brandOrange,
          //           size: 17,
          //         ),
          //       ),
          //       SizedBox(width: 10.w),
          //       const Text(
          //         "Ordered Items",
          //         style: TextStyle(
          //           color: _textPrimary,
          //           fontSize: 15,
          //           fontWeight: FontWeight.w700,
          //         ),
          //       ),
          //       const Spacer(),
          //       Container(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 9,
          //           vertical: 3,
          //         ),
          //         decoration: BoxDecoration(
          //           color: const Color(0xFFF0F0F0),
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: Text(
          //           "${items.length} item${items.length != 1 ? 's' : ''}",
          //           style: const TextStyle(
          //             color: _textMuted,
          //             fontSize: 11,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          if (isScheduled) ...[
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFDFA0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: _accentGold,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Scheduled: ${data['date'] ?? ''} ${data['time'] ?? ''}",
                      style: const TextStyle(
                        color: Color(0xFF8B5E00),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 12.h),

          // Table header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      "#",
                      style: _tableHeaderStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text("Item", style: _tableHeaderStyle),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      "Qty",
                      style: _tableHeaderStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      "Price",
                      style: _tableHeaderStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      "Total",
                      style: _tableHeaderStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Item rows
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final isLast = index == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 26,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item['dishName']?.toString() ?? 'N/A',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _brandOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "${item['quantity'] ?? 0}",
                            style: const TextStyle(
                              color: _brandOrange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 56,
                        child: Text(
                          "₹${(item['price'] as num?)?.toStringAsFixed(1) ?? '0.0'}",
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          "₹${(item['totalPrice'] as num?)?.toStringAsFixed(1) ?? '0.0'}",
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: _divider,
                  ),
              ],
            );
          }),

          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  static const TextStyle _tableHeaderStyle = TextStyle(
    color: _textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ── Totals Card ────────────────────────────────────────────────────────────
  Widget _buildTotalsCard(BuildContext context, Map<String, dynamic> data) {
    final orderType = data['orderType']?.toString().toLowerCase() ?? '';
    final num subTotal = data['subTotal'] ?? 0;
    final num discount = data['discountAmount'] ?? 0;
    final num sgst = data['sgst'] ?? 0;
    final num cgst = data['cgst'] ?? 0;
    final num platformCharges = data['platformCharges'] ?? 0;
    final num packingCharges = data['packingCharges'] ?? 0;
    final num deliveryCharges = data['deliveryCharges'] ?? 0;
    final num grandTotal = data['grandTotal'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _brandOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.summarize_rounded,
                    color: _brandOrange,
                    size: 17,
                  ),
                ),
                SizedBox(width: 10.w),
                const Text(
                  "Order Summary",
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                _priceRow("Sub Total", "₹${subTotal.toStringAsFixed(2)}"),
                _priceRow("SGST", "₹${sgst.toStringAsFixed(2)}"),
                _priceRow("CGST", "₹${cgst.toStringAsFixed(2)}"),
                _priceRow(
                  "Platform Charges",
                  "₹${platformCharges.toStringAsFixed(2)}",
                ),
                if (orderType == 'delivery' || orderType == 'takeaway')
                  _priceRow(
                    "Packing Charges",
                    "₹${packingCharges.toStringAsFixed(2)}",
                  ),
                if (orderType == 'delivery')
                  _priceRow(
                    "Delivery Charges",
                    "₹${deliveryCharges.toStringAsFixed(2)}",
                  ),
                if (discount > 0)
                  _priceRow(
                    "Discount",
                    "-₹${discount.toStringAsFixed(2)}",
                    isDiscount: true,
                  ),
              ],
            ),
          ),

          // Grand total
          Container(
            margin: EdgeInsets.all(12.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFF4A830)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  "₹${grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: _textMuted, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? const Color(0xFF2ECC71) : _textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Download Button ────────────────────────────────────────────────────────
  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () async {
          AppAlert.info(context, "Generating invoice...");
          await FoodPdf().downloadInvoice(widget.orderId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_rounded, size: 20),
            SizedBox(width: 8.w),
            const Text(
              "Download PDF Invoice",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAutoRedirectNote() {
  //   return SafeArea(
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: const [
  //         Icon(Icons.info_outline_rounded, size: 13, color: _textMuted),
  //         SizedBox(width: 4),
  //         Text(
  //           "Auto-redirecting to home in 15s",
  //           style: TextStyle(color: _textMuted, fontSize: 11.5),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── States ─────────────────────────────────────────────────────────────────
  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(_brandOrange),
            ),
          ),
          SizedBox(height: 16.h),
          const Text(
            "Fetching your invoice...",
            style: TextStyle(color: _textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE53E3E),
                size: 40,
              ),
            ),
            SizedBox(height: 16.h),
            const Text(
              "Couldn't load invoice",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              error,
              style: const TextStyle(color: _textMuted, fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_outlined, color: _textMuted, size: 48),
          SizedBox(height: 12.h),
          const Text(
            "No invoice details found.",
            style: TextStyle(color: _textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
