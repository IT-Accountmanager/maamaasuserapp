import '../../Services/Auth_service/catering_authservice.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';

class cateringpdf {
  Future<void> downloadInvoice(int id) async {
    final data = await catering_authservice().fetchOrderById(id);
    if (data == null) return;

    final pdfBytes = await generateCateringInvoice(data);
    await downloadPdf(pdfBytes, "Invoice_${id}.pdf");
  }

  Future<void> downloadPdf(Uint8List pdfBytes, String fileName) async {
    try {
      // Get external storage directory (Downloads folder on Android)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // optional: to save directly in Downloads folder
        String newPath = "";
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/$folder";
          } else {
            break;
          }
        }
        newPath = "$newPath/Download";
        directory = Directory(newPath);
      } else {
        // iOS documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = "${directory.path}/$fileName";
      final file = File(filePath);

      // Write PDF bytes to file
      await file.writeAsBytes(pdfBytes);

      // Open the PDF file
      await OpenFile.open(filePath);

      // print("PDF saved at: $filePath");
    } catch (e) {
      // print("Error saving PDF: $e");
    }
  }

  String _formatDate(dynamic raw) {
    try {
      final parsed = DateTime.parse(raw.toString());

      final dt = DateTime.utc(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
      ).toLocal();

      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "N/A";
    }
  }

  String _formatTime(dynamic raw) {
    try {
      final parsed = DateTime.parse(raw.toString());

      final dt = DateTime.utc(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
      ).toLocal();

      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';

      return "${hour.toString().padLeft(2, '0')}:$min $period";
    } catch (e) {
      return "N/A";
    }
  }

  Future<Uint8List> generateCateringInvoice(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final imageBytes = await rootBundle.load('assets/MAAMAAS.jpeg');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());

    String formatAmount(dynamic value) {
      if (value == null) return '0.00';
      return double.tryParse(value.toString())?.toStringAsFixed(2) ?? '0.00';
    }

    List items = [];

    if (data['orderItems'] is List) {
      items = List.from(data['orderItems']);
    } else if (data['data'] != null && data['data']['orderItems'] is List) {
      items = List.from(data['data']['orderItems']);
    }

    print("FINAL ITEMS: $items");

    print("FULL DATA: $data");
    print("ORDER ITEMS: ${data['orderItems']}");

    pw.Widget keyValue(String key, dynamic value, {bool bold = false}) {
      if (value == null) return pw.SizedBox();

      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == "null") {
        return pw.SizedBox();
      }
      final List items = List.from(data['items'] ?? []);

      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 100,
              child: pw.Text(
                key,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: pw.Text(
                text,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ================= HEADER =================
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(width: 60, height: 60, child: pw.Image(image)),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'MAAMAAS',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Divider(),

          // ================= ORDER + EVENT INFO =================
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ───── ORDER INFO ─────
                if (data['orderId'] != null)
                  keyValue('Order ID', data['orderId']),

                if (data['orderDateTime'] != null) ...[
                  keyValue("Order Date", _formatDate(data['orderDateTime'])),

                  keyValue("Order Time", _formatTime(data['orderDateTime'])),
                ],

                if (data['paymentMethod'] != null)
                  keyValue('Payment Method', data['paymentMethod']),

                if (data['transactionId'] != null)
                  keyValue('Transaction ID', data['transactionId']),

                pw.SizedBox(height: 8),

                // ───── VENDOR INFO ─────
                if (data['vendorRegisteredName'] != null)
                  keyValue('Vendor Name', data['vendorRegisteredName']),

                if (data['vendorFssai'] != null)
                  keyValue('Vendor FSSAI', data['vendorFssai']),

                if (data['vendorFullAddress'] != null)
                  keyValue('Vendor Address', data['vendorFullAddress']),

                if (data['vendorGstIn'] != null)
                  keyValue('Vendor GSTIN', data['vendorGstIn']),

                pw.SizedBox(height: 8),

                // ───── CATERING INFO ─────
                if (data['cateringDate'] != null)
                  keyValue('Catering Date', data['cateringDate']),

                if (data['cateringTime'] != null)
                  keyValue('Catering Time', data['cateringTime']),

                if (data['deliveryUserName'] != null)
                  keyValue('Customer Name', data['deliveryUserName']),

                if (data['mobileNo'] != null)
                  keyValue('Phone', "+91${data['mobileNo']}"),

                if (data['deliveryAddress'] != null)
                  keyValue('Location', data['deliveryAddress']),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ================= ITEMS TABLE =================
          pw.Text(
            'Catering Items',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),

          pw.TableHelper.fromTextArray(
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: pw.TextStyle(fontSize: 9),

            headers: ['#', 'Package', 'Items', 'Qty', 'Price', 'Total'],

            data: items.isEmpty
                ? [
                    ['-', 'No items found', '-', '-', '-', '-'],
                  ]
                : List.generate(items.length, (index) {
                    final item = items[index];

                    final packageName =
                        item['packageName']?.toString() ?? 'N/A';
                    final qty = item['quantity'] ?? 0;

                    // ✅ Handle price safely
                    final price =
                        double.tryParse(
                          item['packagePrice']?.toString() ?? '',
                        ) ??
                        0;

                    final total = qty * price;

                    // ✅ Handle BOTH structures
                    String itemNames = '';

                    if (item['packageItems'] is List &&
                        item['packageItems'].isNotEmpty) {
                      itemNames = (item['packageItems'] as List)
                          .map((e) => e['itemName'] ?? '')
                          .join(', ');
                    } else if (item['itemsName'] != null) {
                      itemNames = item['itemsName'];
                    }

                    return [
                      (index + 1).toString(),
                      packageName,
                      itemNames.isEmpty ? 'N/A' : itemNames,
                      qty.toString(),
                      "₹${price.toStringAsFixed(2)}",
                      "₹${total.toStringAsFixed(2)}",
                    ];
                  }),
          ),

          pw.SizedBox(height: 20),

          // ================= BILL SUMMARY =================
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
                  keyValue('Sub Total', "₹${formatAmount(data['subtotal'])}"),
                  keyValue('SGST', "₹${formatAmount(data['sgst'])}"),
                  keyValue('CGST', "₹${formatAmount(data['cgst'])}"),

                  if ((data['platformFeeAmount'] ?? 0) > 0)
                    keyValue(
                      'Platform Fee',
                      "₹${formatAmount(data['platformFeeAmount'])}",
                    ),

                  if ((data['discountAmount'] ?? 0) > 0)
                    keyValue(
                      'Discount',
                      "- ₹${formatAmount(data['discountAmount'])}",
                    ),

                  keyValue(
                    'Delivery Charges',
                    "₹${formatAmount(data['deliveryFee'])}",
                  ),

                  pw.Divider(height: 12),

                  keyValue(
                    'Grand Total',
                    "₹${formatAmount(data['total'])}",
                    bold: true,
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 30),

          // ================= FOOTER =================
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
