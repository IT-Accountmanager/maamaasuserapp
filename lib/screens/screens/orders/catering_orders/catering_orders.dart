// import 'package:maamaas/screens/screens/supportteam/tickets_screen.dart';
// import '../../../../Services/Auth_service/catering_authservice.dart';
// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import '../../../../Services/paymentservice/razorpayservice.dart';
// import '../../../../Services/App_color_service/app_colours.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:maamaas/widgets/widgets/phonecall.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../../../../Models/caterings/orders_model.dart';
// import '../../../Invoices/cateringPdf.dart';
// import '../catering_enquiry/catering_enquires.dart';
// import 'package:flutter/material.dart';
// import 'catering_ordershelper.dart';
// import 'package:intl/intl.dart';
//
// class CateringOrdersScreen extends StatefulWidget {
//   const CateringOrdersScreen({super.key});
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _CateringOrdersScreenState createState() => _CateringOrdersScreenState();
// }
//
// class _CateringOrdersScreenState extends State<CateringOrdersScreen> {
//   bool _isLoading = true;
//   List<_CombinedItem> _combinedList = [];
//   String selectedFilter = 'order';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     try {
//       final orders = await catering_authservice.getAllCateringOrders();
//       final enquiries = await catering_authservice.getAllEnquiries();
//
//       _combinedList = [
//         ...orders.map((o) => _CombinedItem(type: 'order', data: o)),
//         ...enquiries.map((e) => _CombinedItem(type: 'enquiry', data: e)),
//       ].reversed.toList();
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         body: Column(
//           children: [
//             // Header
//             _buildHeader(),
//             Expanded(
//               child: _isLoading
//                   ? _buildLoadingState()
//                   : _combinedList.isEmpty
//                   ? _buildEmptyState()
//                   : _buildContent(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 16,
//         bottom: 16,
//         left: 12, // slight reduction for scroll
//         right: 12,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         child: Center(
//           child: Row(
//             children: [
//               _buildFilterChip('Orders', 'order'),
//               SizedBox(width: 8.w),
//               _buildFilterChip('Enquiries', 'enquiry'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilterChip(String label, String value) {
//     final isSelected = selectedFilter == value;
//     return GestureDetector(
//       onTap: () => setState(() => selectedFilter = value),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? cateringorders_helper.getChipColor(value)
//               : Colors.grey[200],
//           borderRadius: BorderRadius.circular(20),
//           border: isSelected
//               ? Border.all(
//                   color: cateringorders_helper.getChipColor(value),
//                   width: 2,
//                 )
//               : null,
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     // ignore: deprecated_member_use
//                     color: cateringorders_helper
//                         .getChipColor(value)
//                         .withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               cateringorders_helper.getChipIcon(value),
//               size: 16.w,
//               color: isSelected
//                   ? Colors.white
//                   : cateringorders_helper.getChipColor(value),
//             ),
//             SizedBox(width: 6.w),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected
//                     ? Colors.white
//                     : cateringorders_helper.getChipColor(value),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13.sp,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 60.w,
//             height: 60.h,
//             child: CircularProgressIndicator(
//               strokeWidth: 3,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 const Color(0xFFFF6B35),
//               ),
//             ),
//           ),
//           SizedBox(height: 20.h),
//           Text(
//             'Loading ${cateringorders_helper.getLoadingText(selectedFilter)}...',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             cateringorders_helper.getEmptyStateIcon(selectedFilter),
//             size: 100.w,
//             color: Colors.grey[300],
//           ),
//           SizedBox(height: 24.h),
//           Text(
//             cateringorders_helper.getEmptyStateTitle(selectedFilter),
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             cateringorders_helper.getEmptyStateSubtitle(selectedFilter),
//             style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 24.h),
//           ElevatedButton(
//             onPressed: _loadData,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: cateringorders_helper.getChipColor(
//                 selectedFilter,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
//             ),
//             child: Text(
//               'Refresh',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildContent() {
//     final filteredList = _combinedList
//         .where((item) => item.type == selectedFilter)
//         .toList();
//
//     return Column(
//       children: [
//         SizedBox(height: 10),
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: _loadData,
//             color: cateringorders_helper.getChipColor(selectedFilter),
//             child: filteredList.isEmpty
//                 ? _buildNoResultsForFilter()
//                 : ListView.separated(
//                     itemCount: filteredList.length,
//                     padding: EdgeInsets.symmetric(horizontal: 16.w),
//                     separatorBuilder: (context, index) =>
//                         SizedBox(height: 12.h),
//                     itemBuilder: (context, index) {
//                       final item = filteredList[index];
//                       return _buildItemCard(item);
//                     },
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildItemCard(_CombinedItem item) {
//     switch (item.type) {
//       case 'order':
//         return CateringOrderCard(
//           order: item.data,
//           onRatingSubmitted: _loadData,
//         );
//       case 'enquiry':
//         return EnquiryCard(enquiry: item.data);
//       default:
//         return const SizedBox();
//     }
//   }
//
//   Widget _buildNoResultsForFilter() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             cateringorders_helper.getEmptyStateIcon(selectedFilter),
//             size: 80.w,
//             color: Colors.grey[300],
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             cateringorders_helper.getNoResultsTitle(selectedFilter),
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             cateringorders_helper.getNoResultsSubtitle(selectedFilter),
//             style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _CombinedItem {
//   final String type; // 'order', 'enquiry', or 'enquiry_order'
//   final dynamic data;
//
//   _CombinedItem({required this.type, required this.data});
// }
//
// class CateringOrderCard extends StatelessWidget {
//   final CateringOrder order;
//   final VoidCallback? onRatingSubmitted;
//
//   const CateringOrderCard({
//     super.key,
//     required this.order,
//     this.onRatingSubmitted,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isDelivered = order.orderStatus == OrderStatus.delivered;
//     final hasRating = order.rating > 0;
//
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => OrderDetailsFullScreen(
//                   order: order,
//                   onRatingSubmitted: onRatingSubmitted,
//                 ),
//               ),
//             );
//           },
//           borderRadius: BorderRadius.circular(20),
//           child: Padding(
//             padding: EdgeInsets.all(20.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header with Badge and Status
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // LEFT: Order badge
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.green[400]!, Colors.green[600]!],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.shopping_bag_outlined,
//                             size: 14.w,
//                             color: Colors.white,
//                           ),
//                           SizedBox(width: 6.w),
//                           Text(
//                             'ORDER:#${order.id}',
//                             style: TextStyle(
//                               fontSize: 11.sp,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // RIGHT: Status
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 4.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: cateringorders_helper.getStatusColor(
//                           order.orderStatus,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           Text(
//                             order.orderStatus.name.toUpperCase(),
//                             style: TextStyle(
//                               fontSize: 10.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             size: 12.w,
//                             color: Colors.white,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(height: 16.h),
//
//                 // Date and Time
//                 Row(
//                   children: [
//                     _buildInfoItem(
//                       Icons.calendar_today_outlined,
//                       cateringorders_helper.formatDate(order.orderDateTime),
//                     ),
//                     SizedBox(width: 16.w),
//                     _buildInfoItem(
//                       Icons.access_time_outlined,
//                       cateringorders_helper.formatTime(order.orderDateTime),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16.h),
//
//                 // Items Preview
//                 ...order.items
//                     .take(2)
//                     .map(
//                       (item) => Padding(
//                         padding: EdgeInsets.symmetric(vertical: 4.h),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 "${item.packageName} (${item.quantity})",
//                                 style: TextStyle(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Text(
//                               "₹${item.packagePrice}",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14.sp,
//                                 color: Colors.green[700],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 if (order.items.length > 2)
//                   Padding(
//                     padding: EdgeInsets.only(top: 8.h),
//                     child: Text(
//                       "+ ${order.items.length - 2} more items",
//                       style: TextStyle(
//                         color: Colors.grey[500],
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ),
//                 SizedBox(height: 16.h),
//
//                 // Rating Section for Delivered Orders
//                 if (isDelivered) ...[
//                   Container(
//                     padding: EdgeInsets.all(12.w),
//                     decoration: BoxDecoration(
//                       color: Colors.orange[50],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.orange[100]!),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.star_rate_rounded,
//                           size: 16.w,
//                           color: Colors.orange[700],
//                         ),
//                         SizedBox(width: 8.w),
//                         Expanded(
//                           child: Text(
//                             hasRating
//                                 ? 'You rated this order ${order.rating} stars'
//                                 : 'Rate your order experience',
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.orange[800],
//                             ),
//                           ),
//                         ),
//                         if (!hasRating)
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 12.w,
//                               vertical: 6.h,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.orange[700],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               'Rate Now',
//                               style: TextStyle(
//                                 fontSize: 10.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoItem(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 16.w, color: Colors.grey[600]),
//         SizedBox(width: 6.w),
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: 13.sp,
//             color: Colors.grey[700],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class OrderDetailsFullScreen extends StatefulWidget {
//   final CateringOrder order;
//   final VoidCallback? onRatingSubmitted;
//
//   const OrderDetailsFullScreen({
//     super.key,
//     required this.order,
//     this.onRatingSubmitted,
//   });
//
//   @override
//   State<OrderDetailsFullScreen> createState() => _OrderDetailsFullScreenState();
// }
//
// class _OrderDetailsFullScreenState extends State<OrderDetailsFullScreen> {
//   bool _isSubmittingRating = false;
//   int selectedRating = 0;
//   bool isLoading = false;
//
//   Future<void> _submitRating(int rating) async {
//     setState(() {
//       _isSubmittingRating = true;
//     });
//
//     try {
//       // If you have a text field later, you can replace this
//       final feedback = "No feedback";
//
//       await catering_authservice.submitUserFeedback(
//         orderId: widget.order.id,
//         feedback: feedback,
//         rating: rating,
//       );
//       // ignore: use_build_context_synchronously
//       AppAlert.success(context, 'Thank you for your $rating★ rating!');
//
//       widget.onRatingSubmitted?.call();
//     } catch (e) {
//       // ignore: use_build_context_synchronously
//       AppAlert.error(context, 'Failed to submit feedback. Please try again.');
//     } finally {
//       setState(() {
//         _isSubmittingRating = false;
//       });
//     }
//   }
//
//   void _payRemainingAmount() async {
//     final amount = widget.order.amountRemaining;
//
//     try {
//       setState(() => isLoading = true);
//
//       /// 1️⃣ Create Razorpay Order
//       final orderId = await catering_authservice.createOrder(amount);
//
//       if (orderId == null) {
//         throw Exception("Failed to create Razorpay order");
//       }
//
//       final razorpay = RazorpayService();
//
//       /// 2️⃣ Success Callback
//       razorpay.onSuccess = (PaymentSuccessResponse response) async {
//         try {
//           await catering_authservice.capturePayment(
//             paymentId: response.paymentId!,
//             amount: amount,
//           );
//
//           await _recordPayment(
//             "remaining",
//             "Online_Payment",
//             razorpayPaymentId: response.paymentId,
//             razorpayOrderId: response.orderId,
//           );
//
//           // ignore: use_build_context_synchronously
//           AppAlert.success(context, "Payment successful");
//         } catch (e) {
//           // ignore: use_build_context_synchronously
//           AppAlert.error(context, "Payment captured but recording failed");
//         } finally {
//           setState(() => isLoading = false);
//         }
//       };
//
//       /// 3️⃣ Error
//       razorpay.onError = (PaymentFailureResponse response) {
//         AppAlert.error(context, response.message ?? "Payment Failed");
//         setState(() => isLoading = false);
//       };
//
//       /// 4️⃣ Start Payment
//       razorpay.startPayment(
//         orderId: orderId,
//         amount: amount,
//         description: "Remaining payment for Order #${widget.order.id}",
//       );
//     } catch (e) {
//       // ignore: use_build_context_synchronously
//       AppAlert.error(context, "Failed to start payment");
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> _recordPayment(
//     String paymentType,
//     String paymentMethod, {
//     String? razorpayPaymentId,
//     String? razorpayOrderId,
//     String? razorpaySignature,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt('userId');
//
//       if (userId == null) {
//         throw Exception('User not found');
//       }
//
//       setState(() => isLoading = true);
//
//       final success = await catering_authservice.recordPayment(
//         quotationId: widget.order.quotationId,
//         leadId: widget.order.leadId,
//         userId: userId,
//         amount: widget.order.amountRemaining,
//         paymentType: "FINAL_PAYMENT",
//         paymentMethod: paymentMethod,
//         razorpayPaymentId: razorpayPaymentId,
//         razorpayOrderId: razorpayOrderId,
//         razorpaySignature: razorpaySignature,
//       );
//
//       if (success) {
//         // ignore: use_build_context_synchronously
//         AppAlert.success(context, "Payment recorded successfully");
//       }
//     } catch (e) {
//       // ignore: use_build_context_synchronously
//       AppAlert.error(context, e.toString());
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   void _showHelpBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) {
//         return SafeArea(
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 /// Drag Handle
//                 Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//
//                 const Text(
//                   "How can we help you?",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 _buildHelpTile(
//                   icon: Icons.support_agent,
//                   color: Colors.blue,
//                   title: "Call Support",
//                   subtitle: "Talk to our 24/7 support team",
//                   onTap: () {
//                     Navigator.pop(context);
//                     phonecall.makePhoneCall('+919063888450');
//                   },
//                 ),
//
//                 _buildHelpTile(
//                   icon: Icons.chat_bubble_outline,
//                   color: Colors.green,
//                   title: "Live Chat",
//                   subtitle: "Chat with our support team",
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Navigate to chat screen
//                   },
//                 ),
//
//                 _buildHelpTile(
//                   icon: Icons.report_problem_outlined,
//                   color: Colors.orange,
//                   title: "Report an Issue",
//                   subtitle: "Facing a problem with your order?",
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => CreateTicketScreen(
//                           orderId: widget.order.id,
//                           serviceType: "CATERING",
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final formattedDate = DateFormat(
//       'dd MMM yyyy',
//     ).format(widget.order.orderDateTime);
//     final formattedTime = DateFormat(
//       'hh:mm a',
//     ).format(widget.order.orderDateTime);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("Order #${widget.order.id}"),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black87,
//         centerTitle: true,
//         shape: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Order #${widget.order.id}",
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               Chip(
//                 label: Text(
//                   widget.order.orderStatus.name.toUpperCase(),
//                   style: const TextStyle(color: Colors.white),
//                 ),
//                 backgroundColor: cateringorders_helper.getStatusColor(
//                   widget.order.orderStatus,
//                 ),
//               ),
//             ],
//           ),
//           Card(
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             color: Colors.grey.shade100,
//             child: Padding(
//               padding: EdgeInsets.all(12.w),
//               child: Column(
//                 children: [
//                   _infoRow(Icons.calendar_today, "Date", formattedDate),
//                   _infoRow(Icons.access_time, "Time", formattedTime),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 14.h),
//           Text(
//             "Delivery Details",
//             style: Theme.of(
//               context,
//             ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 8.h),
//
//           Card(
//             color: Colors.green.shade50,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(12.w),
//               child: Column(
//                 children: [
//                   _infoRow(
//                     Icons.event,
//                     "Catering Date",
//                     widget.order.cateringDate,
//                   ),
//                   _infoRow(
//                     Icons.schedule,
//                     "Catering Time",
//                     widget.order.cateringTime,
//                   ),
//                   if (widget.order.deliveryUserName.isNotEmpty)
//                     _infoRow(
//                       Icons.person,
//                       "Name",
//                       widget.order.deliveryUserName.toUpperCase(),
//                     ),
//
//                   if (widget.order.mobileNo.isNotEmpty)
//                     _infoRow(Icons.phone, "Mobile", widget.order.mobileNo),
//
//                   if (widget.order.deliveryAddress.isNotEmpty)
//                     _infoRow(
//                       Icons.location_on,
//                       "Address",
//                       widget.order.deliveryAddress,
//                     ),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 8.h),
//
//           Text("Ordered Items", style: AppStyles.titleStyle),
//           SizedBox(height: 8.h),
//           ...widget.order.items.map((item) => buildOrderItem(item)),
//           SizedBox(height: 8.h),
//           Text("Addons", style: AppStyles.titleStyle),
//           SizedBox(height: 8.h),
//           ...widget.order.addOns.map((item) => buildOrderaddon(item)),
//           Divider(height: 24.h),
//
//           const SizedBox(height: 16),
//
//           _buildOrderSummary(),
//           const SizedBox(height: 20),
//           if (widget.order.paymentStatus.toLowerCase() == "partially_paid" &&
//               widget.order.amountRemaining > 0)
//             _buildPendingPaymentWidget(),
//
//           const SizedBox(height: 20),
//           // ignore: unrelated_type_equality_checks
//           if (widget.order.orderStatus == OrderStatus.delivered)
//             _buildRatingSection(),
//           const SizedBox(height: 10),
//           _buildNeedHelpSection(),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget buildOrderItem(CateringOrderItem item) {
//     return Card(
//       color: Colors.white,
//       margin: EdgeInsets.symmetric(vertical: 4.h),
//       child: Padding(
//         padding: AppStyles.cardPadding,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Header Row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   item.packageName,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//
//                 if (item.packagePrice > 0)
//                   Text(
//                     "₹${item.packagePrice.toStringAsFixed(2)}",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//               ],
//             ),
//
//             const SizedBox(height: 6),
//
//             /// CASE 1 : Single Item
//             if (item.itemsName.isNotEmpty)
//               Text(
//                 "• ${item.itemsName}",
//                 style: const TextStyle(fontSize: 13, color: Colors.grey),
//               ),
//
//             /// CASE 2 : Package Items
//             if (item.packageItems.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: item.packageItems.map((pkgItem) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 2),
//                     child: Text(
//                       "• ${pkgItem.itemName}",
//                       style: const TextStyle(fontSize: 13, color: Colors.grey),
//                     ),
//                   );
//                 }).toList(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildOrderaddon(CateringAddOn addOn) {
//     return Card(
//       color: Colors.white,
//       margin: EdgeInsets.symmetric(vertical: 4.h),
//       child: Padding(
//         padding: AppStyles.cardPadding,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 addOn.addOnType.replaceAll("_", " "),
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//
//             Text(
//               "Qty: ${addOn.quantity}",
//               style: const TextStyle(fontSize: 13),
//             ),
//
//             Text(
//               "₹${addOn.totalAmount.toStringAsFixed(2)}",
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderSummary() {
//     final order = widget.order;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// Header
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Order Summary",
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//
//             /// Invoice Button
//             // if (order.orderStatus == OrderStatus.delivered)
//             InkWell(
//               borderRadius: BorderRadius.circular(8.r),
//               onTap: () async {
//                 if (!mounted) return;
//
//                 AppAlert.info(context, "Generating invoice...");
//                 await cateringpdf().downloadInvoice(widget.order.id);
//
//                 if (!mounted) return;
//               },
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8.r),
//                   gradient: LinearGradient(
//                     colors: [Colors.blue.shade700, Colors.blue.shade500],
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.receipt, size: 16.sp, color: Colors.white),
//                     SizedBox(width: 6.w),
//                     Text(
//                       "Invoice",
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 8.h),
//
//         /// Summary rows
//         _summaryRow("Subtotal", order.subtotal),
//         _summaryRow("SGST", order.sgst),
//         _summaryRow("CGST", order.cgst),
//
//         _summaryRow("Delivery charges", order.deliveryFee),
//
//         _summaryRow("Platform Charges", order.platformFeeAmount),
//
//         const Divider(height: 20),
//
//         /// Total
//         _summaryRow("Total", order.total, isTotal: true),
//       ],
//     );
//   }
//
//   Widget _summaryRow(String title, double amount, {bool isTotal = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 3.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "$title:",
//             style: TextStyle(
//               fontSize: isTotal ? 15.sp : 14.sp,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             "₹${amount.toStringAsFixed(2)}",
//             style: TextStyle(
//               fontSize: isTotal ? 15.sp : 14.sp,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPendingPaymentWidget() {
//     final order = widget.order;
//
//     return Card(
//       color: Colors.red.shade50,
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.warning_amber_rounded,
//                   color: Colors.red.shade700,
//                   size: 28,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     "Pending Payment",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red.shade700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 8),
//
//             Text(
//               "You still have a pending amount to complete this order.",
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//             ),
//
//             const SizedBox(height: 10),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Remaining: ₹${order.amountRemaining.toStringAsFixed(2)}",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//
//                 ElevatedButton.icon(
//                   onPressed: _payRemainingAmount,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.shade600,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   icon: const Icon(Icons.payment, color: Colors.white),
//                   label: const Text(
//                     "Pay Now",
//                     style: TextStyle(color: Colors.white),
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
//   Widget _infoRow(
//     IconData icon,
//     String label,
//     String value, {
//     Color? valueColor,
//     bool isBold = false,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 16.sp, color: Colors.grey.shade600),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: RichText(
//               text: TextSpan(
//                 style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
//                 children: [
//                   TextSpan(
//                     text: "$label: ",
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   TextSpan(
//                     text: value,
//                     style: TextStyle(
//                       fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                       color: valueColor ?? Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRatingSection() {
//     final hasRating = widget.order.rating > 0;
//
//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (hasRating) ...[
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       "Thank you for your rating!",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.green[700],
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(5, (index) {
//                         return Icon(
//                           index < widget.order.rating
//                               ? Icons.star_rounded
//                               : Icons.star_border_rounded,
//                           color: Colors.orange,
//                           size: 32,
//                         );
//                       }),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "${widget.order.rating}/5 Stars",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ] else ...[
//               Text(
//                 "How was your order experience?",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               SizedBox(height: 16),
//               Center(child: _buildRatingStars()),
//               SizedBox(height: 16),
//               if (_isSubmittingRating)
//                 Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
//                   ),
//                 ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRatingStars() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(5, (index) {
//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedRating = index + 1;
//             });
//             _submitRating(selectedRating);
//           },
//           child: Icon(
//             index < selectedRating
//                 ? Icons.star_rounded
//                 : Icons.star_border_rounded,
//             color: Colors.orange,
//             size: 40,
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildNeedHelpSection() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Colors.grey.shade200)),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () => _showHelpBottomSheet(context),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: LinearGradient(
//               colors: [Colors.blue.shade600, Colors.blue.shade400],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.blue.withOpacity(0.25),
//                 blurRadius: 12,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Row(
//             children: const [
//               Icon(Icons.support_agent, color: Colors.white, size: 26),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   "Need Help With Your Order?",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHelpTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: ListTile(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         leading: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: color),
//         ),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//         subtitle: Text(subtitle),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: onTap,
//       ),
//     );
//   }
// }

import 'package:maamaas/screens/screens/supportteam/tickets_screen.dart';
import '../../../../Services/Auth_service/catering_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../../../Services/paymentservice/razorpayservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maamaas/widgets/widgets/phonecall.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../Models/caterings/orders_model.dart';
import '../../../Invoices/cateringPdf.dart';
import '../catering_enquiry/catering_enquires.dart';
import 'package:flutter/material.dart';
import 'catering_ordershelper.dart';
import 'package:intl/intl.dart';

// ─── Shared Design Tokens ──────────────────────────────────────────────────

class _T {
  static const primary = Color(0xFF1B7A50);
  static const primaryLight = Color(0xFFE8F5EE);
  static const surface = Colors.white;
  static const bg = Color(0xFFF4F5F7);
  static const border = Color(0xFFF0F0F0);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF888888);
  static const textMuted = Color(0xFFAAAAAA);
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEF2F2);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFFF8EC);
  static const info = Color(0xFF4F46E5);
  static const infoLight = Color(0xFFEEF2FF);
  static const delivered = Color(0xFF6366F1);
}

// ─── Combined Item ─────────────────────────────────────────────────────────

class _CombinedItem {
  final String type;
  final dynamic data;
  _CombinedItem({required this.type, required this.data});
}

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN 1: Orders List
// ═══════════════════════════════════════════════════════════════════════════

class CateringOrdersScreen extends StatefulWidget {
  const CateringOrdersScreen({super.key});

  @override
  _CateringOrdersScreenState createState() => _CateringOrdersScreenState();
}

class _CateringOrdersScreenState extends State<CateringOrdersScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<_CombinedItem> _combinedList = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final orders = await catering_authservice.getAllCateringOrders();
      final enquiries = await catering_authservice.getAllEnquiries();
      _combinedList = [
        ...orders.map((o) => _CombinedItem(type: 'order', data: o)),
        ...enquiries.map((e) => _CombinedItem(type: 'enquiry', data: e)),
      ].reversed.toList();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _isLoading ? _buildLoader() : _buildTabViews()),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: _T.surface,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: _T.surface,
            unselectedLabelColor: _T.textSecondary,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13.sp),
            indicator: BoxDecoration(
              color: _T.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 16.sp),
                    SizedBox(width: 6.w),
                    const Text('Orders'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline_rounded, size: 16.sp),
                    SizedBox(width: 6.w),
                    const Text('Enquiries'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab Views ────────────────────────────────────────────────────────────

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: [_buildList('order'), _buildList('enquiry')],
    );
  }

  Widget _buildList(String type) {
    final items = _combinedList.where((i) => i.type == type).toList();
    if (items.isEmpty) return _buildEmpty(type);
    return RefreshIndicator(
      color: _T.primary,
      onRefresh: _loadData,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) => type == 'order'
            ? CateringOrderCard(order: items[i].data, onRefresh: _loadData)
            : EnquiryCard(enquiry: items[i].data),
      ),
    );
  }

  // ── Empty / Loader ───────────────────────────────────────────────────────

  Widget _buildLoader() {
    return Center(
      child: CircularProgressIndicator(color: _T.primary, strokeWidth: 2.5),
    );
  }

  Widget _buildEmpty(String type) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type == 'order'
                ? Icons.receipt_long_outlined
                : Icons.help_outline_rounded,
            size: 56.sp,
            color: _T.textMuted,
          ),
          SizedBox(height: 16.h),
          Text(
            type == 'order' ? 'No orders yet' : 'No enquiries yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _T.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 13.sp, color: _T.textMuted),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ORDER CARD
// ═══════════════════════════════════════════════════════════════════════════

class CateringOrderCard extends StatelessWidget {
  final CateringOrder order;
  final VoidCallback? onRefresh;

  const CateringOrderCard({super.key, required this.order, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.orderStatus == OrderStatus.delivered;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: order, onRefresh: onRefresh),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _T.border),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Badge + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OrderBadge(id: order.id),
                _StatusChip(status: order.orderStatus),
              ],
            ),
            SizedBox(height: 12.h),

            // Row 2: Date + Time
            Row(
              children: [
                _MetaTag(
                  icon: Icons.calendar_today_outlined,
                  label: DateFormat('dd MMM yyyy').format(order.orderDateTime),
                ),
                SizedBox(width: 12.w),
                _MetaTag(
                  icon: Icons.access_time_outlined,
                  label: DateFormat('hh:mm a').format(order.orderDateTime),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Items
            ...order.items
                .take(2)
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.packageName} (${item.quantity})',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: _T.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹${item.packagePrice}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: _T.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (order.items.length > 2)
              Text(
                '+ ${order.items.length - 2} more items',
                style: TextStyle(fontSize: 11.sp, color: _T.textMuted),
              ),

            // Rating bar for delivered orders
            if (isDelivered) ...[
              SizedBox(height: 10.h),
              _RatingBar(order: order),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Small Reusable Widgets ────────────────────────────────────────────────

class _OrderBadge extends StatelessWidget {
  final int id;
  const _OrderBadge({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _T.primaryLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 13.sp, color: _T.primary),
          SizedBox(width: 5.w),
          Text(
            'ORDER #$id',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: _T.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  Color get _bg {
    switch (status) {
      case OrderStatus.delivered:
        return _T.delivered;
      case OrderStatus.confirmed:
        return _T.primary;
      default:
        return _T.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: _T.textMuted),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: _T.textSecondary),
        ),
      ],
    );
  }
}

class _RatingBar extends StatelessWidget {
  final CateringOrder order;
  const _RatingBar({required this.order});

  @override
  Widget build(BuildContext context) {
    final hasRating = order.rating > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: _T.warningLight,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 15.sp, color: _T.warning),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              hasRating
                  ? 'You rated ${order.rating} stars'
                  : 'Rate your experience',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB45309),
              ),
            ),
          ),
          if (!hasRating)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: _T.warning,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Text(
                'Rate Now',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN 2: Order Detail
// ═══════════════════════════════════════════════════════════════════════════

class OrderDetailScreen extends StatefulWidget {
  final CateringOrder order;
  final VoidCallback? onRefresh;

  const OrderDetailScreen({super.key, required this.order, this.onRefresh});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _submittingRating = false;
  int _selectedRating = 0;
  bool _isLoading = false;

  // ── Rating ───────────────────────────────────────────────────────────────

  Future<void> _submitRating(int rating) async {
    setState(() => _submittingRating = true);
    try {
      await catering_authservice.submitUserFeedback(
        orderId: widget.order.id,
        feedback: 'No feedback',
        rating: rating,
      );
      if (mounted)
        AppAlert.success(context, 'Thank you for your $rating★ rating!');
      widget.onRefresh?.call();
    } catch (_) {
      if (mounted)
        AppAlert.error(context, 'Failed to submit feedback. Please try again.');
    } finally {
      if (mounted) setState(() => _submittingRating = false);
    }
  }

  // ── Payment ──────────────────────────────────────────────────────────────

  void _payRemaining() async {
    try {
      setState(() => _isLoading = true);
      final orderId = await catering_authservice.createOrder(
        widget.order.amountRemaining,
      );
      if (orderId == null) throw Exception('Failed to create order');

      final rp = RazorpayService();
      rp.onSuccess = (PaymentSuccessResponse r) async {
        try {
          await catering_authservice.capturePayment(
            paymentId: r.paymentId!,
            amount: widget.order.amountRemaining,
          );
          await _recordPayment(
            'remaining',
            'Online_Payment',
            razorpayPaymentId: r.paymentId,
            razorpayOrderId: r.orderId,
          );
          if (mounted) AppAlert.success(context, 'Payment successful');
        } catch (_) {
          if (mounted)
            AppAlert.error(context, 'Payment captured but recording failed');
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      };
      rp.onError = (PaymentFailureResponse r) {
        AppAlert.error(context, r.message ?? 'Payment Failed');
        setState(() => _isLoading = false);
      };
      rp.startPayment(
        orderId: orderId,
        amount: widget.order.amountRemaining,
        description: 'Remaining payment for Order #${widget.order.id}',
      );
    } catch (_) {
      if (mounted) AppAlert.error(context, 'Failed to start payment');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recordPayment(
    String paymentType,
    String paymentMethod, {
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) throw Exception('User not found');

    setState(() => _isLoading = true);
    try {
      final ok = await catering_authservice.recordPayment(
        quotationId: widget.order.quotationId,
        leadId: widget.order.leadId,
        userId: userId,
        amount: widget.order.amountRemaining,
        paymentType: 'FINAL_PAYMENT',
        paymentMethod: paymentMethod,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );
      if (ok && mounted)
        AppAlert.success(context, 'Payment recorded successfully');
    } catch (e) {
      if (mounted) AppAlert.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Help Sheet ───────────────────────────────────────────────────────────

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'How can we help you?',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20.h),
              _HelpTile(
                icon: Icons.support_agent_outlined,
                color: Colors.blue,
                title: 'Call Support',
                subtitle: 'Talk to our 24/7 support team',
                onTap: () {
                  Navigator.pop(context);
                  phonecall.makePhoneCall('+919063888450');
                },
              ),
              _HelpTile(
                icon: Icons.chat_bubble_outline_rounded,
                color: Colors.green,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () => Navigator.pop(context),
              ),
              _HelpTile(
                icon: Icons.report_problem_outlined,
                color: Colors.orange,
                title: 'Report an Issue',
                subtitle: 'Facing a problem with your order?',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateTicketScreen(
                        orderId: widget.order.id,
                        serviceType: 'CATERING',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final fDate = DateFormat('dd MMM yyyy').format(order.orderDateTime);
    final fTime = DateFormat('hh:mm a').format(order.orderDateTime);

    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _T.textPrimary,
        title: Text(
          'Order #${order.id}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _T.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: _T.border),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              AppAlert.info(context, 'Generating invoice...');
              await cateringpdf().downloadInvoice(order.id);
            },
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _T.infoLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_outlined, size: 14.sp, color: _T.info),
                  SizedBox(width: 5.w),
                  Text(
                    'Invoice',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _T.info,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: _T.primary,
                strokeWidth: 2.5,
              ),
            )
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              children: [
                // Order hero card
                _Section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'Placed on $fDate',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: _T.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          _StatusChip(status: order.orderStatus),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          _DateChip(
                            icon: Icons.calendar_today_outlined,
                            label: fDate,
                          ),
                          SizedBox(width: 10.w),
                          _DateChip(
                            icon: Icons.access_time_outlined,
                            label: fTime,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                _SectionLabel(label: 'Delivery Details'),
                _Section(
                  color: const Color(0xFFF0FAF5),
                  borderColor: const Color(0xFFC6F0DA),
                  child: Column(
                    children: [
                      if (order.cateringDate.isNotEmpty)
                        _InfoRow(
                          icon: Icons.event_outlined,
                          label: 'Event Date',
                          value: order.cateringDate,
                        ),
                      if (order.cateringTime.isNotEmpty)
                        _InfoRow(
                          icon: Icons.schedule_outlined,
                          label: 'Event Time',
                          value: order.cateringTime,
                        ),
                      if (order.deliveryUserName.isNotEmpty)
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Name',
                          value: order.deliveryUserName.toUpperCase(),
                        ),
                      if (order.mobileNo.isNotEmpty)
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Mobile',
                          value: order.mobileNo,
                        ),
                      if (order.deliveryAddress.isNotEmpty)
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: order.deliveryAddress,
                        ),
                    ],
                  ),
                ),

                _SectionLabel(label: 'Ordered Items'),
                _Section(
                  child: Column(
                    children: order.items
                        .map((item) => _ItemRow(item: item))
                        .toList(),
                  ),
                ),

                if (order.addOns.isNotEmpty) ...[
                  _SectionLabel(label: 'Add-ons'),
                  _Section(
                    child: Column(
                      children: order.addOns
                          .map((a) => _AddonRow(addOn: a))
                          .toList(),
                    ),
                  ),
                ],

                _SectionLabel(label: 'Order Summary'),
                _Section(
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Subtotal', amount: order.subtotal),
                      _SummaryRow(label: 'SGST', amount: order.sgst),
                      _SummaryRow(label: 'CGST', amount: order.cgst),
                      _SummaryRow(label: 'Delivery', amount: order.deliveryFee),
                      _SummaryRow(
                        label: 'Platform Fee',
                        amount: order.platformFeeAmount,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Divider(color: _T.border, height: 1),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        amount: order.total,
                        bold: true,
                      ),
                    ],
                  ),
                ),

                if (order.paymentStatus.toLowerCase() == 'partially_paid' &&
                    order.amountRemaining > 0) ...[
                  SizedBox(height: 4.h),
                  _PendingPaymentCard(
                    amount: order.amountRemaining,
                    onPay: _payRemaining,
                  ),
                ],

                if (order.orderStatus == OrderStatus.delivered) ...[
                  SizedBox(height: 4.h),
                  _RatingSection(
                    order: order,
                    selectedRating: _selectedRating,
                    isSubmitting: _submittingRating,
                    onRate: (r) {
                      setState(() => _selectedRating = r);
                      _submitRating(r);
                    },
                  ),
                ],

                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: _showHelp,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.support_agent_outlined,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need Help?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Call, chat or report an issue',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
    );
  }
}

