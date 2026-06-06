// مسار الملف: lib/core/services/printers/printer_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

/// واجهة الخدمة لضمان قابلية الاختبار (Dependency Inversion Principle)
abstract class IPrinterService {
  Future<bool> printReceiptUsb({
    required Widget receiptWidget,
    required String printerName,
  });
}

class PrinterService implements IPrinterService {
  final ScreenshotController _screenshotController = ScreenshotController();
  final PrinterManager _printerManager = PrinterManager.instance;

  @override
  Future<bool> printReceiptUsb({
    required Widget receiptWidget,
    required String printerName,
  }) async {
    try {
      debugPrint('USB Print: Starting print process for [$printerName]...');

      // 1. استخراج الأوامر وتحويل الصورة (SRP)
      final List<int>? bytes = await _generatePrintBytes(receiptWidget);
      if (bytes == null || bytes.isEmpty) return false;

      // 2. البحث عن الطابعة
      final targetDevice = await _findUsbPrinter(printerName);

      // 3. [FIX] التحقق الصارم لمنع انهيار الـ Native Android (NullPointerException)
      // لا نرسل طلب اتصال إذا كانت معرفات الـ USB مفقودة
      if (targetDevice == null || targetDevice.productId == null || targetDevice.vendorId == null) {
        debugPrint('Print Error: Printer not found or missing Hardware IDs (vendorId/productId).');
        return false;
      }

      // 4. الاتصال والطباعة
      return await _connectAndPrint(targetDevice, bytes);

    } catch (e) {
      debugPrint('USB Print Exception (Main Flow): $e');
      return false;
    }
  }

  /// مسؤولية تحويل الـ Widget إلى مصفوفة بايتات ESC/POS
  Future<List<int>?> _generatePrintBytes(Widget receiptWidget) async {
    try {
      final Uint8List capturedImage = await _screenshotController.captureFromWidget(
        receiptWidget,
        pixelRatio: 2.0,
        delay: const Duration(milliseconds: 300),
      );

      final img.Image? decodedImage = img.decodeImage(capturedImage);
      if (decodedImage == null) return null;

      final img.Image resizedImage = img.copyResize(decodedImage, width: 576);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      
      List<int> bytes = [];
      bytes.addAll(generator.reset());
      bytes.addAll(generator.imageRaster(resizedImage, align: PosAlign.center));
      bytes.addAll(generator.drawer(pin: PosDrawer.pin2));
      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());
      
      return bytes;
    } catch (e) {
      debugPrint('Print Error: Failed to generate print bytes - $e');
      return null;
    }
  }

  /// مسؤولية اكتشاف الطابعة عبر منفذ USB بأمان
  Future<PrinterDevice?> _findUsbPrinter(String printerName) async {
    final completer = Completer<PrinterDevice?>();
    StreamSubscription? subscription;

    try {
      subscription = _printerManager.discovery(type: PrinterType.usb).listen((device) {
        if (device.name.trim().toLowerCase() == printerName.trim().toLowerCase()) {
          if (!completer.isCompleted) {
            completer.complete(device);
          }
        }
      });

      // مهلة زمنية للبحث لتجنب الـ Deadlock
      Future.delayed(const Duration(seconds: 3), () {
        if (!completer.isCompleted) completer.complete(null);
      });

      return await completer.future;
    } finally {
      // ضمان إغلاق الـ Stream دائماً
      await subscription?.cancel();
    }
  }

  /// مسؤولية الاتصال الفعلي بالطابعة وإرسال البيانات
  Future<bool> _connectAndPrint(PrinterDevice device, List<int> bytes) async {
    try {
      // محاولة الفصل المسبق للتأكد من عدم وجود جلسات معلقة
      try {
        await _printerManager.disconnect(type: PrinterType.usb);
      } catch (_) {}

      debugPrint('USB Print: Connecting to ${device.name}...');
      
      final isConnected = await _printerManager.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(
          name: device.name,
          productId: device.productId, // أصبحنا متأكدين أنها ليست Null بفضل التحقق السابق
          vendorId: device.vendorId,   // أصبحنا متأكدين أنها ليست Null بفضل التحقق السابق
        ),
      );

      if (isConnected != true) {
        debugPrint('Print Error: Failed to establish USB connection.');
        return false;
      }

      debugPrint('USB Print: Connected. Sending bytes...');
      final result = await _printerManager.send(type: PrinterType.usb, bytes: bytes);
      
      // تأخير بسيط لضمان اكتمال استلام الطابعة للبيانات قبل إغلاق الاتصال
      await Future.delayed(const Duration(milliseconds: 500));
      await _printerManager.disconnect(type: PrinterType.usb);
      
      return result;
    } catch (e) {
      debugPrint('Print Error during connection/sending: $e');
      return false;
    }
  }
}