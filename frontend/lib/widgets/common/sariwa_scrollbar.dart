import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Crash-safe, web-aware scrollbar wrapper.
///
/// - On mobile (`!kIsWeb`), renders the scrollable directly with no extra chrome.
/// - On web (`kIsWeb`), renders a themed [Scrollbar] bound to the exact same
///   [ScrollController] passed to [builder], while disabling the implicit
///   [ScrollBehavior] scrollbar inside [builder] to prevent duplicate scrollbars.
class SariwaScrollbar extends StatefulWidget {
  final ScrollController? controller;
  final bool alwaysVisible;
  final bool interactive;
  final Widget Function(BuildContext context, ScrollController controller)
      builder;

  const SariwaScrollbar({
    super.key,
    this.controller,
    this.alwaysVisible = true,
    this.interactive = true,
    required this.builder,
  });

  @override
  State<SariwaScrollbar> createState() => _SariwaScrollbarState();
}

class _SariwaScrollbarState extends State<SariwaScrollbar> {
  ScrollController? _internalController;

  ScrollController get _effectiveController {
    if (widget.controller != null) {
      return widget.controller!;
    }
    _internalController ??= ScrollController();
    return _internalController!;
  }

  @override
  void didUpdateWidget(covariant SariwaScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _internalController?.dispose();
      _internalController = null;
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;

    if (!kIsWeb || MediaQuery.sizeOf(context).width < 768) {
      return widget.builder(context, controller);
    }

    final child = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: widget.builder(context, controller),
    );

    return Scrollbar(
      controller: controller,
      thumbVisibility: widget.alwaysVisible,
      trackVisibility: false,
      interactive: widget.interactive,
      child: child,
    );
  }
}
