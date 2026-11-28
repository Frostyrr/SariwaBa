import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// App-wide scroll behavior:
/// - Enables mouse/trackpad dragging on web while keeping native touch physics.
/// - Hides scrollbars on mobile viewports (`< 768px`) and touch platforms (`iOS`/`Android`).
/// - Uses the global light-grey `ScrollbarThemeData` on desktop (`>= 768px`).
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final platform = getPlatform(context);
    final isTouchPlatform = !kIsWeb &&
        (platform == TargetPlatform.android || platform == TargetPlatform.iOS);

    if (width < 768 || isTouchPlatform) {
      return child;
    }

    return Scrollbar(
      controller: details.controller,
      child: child,
    );
  }
}
