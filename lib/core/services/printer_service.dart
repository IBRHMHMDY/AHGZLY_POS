import 'dart:typed_data';
import 'package:ahgzly_pos/core/di/dependency_injection.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// دالة الطباعة المخصصة لطابعات الـ USB عبر نظام Windows
  // lib/core/services/printer_service.dart

  Future<bool> printReceiptUsb({
    required Widget receiptWidget,
  }) async {
    try {
      // 1. التقاط الصورة مع إعطاء وقت كافٍ لرسم النصوص (300ms) لتجنب الشاشات البيضاء
      final Uint8List capturedImage = await _screenshotController.captureFromWidget(
        receiptWidget,
        pixelRatio: 2.0, 
        delay: const Duration(milliseconds: 300), 
      );

      final pdf = pw.Document();
      final image = pw.MemoryImage(capturedImage);

      // 2. 🪄 الإصلاح الجوهري: حساب طول الفاتورة الفعلي لمنع الطابعة من تجاهل الأمر
      // عرض ورق 80mm يساوي تقريباً 226.77 نقطة (Points)
      final double printWidth = PdfPageFormat.roll80.width;
      final double imgWidth = image.width!.toDouble();
      final double imgHeight = image.height!.toDouble();
      
      // حساب الطول المتناسب مع العرض
      final double printHeight = (imgHeight / imgWidth) * printWidth;

      pdf.addPage(
        pw.Page(
          // إنشاء مقاس ورق دقيق يطابق طول الفاتورة بدلاً من الطول اللانهائي
          pageFormat: PdfPageFormat(printWidth, printHeight, marginAll: 0),
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(image, fit: pw.BoxFit.fill),
            );
          },
        ),
      );

      // 3. جلب اسم الطابعة
      final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
      String savedPrinterName = '';
      settingsResult.fold(
        (failure) => null,
        (settings) => savedPrinterName = settings.printerName,
      );

      // 4. مطابقة الطابعة
      final printers = await Printing.listPrinters();
      Printer? targetPrinter;
      for (var p in printers) {
        if (p.name.trim().toLowerCase() == savedPrinterName.trim().toLowerCase()) {
          targetPrinter = p;
          break;
        }
      }

      // 5. أمر الطباعة
      if (targetPrinter != null) {
        await Printing.directPrintPdf(
          printer: targetPrinter,
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        await Printing.layoutPdf(
          name: 'Z-Report',
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