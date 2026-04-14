import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; 
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ahgzly_pos/core/database/app_database.dart'; // 🪄 استيراد قاعدة البيانات

class BackupService {
  final String dbFileName;
  final AppDatabase appDatabase; // 🪄 حقن قاعدة البيانات للتحكم بالاتصال

  BackupService({
    required this.appDatabase,
    this.dbFileName = 'pos_sys_drift.db',
  });

  /// Exports the database to an external file safely
  Future<bool> exportDatabase() async {
    try {
      // 🪄 [Refactored]: إجبار النظام على دمج ملفات WAL في الملف الرئيسي دون إغلاق الاتصال
      await appDatabase.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

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

  /// Imports the database from an external file securely
  Future<bool> importDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'استعادة النسخة الاحتياطية',
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) return false;

      final backupFile = File(result.files.single.path!);
      
      // 🪄 [Refactored]: إغلاق الاتصال النشط بقاعدة البيانات لمنع التلف (Corruption)
      await appDatabase.close();

      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, dbFileName);
      
      // 🪄 [Refactored]: تحديد مسارات الملفات المؤقتة
      final walPath = p.join(dbFolder.path, '$dbFileName-wal');
      final shmPath = p.join(dbFolder.path, '$dbFileName-shm');

      // 🪄 [Refactored]: حذف الملفات المؤقتة القديمة إن وجدت حتى لا تتداخل مع النسخة المسترجعة
      final walFile = File(walPath);
      final shmFile = File(shmPath);
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();

      // استبدال الملف الرئيسي
      await backupFile.copy(dbPath);
      debugPrint('Backup Success: Imported from ${result.files.single.path}');
      return true;
    } catch (e) {
      debugPrint('Backup Import Exception: $e'); 
      return false;
    }
  }
}