import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../Services/Auth_service/catering_authservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Food&beverages/RestaurentsScreen/restaurentsnew.dart';
import '../Invoices/catering Invoices.dart';
import 'package:flutter/material.dart';
import '../foodmainscreen.dart';
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
class _catering_invoiceState extends State<catering_invoice> {
  late final int orderId;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreenfood()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Navigate to home and clear previous stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Restaurents(scrollController: _scrollController),
          ),
          (route) => false,
        );
        return false; // prevent normal back
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface, // Use theme background
          appBar: AppBar(title: Center(child: Text("Invoice"))),
          body: Stack(
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: catering_authservice().fetchOrderById(widget.orderId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error fetching invoice: ${snapshot.error}",
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                      child: Text("No invoice details found."),
                    );
                  }

                  final data = snapshot.data!;
                  final List<dynamic> items =
                      data['orderItems'] as List<dynamic>? ?? [];

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 16.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInvoiceContentCard(context, theme, data, items),
                        SizedBox(height: 24.h),
                        _buildActionButtons(context, theme, data),
                      ],
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

  Widget _buildInvoiceContentCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
    List<dynamic> items,
  ) {
    final cardBackgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]
        // : Color(0xFF6A1B9A);
        : AppColors.of(context).primary;
    final onCardColor = Colors.white;
    final dateTimeString = data['orderDateTime'] ?? '';
    DateTime? parsedDateTime;

    try {
      parsedDateTime = DateTime.parse(dateTimeString);
    } catch (e) {
      parsedDateTime = null;
    }

    final formattedDate = parsedDateTime != null
        ? "${parsedDateTime.year}-${parsedDateTime.month.toString().padLeft(2, '0')}-${parsedDateTime.day.toString().padLeft(2, '0')}"
        : 'N/A';

    final formattedTime = parsedDateTime != null
        ? "${parsedDateTime.hour.toString().padLeft(2, '0')}:${parsedDateTime.minute.toString().padLeft(2, '0')}"
        : 'N/A';

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: cardBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Order Summary",
                style: TextStyle(
                  color: onCardColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _buildInfoRow(
              context,
              "Order ID:",
              "${data['orderId'] ?? 'N/A'}",
              onCardColor: onCardColor,
            ),
            _buildInfoRow(
              context,
              "Date:",
              formattedDate,
              onCardColor: onCardColor,
            ),
            _buildInfoRow(
              context,
              "Time:",
              formattedTime,
              onCardColor: onCardColor,
            ),

            _buildInfoRow(
              context,
              "Payment:",
              (data['paymentMethod'] as String?)?.replaceAll('_', ' ') ?? 'N/A',
              onCardColor: onCardColor,
            ),
            if (data['paymentMethod']?.toString() == "Online_Payment")
              _buildInfoRow(
                context,
                "Transaction ID:",
                data['transactionId'] ?? "N/A",
                onCardColor: onCardColor,
              ),
            _buildInfoRow(
              context,
              "Date:",
              "${data['cateringDate'] ?? 'N/A'}",
              onCardColor: onCardColor,
            ),
            _buildInfoRow(
              context,
              "Time:",
              "${data['cateringTime'] ?? 'N/A'}",
              onCardColor: onCardColor,
            ),
            if (data['location'] != null &&
                (data['location'] as String).isNotEmpty)
              _buildInfoRow(
                context,
                "Location:",
                "${data['location']}",
                onCardColor: onCardColor,
              ),

            Divider(
              // ignore: deprecated_member_use
              color: onCardColor.withOpacity(0.4),
              thickness: 0.8,
              height: 25.h,
            ),
            Text(
              "Ordered Items",
              style: TextStyle(
                color: onCardColor,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 10.h),
            _buildItemsTable(context, items, onCardColor),

            SizedBox(height: 15.h),
            _buildPriceDetails(context, data, onCardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    required Color onCardColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                // ignore: deprecated_member_use
                color: onCardColor.withOpacity(0.85),
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: onCardColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(
    BuildContext context,
    List<dynamic> items,
    Color onCardColor,
  ) {
    final headerStyle = TextStyle(
      // ignore: deprecated_member_use
      color: onCardColor.withOpacity(0.95),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    final cellStyle = TextStyle(color: onCardColor, fontSize: 11);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
      ),
      child: Table(
        border: TableBorder.symmetric(
          // ignore: deprecated_member_use
          inside: BorderSide(color: onCardColor.withOpacity(0.1)),
        ),
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(3),
          2: IntrinsicColumnWidth(),
          3: IntrinsicColumnWidth(),
        },
        children: [
          // 🏷️ Header Row
          TableRow(
            // ignore: deprecated_member_use
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15)),
            children: [
              _tableCell("S.No", headerStyle, align: TextAlign.center),
              _tableCell("Package (Items)", headerStyle),
              _tableCell("Qty", headerStyle, align: TextAlign.center),
              _tableCell("Total", headerStyle, align: TextAlign.right),
            ],
          ),

          // 📦 Data Rows
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value as Map<String, dynamic>;

            // Extract nested package items safely
            final List<dynamic> packageItems = (data['packageItems'] is String)
                ? (jsonDecode(data['packageItems']) as List)
                : (data['packageItems'] ?? []);

            // Build bullet points for item names
            final String itemNames = packageItems.isNotEmpty
                ? packageItems.map((e) => "• ${e['itemName'] ?? ''}").join('\n')
                : '—';

            // Calculate total for this package
            final double packagePrice =
                (data['packagePrice'] as num?)?.toDouble() ?? 0.0;
            final int quantity = (data['quantity'] as num?)?.toInt() ?? 0;
            final double total = packagePrice * quantity;

            return TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    // ignore: deprecated_member_use
                    color: onCardColor.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
              ),
              children: [
                _tableCell(
                  "${index + 1}",
                  cellStyle,
                  align: TextAlign.center,
                  padding: 8,
                ),
                _tableCell(
                  "${data['packageName'] ?? 'N/A'}\n$itemNames",
                  cellStyle.copyWith(height: 1.4),
                  padding: 8,
                ),
                _tableCell(
                  quantity.toString(),
                  cellStyle,
                  align: TextAlign.center,
                  padding: 8,
                ),
                _tableCell(
                  "₹${total.toStringAsFixed(2)}",
                  cellStyle,
                  align: TextAlign.right,
                  padding: 8,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tableCell(
    String text,
    TextStyle style, {
    TextAlign align = TextAlign.left,
    double padding = 6,
  }) {
    return Padding(
      padding: EdgeInsets.all(padding.w),
      child: Text(text, style: style, textAlign: align),
    );
  }

  Widget _buildPriceDetails(
    BuildContext context,
    Map<String, dynamic> data,
    Color onCardColor,
  ) {
    final num subTotal = data['subtotal'] ?? 0;
    final num discount = data['discountAmount'] ?? 0;
    final num sgst = data['sgst'] ?? 0;
    final num cgst = data['cgst'] ?? 0;
    final num platformCharges = data['platformFeeAmount'] ?? 0;
    final num grandTotal = data['total'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 5.h),
        _buildInfoRow(
          context,
          "Sub Total:",
          "₹${subTotal.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),
        if (discount > 0)
          _buildInfoRow(
            context,
            "Discount:",
            "- ₹${discount.toStringAsFixed(2)}",
            onCardColor: Colors.greenAccent,
          ),

        _buildInfoRow(
          context,
          "Platform charges",
          "₹${platformCharges.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),

        _buildInfoRow(
          context,
          "SGST:",
          "₹${sgst.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),
        _buildInfoRow(
          context,
          "CGST:",
          "₹${cgst.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),
        Divider(
          // ignore: deprecated_member_use
          color: onCardColor.withOpacity(0.4),
          thickness: 0.8,
          height: 20.h,
        ),
        _buildInfoRow(
          context,
          "Grand Total:",
          "₹${grandTotal.toStringAsFixed(2)}",
          onCardColor: onCardColor,
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w),

      child: Expanded(
        child: ElevatedButton.icon(
          onPressed: () async {
            AppAlert.info(context, "Generating invoice...");

            await cateringpdf().downloadInvoice(widget.orderId);
          },
          icon: Icon(Icons.download),
          label: Text(
            "Download PDF",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white, // Text & icon color
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 4, // Shadow
          ),
        ),
      ),
    );
  }
}
