import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BackupService {
  /// تصدير قاعدة البيانات لملف خارجي
  Future<bool> exportDatabase() async {
    try {
      final dbFolder = await getDatabasesPath();
      final dbPath = join(dbFolder, 'ahgzly_pos.db');
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) return false;

      // فتح نافذة اختيار مسار الحفظ
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ النسخة الاحتياطية',
        fileName: 'ahgzly_backup_${DateTime.now().millisecondsSinceEpoch}.db',
      );

      if (outputFile == null) return false; // المستخدم ألغى العملية

      await dbFile.copy(outputFile);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// استعادة قاعدة البيانات من ملف خارجي
  Future<bool> importDatabase() async {
    try {
      // فتح نافذة لاختيار ملف النسخة الاحتياطية
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'استعادة النسخة الاحتياطية',
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) return false;

      final backupFile = File(result.files.single.path!);
      
      final dbFolder = await getDatabasesPath();
      final dbPath = join(dbFolder, 'ahgzly_pos.db');
      final dbFile = File(dbPath);

      // استبدال الملف الحالي بملف النسخة الاحتياطية
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      await backupFile.copy(dbPath);
      return true;
    } catch (e) {
      return false;
    }
  }
}