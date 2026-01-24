import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/vehicle.dart';
import '../models/payment.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndShareInvoice(Vehicle vehicle) async {
    final pdf = pw.Document();
    final payment = vehicle.payment;
    
    if (payment == null) return;

    final date = payment.createdAt != null 
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(payment.createdAt!).toLocal())
        : DateFormat('MMM dd, yyyy').format(DateTime.now());

    final netAmount = payment.amount;
    final vehiclePrice = payment.vehiclePrice;
    final feePercentage = payment.feePercentage;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                      pw.SizedBox(height: 8),
                      pw.Text('GariBD Marketplace', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: $date'),
                      pw.Text('Transaction ID: ${payment.transactionId ?? "N/A"}'),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2, height: 40),
              
              // Vehicle Details
              pw.Text('Vehicle Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Title:')),
                  pw.Expanded(child: pw.Text(vehicle.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Brand:')),
                  pw.Expanded(child: pw.Text(vehicle.brand)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Type:')),
                  pw.Expanded(child: pw.Text(vehicle.type.toUpperCase())),
                ],
              ),
              
              pw.SizedBox(height: 40),
              
              // Payment Details Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Vehicle Listing Price')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('BDT ${vehiclePrice.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Platform Fee ($feePercentage%)')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('BDT ${netAmount.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Paid:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('BDT ${netAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text('Thank you for using GariBD Marketplace', style: const pw.TextStyle(color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_${payment.transactionId ?? payment.id}.pdf');
  }
}
