import '../../Services/Auth_service/food_authservice.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';

class FoodPdf {
  // ---------------- Download invoice ----------------
  Future<void> downloadInvoice(int orderId) async {
    final data = await food_Authservice.fetchOrderById(orderId);
    if (data == null) return;

    final pdfBytes = await generateOrderPdf(data);

    // Use temporary directory
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/Invoice_$orderId.pdf');

    await file.writeAsBytes(pdfBytes);

    // Open PDF
    await OpenFile.open(file.path);
  }

  // ---------------- Generate PDF ----------------
  Future<Uint8List> generateOrderPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    final List items = List.from(data['order'] ?? []);

    final imageBytes = await rootBundle.load('assets/iconimage.png');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    // ✅ Safe text helper
    String safeText(dynamic value) {
      if (value == null) return 'N/A';
      return value.toString();
    }

    // ✅ Format currency
    String formatAmount(dynamic value) {
      if (value == null) return '0.00';
      return double.tryParse(value.toString())?.toStringAsFixed(2) ?? '0.00';
    }

    final isDelivery = data['orderType']?.toString() == "DELIVERY";
    final isTakeaway = data['orderType']?.toString() == "TAKEAWAY";

    // ---------------- Key-Value row helper ----------------
    pw.Widget keyValue(String key, String value, {bool bold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 90,
              child: pw.Text(
                key,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Spacer(),
            pw.Expanded(
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ---------------- Build PDF page ----------------
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ---------------- HEADER ----------------
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(width: 60, height: 60, child: pw.Image(image)),
                  pw.SizedBox(width: 10),
                ],
              ),
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Divider(),

          // ---------------- ORDER INFO ----------------
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue('Order ID', "#${safeText(data['orderId'])}"),
                      if (data['orderDateAndTime'] != null)
                        () {
                          final dt = DateTime.tryParse(
                            safeText(data['orderDateAndTime']),
                          );
                          if (dt != null) {
                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                keyValue(
                                  'Date',
                                  "${dt.day}-${dt.month}-${dt.year}",
                                ),
                                keyValue(
                                  'Time',
                                  "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}",
                                ),
                              ],
                            );
                          }
                          return pw.Container();
                        }(),
                      keyValue(
                        'Order Type',
                        safeText(data['orderType']).replaceAll('_', ' '),
                      ),
                      keyValue(
                        'Payment',
                        safeText(data['paymentMethod']).replaceAll('_', ' '),
                      ),
                      if (data['transactionId'] != null &&
                          data['transactionId'].toString().trim().isNotEmpty &&
                          data['paymentMethod'] != "Maamaas_Wallet")
                        keyValue(
                          'Transaction ID',
                          safeText(data['transactionId']),
                        ),
                      if ((data["sheduled"] ?? false) == true) ...[
                        pw.Text(
                          'Scheduled Details',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if ((data['date']?.toString().isNotEmpty ?? false))
                          keyValue('Scheduled Date', safeText(data['date'])),
                        if ((data['time']?.toString().isNotEmpty ?? false))
                          keyValue('Scheduled Time', safeText(data['time'])),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue(
                        'Restaurant Name',
                        safeText(
                          data['vendorRegisteredName'],
                        ).replaceAll('_', ' ').toUpperCase(),
                      ),
                      keyValue('FSSAI No', safeText(data['vendorFssai'])),
                      keyValue('GSTIN', safeText(data['vendorGstIn'])),
                      keyValue(
                        'Restaurant Address',
                        [
                              data['vendorFullAddress'],
                              data['vendorCity'],
                              data['vendorState'],
                            ]
                            .where((e) => e != null && e.toString().isNotEmpty)
                            .join(', '),
                      ),
                      if (isDelivery) ...[
                        keyValue(
                          'Customer Name',
                          safeText(data['deliveryUserName']).toUpperCase(),
                        ),
                        keyValue(
                          'Mobile Number',
                          data['mobileNo'] != null
                              ? "+91 ${data['mobileNo']}"
                              : "N/A",
                        ),
                        keyValue(
                          'Delivery Address',
                          safeText(
                            data['deliveryAddress'],
                          ).replaceAll('_', ' '),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // // ---------------- ITEMS TABLE ----------------
          // pw.Text(
          //   'Ordered Items',
          //   style: pw.TextStyle(
          //     font: ttf,
          //     fontSize: 14,
          //     fontWeight: pw.FontWeight.bold,
          //   ),
          // ),
          // pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Item', 'Qty', 'Price', 'Total'],
            headerStyle: pw.TextStyle(
              font: ttf,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: pw.TextStyle(font: ttf, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4,
            ),
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            data: List.generate(items.length, (i) {
              final item = items[i];
              return [
                (i + 1).toString(),
                safeText(item['dishName']),
                safeText(item['quantity']),
                "₹${formatAmount(item['price'])}",
                "₹${formatAmount(item['totalPrice'])}",
              ];
            }),
          ),

          pw.SizedBox(height: 20),

          // ---------------- BILLING SUMMARY ----------------
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 240,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Order Summary',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  keyValue('Sub Total', "₹${formatAmount(data['subTotal'])}"),
                  keyValue('SGST', "₹${formatAmount(data['sgst'])}"),
                  keyValue('CGST', "₹${formatAmount(data['cgst'])}"),
                  if ((data['platformCharges'] ?? 0) > 0)
                    keyValue(
                      'Platform Charges',
                      "₹${formatAmount(data['platformCharges'])}",
                    ),
                  if ((data['discountAmount'] ?? 0) > 0)
                    keyValue(
                      'Discount',
                      "- ₹${formatAmount(data['discountAmount'])}",
                    ),
                  if (isTakeaway || isDelivery)
                    keyValue(
                      'Packing Charges',
                      "₹${formatAmount(data['packingCharges'])}",
                    ),
                  if (isDelivery)
                    keyValue(
                      'Delivery Charges',
                      "₹${formatAmount(data['deliveryCharges'])}",
                    ),
                  pw.Divider(height: 12),
                  keyValue(
                    'Grand Total',
                    "₹${formatAmount(data['grandTotal'])}",
                    bold: true,
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 30),

          // ---------------- FOOTER ----------------
          pw.Center(
            child: pw.Text(
              'Thank you for ordering with MAAMAAS ',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
          pw.Center(
            child: pw.Text(
              'www.maamaas.com',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
