import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';
import '../../services/classification/classification_service.dart';
import '../classification/eye_zoom_modal.dart';
import 'frosted_glass_card.dart';

/// Current-scan right column (wide) / stacked panel (narrow) containing:
/// - Idle empty state before any scan
/// - Detected Eyes gallery (grid on desktop, horizontal strip on mobile)
/// - Exact selected crop preview + Check freshness CTA
/// - Model-aligned Freshness Result card ("Model confidence")
/// - Local recovery actions (Find Eyes, Adjust crop, Change region, Retry, Retake)
class CurrentScanPanel extends StatelessWidget {
  final ClassificationState state;
  final ClassificationController controller;
  final bool isWide;
  final VoidCallback onAdjustCrop;
  final VoidCallback? onViewHistory;

  const CurrentScanPanel({
    super.key,
    required this.state,
    required this.controller,
    required this.isWide,
    required this.onAdjustCrop,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final String panelKey;
    final Widget body;

    if (state.batchScans.isNotEmpty) {
      panelKey =
          'batch_${state.batchScans.length}_${state.isBatchRunning}_${state.selectedImageName}_${state.latestResult?.scanId}_${state.errorCode}';
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.hasSelectedImage) ...[
            if (state.isFindingEyes) ...[
              _buildDetectingEyesBanner(),
              const SizedBox(height: 12),
            ] else if (state.alreadyCloseUpEye || state.alreadyCloseUpGill) ...[
              _buildCloseUpDetectedBanner(isGill: state.alreadyCloseUpGill),
              const SizedBox(height: 12),
            ],
            if (state.latestResult != null) ...[
              _buildResultCard(context, state.latestResult!),
              const SizedBox(height: 16),
            ] else if (state.errorMessage != null) ...[
              _buildRecoveryCard(),
              const SizedBox(height: 16),
            ] else ...[
              _buildReadyToCheckCard(context),
              const SizedBox(height: 16),
            ],
          ],
          _buildBatchResultsCard(),
        ],
      );
    } else if (!state.hasSelectedImage) {
      panelKey = 'idle';
      body = _buildIdleState();
    } else if (state.latestResult != null) {
      panelKey =
          'result_${state.latestResult!.scanId ?? state.latestResult!.label}_${state.selectedEyeProposalIndex}';
      body = _buildResultCard(context, state.latestResult!);
    } else if (state.errorMessage != null) {
      panelKey = 'error_${state.errorCode}';
      body = _buildRecoveryCard();
    } else {
      panelKey =
          'ready_${state.selectedEyeProposalIndex}_${state.isFindingEyes}_${state.alreadyCloseUpEye}_${state.alreadyCloseUpGill}';
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isFindingEyes) ...[
            _buildDetectingEyesBanner(),
            const SizedBox(height: 16),
          ] else if (state.alreadyCloseUpEye || state.alreadyCloseUpGill) ...[
            _buildCloseUpDetectedBanner(isGill: state.alreadyCloseUpGill),
            const SizedBox(height: 16),
          ],
          _buildReadyToCheckCard(context),
        ],
      );
    }

    return FrostedGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 16,
      blurSigma: 6,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(panelKey), child: body),
      ),
    );
  }

  Widget _buildBatchResultsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.square_stack_3d_up,
                size: 17,
                color: SariwaColors.brandPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.isBatchRunning
                    ? 'Checking batch (${state.batchScans.length})…'
                    : 'Batch Results (${state.batchScans.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final (index, item) in state.batchScans.indexed) ...[
          _buildBatchItemCard(index, item),
          if (index < state.batchScans.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildBatchItemCard(int index, BatchScanItem item) {
    final result = item.result;
    final isComplete = item.status == BatchScanStatus.complete && result != null;
    final isFresh = result?.isFresh ?? false;

    final Color pillBg;
    final Color pillText;
    final Color dotColor;
    final String statusLabel;

    if (isComplete) {
      pillBg = isFresh ? SariwaColors.freshTrack : SariwaColors.notFreshTrack;
      pillText = isFresh ? SariwaColors.freshText : SariwaColors.notFreshText;
      dotColor = isFresh ? SariwaColors.statusFresh : SariwaColors.statusSpoiled;
      statusLabel = result.label;
    } else if (item.status == BatchScanStatus.checking) {
      pillBg = SariwaColors.brandPrimary.withValues(alpha: 0.10);
      pillText = SariwaColors.brandPrimary;
      dotColor = SariwaColors.brandPrimary;
      statusLabel = 'Checking…';
    } else if (item.status == BatchScanStatus.queued) {
      pillBg = SariwaColors.surfaceSlateWash;
      pillText = SariwaColors.inkSlateMuted;
      dotColor = SariwaColors.inkSlateSubtle;
      statusLabel = 'Waiting';
    } else {
      pillBg = SariwaColors.warningBg;
      pillText = const Color(0xFFB45309);
      dotColor = SariwaColors.warningText;
      statusLabel = item.status == BatchScanStatus.rejected
          ? 'Rejected'
          : 'Needs review';
    }

    return Material(
      color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: state.isBatchRunning ||
                state.isClassifying ||
                state.isFindingEyes
            ? null
            : () {
                HapticFeedback.selectionClick();
                controller.openBatchPhoto(index);
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SariwaColors.borderLightTeal),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: FutureBuilder<Uint8List>(
                    future: item.photo.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Container(
                          color: SariwaColors.notFreshIconBg,
                          child: const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 18,
                            color: SariwaColors.notFreshText,
                          ),
                        );
                      }
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      }
                      return Container(
                        color: SariwaColors.surfaceSlateWash,
                        child: const Icon(
                          CupertinoIcons.photo,
                          size: 18,
                          color: SariwaColors.inkSlateSubtle,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.photo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isComplete
                          ? 'Model confidence: ${result.formattedConfidence}'
                          : (item.message ?? statusLabel),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: SariwaColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: pillText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.sparkles,
                size: 18,
                color: SariwaColors.brandPrimary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Current Scan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Select a photo to preview the region and check freshness.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.45,
            color: SariwaColors.textSecondaryDark,
          ),
        ),
        if (isWide) ...[
          const SizedBox(height: 16),
          _buildGuideStep(
            '1',
            'Close-up eye or gill',
            'Checks right away without manual cropping.',
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            '2',
            'Whole fish or tray',
            'Tap any detected eye to inspect it.',
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            '3',
            'Instant reading',
            'Shows Fresh or Not Fresh with a confidence score.',
          ),
        ],
      ],
    );
  }

  Widget _buildGuideStep(String num, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SariwaColors.brandPrimary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            num,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: SariwaColors.brandPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: SariwaColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetectingEyesBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: SariwaColors.brandPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SariwaColors.brandPrimary.withValues(alpha: 0.22),
        ),
      ),
      child: const Row(
        children: [
          CupertinoActivityIndicator(radius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Detecting Tilapia eyes...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: SariwaColors.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseUpDetectedBanner({bool isGill = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: SariwaColors.freshIconBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.freshBorder),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.checkmark_seal_fill,
            size: 16,
            color: SariwaColors.statusFresh,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isGill
                  ? 'Close-up gill ready — tap Check freshness.'
                  : 'Close-up eye ready — tap Check freshness.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: SariwaColors.freshText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedEyesGallery() {
    final proposals = state.eyeProposals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.eye_fill,
              size: 16,
              color: SariwaColors.brandPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                proposals.length == 1
                    ? 'Detected Eye (1)'
                    : 'Detected Eyes (${proposals.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          proposals.length == 1
              ? 'Previewing detected eye. Tap Check freshness when ready.'
              : 'Tap a numbered eye to select its fish before checking freshness.',
          style: const TextStyle(
            fontSize: 12,
            color: SariwaColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 12),
        if (isWide)
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < proposals.length; i++)
                    SizedBox(
                      width: tileWidth,
                      child: _buildEyeTile(i, proposals[i]),
                    ),
                ],
              );
            },
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < proposals.length; i++) ...[
                  SizedBox(width: 132, child: _buildEyeTile(i, proposals[i])),
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEyeTile(int index, EyeCropProposal proposal) {
    final isSelected = state.selectedEyeProposalIndex == index;
    final checkedFresh = state.eyeProposalFreshness[index];

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Eye ${index + 1}${isSelected ? ', selected' : ''}',
      child: InkWell(
        key: Key('eye_proposal_tile_$index'),
        onTap: () {
          HapticFeedback.selectionClick();
          controller.selectEyeProposal(index);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? SariwaColors.brandPrimary.withValues(alpha: 0.09)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? SariwaColors.brandPrimary
                  : SariwaColors.lineSlate,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  proposal.bytes,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Eye #${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w500,
                        color: isSelected
                            ? SariwaColors.brandPrimary
                            : SariwaColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      checkedFresh != null
                          ? (checkedFresh ? 'Fresh ✓' : 'Not Fresh !')
                          : (isSelected ? 'Selected' : 'Tap to select'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: checkedFresh != null
                            ? (checkedFresh
                                  ? SariwaColors.freshText
                                  : SariwaColors.notFreshText)
                            : SariwaColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSelectedEyeZoom(BuildContext context, Uint8List fallbackBytes) {
    if (state.eyeProposals.isNotEmpty) {
      EyeZoomModal.show(
        context,
        images: [for (final p in state.eyeProposals) p.bytes],
        initialIndex: state.selectedEyeProposalIndex ?? 0,
        onIndexChanged: controller.selectEyeProposal,
      );
      return;
    }
    final regionLabel = switch (state.selectedRegion) {
      AnatomicalRegion.gill => 'Selected Gill Close-Up',
      AnatomicalRegion.eye => 'Selected Eye Close-Up',
      _ => 'Selected Close-Up Preview',
    };
    EyeZoomModal.show(
      context,
      images: [fallbackBytes],
      titleBuilder: (_, _) => regionLabel,
    );
  }

  Widget _buildReadyToCheckCard(BuildContext context) {
    final previewBytes = state.confirmedImageBytes ?? state.selectedImageBytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (previewBytes != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SariwaColors.borderLightTeal),
            ),
            child: Row(
              children: [
                HoverZoomEyePreview(
                  key: const Key('selected_eye_preview_thumbnail'),
                  imageBytes: previewBytes,
                  width: 64,
                  height: 64,
                  borderRadius: 12,
                  tooltip: state.selectedEyeProposalIndex != null
                      ? 'Hover or click to zoom Eye #${state.selectedEyeProposalIndex! + 1}'
                      : 'Hover or click to zoom preview',
                  onTapZoom: () => _openSelectedEyeZoom(context, previewBytes),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.selectedEyeProposalIndex != null
                            ? 'Selected: Eye #${state.selectedEyeProposalIndex! + 1}'
                            : 'Ready to inspect',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.isClassifying
                            ? (state.processingStage ??
                                  'Analyzing freshness...')
                            : (state.isFullImageConfirmed ||
                                      !state.isCropConfirmed
                                  ? 'Tap Check freshness under the scanner to analyze this close-up.'
                                  : 'Exact cropped eye will be analyzed when you tap Check freshness.'),
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: SariwaColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, ClassificationResult result) {
    final isFresh = result.isFresh;
    final primaryColor = isFresh
        ? SariwaColors.brandPrimary
        : SariwaColors.notFreshPrimary;
    final cropBytes = state.confirmedImageBytes ?? state.selectedImageBytes;

    return Container(
      key: const Key('classification_result_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (cropBytes != null) ...[
                HoverZoomEyePreview(
                  key: const Key('result_eye_preview_thumbnail'),
                  imageBytes: cropBytes,
                  width: 54,
                  height: 54,
                  borderRadius: 10,
                  tooltip: 'Hover or click to zoom analyzed close-up',
                  onTapZoom: () => _openSelectedEyeZoom(context, cropBytes),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.25,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Confidence · ${result.formattedConfidence}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: result.confidence.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: const Color(0xFFE5E5E7),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visual freshness estimate — not a food-safety guarantee.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              height: 1.35,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: controller.clearSelection,
                  icon: const Icon(
                    CupertinoIcons.camera_viewfinder,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text('Scan Another'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 44),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  controller.editCrop();
                  onAdjustCrop();
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF111111),
                  side: const BorderSide(color: Color(0x1A171717)),
                  minimumSize: const Size(0, 44),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Adjust crop'),
              ),
            ],
          ),
          if (state.eyeProposals.length > 1) ...[
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final total = state.eyeProposals.length;
                final currentIdx = state.selectedEyeProposalIndex ?? 0;
                final nextIdx = (currentIdx + 1) % total;
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: const Key('result_next_eye_button'),
                    onPressed: () => controller.selectEyeProposal(nextIdx),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF111111),
                      side: BorderSide(
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                      minimumSize: const Size(0, 42),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text('Next Eye (${nextIdx + 1}/$total) →'),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecoveryCard() {
    final code = state.errorCode;
    final isWholeTilapia = code == 'WHOLE_TILAPIA_CLOSE_UP_REQUIRED';
    final isRegionMismatch = code == 'REGION_MISMATCH';
    final isNetworkOrServer = !state.isInputRejection;

    return Container(
      key: const Key('image_rejection_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SariwaColors.notFreshIconBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.notFreshBorder, width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 18,
                color: SariwaColors.notFreshPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isNetworkOrServer
                      ? 'Connection or Server Issue'
                      : ClassificationApiException.rejectionTitleForCode(code),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SariwaColors.notFreshText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'Unable to classify this photo.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isWholeTilapia &&
                  controller.canFindEyes &&
                  state.selectedRegion != AnatomicalRegion.gill)
                FilledButton.icon(
                  onPressed: state.isBatchRunning || state.isFindingEyes
                      ? null
                      : controller.detectEyesForCurrentImage,
                  icon: const Icon(CupertinoIcons.eye, size: 15),
                  label: const Text('Find Eyes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (isRegionMismatch)
                FilledButton.icon(
                  key: const Key('rejection_change_region_button'),
                  onPressed: controller.changeRegion,
                  icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 15),
                  label: Text(
                    (state.selectedRegion == AnatomicalRegion.eye ||
                            (state.errorMessage?.toLowerCase().contains(
                                  'gill',
                                ) ??
                                false))
                        ? 'Switch to Gill'
                        : 'Switch to Eye',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (isNetworkOrServer)
                FilledButton.icon(
                  key: const Key('rejection_try_again_button'),
                  onPressed: controller.classify,
                  icon: const Icon(CupertinoIcons.refresh, size: 15),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              OutlinedButton.icon(
                key: const Key('rejection_edit_crop_button'),
                onPressed: () {
                  controller.editCrop();
                  onAdjustCrop();
                },
                icon: const Icon(CupertinoIcons.crop, size: 14),
                label: const Text('Adjust crop'),
              ),
              OutlinedButton.icon(
                key: const Key('rejection_replace_image_button'),
                onPressed: controller.clearSelection,
                icon: const Icon(CupertinoIcons.photo, size: 14),
                label: const Text('Retake photo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
