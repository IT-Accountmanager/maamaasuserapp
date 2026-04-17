// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import '../../Services/Auth_service/catering_authservice.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../Food&beverages/RestaurentsScreen/restaurentsnew.dart';
// import '../Invoices/cateringPdf.dart';
// import 'package:flutter/material.dart';
// import '../foodmainscreen.dart';
// import 'dart:convert';
//
//
// import 'package:maamaas/Services/App_color_service/app_colours.dart';
// // ignore: camel_case_types
// class catering_invoice extends StatefulWidget {
//   final int orderId;
//   const catering_invoice({super.key, required this.orderId});
//   @override
//   _catering_invoiceState createState() => _catering_invoiceState();
// }
//
// // ignore: camel_case_types
// class _catering_invoiceState extends State<catering_invoice> {
//   late final int orderId;
//
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(const Duration(seconds: 10), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => MainScreenfood()),
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     // ignore: deprecated_member_use
//     return WillPopScope(
//       onWillPop: () async {
//         // Navigate to home and clear previous stack
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 Restaurents(scrollController: _scrollController),
//           ),
//           (route) => false,
//         );
//         return false; // prevent normal back
//       },
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: theme.colorScheme.surface, // Use theme background
//           appBar: AppBar(title: Center(child: Text("Invoice"))),
//           body: Stack(
//             children: [
//               FutureBuilder<Map<String, dynamic>?>(
//                 future: catering_authservice().fetchOrderById(widget.orderId),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(
//                       child: Text(
//                         "Error fetching invoice: ${snapshot.error}",
//                         style: TextStyle(color: theme.colorScheme.error),
//                       ),
//                     );
//                   } else if (!snapshot.hasData || snapshot.data == null) {
//                     return const Center(
//                       child: Text("No invoice details found."),
//                     );
//                   }
//
//                   final data = snapshot.data!;
//                   final List<dynamic> items =
//                       data['orderItems'] as List<dynamic>? ?? [];
//
//                   return SingleChildScrollView(
//                     padding: EdgeInsets.symmetric(
//                       vertical: 20.h,
//                       horizontal: 16.w,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         _buildInvoiceContentCard(context, theme, data, items),
//                         SizedBox(height: 24.h),
//                         _buildActionButtons(context, theme, data),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInvoiceContentCard(
//     BuildContext context,
//     ThemeData theme,
//     Map<String, dynamic> data,
//     List<dynamic> items,
//   ) {
//     final cardBackgroundColor = theme.brightness == Brightness.dark
//         ? Colors.grey[800]
//         // : Color(0xFF6A1B9A);
//         : AppColors.of(context).primary;
//     final onCardColor = Colors.white;
//     final dateTimeString = data['orderDateTime'] ?? '';
//     DateTime? parsedDateTime;
//
//     try {
//       parsedDateTime = DateTime.parse(dateTimeString);
//     } catch (e) {
//       parsedDateTime = null;
//     }
//
//     final formattedDate = parsedDateTime != null
//         ? "${parsedDateTime.year}-${parsedDateTime.month.toString().padLeft(2, '0')}-${parsedDateTime.day.toString().padLeft(2, '0')}"
//         : 'N/A';
//
//     final formattedTime = parsedDateTime != null
//         ? "${parsedDateTime.hour.toString().padLeft(2, '0')}:${parsedDateTime.minute.toString().padLeft(2, '0')}"
//         : 'N/A';
//
//     return Card(
//       elevation: 3,
//       margin: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       color: cardBackgroundColor,
//       child: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Text(
//                 "Order Summary",
//                 style: TextStyle(
//                   color: onCardColor,
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             _buildInfoRow(
//               context,
//               "Order ID:",
//               "${data['orderId'] ?? 'N/A'}",
//               onCardColor: onCardColor,
//             ),
//             _buildInfoRow(
//               context,
//               "Date:",
//               formattedDate,
//               onCardColor: onCardColor,
//             ),
//             _buildInfoRow(
//               context,
//               "Time:",
//               formattedTime,
//               onCardColor: onCardColor,
//             ),
//
//             _buildInfoRow(
//               context,
//               "Payment:",
//               (data['paymentMethod'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
//               onCardColor: onCardColor,
//             ),
//             if (data['paymentMethod']?.toString() == "Online_Payment")
//               _buildInfoRow(
//                 context,
//                 "Transaction ID:",
//                 data['transactionId'] ?? "N/A",
//                 onCardColor: onCardColor,
//               ),
//             _buildInfoRow(
//               context,
//               "Date:",
//               "${data['cateringDate'] ?? 'N/A'}",
//               onCardColor: onCardColor,
//             ),
//             _buildInfoRow(
//               context,
//               "Time:",
//               "${data['cateringTime'] ?? 'N/A'}",
//               onCardColor: onCardColor,
//             ),
//             if (data['location'] != null &&
//                 (data['location'] as String).isNotEmpty)
//               _buildInfoRow(
//                 context,
//                 "Location:",
//                 "${data['location']}",
//                 onCardColor: onCardColor,
//               ),
//
//             Divider(
//               // ignore: deprecated_member_use
//               color: onCardColor.withOpacity(0.4),
//               thickness: 0.8,
//               height: 25.h,
//             ),
//             Text(
//               "Ordered Items",
//               style: TextStyle(
//                 color: onCardColor,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15.sp,
//               ),
//             ),
//             SizedBox(height: 10.h),
//             _buildItemsTable(context, items, onCardColor),
//
//             SizedBox(height: 15.h),
//             _buildPriceDetails(context, data, onCardColor),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(
//     BuildContext context,
//     String label,
//     String value, {
//     required Color onCardColor,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 3.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 // ignore: deprecated_member_use
//                 color: onCardColor.withOpacity(0.85),
//                 fontSize: 13.sp,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: onCardColor,
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemsTable(
//     BuildContext context,
//     List<dynamic> items,
//     Color onCardColor,
//   ) {
//     final headerStyle = TextStyle(
//       // ignore: deprecated_member_use
//       color: onCardColor.withOpacity(0.95),
//       fontSize: 12,
//       fontWeight: FontWeight.bold,
//     );
//     final cellStyle = TextStyle(color: onCardColor, fontSize: 11);
//
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         // ignore: deprecated_member_use
//         color: Colors.white.withOpacity(0.05),
//       ),
//       child: Table(
//         border: TableBorder.symmetric(
//           // ignore: deprecated_member_use
//           inside: BorderSide(color: onCardColor.withOpacity(0.1)),
//         ),
//         columnWidths: const {
//           0: IntrinsicColumnWidth(),
//           1: FlexColumnWidth(3),
//           2: IntrinsicColumnWidth(),
//           3: IntrinsicColumnWidth(),
//         },
//         children: [
//           // 🏷️ Header Row
//           TableRow(
//             // ignore: deprecated_member_use
//             decoration: BoxDecoration(color: Colors.white.withOpacity(0.15)),
//             children: [
//               _tableCell("S.No", headerStyle, align: TextAlign.center),
//               _tableCell("Package (Items)", headerStyle),
//               _tableCell("Qty", headerStyle, align: TextAlign.center),
//               _tableCell("Total", headerStyle, align: TextAlign.right),
//             ],
//           ),
//
//           // 📦 Data Rows
//           ...items.asMap().entries.map((entry) {
//             final index = entry.key;
//             final data = entry.value as Map<String, dynamic>;
//
//             // Extract nested package items safely
//             final List<dynamic> packageItems = (data['packageItems'] is String)
//                 ? (jsonDecode(data['packageItems']) as List)
//                 : (data['packageItems'] ?? []);
//
//             // Build bullet points for item names
//             final String itemNames = packageItems.isNotEmpty
//                 ? packageItems.map((e) => "• ${e['itemName'] ?? ''}").join('\n')
//                 : '—';
//
//             // Calculate total for this package
//             final double packagePrice =
//                 (data['packagePrice'] as num?)?.toDouble() ?? 0.0;
//             final int quantity = (data['quantity'] as num?)?.toInt() ?? 0;
//             final double total = packagePrice * quantity;
//
//             return TableRow(
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     // ignore: deprecated_member_use
//                     color: onCardColor.withOpacity(0.15),
//                     width: 0.5,
//                   ),
//                 ),
//               ),
//               children: [
//                 _tableCell(
//                   "${index + 1}",
//                   cellStyle,
//                   align: TextAlign.center,
//                   padding: 8,
//                 ),
//                 _tableCell(
//                   "${data['packageName'] ?? 'N/A'}\n$itemNames",
//                   cellStyle.copyWith(height: 1.4),
//                   padding: 8,
//                 ),
//                 _tableCell(
//                   quantity.toString(),
//                   cellStyle,
//                   align: TextAlign.center,
//                   padding: 8,
//                 ),
//                 _tableCell(
//                   "₹${total.toStringAsFixed(2)}",
//                   cellStyle,
//                   align: TextAlign.right,
//                   padding: 8,
//                 ),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _tableCell(
//     String text,
//     TextStyle style, {
//     TextAlign align = TextAlign.left,
//     double padding = 6,
//   }) {
//     return Padding(
//       padding: EdgeInsets.all(padding.w),
//       child: Text(text, style: style, textAlign: align),
//     );
//   }
//
//   Widget _buildPriceDetails(
//     BuildContext context,
//     Map<String, dynamic> data,
//     Color onCardColor,
//   ) {
//     final num subTotal = data['subtotal'] ?? 0;
//     final num discount = data['discountAmount'] ?? 0;
//     final num sgst = data['sgst'] ?? 0;
//     final num cgst = data['cgst'] ?? 0;
//     final num platformCharges = data['platformFeeAmount'] ?? 0;
//     final num grandTotal = data['total'] ?? 0;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         SizedBox(height: 5.h),
//         _buildInfoRow(
//           context,
//           "Sub Total:",
//           "₹${subTotal.toStringAsFixed(2)}",
//           onCardColor: onCardColor,
//         ),
//         if (discount > 0)
//           _buildInfoRow(
//             context,
//             "Discount:",
//             "- ₹${discount.toStringAsFixed(2)}",
//             onCardColor: Colors.greenAccent,
//           ),
//
//         _buildInfoRow(
//           context,
//           "Platform charges",
//           "₹${platformCharges.toStringAsFixed(2)}",
//           onCardColor: onCardColor,
//         ),
//
//         _buildInfoRow(
//           context,
//           "SGST:",
//           "₹${sgst.toStringAsFixed(2)}",
//           onCardColor: onCardColor,
//         ),
//         _buildInfoRow(
//           context,
//           "CGST:",
//           "₹${cgst.toStringAsFixed(2)}",
//           onCardColor: onCardColor,
//         ),
//         Divider(
//           // ignore: deprecated_member_use
//           color: onCardColor.withOpacity(0.4),
//           thickness: 0.8,
//           height: 20.h,
//         ),
//         _buildInfoRow(
//           context,
//           "Grand Total:",
//           "₹${grandTotal.toStringAsFixed(2)}",
//           onCardColor: onCardColor,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButtons(
//     BuildContext context,
//     ThemeData theme,
//     Map<String, dynamic> data,
//   ) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 0.w),
//
//       child: Expanded(
//         child: ElevatedButton.icon(
//           onPressed: () async {
//             AppAlert.info(context, "Generating invoice...");
//
//             await cateringpdf().downloadInvoice(widget.orderId);
//           },
//           icon: Icon(Icons.download),
//           label: Text(
//             "Download PDF",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white, // Text & icon color
//             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             elevation: 4, // Shadow
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../Services/Auth_service/catering_authservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Food&beverages/RestaurentsScreen/restaurentsnew.dart';
import '../Invoices/cateringPdf.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:maamaas/Services/App_color_service/app_colours.dart';

// ignore: camel_case_types
class catering_invoice extends StatefulWidget {
  final int orderId;
  const catering_invoice({super.key, required this.orderId});

  @override
  _catering_invoiceState createState() => _catering_invoiceState();
}

// ignore: camel_case_types
class _catering_invoiceState extends State<catering_invoice>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();

    // Future.delayed(const Duration(seconds: 10), () {
    //   if (mounted) {
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (_) => MainScreenfood()),
    //     );
    //   }
    // });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => Restaurents(scrollController: _scrollController),
          ),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F0F0F)
            : const Color(0xFFF5F6FA),
        body: FutureBuilder<Map<String, dynamic>?>(
          future: catering_authservice().fetchOrderById(widget.orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoader(isDark);
            } else if (snapshot.hasError) {
              return _buildError(snapshot.error.toString(), theme);
            } else if (!snapshot.hasData || snapshot.data == null) {
              return _buildEmpty();
            }

            final data = snapshot.data!;
            final items = data['orderItems'] as List<dynamic>? ?? [];

            return FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildSliverAppBar(context, isDark, data),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        child: Column(
                          children: [
                            // _buildStatusBadge(data, isDark),
                            // SizedBox(height: 16.h),
                            _buildOrderInfoCard(data, isDark),
                            SizedBox(height: 12.h),
                            _buildCateringDetailsCard(data, isDark),
                            SizedBox(height: 12.h),
                            _buildItemsCard(items, isDark),
                            SizedBox(height: 12.h),
                            _buildBillCard(data, isDark),
                            SizedBox(height: 20.h),
                            _buildDownloadButton(context),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Sliver App Bar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> data,
  ) {
    final primaryColor = AppColors.of(context).primary;

    return SliverAppBar(
      expandedHeight: 40.h, // 🔥 FIX: proper height
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,

      // ─── BACK BUTTON ─────────────────────────────
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        onPressed: () {
          Navigator.pop(context); // 🔥 FIX: normal back
        },
      ),

      // ─── FLEXIBLE AREA ───────────────────────────
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 14.h),

        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Invoice",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Order Info Card ───────────────────────────────────────────────────────

  Widget _buildOrderInfoCard(Map<String, dynamic> data, bool isDark) {
    final paymentMethod =
        (data['paymentMethod'] as String?)?.replaceAll('_', ' ') ?? 'N/A';
    final isOnline = data['paymentMethod']?.toString() == "Online_Payment";

    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Order Details", Icons.info_outline_rounded, isDark),
          SizedBox(height: 12.h),
          _infoTile("Order ID", "#${data['orderId'] ?? 'N/A'}", isDark),
          _divider(isDark),
          _infoTile("Date", _formatDate(data['orderDateTime']), isDark),
          _divider(isDark),
          _infoTile("Time", _formatTime(data['orderDateTime']), isDark),
          _divider(isDark),
          _infoTile(
            "Payment",
            paymentMethod,
            isDark,
            valueColor: const Color(0xFF2196F3),
            icon: _paymentIcon(paymentMethod),
          ),
          if (isOnline) ...[
            _divider(isDark),
            _infoTile(
              "Transaction ID",
              data['transactionId'] ?? 'N/A',
              isDark,
              mono: true,
            ),
          ],
        ],
      ),
    );
  }

  // ─── Catering Details Card ─────────────────────────────────────────────────

  Widget _buildCateringDetailsCard(Map<String, dynamic> data, bool isDark) {
    final hasLocation =
        data['location'] != null && (data['location'] as String).isNotEmpty;

    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            "Catering Details",
            Icons.event_available_rounded,
            isDark,
          ),

          SizedBox(height: 12.h),

          _infoTile("Date", "${data['cateringDate'] ?? 'N/A'}", isDark),
          _divider(isDark),

          _infoTile("Time", "${data['cateringTime'] ?? 'N/A'}", isDark),
          _divider(isDark),

          _infoTile("Phone Number", "+91${data['mobileNo']}", isDark),
          _divider(isDark),

          _infoTile("Name", "${data["deliveryUserName"]}", isDark),

          if (hasLocation) ...[
            _divider(isDark),

            _infoTile(
              "Location",
              data['deliveryAddress'] ?? "N/A",
              isDark,
              isMultiline: true, // 🔥 IMPORTANT
            ),
          ],
        ],
      ),
    );
  }

  // ─── Items Card ────────────────────────────────────────────────────────────

  Widget _buildItemsCard(List<dynamic> items, bool isDark) {
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            "Ordered Items",
            Icons.restaurant_menu_rounded,
            isDark,
          ),
          SizedBox(height: 14.h),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value as Map<String, dynamic>;

            final List<dynamic> packageItems = (item['packageItems'] is String)
                ? (jsonDecode(item['packageItems']) as List)
                : (item['packageItems'] ?? []);

            final double packagePrice =
                (item['packagePrice'] as num?)?.toDouble() ?? 0.0;
            final int quantity = (item['quantity'] as num?)?.toInt() ?? 0;
            final double total = packagePrice * quantity;

            return Column(
              children: [
                if (index > 0) _divider(isDark),
                _itemRow(
                  index: index + 1,
                  packageName: item['packageName'] ?? 'N/A',
                  packageItems: packageItems,
                  quantity: quantity,
                  total: total,
                  isDark: isDark,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _itemRow({
    required int index,
    required String packageName,
    required List<dynamic> packageItems,
    required int quantity,
    required double total,
    required bool isDark,
  }) {
    final subTextColor = isDark
        ? Colors.white.withOpacity(0.45)
        : Colors.black.withOpacity(0.4);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index chip
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                "$index",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // Package info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  packageName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (packageItems.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  ...packageItems.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 4.sp, color: subTextColor),
                          SizedBox(width: 5.w),
                          Text(
                            "${e['itemName'] ?? ''}",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // Qty & Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "x$quantity",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "₹${total.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Bill Card ─────────────────────────────────────────────────────────────

  Widget _buildBillCard(Map<String, dynamic> data, bool isDark) {
    final num subTotal = data['subtotal'] ?? 0;
    final num discount = data['discountAmount'] ?? 0;
    final num sgst = data['sgst'] ?? 0;
    final num cgst = data['cgst'] ?? 0;
    final num platform = data['platformFeeAmount'] ?? 0;
    final num grandTotal = data['total'] ?? 0;

    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Bill Summary", Icons.receipt_rounded, isDark),
          SizedBox(height: 12.h),
          _billRow("Sub Total", "₹${subTotal.toStringAsFixed(2)}", isDark),
          if (discount > 0)
            _billRow(
              "Discount",
              "− ₹${discount.toStringAsFixed(2)}",
              isDark,
              valueColor: const Color(0xFF4CAF50),
            ),
          _billRow(
            "Platform Charges",
            "₹${platform.toStringAsFixed(2)}",
            isDark,
          ),
          _billRow("SGST", "₹${sgst.toStringAsFixed(2)}", isDark),
          _billRow("CGST", "₹${cgst.toStringAsFixed(2)}", isDark),
          SizedBox(height: 10.h),
          Divider(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
            thickness: 1.2,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Grand Total",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                "₹${grandTotal.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Download Button ───────────────────────────────────────────────────────

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: () async {
          AppAlert.info(context, "Generating invoice...");
          await cateringpdf().downloadInvoice(widget.orderId);
        },
        icon: const Icon(Icons.download_rounded, size: 20),
        label: Text(
          "Download PDF",
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  // ─── Shared UI Helpers ─────────────────────────────────────────────────────

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: isDark
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.35),
        ),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: isDark
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.35),
          ),
        ),
      ],
    );
  }

  Widget _infoTile(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
    IconData? icon,
    bool mono = false,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          // LABEL (fixed width = perfect alignment)
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? Colors.white.withOpacity(0.55)
                    : Colors.black.withOpacity(0.45),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // VALUE (flexible)
          Expanded(
            child: Row(
              crossAxisAlignment: isMultiline
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14.sp, color: valueColor ?? Colors.black87),
                  SizedBox(width: 6.w),
                ],

                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.left,
                    maxLines: isMultiline ? 3 : 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      height: isMultiline ? 1.4 : 1.0,
                      color:
                          valueColor ??
                          (isDark ? Colors.white : Colors.black87),
                      fontFamily: mono ? 'monospace' : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? Colors.white.withOpacity(0.55)
                  : Colors.black.withOpacity(0.45),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.05),
    );
  }

  IconData _paymentIcon(String method) {
    if (method.toLowerCase().contains('online') ||
        method.toLowerCase().contains('upi')) {
      return Icons.phone_android_rounded;
    } else if (method.toLowerCase().contains('card')) {
      return Icons.credit_card_rounded;
    }
    return Icons.payments_outlined;
  }

  // ─── State Screens ─────────────────────────────────────────────────────────

  Widget _buildLoader(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: const Color(0xFF6A1B9A),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            "Loading invoice...",
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.black.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 12.h),
            Text(
              "Failed to load invoice",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 52.sp, color: Colors.grey),
          SizedBox(height: 12.h),
          Text(
            "No invoice details found",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ─── Date/Time Helpers ─────────────────────────────────────────────────────

  String _formatDate(dynamic raw) {
    if (raw == null) return 'N/A';
    try {
      final dt = DateTime.parse(raw.toString());
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return 'N/A';
    }
  }

  String _formatTime(dynamic raw) {
    if (raw == null) return 'N/A';
    try {
      final dt = DateTime.parse(raw.toString());
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return 'N/A';
    }
  }
}
