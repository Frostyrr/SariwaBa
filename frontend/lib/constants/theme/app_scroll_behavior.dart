import 'dart:ui';
import 'package:material_ui/material_ui.dart';

/// App-wide scroll behavior enabling mouse/trackpad dragging on web
/// (useful for horizontal chip/tab strips) while keeping native touch physics.
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
}
