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

    final List items = List.from(data['items'] ?? []);

    pw.Widget keyValue(String key, String value, {bool bold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start, // 👈 important
          children: [
            pw.SizedBox(
              width: 90, // 👈 fixed width for label
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
              // 👈 allows wrapping
              child: pw.Text(
                value,
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
                    'MAAMAAS CATERING',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Text(
                'CATERING INVOICE',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
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
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // LEFT SIDE - ORDER DETAILS
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue(
                        'Order ID',
                        data['orderId']?.toString() ?? 'N/A',
                      ),
                      keyValue('Order Date', data['orderDate'] ?? 'N/A'),
                      keyValue(
                        'Payment Method',
                        data['paymentMethod'] ?? 'N/A',
                      ),
                      keyValue(
                        'Transaction ID',
                        data['transactionId'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 20),

                // RIGHT SIDE - EVENT DETAILS
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue('Event Type', data['eventType'] ?? 'N/A'),
                      keyValue('Event Date', data['eventDate'] ?? 'N/A'),
                      keyValue('Event Time', data['eventTime'] ?? 'N/A'),
                      keyValue('Guests', data['people']?.toString() ?? '0'),
                      keyValue('Location', data['location'] ?? 'N/A'),
                    ],
                  ),
                ),
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
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4,
            ),
            headers: ['#', 'Item', 'Qty', 'Price', 'Total'],
            data: List.generate(items.length, (index) {
              final item = items[index];
              return [
                (index + 1).toString(),
                item['name'] ?? 'N/A',
                item['quantity'].toString(),
                "₹${formatAmount(item['price'])}",
                "₹${formatAmount(item['totalPrice'])}",
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
                    'Billing Summary',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  keyValue('Sub Total', "₹${formatAmount(data['subtotal'])}"),
                  keyValue('SGST', "₹${formatAmount(data['sgst'])}"),
                  keyValue('CGST', "₹${formatAmount(data['cgst'])}"),
                  keyValue(
                    'Platform Fee',
                    "₹${formatAmount(data['platformFeeAmount'])}",
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
              'Thank you for choosing MAAMAAS Catering Services',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
