import 'dart:typed_data';
import 'web_drag_drop_stub.dart'
    if (dart.library.html) 'web_drag_drop_web.dart';

abstract class WebDragDropService {
  static WebDragDropService create() => getWebDragDropService();

  void initialize({
    required void Function(bool isDragging) onDragStateChanged,
    required void Function(Uint8List bytes, String filename) onFileDropped,
  });

  void dispose();
}
