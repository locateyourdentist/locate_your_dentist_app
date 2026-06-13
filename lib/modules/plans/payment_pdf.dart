
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:open_filex/open_filex.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/model/company_invoice_model.dart';

Future<void> savePdf(Uint8List pdfBytes, String invoiceId) async {
  if (kIsWeb) {
    await Printing.sharePdf(bytes: pdfBytes, filename: 'invoice_$invoiceId.pdf');
  } else {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_$invoiceId.pdf');
    await file.writeAsBytes(pdfBytes);
    await OpenFilex.open(file.path);
  }
}
class PdfGenerator {
  static Future<void> generateInvoicePdf({
    required String userName,
    required String planName,
    required String planType,
    required String startDate,
    required String endDate,
    required TaxSummary taxSummary,
    required Company company,
    required String invoiceId,
  }) async {
    final pdf = pw.Document();

    // Load fonts (Roboto regular and bold)
    final regularFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final boldFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    // User location info
    String state = Api.userInfo.read('state') ?? "";
    String district = Api.userInfo.read('district') ?? "";
    String city = Api.userInfo.read('city') ?? "";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(font: boldFont, fontSize: 26, color: PdfColor.fromHex('#004958')),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue900, width: 2),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'Invoice #$invoiceId',
                  style: pw.TextStyle(font: boldFont, fontSize: 14),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Company & Customer
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(company.companyName, style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  pw.Text('GSTIN: ${company.gstin}', style: pw.TextStyle(font: regularFont)),
                  pw.Text(company.address, style: pw.TextStyle(font: regularFont)),
                  pw.Text('Email: ${company.email}', style: pw.TextStyle(font: regularFont)),
                  pw.Text('Phone: ${company.phone}', style: pw.TextStyle(font: regularFont)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Bill To:', style: pw.TextStyle(font: boldFont, fontSize: 14)),
                  pw.Text(userName, style: pw.TextStyle(font: regularFont)),
                  if (city.isNotEmpty) pw.Text(city, style: pw.TextStyle(font: regularFont)),
                  if (district.isNotEmpty) pw.Text(district, style: pw.TextStyle(font: regularFont)),
                  if (state.isNotEmpty) pw.Text(state, style: pw.TextStyle(font: regularFont)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Plan Details
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Plan Details', style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColor.fromHex('#004958'))),
                pw.SizedBox(height: 8),
                pw.Row(children: [
                  pw.Text('Plan Name:', style: pw.TextStyle(font: regularFont)),
                  pw.SizedBox(width: 8),
                  pw.Text(planName, style: pw.TextStyle(font: boldFont)),
                ]),
                pw.SizedBox(height: 4),
                pw.Row(children: [
                  pw.Text('Plan Type:', style: pw.TextStyle(font: regularFont)),
                  pw.SizedBox(width: 8),
                  pw.Text(planType, style: pw.TextStyle(font: boldFont)),
                ]),
                pw.SizedBox(height: 4),
                pw.Row(children: [
                  pw.Text('Start Date:', style: pw.TextStyle(font: regularFont)),
                  pw.SizedBox(width: 8),
                  pw.Text(startDate, style: pw.TextStyle(font: regularFont)),
                ]),
                pw.SizedBox(height: 4),
                pw.Row(children: [
                  pw.Text('End Date:', style: pw.TextStyle(font: regularFont)),
                  pw.SizedBox(width: 8),
                  pw.Text(endDate, style: pw.TextStyle(font: regularFont)),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Tax Table
          pw.Table.fromTextArray(
            headers: ['Description', 'Amount (₹)',],

            data: [
              ['Base Amount', taxSummary.baseAmount.toStringAsFixed(2)],
              if (taxSummary.cgst > 0) ['CGST (${taxSummary.cgstPercentage.toStringAsFixed(0)}%)', taxSummary.cgst.toStringAsFixed(2)],
              if (taxSummary.sgst > 0) ['SGST (${taxSummary.sgstPercentage.toStringAsFixed(0)}%)', taxSummary.sgst.toStringAsFixed(2)],
              if (taxSummary.igst > 0) ['IGST (${taxSummary.igstPercentage.toStringAsFixed(0)}%)', taxSummary.igst.toStringAsFixed(2)],
            ],
            headerStyle: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontFallback: [regularFont]),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#004958')),
            cellStyle: pw.TextStyle(font: regularFont),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(1)},
          ),

          pw.Divider(height: 1, color: PdfColors.grey600),
          pw.SizedBox(height: 8),

          // Total
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total Amount: ₹${taxSummary.totalAmount.toStringAsFixed(2)}',
              style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.red800, fontFallback: [regularFont]),
            ),
          ),
          pw.SizedBox(height: 32),

          pw.Center(
            child: pw.Text('Thank you for your business!', style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.green800)),
          ),
        ],
      ),
    );

    final pdfBytes = await pdf.save();
    await savePdf(pdfBytes, invoiceId);
  }
}