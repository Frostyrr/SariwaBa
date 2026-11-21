import '../models/classification/classification_result.dart';
import 'csv_export_stub.dart' if (dart.library.html) 'csv_export_web.dart' as platform;

String _escapeCsv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

String buildAnalyticsCsv(List<ClassificationResult> history) {
  final buffer = StringBuffer();
  buffer.writeln('Timestamp,Region,Prediction,Confidence (%)');
  for (final item in history) {
    final ts = (item.createdAt ?? DateTime.now()).toIso8601String();
    final region = item.regionType ?? 'unknown';
    final label = item.label;
    final conf = (item.confidence * 100).toStringAsFixed(1);
    buffer.writeln(
      '${_escapeCsv(ts)},${_escapeCsv(region)},${_escapeCsv(label)},$conf',
    );
  }
  return buffer.toString();
}

Future<bool> exportAnalyticsCsv(List<ClassificationResult> history) {
  final csv = buildAnalyticsCsv(history);
  final dateTag = DateTime.now().toIso8601String().split('T').first;
  return platform.downloadCsvFile('sariwaba_analytics_$dateTag.csv', csv);
}