// ─── Detail Screen Sub-widgets ─────────────────────────────────────────────

class _Section extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;

  const _Section({required this.child, this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color ?? _T.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor ?? _T.border),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, left: 2.w),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: _T.textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DateChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12.sp, color: _T.textSecondary),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: _T.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: _T.primary),
          SizedBox(width: 8.w),
          SizedBox(
            width: 70.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _T.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, color: _T.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CateringOrderItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.packageName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.packagePrice > 0)
                Text(
                  '₹${item.packagePrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _T.primary,
                  ),
                ),
            ],
          ),
          if (item.itemsName.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                '• ${item.itemsName}',
                style: TextStyle(fontSize: 11.sp, color: _T.textSecondary),
              ),
            ),
          ...item.packageItems.map(
            (p) => Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                '• ${p.itemName}',
                style: TextStyle(fontSize: 11.sp, color: _T.textSecondary),
              ),
            ),
          ),
          if (item != (context.findAncestorWidgetOfExactType<_Section>()))
            Divider(height: 10.h, color: _T.border),
        ],
      ),
    );
  }
}

class _AddonRow extends StatelessWidget {
  final CateringAddOn addOn;
  const _AddonRow({required this.addOn});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              addOn.addOnType.replaceAll('_', ' '),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            'Qty: ${addOn.quantity}',
            style: TextStyle(fontSize: 12.sp, color: _T.textSecondary),
          ),
          SizedBox(width: 12.w),
          Text(
            '₹${addOn.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _T.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  const _SummaryRow({
    required this.label,
    required this.amount,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 15.sp : 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? _T.textPrimary : _T.textSecondary,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: bold ? 15.sp : 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold ? _T.textPrimary : _T.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  final double amount;
  final VoidCallback onPay;
  const _PendingPaymentCard({required this.amount, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: _T.dangerLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _T.danger, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Payment',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _T.danger,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '₹${amount.toStringAsFixed(2)} remaining',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onPay,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _T.danger,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Pay Now',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final CateringOrder order;
  final int selectedRating;
  final bool isSubmitting;
  final ValueChanged<int> onRate;

  const _RatingSection({
    required this.order,
    required this.selectedRating,
    required this.isSubmitting,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final hasRating = order.rating > 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _T.border),
      ),
      child: hasRating
          ? Column(
              children: [
                Text(
                  'Thank you for your rating!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _T.primary,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < order.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _T.warning,
                      size: 30.sp,
                    );
                  }),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${order.rating}/5 Stars',
                  style: TextStyle(fontSize: 13.sp, color: _T.textSecondary),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 14.h),
                if (isSubmitting)
                  Center(
                    child: CircularProgressIndicator(
                      color: _T.warning,
                      strokeWidth: 2.5,
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => onRate(i + 1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            i < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: _T.warning,
                            size: 38.sp,
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _T.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: _T.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: _T.textMuted),
          ],
        ),
      ),
    );
  }
}
