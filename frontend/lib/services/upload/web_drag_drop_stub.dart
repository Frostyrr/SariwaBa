import 'dart:typed_data';
import 'web_drag_drop_service.dart';

WebDragDropService getWebDragDropService() => _StubWebDragDropService();

class _StubWebDragDropService implements WebDragDropService {
  @override
  void initialize({
    required void Function(bool isDragging) onDragStateChanged,
    required void Function(Uint8List bytes, String filename) onFileDropped,
  }) {}

  @override
  void dispose() {}
}
