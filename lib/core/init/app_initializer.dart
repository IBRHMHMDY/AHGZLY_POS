import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initDesktopWindow();
  }

  static Future<void> _initDesktopWindow() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1024, 768),
        minimumSize: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        titleBarStyle: TitleBarStyle.hidden, 
        title: 'Ahgzly POS System',
      );
      
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        // await windowManager.setAsFrameless(); 
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setFullScreen(true); 
      });
    }
  }
}