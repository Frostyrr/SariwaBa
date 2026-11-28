import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';
import '../../services/classification/classification_service.dart';
import '../../constants/config/app_breakpoints.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../constants/theme/timber_typography.dart';
import '../classification/eye_zoom_modal.dart';
import '../classification/responsive_image_upload_zone.dart';
import '../common/app_button.dart';
import '../common/staggered_reveal.dart';
import 'frosted_glass_card.dart';

/// Workstation scanner card providing image upload, interactive ROI cropping preview, classifying state, and result inspection.
class ScannerWorkstationCard extends StatefulWidget {
  final ClassificationState state;
  final ClassificationController controller;
  final bool isCropModalOpen;
  final VoidCallback onOpenCropModal;
  final Future<bool> Function(ImageSource source)? onRequestPermission;

  const ScannerWorkstationCard({
    super.key,
    required this.state,
    required this.controller,
    required this.isCropModalOpen,
    required this.onOpenCropModal,
    this.onRequestPermission,
  });

  @override
  State<ScannerWorkstationCard> createState() => _ScannerWorkstationCardState();
}

class _ScannerWorkstationCardState extends State<ScannerWorkstationCard> {
  ui.Image? _decodedImage;
  Uint8List? _decodedBytes;
  int? _hoveredEyeTileIndex;
  int? _hoveredEyeMarkerIndex;

  void _openEyeZoomModal(
    ClassificationState state,
    ClassificationController controller,
    int initialIndex,
  ) {
    if (state.eyeProposals.isEmpty) return;
    EyeZoomModal.show(
      context,
      images: [for (final p in state.eyeProposals) p.bytes],
      initialIndex: initialIndex,
      onIndexChanged: controller.selectEyeProposal,
    );
  }

  @override
  void initState() {
    super.initState();
    _syncDecodedImage();
  }

