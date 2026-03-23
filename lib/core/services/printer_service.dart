import 'dart:typed_data';
import 'package:ahgzly_pos/core/di/injection_container.dart';
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
      final settingsResult = await sl<GetSettingsUseCase>().call(NoParams());
      String savedPrinterName = '';
      settingsResult.fold(
        (failure) => null,
        (settings) => savedPrinterName = settings.printerName,
      );

      // 2. جلب قائمة الطابعات المتصلة بالويندوز
      final printers = await Printing.listPrinters();
      Printer? targetPrinter;

      // 3. البحث عن الطابعة المطلوبة بالاسم
      for (var p in printers) {
        if (p.name.trim().toLowerCase() == savedPrinterName.trim().toLowerCase()) {
          targetPrinter = p;
          break;
        }
      }

      // 4. تنفيذ الطباعة
      if (targetPrinter != null) {
        // طباعة صامتة (مباشرة) في الخلفية بدون نوافذ
        await Printing.directPrintPdf(
          printer: targetPrinter,
          onLayout: (PdfPageFormat format) async => pdf.save(), // تأكد أن اسم المتغير pdf مطابق لما لديك (أو doc)
        );
      } else {
        // في حال كان اسم الطابعة في الإعدادات خاطئاً، نفتح النافذة كحل بديل للطوارئ
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