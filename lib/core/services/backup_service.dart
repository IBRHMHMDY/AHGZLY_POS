import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // 🪄 ضروري لـ debugPrint
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupService {
  final String dbFileName;

  BackupService({this.dbFileName = 'pos_sys_drift.db'});

  /// Exports the database to an external file manually
  Future<bool> exportDatabase() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, dbFileName);
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        debugPrint('Backup Error: Database file not found at $dbPath');
        return false;
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ النسخة الاحتياطية',
        fileName: 'ahgzly_backup_${DateTime.now().millisecondsSinceEpoch}.db',
      );

      if (outputFile == null) return false; // المستخدم ألغى العملية

      await dbFile.copy(outputFile);
      debugPrint('Backup Success: Exported to $outputFile');
      return true;
    } catch (e) {
      debugPrint('Backup Export Exception: $e');
      return false;
    }
  }

  /// Automatically backups the database to a dedicated hidden/local folder
  Future<bool> autoBackupDatabase() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, dbFileName);
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        debugPrint('Auto Backup Error: Database not found.');
        return false;
      }

      // Create a dedicated backup directory
      final backupDir = Directory(p.join(dbFolder.path, 'AhgzlyAutoBackups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Format name: YYYY-MM-DD.db
      final dateStr = DateTime.now().toIso8601String().split('T').first;
      final autoBackupPath = p.join(backupDir.path, 'backup_$dateStr.db');
      
      await dbFile.copy(autoBackupPath);
      debugPrint('Auto Backup Success: Saved to $autoBackupPath');
      
      // Optional: Cleanup old backups (keep last 7 days)
      final files = backupDir.listSync();
      if (files.length > 7) {
        files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
        // Delete oldest
        for (int i = 0; i < files.length - 7; i++) {
          await files[i].delete();
        }
      }

      return true;
    } catch (e) {
      debugPrint('Auto Backup Exception: $e');
      return false;
    }
  }

  /// Imports the database from an external file
  Future<bool> importDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'استعادة النسخة الاحتياطية',
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) return false;

      final backupFile = File(result.files.single.path!);
      
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, dbFileName);

      await backupFile.copy(dbPath);
      debugPrint('Backup Success: Imported from ${result.files.single.path}');
      return true;
    } catch (e) {
      debugPrint('Backup Import Exception: $e'); // 🪄 تسجيل الخطأ لسهولة التتبع
      return false;
    }
  }
}