import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;

class PrinterService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// تقوم هذه الدالة بتحويل الـ Widget إلى صورة وإرسالها للطابعة
  Future<bool> printReceiptIP({
    required Widget receiptWidget,
    required String printerIp,
    int port = 9100, // البورت الافتراضي لطابعات الشبكة
  }) async {
    try {
      // 1. التقاط صورة للـ Widget في الخلفية (Off-screen)
      final Uint8List capturedImage = await _screenshotController.captureFromWidget(
        receiptWidget,
        delay: const Duration(milliseconds: 200),
      );

      // 2. تحويل الصورة وتجهيزها للطابعة الحرارية (أبيض وأسود)
      final img.Image? decodedImage = img.decodeImage(capturedImage);
      if (decodedImage == null) return false;

      // 3. تجهيز أوامر الطباعة (ESC/POS)
      final profile = await CapabilityProfile.load();
      // استخدمنا PaperSize.mm80 لأنه المقاس القياسي لفواتير المطاعم
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.image(decodedImage);
      bytes += generator.feed(2); // مسافة سطرين
      bytes += generator.cut();   // أمر قص الورقة

      // 4. إرسال الأوامر للطابعة عبر الشبكة
      final socket = await Socket.connect(printerIp, port, timeout: const Duration(seconds: 5));
      socket.add(bytes);
      await socket.flush();
      socket.destroy();

      return true;
    } catch (e) {
      debugPrint('Print Error: $e');
      return false;
    }
  }
}