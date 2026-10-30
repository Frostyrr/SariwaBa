import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Item configuration for the Floating Dock.
class DockItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isActive;
  final int? badgeCount;
  final Color? badgeColor;

  const DockItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isActive = false,
    this.badgeCount,
    this.badgeColor,
  });
}

/// Desktop macOS-Inspired Floating Dock with Parabolic Magnification
/// per Timber Dashboard Design System Specification (v2.0.0).
class FloatingDock extends StatefulWidget {
  final List<DockItemData> items;
  final VoidCallback onQuickScan;
  final VoidCallback onSync;
  final bool isSyncing;

  const FloatingDock({
    super.key,
    required this.items,
    required this.onQuickScan,
    required this.onSync,
    this.isSyncing = false,
  });

  @override
  State<FloatingDock> createState() => _FloatingDockState();
}

class _FloatingDockState extends State<FloatingDock> {
  double? _mouseY;
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mouseY = event.localPosition.dy;
        });
      },
      onExit: (_) {
        setState(() {
          _mouseY = null;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.92),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F0A2229),
                  blurRadius: 36,
                  offset: Offset(0, 14),
                ),
                BoxShadow(
                  color: Color(0x0A0A2229),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Prominent Quick Action Button (+)
                _buildQuickActionButton(),

                const SizedBox(height: 8),
                Container(
                  width: 28,
                  height: 1,
                  color: SariwaColors.colorLine,
                ),
                const SizedBox(height: 8),

                // Navigation Items with Parabolic Magnification
                ...List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: _buildMagnifiedItem(index, item),
                  );
                }),

                const SizedBox(height: 8),
                Container(
                  width: 28,
                  height: 1,
                  color: SariwaColors.colorLine,
                ),
                const SizedBox(height: 8),

                // Bottom Sync Status Pill
                _buildSyncButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton() {
    return Tooltip(
      message: 'Quick Fish Scan',
      preferBelow: false,
      verticalOffset: 0,
      margin: const EdgeInsets.only(left: 60),
      decoration: BoxDecoration(
        color: SariwaColors.colorInk,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onQuickScan,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SariwaColors.colorPrimary,
              boxShadow: [
                BoxShadow(
                  color: SariwaColors.colorPrimary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.add_a_photo_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncButton() {
    return Tooltip(
      message: widget.isSyncing ? 'Syncing...' : 'Sync PostgreSQL',
      preferBelow: false,
      verticalOffset: 0,
      margin: const EdgeInsets.only(left: 60),
      decoration: BoxDecoration(
        color: SariwaColors.colorInk,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onSync,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SariwaColors.colorSurface,
              border: Border.all(color: SariwaColors.colorLine),
            ),
            child: Center(
              child: widget.isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SariwaColors.colorPrimary,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: SariwaColors.colorPrimary,
                      size: 19,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMagnifiedItem(int index, DockItemData item) {
    _itemKeys.putIfAbsent(index, () => GlobalKey());

    // Calculate parabolic magnification scale
    double scale = 1.0;
    double nudge = 0.0;

    if (_mouseY != null) {
      // Estimated height per item ~46px plus header offset
      final approxItemCenterY = 60.0 + (index * 46.0) + 23.0;
      final dist = (_mouseY! - approxItemCenterY).abs();
      const maxDistance = 110.0;
      const maxScale = 1.28;

      if (dist < maxDistance) {
        final factor = math.cos((dist / maxDistance) * (math.pi / 2));
        scale = 1.0 + (maxScale - 1.0) * factor;
        final direction = approxItemCenterY < _mouseY! ? -1.0 : 1.0;
        nudge = direction * 3.5 * math.sin((dist / maxDistance) * math.pi);
      }
    }

    final isSelected = item.isActive;
    final bgColor = isSelected
        ? SariwaColors.colorPrimary
        : (item.isPrimary ? SariwaColors.colorPale : Colors.transparent);
    final iconColor = isSelected
        ? Colors.white
        : (item.isPrimary ? SariwaColors.colorPrimary : SariwaColors.colorMutedInk);

    return Tooltip(
      message: item.label,
      preferBelow: false,
      verticalOffset: 0,
      margin: const EdgeInsets.only(left: 60),
      decoration: BoxDecoration(
        color: SariwaColors.colorInk,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0A2229),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      textStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: item.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0.0, nudge, 0.0)
              ..scaleByDouble(scale, scale, 1.0, 1.0),
            transformAlignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  key: _itemKeys[index],
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgColor,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 1,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: SariwaColors.colorPrimary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      color: iconColor,
                      size: 19,
                    ),
                  ),
                ),

                // Item Badge Count
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1.5,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      decoration: BoxDecoration(
                        color: item.badgeColor ?? SariwaColors.statusModerate,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          item.badgeCount! > 9 ? '9+' : '${item.badgeCount}',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
