import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<bool> printReceiptUsb({
    required Widget receiptWidget,
    required String printerName, 
  }) async {
    try {
      // 1. البحث عن الطابعة بشكل آمن
      final printers = await Printing.listPrinters();
      final targetPrinter = printers.cast<Printer?>().firstWhere(
        (p) => p != null && p.name.trim().toLowerCase() == printerName.trim().toLowerCase(),
        orElse: () => null,
      );

      if (targetPrinter == null || !targetPrinter.isAvailable) {
        debugPrint('Print Error: Printer [$printerName] not found or offline.');
        return false;
      }

      // 2. التقاط صورة للفاتورة
      final Uint8List capturedImage = await _screenshotController.captureFromWidget(
        receiptWidget,
        pixelRatio: 2.0, 
        delay: const Duration(milliseconds: 300), 
      );

      // 3. بناء ملف الـ PDF بأبعاد الطابعة الحرارية
      final pdf = pw.Document();
      final image = pw.MemoryImage(capturedImage);
      final double printWidth = PdfPageFormat.roll80.width;
      final double printHeight = (image.height!.toDouble() / image.width!.toDouble()) * printWidth;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(printWidth, printHeight, marginAll: 0),
          build: (pw.Context context) => pw.FullPage(
            ignoreMargins: true, 
            child: pw.Image(image, fit: pw.BoxFit.contain), 
          ),
        ),
      );

      // 4. 🚀 [FIXED]: إرجاع حلك الذكي لتغليف FutureOr لتفعيل الـ timeout
      final bool printResult = await Future<bool>.value(
        Printing.directPrintPdf(
          printer: targetPrinter,
          onLayout: (PdfPageFormat format) async => pdf.save(),
        )
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Print Error: Spooler Timeout.');
          return false;
        },
      );

      return printResult;

    } catch (e) {
      debugPrint('USB Print Exception: $e');
      return false;
    }
  }
}