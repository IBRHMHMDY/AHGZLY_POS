import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

class AppInitializer {
  /// دالة واحدة تستدعي جميع التهيئات المطلوبة قبل تشغيل التطبيق
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    _initDesktopDatabase();
    await _initDesktopWindow();
  }

  static void _initDesktopDatabase() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  static Future<void> _initDesktopWindow() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1024, 768),
        minimumSize: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: 'Ahgzly POS System',
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setFullScreen(true);
      });
    }
  }
}