import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// دالة الطباعة المخصصة لطابعات الـ USB عبر نظام Windows
  Future<bool> printReceiptUsb({
    required Widget receiptWidget,
  }) async {
    try {
      // 1. التقاط صورة للـ Widget بجودة عالية
      final Uint8List capturedImage = await _screenshotController.captureFromWidget(
        receiptWidget,
        pixelRatio: 2.0, // لضمان وضوح النصوص العربية
        delay: const Duration(milliseconds: 200),
      );

      // 2. إنشاء وثيقة PDF صامتة تحتوي على الصورة
      final pdf = pw.Document();
      final image = pw.MemoryImage(capturedImage);

      pdf.addPage(
        pw.Page(
          // مقاس ورق الكاشير 80mm
          pageFormat: PdfPageFormat.roll80, 
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );

      // 3. إرسال الـ PDF مباشرة إلى مدير طباعة الويندوز
      // ستظهر نافذة اختيار الطابعة (اختر Epson)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Ahgzly_Receipt',
      );

      return true;
    } catch (e) {
      debugPrint('USB Print Error: $e');
      return false;
    }
  }
}