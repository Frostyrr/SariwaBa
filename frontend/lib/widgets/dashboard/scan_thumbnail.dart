import 'dart:convert';
import 'dart:typed_data';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/config/app_config.dart';
import '../../models/classification/classification_result.dart';

/// Displays a real scan thumbnail from local base64 cache or remote [imageUrl],
/// falling back to a quiet monochrome placeholder icon only when no image exists.
class ScanThumbnail extends StatelessWidget {
  final ClassificationResult scan;
  final double size;
  final double borderRadius;
  final double iconSize;

  const ScanThumbnail({
    super.key,
    required this.scan,
    this.size = 44,
    this.borderRadius = 8,
    this.iconSize = 18,
  });

  static Uint8List? _tryDecodeBase64(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  static String? _resolveUrl(String? rawUrl) {
    final trimmed = rawUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '${AppConfig.apiBaseUrl}${trimmed.startsWith('/') ? '' : '/'}$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final memoryBytes = _tryDecodeBase64(scan.thumbnailBase64);
    final resolvedUrl = _resolveUrl(scan.imageUrl);

    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      alignment: Alignment.center,
      child: Icon(
        CupertinoIcons.photo,
        size: iconSize,
        color: const Color(0xFF737373),
      ),
    );

    if (memoryBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox.square(
          dimension: size,
          child: Image.memory(
            memoryBytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) => placeholder,
          ),
        ),
      );
    }

    if (resolvedUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox.square(
          dimension: size,
          child: Image.network(
            resolvedUrl,
            fit: BoxFit.cover,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (context, error, stackTrace) => placeholder,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : placeholder,
          ),
        ),
      );
    }

    return placeholder;
  }
}
