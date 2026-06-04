// مسار الملف: lib/core/services/printer_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class PrinterService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<bool> printReceiptUsb({
    required Widget receiptWidget,
    required String printerName, 
  }) async {
    try {
      debugPrint('USB Print: Searching for printer [$printerName]...');
      
      // 1. التقاط صورة للفاتورة
      final Uint8List capturedImage = await _screenshotController.captureFromWidget(
        receiptWidget,
        pixelRatio: 2.0, // دقة عالية لضمان وضوح النص
        delay: const Duration(milliseconds: 300), 
      );

      // 2. تحويل الصورة
      final img.Image? decodedImage = img.decodeImage(capturedImage);
      if (decodedImage == null) {
        debugPrint('Print Error: Failed to decode captured image.');
        return false;
      }

      // 🚀 [REFACTORED]: استخدام مكتبة Image لتغيير الحجم ليتناسب مع الطابعة 80mm
      final img.Image resizedImage = img.copyResize(decodedImage, width: 576);

      // 3. توليد أوامر ESC/POS باستخدام المكتبة القياسية بدلاً من التحويل اليدوي المعقد
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];
      
      // تهيئة الطابعة
      bytes.addAll(generator.reset());
      
      // طباعة الصورة
      bytes.addAll(generator.imageRaster(resizedImage, align: PosAlign.center));
      
      // فتح الدرج وقص الورقة
      bytes.addAll(generator.drawer(pin: PosDrawer.pin2));
      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      // 4. 🚀 [REFACTORED]: إصلاح منطق البحث عن الطابعة لمنع التعليق (Deadlock)
      PrinterDevice? targetDevice;
      final completer = Completer<PrinterDevice?>();
      
      final subscription = PrinterManager.instance.discovery(type: PrinterType.usb).listen((device) {
        if (device.name.trim().toLowerCase() == printerName.trim().toLowerCase()) {
          if (!completer.isCompleted) {
            completer.complete(device);
          }
        }
      });

      // ننتظر 3 ثواني كحد أقصى للبحث عن الطابعة
      Future.delayed(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      targetDevice = await completer.future;
      await subscription.cancel(); // التأكد من الإغلاق دائماً

      if (targetDevice == null) {
        debugPrint('Print Error: Printer [$printerName] not found on USB ports.');
        return false;
      }

      // 5. الاتصال بالطابعة وإرسال الأوامر المباشرة عبر الـ USB
      debugPrint('USB Print: Printer found! Connecting...');
      try {
        await PrinterManager.instance.disconnect(type: PrinterType.usb);
      } catch (_) {}
      
      await PrinterManager.instance.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(
          name: targetDevice.name,
          productId: targetDevice.productId,
          vendorId: targetDevice.vendorId,
        ),
      );

      debugPrint('USB Print: Connected. Sending bytes...');
      final result = await PrinterManager.instance.send(type: PrinterType.usb, bytes: bytes);
      
      await Future.delayed(const Duration(milliseconds: 500));
      await PrinterManager.instance.disconnect(type: PrinterType.usb);
      
      return result;

    } catch (e) {
      debugPrint('USB Print Exception: $e');
      return false;
    }
  }
}