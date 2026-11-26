// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';

import 'web_drag_drop_service.dart';

WebDragDropService getWebDragDropService() => _WebDragDropServiceImpl();

class _WebDragDropServiceImpl implements WebDragDropService {
  static const int _maxDirectDimension = 2048;
  static const int _maxDirectBytes = 4 * 1024 * 1024;

  StreamSubscription<html.MouseEvent>? _dragEnterSub;
  StreamSubscription<html.MouseEvent>? _dragOverSub;
  StreamSubscription<html.MouseEvent>? _dragLeaveSub;
  StreamSubscription<html.MouseEvent>? _dropSub;

  int _dragDepth = 0;

  Future<void> _normalizeAndEmitDroppedBytes(
    Uint8List rawBytes,
    String filename,
    void Function(Uint8List bytes, String filename) onFileDropped,
  ) async {
    final lower = filename.toLowerCase();
    // Pass HEIC/HEIF or non-raster files straight to controller validation
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) {
      onFileDropped(rawBytes, filename);
      return;
    }

    String? objectUrl;
    try {
      final blob = html.Blob([rawBytes]);
      objectUrl = html.Url.createObjectUrlFromBlob(blob);
      final img = html.ImageElement();
      final completer = Completer<bool>();
      img.onLoad.first.then((_) {
        if (!completer.isCompleted) completer.complete(true);
      });
      img.onError.first.then((_) {
        if (!completer.isCompleted) completer.complete(false);
      });
      img.src = objectUrl;

      final loaded = await completer.future.timeout(
        const Duration(seconds: 4),
        onTimeout: () => false,
      );
      if (!loaded || img.naturalWidth <= 0 || img.naturalHeight <= 0) {
        onFileDropped(rawBytes, filename);
        return;
      }

      final w = img.naturalWidth;
      final h = img.naturalHeight;
      if (w <= _maxDirectDimension &&
          h <= _maxDirectDimension &&
          rawBytes.lengthInBytes <= _maxDirectBytes) {
        onFileDropped(rawBytes, filename);
        return;
      }

      final scale = math.min(
        1.0,
        _maxDirectDimension / math.max(w, h).toDouble(),
      );
      final targetW = math.max(1, (w * scale).round());
      final targetH = math.max(1, (h * scale).round());

      final canvas = html.CanvasElement(width: targetW, height: targetH);
      final ctx = canvas.context2D;
      ctx.imageSmoothingEnabled = true;
      ctx.imageSmoothingQuality = 'high';
      ctx.drawImageScaled(img, 0, 0, targetW, targetH);

      final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);
      final commaIndex = dataUrl.indexOf(',');
      if (commaIndex <= 0) {
        onFileDropped(rawBytes, filename);
        return;
      }
      final normalizedBytes = base64Decode(dataUrl.substring(commaIndex + 1));
      final dotIndex = filename.lastIndexOf('.');
      final baseName = dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
      onFileDropped(normalizedBytes, '$baseName.jpg');
    } catch (_) {
      onFileDropped(rawBytes, filename);
    } finally {
      if (objectUrl != null) {
        try {
          html.Url.revokeObjectUrl(objectUrl);
        } catch (_) {}
      }
    }
  }

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
              _normalizeAndEmitDroppedBytes(result, file.name, onFileDropped);
            } else if (result is List<int>) {
              _normalizeAndEmitDroppedBytes(
                Uint8List.fromList(result),
                file.name,
                onFileDropped,
              );
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
