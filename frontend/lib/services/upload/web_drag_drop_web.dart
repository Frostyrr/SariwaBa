// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'web_drag_drop_service.dart';

WebDragDropService getWebDragDropService() => _WebDragDropServiceImpl();

class _WebDragDropServiceImpl implements WebDragDropService {
  StreamSubscription<html.MouseEvent>? _dragEnterSub;
  StreamSubscription<html.MouseEvent>? _dragOverSub;
  StreamSubscription<html.MouseEvent>? _dragLeaveSub;
  StreamSubscription<html.MouseEvent>? _dropSub;

  int _dragDepth = 0;

  @override
  void initialize({
    required void Function(bool isDragging) onDragStateChanged,
    required void Function(Uint8List bytes, String filename) onFileDropped,
  }) {
    _dragEnterSub = html.window.onDragEnter.listen((event) {
      event.preventDefault();
      _dragDepth++;
      if (_dragDepth == 1) {
        onDragStateChanged(true);
      }
    });

    _dragOverSub = html.window.onDragOver.listen((event) {
      event.preventDefault();
      try {
        final dt = (event as dynamic).dataTransfer;
        if (dt != null) {
          dt.dropEffect = 'copy';
        }
      } catch (_) {}
    });

    _dragLeaveSub = html.window.onDragLeave.listen((event) {
      event.preventDefault();
      _dragDepth--;
      if (_dragDepth <= 0) {
        _dragDepth = 0;
        onDragStateChanged(false);
      }
    });

    _dropSub = html.window.onDrop.listen((event) {
      event.preventDefault();
      _dragDepth = 0;
      onDragStateChanged(false);

      try {
        final dt = (event as dynamic).dataTransfer;
        final files = dt?.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();
          reader.onLoadEnd.listen((_) {
            final result = reader.result;
            if (result is Uint8List) {
              onFileDropped(result, file.name);
            } else if (result is List<int>) {
              onFileDropped(Uint8List.fromList(result), file.name);
            }
          });
          reader.readAsArrayBuffer(file);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _dragEnterSub?.cancel();
    _dragOverSub?.cancel();
    _dragLeaveSub?.cancel();
    _dropSub?.cancel();
  }
}
