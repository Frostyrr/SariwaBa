import 'dart:convert';
import 'dart:io';

Future<bool> downloadCsvFile(String filename, String csvContent) async {
  try {
    final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
    Directory targetDir = Directory.systemTemp;
    if (home != null && home.isNotEmpty) {
      final downloads = Directory('$home${Platform.pathSeparator}Downloads');
      if (await downloads.exists()) {
        targetDir = downloads;
      }
    }
    final file = File('${targetDir.path}${Platform.pathSeparator}$filename');
    await file.writeAsBytes(utf8.encode('\uFEFF$csvContent'), flush: true);
    return true;
  } catch (_) {
    return false;
  }
}
