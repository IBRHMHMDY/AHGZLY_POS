import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Prints a receipt via USB. 
  /// [printerName] is now passed as a parameter to avoid tight coupling with the Service Locator (DI).
  Future<bool> printReceiptUsb({
    required Widget receiptWidget,
    required String printerName, // Refactored: Injected parameter instead of calling UseCase inside
  }) async {
    try {
      // 1. Capture image with sufficient delay to render text
      final Uint8List capturedImage = await _screenshotController.captureFromWidget(
        receiptWidget,
        pixelRatio: 2.0, 
        delay: const Duration(milliseconds: 300), 
      );

      final pdf = pw.Document();
      final image = pw.MemoryImage(capturedImage);

      // 2. Calculate dynamic receipt height based on standard 80mm width
      final double printWidth = PdfPageFormat.roll80.width;
      final double imgWidth = image.width!.toDouble();
      final double imgHeight = image.height!.toDouble();
      final double printHeight = (imgHeight / imgWidth) * printWidth;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(printWidth, printHeight, marginAll: 0),
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(image, fit: pw.BoxFit.fill),
            );
          },
        ),
      );

      // 3. Match the printer name provided by the presentation/domain layer
      final printers = await Printing.listPrinters();
      Printer? targetPrinter;
      for (var p in printers) {
        if (p.name.trim().toLowerCase() == printerName.trim().toLowerCase()) {
          targetPrinter = p;
          break;
        }
      }

      // 4. Execute print command
      if (targetPrinter != null) {
        await Printing.directPrintPdf(
          printer: targetPrinter,
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        // Fallback to standard dialog if printer is not found
        await Printing.layoutPdf(
          name: 'Receipt',
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      }
      return true;
    } catch (e) {
      debugPrint('USB Print Error: $e');
      return false;
    }
  }
}