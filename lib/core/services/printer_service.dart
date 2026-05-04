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
      
      // 1. التقاط صورة للفاتورة بدقة عالية
      final Uint8List capturedImage = await _screenshotController.captureFromWidget(
        receiptWidget,
        pixelRatio: 2.0, 
        delay: const Duration(milliseconds: 300), 
      );

      // 2. تحويل الصورة إلى صيغة متوافقة مع مكتبة الطباعة
      final img.Image? decodedImage = img.decodeImage(capturedImage);
      if (decodedImage == null) {
        debugPrint('Print Error: Failed to decode captured image.');
        return false;
      }

      // 3. توليد أوامر ESC/POS المباشرة (Raw Bytes)
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];
      
      // تهيئة الطابعة
      bytes.addAll(generator.reset());
      
      // 🚀 [FIXED]: معالجة الصورة وطباعتها بنظام Raster (GS v 0) لضمان السرعة العالية وتطابق المقاس تماماً مع 80 مم (576 بكسل)
      final img.Image resizedImage = img.copyResize(decodedImage, width: 576);
      
      final int width = resizedImage.width;
      final int height = resizedImage.height;
      final int widthBytes = (width + 7) ~/ 8;
      
      bytes.addAll([29, 118, 48, 0]); // GS v 0
      bytes.add(widthBytes % 256);
      bytes.add(widthBytes ~/ 256);
      bytes.add(height % 256);
      bytes.add(height ~/ 256);
      
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < widthBytes; x++) {
          int byte = 0;
          for (int b = 0; b < 8; b++) {
            int px = x * 8 + b;
            if (px < width) {
              final pixel = resizedImage.getPixel(px, y);
              // تجاهل البكسلات الشفافة
              if (pixel.a > 0) {
                // حساب درجة النصوع لمعرفة اللون الأسود من الأبيض
                final luminance = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b);
                if (luminance < 128) {
                  byte |= (1 << (7 - b));
                }
              }
            }
          }
          bytes.add(byte);
        }
      }
      
      // فتح الدرج وقص الورقة
      bytes.addAll(generator.drawer(pin: PosDrawer.pin2));
      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      // 4. البحث عن الطابعة المطلوبة أولاً
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
      await subscription.cancel();

      if (targetDevice == null) {
        debugPrint('Print Error: Printer [$printerName] not found on USB ports.');
        return false;
      }

      // 5. الاتصال بالطابعة وإرسال الأوامر المباشرة عبر الـ USB
      debugPrint('USB Print: Printer found! Connecting...');
      try {
        await PrinterManager.instance.disconnect(type: PrinterType.usb); // التأكد من عدم وجود اتصال معلق
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
      
      await Future.delayed(const Duration(milliseconds: 500)); // انتظار بسيط لضمان اكتمال الإرسال
      await PrinterManager.instance.disconnect(type: PrinterType.usb);
      
      return result;

    } catch (e) {
      debugPrint('USB Print Exception: $e');
      return false;
    }
  }
}