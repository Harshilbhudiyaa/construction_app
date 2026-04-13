import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:construction_app/data/models/inventory_transaction.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportExportService {
  static const _companyName = 'SMART CONSTRUCTION ERP';
  static const _companyTagline = 'Enterprise Site Intelligence & Inventory Management';

  // --- Excel Export Helpers ---

  static void _addExcelHeader(Sheet sheet, String reportTitle) {
    sheet.appendRow([TextCellValue(_companyName)]);
    sheet.appendRow([TextCellValue(reportTitle)]);
    sheet.appendRow([TextCellValue('Generated on: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}')]);
    sheet.appendRow([]); // Spacer
  }

  // --- PDF Export Helpers ---

  static pw.Widget _buildPdfHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(_companyName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.Text(_companyTagline, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  // --- Inward Log Exports ---

  static Future<void> exportInwardLogsToExcel(List<InwardMovementModel> logs, String fileName) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Inward Report'];
    _addExcelHeader(sheet, 'INWARD MOVEMENT DETAILED REPORT');

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Material'),
      TextCellValue('Transporter'),
      TextCellValue('Quantity'),
      TextCellValue('Rate/Unit'),
      TextCellValue('Total Amount'),
      TextCellValue('Status'),
    ]);

    for (var log in logs) {
      sheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd').format(log.createdAt)),
        TextCellValue(log.materialName),
        TextCellValue(log.transporterName),
        DoubleCellValue(log.quantity),
        DoubleCellValue(log.ratePerUnit),
        DoubleCellValue(log.totalAmount),
        TextCellValue(log.status.name.toUpperCase()),
      ]);
    }

    await _saveAndShareExcel(excel, fileName);
  }

  static Future<void> exportInwardLogsToPdf(List<InwardMovementModel> logs, String fileName) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildPdfHeader('INWARD MOVEMENT DETAILED REPORT'),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Material', 'Transporter', 'Qty', 'Rate', 'Total', 'Status'],
            data: logs.map((l) => [
              DateFormat('dd/MM/yy').format(l.createdAt),
              l.materialName,
              l.transporterName,
              l.quantity.toString(),
              l.ratePerUnit.toString(),
              l.totalAmount.toStringAsFixed(0),
              l.status.name.toUpperCase(),
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.center,
            },
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20),
            child: pw.Text('Authorized Personnel Signature: _______________________', style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );

    await _saveAndSharePdf(pdf, fileName);
  }

  // --- Stock Report Exports ---

  static Future<void> exportStockToExcel(List<ConstructionMaterial> materials, String fileName) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Stock Report'];
    _addExcelHeader(sheet, 'INVENTORY STOCK VALUATION REPORT');

    sheet.appendRow([
      TextCellValue('Material Name'),
      TextCellValue('Brand'),
      TextCellValue('Sub-type'),
      TextCellValue('Current Stock'),
      TextCellValue('Unit'),
      TextCellValue('Price/Unit'),
      TextCellValue('Total Value'),
    ]);

    for (var m in materials) {
      sheet.appendRow([
        TextCellValue(m.name),
        TextCellValue(m.brand ?? ''),
        TextCellValue(m.subType),
        DoubleCellValue(m.currentStock),
        TextCellValue(m.unitType),
        DoubleCellValue(m.pricePerUnit),
        DoubleCellValue(m.totalAmount),
      ]);
    }

    await _saveAndShareExcel(excel, fileName);
  }

  static Future<void> exportStockToPdf(List<ConstructionMaterial> materials, String fileName) async {
    final pdf = pw.Document();
    final totalValue = materials.fold<double>(0, (sum, m) => sum + m.totalAmount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildPdfHeader('INVENTORY STOCK VALUATION REPORT'),
          pw.TableHelper.fromTextArray(
            headers: ['Material', 'Sub-type', 'Stock', 'Unit', 'Value'],
            data: materials.map((m) => [
              m.name,
              m.subType,
              m.currentStock.toString(),
              m.unitType,
              m.totalAmount.toStringAsFixed(0),
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('TOTAL INVENTORY VALUE: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Rs. ${NumberFormat('#,##,###').format(totalValue)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            ],
          ),
        ],
      ),
    );

    await _saveAndSharePdf(pdf, fileName);
  }

  // --- Generic Persistence ---

  static Future<void> _saveAndShareExcel(Excel excel, String fileName) async {
    final List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.xlsx')
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Excel Report: $fileName');
    }
  }

  static Future<void> _saveAndSharePdf(pw.Document pdf, String fileName) async {
    final List<int> fileBytes = await pdf.save();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.pdf')
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);
    await Share.shareXFiles([XFile(file.path)], text: 'PDF Report: $fileName');
  }

  // --- Transaction Logic (Generic) ---

  static Future<void> exportTransactionsToExcel(List<InventoryTransaction> transactions, String fileName, {String title = 'INVENTORY TRANSACTION REPORT'}) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Transactions'];
    _addExcelHeader(sheet, title);

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Material'),
      TextCellValue('Quantity'),
      TextCellValue('Unit'),
      TextCellValue('Type'),
      TextCellValue('Remarks'),
    ]);

    for (var t in transactions) {
      sheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(t.timestamp)),
        TextCellValue(t.materialName),
        DoubleCellValue(t.quantity),
        TextCellValue(t.unit),
        TextCellValue(t.type.toString().split('.').last.toUpperCase()),
        TextCellValue(t.remarks ?? ''),
      ]);
    }

    await _saveAndShareExcel(excel, fileName);
  }

  static Future<void> exportTransactionsToPdf(List<InventoryTransaction> transactions, String fileName, {String title = 'INVENTORY TRANSACTION REPORT'}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildPdfHeader(title),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Material', 'Qty', 'Unit', 'Type'],
            data: transactions.map((t) => [
              DateFormat('dd/MM HH:mm').format(t.timestamp),
              t.materialName,
              t.quantity.toString(),
              t.unit,
              t.type.toString().split('.').last.toUpperCase(),
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
          ),
        ],
      ),
    );

    await _saveAndSharePdf(pdf, fileName);
  }

  // Backward compatibility alias
  static Future<void> exportStockValueToExcel(List<ConstructionMaterial> materials, String fileName) => exportStockToExcel(materials, fileName);
}