  @override
  void didUpdateWidget(covariant ScannerWorkstationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.state.selectedImageBytes, _decodedBytes)) {
      _syncDecodedImage();
    }
  }

  @override
  void dispose() {
    _decodedImage?.dispose();
    super.dispose();
  }

  Future<void> _syncDecodedImage() async {
    final bytes = widget.state.selectedImageBytes;
    _decodedBytes = bytes;
    if (bytes == null) {
      _decodedImage?.dispose();
      _decodedImage = null;
      return;
    }
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted || !identical(widget.state.selectedImageBytes, bytes)) {
        frame.image.dispose();
        return;
      }
      _decodedImage?.dispose();
      setState(() => _decodedImage = frame.image);
    } catch (_) {
      // Fallback: image still renders via Image.memory
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = widget.controller;
    final isMobileScreen =
        AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return FrostedGlassCard(
      padding: EdgeInsets.all(isMobileScreen ? 12 : 24),
      borderRadius: isMobileScreen ? 24 : 16,
      blurSigma: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobileScreen) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.viewfinder,
                    size: 18,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Freshness Scanner',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.16,
                          color: Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Eye, gill, or whole fish photo.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                          color: Color(0xFF737373),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: state.isUploadingImage
                ? KeyedSubtree(
                    key: const ValueKey('scanner_uploading'),
                    child: _buildImageUploadingCard(),
                  )
                : state.selectedImageBytes == null
                ? KeyedSubtree(
                    key: const ValueKey('scanner_dropzone'),
                    child: ResponsiveImageUploadZone(
                      state: state,
                      controller: controller,
                      showMobileCameraButton: !isMobileScreen,
                      onRequestPermission: widget.onRequestPermission,
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('scanner_workspace'),
                    child: _buildInlineImageWorkspace(
                      state,
                      controller,
                      isMobileScreen: isMobileScreen,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineImageWorkspace(
    ClassificationState state,
    ClassificationController controller, {
    required bool isMobileScreen,
  }) {
    final bytes = state.selectedImageBytes!;
    final canUseEyeFinder = state.selectedRegion != AnatomicalRegion.gill;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isMobileScreen) ...[
          // Desktop action row above image canvas
          Row(
            children: [
              const Icon(
                CupertinoIcons.photo,
                size: 14,
                color: SariwaColors.textSecondaryDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.selectedImageName ?? 'Tilapia specimen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildToolbarIconButton(
                key: const Key('scanner_adjust_crop_button'),
                tooltip: 'Adjust crop',
                icon: CupertinoIcons.crop,
                onTap: state.isClassifying
                    ? null
                    : () {
                        controller.editCrop();
                        widget.onOpenCropModal();
                      },
              ),
              const SizedBox(width: 8),
              _buildToolbarIconButton(
                tooltip: 'Remove photo',
                icon: CupertinoIcons.xmark,
                iconColor: SariwaColors.textSecondaryDark,
                onTap: state.isClassifying ? null : controller.clearSelection,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        // Full-frame BoxFit.contain viewport (clamped 3:4..4:3 with soft #F4F4F5 surface on mobile)
        Builder(
          builder: (context) {
            double clampedMobileAspect = 4 / 3;
            if (isMobileScreen) {
              double? rawAspect;
              if (_decodedImage != null &&
                  _decodedImage!.width > 0 &&
                  _decodedImage!.height > 0) {
                rawAspect = _decodedImage!.width / _decodedImage!.height;
              } else if (state.sourceImageSize != null &&
                  state.sourceImageSize!.width > 0 &&
                  state.sourceImageSize!.height > 0) {
                rawAspect =
                    state.sourceImageSize!.width / state.sourceImageSize!.height;
              }
              if (rawAspect != null) {
                clampedMobileAspect = rawAspect.clamp(3 / 4, 4 / 3);
              }
            }

            final viewportContent = Container(
              height: isMobileScreen ? null : 320,
              width: double.infinity,
              color: isMobileScreen
                  ? const Color(0xFFF4F4F5)
                  : const Color(0xFF0A1926),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final containerSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  final displayedRect = _computeContainedImageRect(
                    containerSize,
                    _decodedImage,
                    state.sourceImageSize,
                  );

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                        width: containerSize.width,
                        height: containerSize.height,
                      ),
                      if (state.eyeProposals.isNotEmpty)
                        for (int i = 0; i < state.eyeProposals.length; i++)
                          _buildProposalMarker(
                            index: i,
                            proposal: state.eyeProposals[i],
                            displayedRect: displayedRect,
                            isSelected: state.selectedEyeProposalIndex == i,
                            isHovered: _hoveredEyeMarkerIndex == i,
                            onHoverChanged: (hovered) {
                              setState(
                                () => _hoveredEyeMarkerIndex = hovered ? i : null,
                              );
                            },
                            onTap: () {
                              HapticFeedback.selectionClick();
                              if (state.selectedEyeProposalIndex == i) {
                                _openEyeZoomModal(state, controller, i);
                              } else {
                                controller.selectEyeProposal(i);
                              }
                            },
                          ),
                      if (isMobileScreen)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildOverlayPillButton(
                                key: const Key('scanner_adjust_crop_button'),
                                tooltip: 'Adjust crop',
                                icon: CupertinoIcons.crop,
                                onTap: state.isClassifying
                                    ? null
                                    : () {
                                        controller.editCrop();
                                        widget.onOpenCropModal();
                                      },
                              ),
                              const SizedBox(width: 8),
                              _buildOverlayPillButton(
                                tooltip: 'Remove photo',
                                icon: CupertinoIcons.xmark,
                                onTap: state.isClassifying
                                    ? null
                                    : controller.clearSelection,
                              ),
                            ],
                          ),
                        ),
                      if (state.eyeProposals.length > 1) ...[
                        // Previous Eye Arrow (<)
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _buildCarouselArrowButton(
                              icon: CupertinoIcons.chevron_left,
                              tooltip: 'Previous eye',
                              onTap: () {
                                final current =
                                    state.selectedEyeProposalIndex ?? 0;
                                final prev =
                                    (current - 1 + state.eyeProposals.length) %
                                    state.eyeProposals.length;
                                HapticFeedback.selectionClick();
                                controller.selectEyeProposal(prev);
                              },
                            ),
                          ),
                        ),
                        // Next Eye Arrow (>)
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _buildCarouselArrowButton(
                              icon: CupertinoIcons.chevron_right,
                              tooltip: 'Next eye',
                              onTap: () {
                                final current =
                                    state.selectedEyeProposalIndex ?? -1;
                                final next =
                                    (current + 1) % state.eyeProposals.length;
                                HapticFeedback.selectionClick();
                                controller.selectEyeProposal(next);
                              },
                            ),
                          ),
                        ),
                        // Counter pill (e.g., "1 / 4")
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xCC0A1926),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              state.selectedEyeProposalIndex != null
                                  ? '${state.selectedEyeProposalIndex! + 1} / ${state.eyeProposals.length}'
                                  : '${state.eyeProposals.length} eyes',
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            );

            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: isMobileScreen
                  ? LayoutBuilder(
                      builder: (context, boxConstraints) {
                        final maxMobileHeight =
                            (MediaQuery.sizeOf(context).height * 0.34)
                                .clamp(210.0, 280.0);
                        final idealHeight =
                            boxConstraints.maxWidth / clampedMobileAspect;
                        final clampedHeight = idealHeight.clamp(
                          160.0,
                          maxMobileHeight,
                        );
                        return SizedBox(
                          width: double.infinity,
                          height: clampedHeight,
                          child: viewportContent,
                        );
                      },
                    )
                  : viewportContent,
            );
          },
        ),
        if (state.eyeProposals.isNotEmpty) ...[
          SizedBox(height: isMobileScreen ? 10 : 12),
          _buildEyeFilmstrip(state, controller),
        ],
        SizedBox(height: isMobileScreen ? 12 : 16),
        // Region toggle + compact icon toolbar (Detect Eyes)
        Row(
          children: [
            Expanded(child: _buildSoftRegionSwitcher(state, controller)),
            if (canUseEyeFinder && controller.canFindEyes) ...[
              const SizedBox(width: 8),
              _buildToolbarIconButton(
                key: const Key('scanner_find_eye_button'),
                tooltip: state.isFindingEyes
                    ? 'Detecting eyes...'
                    : 'Detect eyes',
                isLoading: state.isFindingEyes,
                icon: Icons.center_focus_strong_rounded,
                iconColor: SariwaColors.brandPrimary,
                onTap:
                    state.isBatchRunning ||
                        state.isFindingEyes ||
                        state.isClassifying
                    ? null
                    : controller.detectEyesForCurrentImage,
              ),
            ],
          ],
        ),
        SizedBox(height: isMobileScreen ? 12 : 16),
        if (state.latestResult != null && !state.isClassifying)
          OutlinedButton.icon(
            key: const Key('current_scan_check_freshness_button'),
            onPressed: null,
            icon: const Icon(CupertinoIcons.checkmark_alt_circle, size: 17),
            label: const Text('Checked'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: SariwaColors.brandPrimary,
              disabledForegroundColor: SariwaColors.textSecondaryDark,
              side: const BorderSide(color: SariwaColors.lineSlate),
              shape: const StadiumBorder(),
            ),
          )
        else
          FilledButton(
            key: const Key('current_scan_check_freshness_button'),
            onPressed: state.isClassifying
                ? null
                : () async {
                    HapticFeedback.mediumImpact();
                    if (!state.isCropConfirmed) {
                      controller.confirmFullImageAsCloseUp();
                    }
                    await controller.classify();
                  },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF404040),
              disabledForegroundColor: Colors.white70,
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isClassifying)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    CupertinoIcons.sparkles,
                    size: 16,
                    color: Colors.white,
                  ),
                const SizedBox(width: 8),
                Text(
                  state.isClassifying
                      ? (state.processingStage ?? 'Checking...')
                      : 'Check freshness',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSoftRegionSwitcher(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final selected = state.selectedRegion ?? AnatomicalRegion.auto;

    Widget buildOption(AnatomicalRegion region, String label, IconData icon) {
      final isSelected = selected == region;
      return Expanded(
        child: GestureDetector(
          onTap: state.isClassifying
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  controller.selectRegion(region);
                },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? SariwaColors.cardSurfaceLight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: SariwaColors.shadowSubtle,
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? const Color(0xFF111111)
                      : const Color(0xFF737373),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFF111111)
                          : const Color(0xFF737373),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: SariwaColors.surfaceSlateWash,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.surfaceSlateSubtle),
      ),
      child: Row(
        children: [
          buildOption(AnatomicalRegion.auto, 'Auto', CupertinoIcons.sparkles),
          const SizedBox(width: 2),
          buildOption(AnatomicalRegion.eye, 'Eye', CupertinoIcons.eye),
          const SizedBox(width: 2),
          buildOption(
            AnatomicalRegion.gill,
            'Gill',
            CupertinoIcons.waveform_path,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarIconButton({
    Key? key,
    required String tooltip,
    required IconData icon,
    Color? iconColor,
    bool isLoading = false,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: key,
            onTap: onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap();
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: enabled
                      ? SariwaColors.lineSlate
                      : SariwaColors.surfaceSlateSubtle,
                ),
              ),
              child: Center(
                child: isLoading
                    ? const CupertinoActivityIndicator(radius: 8)
                    : Icon(
                        icon,
                        size: 18,
                        color: enabled
                            ? (iconColor ?? SariwaColors.textPrimaryDark)
                            : SariwaColors.inkSlateSubtle,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselArrowButton({
    Key? key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xB80A1926),
        shape: const CircleBorder(),
        child: InkWell(
          key: key,
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, size: 17, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildEyeFilmstrip(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final proposals = state.eyeProposals;
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: proposals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final proposal = proposals[index];
          final isSelected = state.selectedEyeProposalIndex == index;
          final isHovered = _hoveredEyeTileIndex == index;
          final checkedFresh = state.eyeProposalFreshness[index];

          return StaggeredReveal(
            staggerIndex: index.clamp(0, 6),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: isSelected
                  ? 'Eye ${index + 1}, selected. Activate to zoom'
                  : 'Eye ${index + 1}',
              child: Tooltip(
                message: isSelected
                    ? 'Click to zoom Eye #${index + 1}'
                    : 'Select Eye #${index + 1}',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) =>
                      setState(() => _hoveredEyeTileIndex = index),
                  onExit: (_) {
                    if (_hoveredEyeTileIndex == index) {
                      setState(() => _hoveredEyeTileIndex = null);
                    }
                  },
                  child: GestureDetector(
                    key: Key('eye_proposal_tile_$index'),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (isSelected) {
                        _openEyeZoomModal(state, controller, index);
                      } else {
                        controller.selectEyeProposal(index);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      width: 84,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? SariwaColors.brandPrimary
                              : (isHovered
                                    ? SariwaColors.brandGlow
                                    : SariwaColors.lineSlate),
                          width: isSelected ? 2.2 : 1.2,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              proposal.bytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (isSelected)
                            IgnorePointer(
                              child: AnimatedOpacity(
                                key: Key('eye_proposal_hover_zoom_$index'),
                                opacity: isHovered ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOutCubic,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0x8C0A1926),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: SariwaColors.cardSurfaceLight.withValues(
                                          alpha: 0.22,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: SariwaColors.cardSurfaceLight.withValues(
                                            alpha: 0.65,
                                          ),
                                        ),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.zoom_in,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? SariwaColors.brandPrimary
                                    : const Color(0xCC0A1926),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (isSelected && !isHovered)
                            Positioned(
                              left: 4,
                              bottom: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xBF0A1926),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  CupertinoIcons.zoom_in,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (checkedFresh != null)
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  checkedFresh
                                      ? CupertinoIcons.checkmark_circle_fill
                                      : CupertinoIcons
                                            .exclamationmark_circle_fill,
                                  size: 14,
                                  color: checkedFresh
                                      ? SariwaColors.statusFresh
                                      : SariwaColors.notFreshPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlayPillButton({
    Key? key,
    required String tooltip,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: enabled ? 0.55 : 0.30),
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            key: key,
            onTap: onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap();
                  },
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                icon,
                size: 16,
                color: enabled ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Rect _computeContainedImageRect(
    Size containerSize,
    ui.Image? image,
    Size? fallbackSize,
  ) {
    final double imgWidth;
    final double imgHeight;
    if (image != null && image.width > 0 && image.height > 0) {
      imgWidth = image.width.toDouble();
      imgHeight = image.height.toDouble();
    } else if (fallbackSize != null &&
        fallbackSize.width > 0 &&
        fallbackSize.height > 0) {
      imgWidth = fallbackSize.width;
      imgHeight = fallbackSize.height;
    } else {
      return Offset.zero & containerSize;
    }
    final imageAspect = imgWidth / imgHeight;
    final containerAspect = containerSize.width / containerSize.height;
    if (imageAspect > containerAspect) {
      final width = containerSize.width;
      final height = width / imageAspect;
      final dy = (containerSize.height - height) / 2;
      return Rect.fromLTWH(0, dy, width, height);
    } else {
      final height = containerSize.height;
      final width = height * imageAspect;
      final dx = (containerSize.width - width) / 2;
      return Rect.fromLTWH(dx, 0, width, height);
    }
  }

  Widget _buildProposalMarker({
    required int index,
    required EyeCropProposal proposal,
    required Rect displayedRect,
    required bool isSelected,
    required bool isHovered,
    required ValueChanged<bool> onHoverChanged,
    required VoidCallback onTap,
  }) {
    final left = displayedRect.left + proposal.rect.left * displayedRect.width;
    final top = displayedRect.top + proposal.rect.top * displayedRect.height;
    final width = (proposal.rect.width * displayedRect.width).clamp(
      28.0,
      220.0,
    );
    final height = (proposal.rect.height * displayedRect.height).clamp(
      28.0,
      220.0,
    );

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: isSelected
            ? 'Detected eye marker ${index + 1}, selected. Activate to zoom'
            : 'Detected eye marker ${index + 1}',
        child: Tooltip(
          message: isSelected
              ? 'Click to zoom Eye #${index + 1}'
              : 'Select Eye #${index + 1}',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => onHoverChanged(true),
            onExit: (_) => onHoverChanged(false),
            child: GestureDetector(
              key: Key('eye_proposal_marker_$index'),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? SariwaColors.brandGlow
                        : const Color(0xFFFACC15),
                    width: isSelected ? 3.0 : 2.0,
                  ),
                  color: isSelected
                      ? SariwaColors.brandGlow.withValues(
                          alpha: isHovered ? 0.28 : 0.18,
                        )
                      : Colors.transparent,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SariwaColors.brandPrimary
                              : const Color(0xE60A2229),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: AnimatedOpacity(
                          opacity: isHovered ? 1.0 : 0.85,
                          duration: const Duration(milliseconds: 160),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xD90A1926),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.zoom_in,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadingCard() {
    return Container(
      key: const Key('image_uploading_state'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.surfaceSlateSubtle, width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SariwaColors.surfaceSlateSubtle, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: SariwaColors.shadowSubtle,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Center(child: CupertinoActivityIndicator(radius: 12)),
          ),
          const SizedBox(height: 16),
          Text(
            'Uploading & Processing Photo...',
            style: TextStyle(
              fontFamily: TimberTypography.primarySansFamily,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verifying image headers and preparing viewer...',
            style: TextStyle(
              fontFamily: TimberTypography.primarySansFamily,
              fontSize: 12,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.1,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: SariwaColors.surfaceSlateSubtle,
                color: SariwaColors.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveModalPlaceholderCard(ClassificationState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SariwaColors.surfaceSlateTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.surfaceSlateSubtle, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.crop,
              color: SariwaColors.brandPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedImageName ?? 'tilapia_scan.jpg',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  state.latestResult != null
                      ? 'Viewing freshness results in inspection modal...'
                      : (state.isClassifying
                            ? 'Evaluating image freshness in modal...'
                            : 'Adjusting photo in crop view...'),
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4ClassifySection(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final statusText = state.processingStage ?? 'Analyzing image...';

    Future<void> handleClassifyTap() async {
      if (state.isClassifying) return;
      if (state.selectedRegion == null) {
        await controller.classify();
        return;
      }
      if (!state.isCropConfirmed) {
        if (controller.canFindEyes && state.selectedRegion?.apiValue == 'eye') {
          widget.onOpenCropModal();
          return;
        }
        controller.confirmFullImageAsCloseUp();
      }
      await controller.classify();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton.primary(
          key: const Key('validate_and_classify_button'),
          label: state.isClassifying
              ? statusText
              : 'Validate & Classify Freshness',
          isLoading: state.isClassifying,
          height: 50,
          borderRadius: 16,
          icon: const Icon(
            CupertinoIcons.sparkles,
            size: 18,
            color: Colors.white,
          ),
          onPressed: state.isClassifying ? null : handleClassifyTap,
        ),
        if (state.isClassifying) ...[
          const SizedBox(height: 12),
          Container(
            key: const Key('analyzing_image_status'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.90)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const CupertinoActivityIndicator(radius: 8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: SariwaColors.surfaceSlateSubtle,
                    color: SariwaColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageRejectionCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final code = state.errorCode;
    final guidance = ClassificationApiException.contextualGuidanceForCode(code);
    final serverMessage = state.errorMessage ?? guidance;

    return Container(
      key: const Key('image_rejection_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SariwaColors.statusSpoiled.withValues(alpha: 0.32),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: SariwaColors.shadowHairline,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SariwaColors.statusSpoiled.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.xmark_octagon,
                  color: SariwaColors.statusSpoiled,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          ClassificationApiException.rejectionTitleForCode(
                            code,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      guidance,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (state.hasSelectedImage)
                OutlinedButton.icon(
                  key: const Key('rejection_edit_crop_button'),
                  onPressed: () {
                    controller.editCrop();
                    widget.onOpenCropModal();
                  },
                  icon: const Icon(CupertinoIcons.crop, size: 14),
                  label: const Text('Edit Crop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.brandPrimary,
                    side: const BorderSide(color: SariwaColors.surfaceSlateSubtle),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              if (state.hasSelectedImage)
                OutlinedButton.icon(
                  key: const Key('rejection_change_region_button'),
                  onPressed: () {
                    controller.changeRegion();
                    widget.onOpenCropModal();
                  },
                  icon: const Icon(
                    CupertinoIcons.arrow_up_arrow_down,
                    size: 14,
                  ),
                  label: const Text('Change Region'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.brandPrimary,
                    side: const BorderSide(color: SariwaColors.surfaceSlateSubtle),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              OutlinedButton.icon(
                key: const Key('rejection_replace_image_button'),
                onPressed: () => controller.clearSelection(),
                icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 14),
                label: const Text('Replace Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.statusSpoiled,
                  side: const BorderSide(color: SariwaColors.surfaceSlateSubtle),
                  backgroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              if (state.isReadyToClassify)
                ElevatedButton.icon(
                  key: const Key('rejection_try_again_button'),
                  onPressed: () => controller.classify(),
                  icon: const Icon(CupertinoIcons.refresh, size: 14),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalErrorCard(
    ClassificationState state,
    ClassificationController controller,
  ) {
    return Container(
      key: const Key('technical_error_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.surfaceSlateSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.wifi_exclamationmark,
                color: SariwaColors.textSecondaryDark,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Service or Connection Issue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ??
                'Unable to reach the classification service. Please try again.',
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (state.isReadyToClassify)
                ElevatedButton.icon(
                  key: const Key('technical_try_again_button'),
                  onPressed: () => controller.classify(),
                  icon: const Icon(CupertinoIcons.refresh, size: 14),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              if (state.hasSelectedImage)
                OutlinedButton.icon(
                  onPressed: () => controller.clearSelection(),
                  icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 14),
                  label: const Text('Replace Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.textPrimaryDark,
                    side: const BorderSide(color: SariwaColors.surfaceSlateSubtle),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionResultView(ClassificationResult result) {
    final selectedRegionText = result.selectedRegionLabel;
    final timestampText = result.formattedTimestamp;

    final isNotFresh = result.isNotFresh;
    final primaryColor = isNotFresh
        ? SariwaColors.notFreshPrimary
        : SariwaColors.brandPrimary;
    final textColor = isNotFresh
        ? SariwaColors.notFreshText
        : SariwaColors.freshText;
    final iconBgColor = isNotFresh
        ? SariwaColors.notFreshIconBg
        : SariwaColors.freshIconBg;
    final cardBorderColor = isNotFresh
        ? SariwaColors.notFreshBorder
        : SariwaColors.freshBorder;
    final trackColor = isNotFresh
        ? SariwaColors.notFreshTrack
        : SariwaColors.freshTrack;
    final cardBgColor = isNotFresh
        ? SariwaColors.notFreshCardBg
        : SariwaColors.freshCardBg;

    return Container(
      key: const Key('classification_result_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorderColor, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: SariwaColors.shadowHairline,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconBgColor,
                      ),
                      child: Icon(
                        result.isFresh
                            ? CupertinoIcons.checkmark_alt
                            : CupertinoIcons.exclamationmark_triangle,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      result.label,
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: textColor,
                                      ),
                                    ),
                                    if (selectedRegionText != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: SariwaColors.surfaceSlateWash,
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                        ),
                                        child: Text(
                                          selectedRegionText,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: AppTypography
                                                .defaultLetterSpacing,
                                            color: SariwaColors.brandPrimary,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: SariwaColors.surfaceSlateTint,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        result.assessmentScopeLabel,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: AppTypography
                                              .defaultLetterSpacing,
                                          color: SariwaColors.textSecondaryDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                result.isFresh
                                    ? CupertinoIcons.checkmark_circle_fill
                                    : CupertinoIcons
                                          .exclamationmark_circle_fill,
                                color: primaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Model Confidence',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing:
                                        AppTypography.defaultLetterSpacing,
                                    color: SariwaColors.textPrimaryDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                result.formattedConfidence,
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: result.confidence.clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: trackColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor,
                              ),
                            ),
                          ),
                          if (timestampText != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Classified at: $timestampText',
                              style: const TextStyle(
                                fontSize: 12,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                          if (result.modelVersion != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Model: ${result.modelVersion}',
                              style: const TextStyle(
                                fontSize: 12,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          const Text(
                            ClassificationResult.confidenceExplanation,
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            key: const Key('result_save_status_banner'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SariwaColors.surfaceSlateTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SariwaColors.surfaceSlateSubtle, width: 0.8),
            ),
            child: Row(
              children: [
                Icon(
                  result.saved
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.info_circle,
                  size: 16,
                  color: result.saved
                      ? SariwaColors.brandPrimary
                      : SariwaColors.textSecondaryDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.saveStatusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: AppTypography.defaultLetterSpacing,
                      color: result.saved
                          ? SariwaColors.brandPrimary
                          : SariwaColors.textSecondaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SariwaColors.surfaceSlateTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SariwaColors.surfaceSlateSubtle, width: 0.8),
            ),
            child: Text(
              result.disclaimer,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w400,
                letterSpacing: AppTypography.defaultLetterSpacing,
                color: SariwaColors.textSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
