import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupService {
  // Refactored: Inject database name to prevent hardcoding (DRY principle)
  final String dbFileName;

  BackupService({this.dbFileName = 'pos_sys_drift.db'});

  /// Exports the database to an external file
  Future<bool> exportDatabase() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, dbFileName);
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) return false;

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ النسخة الاحتياطية',
        fileName: 'ahgzly_backup_${DateTime.now().millisecondsSinceEpoch}.db',
      );

      if (outputFile == null) return false;

      await dbFile.copy(outputFile);
      return true;
    } catch (e) {
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
      return true;
    } catch (e) {
      return false;
    }
  }
}