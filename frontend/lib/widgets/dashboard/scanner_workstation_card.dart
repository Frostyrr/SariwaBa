import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';
import '../../services/classification/classification_service.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../constants/theme/timber_typography.dart';
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

  const ScannerWorkstationCard({
    super.key,
    required this.state,
    required this.controller,
    required this.isCropModalOpen,
    required this.onOpenCropModal,
  });

  @override
  State<ScannerWorkstationCard> createState() => _ScannerWorkstationCardState();
}

class _ScannerWorkstationCardState extends State<ScannerWorkstationCard> {
  ui.Image? _decodedImage;
  Uint8List? _decodedBytes;

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

    return FrostedGlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      blurSigma: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.viewfinder,
                        size: 20,
                        color: SariwaColors.brandPrimary,
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
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Upload a Tilapia eye, exposed gill, or whole fish photo.',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textSecondaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: SariwaColors.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Tilapia only',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('scanner_workspace'),
                    child: _buildInlineImageWorkspace(state, controller),
                  ),
          ),
          if (state.batchScans.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              state.isBatchRunning
                  ? 'Checking photos one at a time…'
                  : 'Batch results',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final (index, item) in state.batchScans.indexed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.photo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(switch (item.status) {
                  BatchScanStatus.queued => 'Waiting',
                  BatchScanStatus.checking => 'Checking freshness…',
                  BatchScanStatus.needsReview =>
                    'Needs review · ${item.message}',
                  BatchScanStatus.rejected => item.message ?? 'Photo rejected',
                  BatchScanStatus.failed =>
                    item.message ?? 'Could not check this photo',
                  BatchScanStatus.complete => item.result?.label ?? 'Complete',
                }),
                trailing:
                    item.status == BatchScanStatus.needsReview ||
                        item.status == BatchScanStatus.failed
                    ? TextButton(
                        onPressed:
                            state.isBatchRunning ||
                                state.isClassifying ||
                                state.isUploadingImage
                            ? null
                            : () => controller.openBatchPhoto(index),
                        child: const Text('Review'),
                      )
                    : null,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineImageWorkspace(
    ClassificationState state,
    ClassificationController controller,
  ) {
    final bytes = state.selectedImageBytes!;
    final canUseEyeFinder = state.selectedRegion != AnatomicalRegion.gill;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Original image preview with letterboxing-aware numbered eye markers
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 320,
            width: double.infinity,
            color: const Color(0xFF0A1926),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final containerSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                final displayedRect = _computeContainedImageRect(
                  containerSize,
                  _decodedImage,
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
                          onTap: () {
                            HapticFeedback.selectionClick();
                            controller.selectEyeProposal(i);
                          },
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
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xCC0A1926),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Text(
                            state.selectedEyeProposalIndex != null
                                ? '${state.selectedEyeProposalIndex! + 1} / ${state.eyeProposals.length}'
                                : '${state.eyeProposals.length} eyes',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
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
          ),
        ),
        if (state.eyeProposals.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildEyeFilmstrip(state, controller),
        ],
        const SizedBox(height: 14),
        // Region toggle + compact icon toolbar (Detect Eyes, Adjust Crop, Replace)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<AnatomicalRegion>(
              segments: [
                ButtonSegment(
                  value: AnatomicalRegion.auto,
                  label: Text(
                    state.selectedRegion == AnatomicalRegion.auto &&
                            state.latestResult?.anatomicalRegion != null
                        ? "Auto: ${state.latestResult!.anatomicalRegion!.displayName}"
                        : "Auto",
                  ),
                ),
                ButtonSegment(
                  value: AnatomicalRegion.eye,
                  label: Text('Eye'),
                  icon: Icon(CupertinoIcons.eye, size: 15),
                ),
                ButtonSegment(
                  value: AnatomicalRegion.gill,
                  label: Text('Gill'),
                  icon: Icon(CupertinoIcons.waveform_path, size: 15),
                ),
              ],
              selected: {state.selectedRegion ?? AnatomicalRegion.auto},
              onSelectionChanged: state.isClassifying
                  ? null
                  : (selection) {
                      HapticFeedback.selectionClick();
                      controller.selectRegion(selection.first);
                    },
            ),
            if (canUseEyeFinder && controller.canFindEyes) ...[
              _buildToolbarIconButton(
                key: const Key('scanner_find_eye_button'),
                tooltip: state.isFindingEyes
                    ? 'Detecting Tilapia eyesâ€¦'
                    : 'Detect Tilapia eyes',
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
            _buildToolbarIconButton(
              key: const Key('scanner_adjust_crop_button'),
              tooltip: 'Adjust crop',
              icon: CupertinoIcons.crop,
              onTap: state.isClassifying ? null : widget.onOpenCropModal,
            ),
            _buildToolbarIconButton(
              tooltip: 'Replace photo',
              icon: CupertinoIcons.photo,
              iconColor: SariwaColors.textSecondaryDark,
              onTap: state.isClassifying ? null : controller.clearSelection,
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppButton.primary(
          key: const Key('current_scan_check_freshness_button'),
          label: state.isClassifying
              ? (state.processingStage ?? 'Checking freshness...')
              : 'Check freshness',
          isLoading: state.isClassifying,
          height: 48,
          borderRadius: 14,
          icon: const Icon(
            CupertinoIcons.sparkles,
            size: 17,
            color: Colors.white,
          ),
          onPressed: state.isClassifying
              ? null
              : () async {
                  HapticFeedback.mediumImpact();
                  if (!state.isCropConfirmed) {
                    controller.confirmFullImageAsCloseUp();
                  }
                  await controller.classify();
                },
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
      return GestureDetector(
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? SariwaColors.brandPrimary
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? SariwaColors.textPrimaryDark
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildOption(AnatomicalRegion.auto, 'Auto', CupertinoIcons.sparkles),
          const SizedBox(width: 2),
          buildOption(AnatomicalRegion.eye, 'Eye', CupertinoIcons.eye),
          const SizedBox(width: 2),
          buildOption(AnatomicalRegion.gill, 'Gill', CupertinoIcons.waveform_path),
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
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFE2E8F0),
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
                            : const Color(0xFF94A3B8),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselArrowButton({
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
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
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
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final proposal = proposals[index];
          final isSelected = state.selectedEyeProposalIndex == index;
          final checkedFresh = state.eyeProposalFreshness[index];

          return StaggeredReveal(
            staggerIndex: index.clamp(0, 6),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: 'Eye ${index + 1}${isSelected ? ', selected' : ''}',
              child: GestureDetector(
                key: Key('eye_proposal_tile_$index'),
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.selectEyeProposal(index);
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: 84,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? SariwaColors.brandPrimary
                            : const Color(0xFFCBD5E1),
                        width: isSelected ? 2.2 : 1.0,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            proposal.bytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? SariwaColors.brandPrimary
                                  : const Color(0xCC0A1926),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
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
          );
        },
      ),
    );
  }

  Rect _computeContainedImageRect(Size containerSize, ui.Image? image) {
    if (image == null || image.width == 0 || image.height == 0) {
      return Offset.zero & containerSize;
    }
    final imageAspect = image.width / image.height;
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
        label: 'Detected eye marker ${index + 1}',
        child: GestureDetector(
          key: Key('eye_proposal_marker_$index'),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? SariwaColors.brandGlow
                    : const Color(0xFFFACC15),
                width: isSelected ? 3.0 : 2.0,
              ),
              color: isSelected
                  ? SariwaColors.brandGlow.withValues(alpha: 0.18)
                  : Colors.transparent,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? SariwaColors.brandPrimary
                      : const Color(0xE60A2229),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
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
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Center(child: CupertinoActivityIndicator(radius: 12)),
          ),
          const SizedBox(height: 18),
          Text(
            'Uploading & Processing Photo...',
            style: TextStyle(
              fontFamily: TimberTypography.primarySansFamily,
              fontSize: 15,
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
              borderRadius: BorderRadius.circular(99),
              child: const LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Color(0xFFE2E8F0),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
                    fontSize: 13.5,
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
          const SizedBox(height: 10),
          Container(
            key: const Key('analyzing_image_status'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.90)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const CupertinoActivityIndicator(radius: 8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: Color(0xFFE2E8F0),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SariwaColors.statusSpoiled.withValues(alpha: 0.32),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
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
                padding: const EdgeInsets.all(10),
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
                            fontSize: 15.5,
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
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
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
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
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
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  backgroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
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
                      borderRadius: BorderRadius.circular(99),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Service or Connection Issue',
                  style: const TextStyle(
                    fontSize: 15,
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
              fontSize: 12.5,
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
                      borderRadius: BorderRadius.circular(99),
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
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorderColor, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x060F172A),
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
                    const SizedBox(width: 14),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: textColor,
                                      ),
                                    ),
                                    if (selectedRegionText != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                        ),
                                        child: Text(
                                          selectedRegionText,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: AppTypography
                                                .defaultLetterSpacing,
                                            color: SariwaColors.brandPrimary,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        result.assessmentScopeLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
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
                                    fontSize: 13,
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
                                  fontSize: 13,
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
                            borderRadius: BorderRadius.circular(99),
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
                                fontSize: 11.5,
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
                                fontSize: 11.5,
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
                              fontSize: 11.5,
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
          const SizedBox(height: 10),
          Container(
            key: const Key('result_save_status_banner'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
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
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            ),
            child: Text(
              result.disclaimer,
              style: const TextStyle(
                fontSize: 11.5,
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
