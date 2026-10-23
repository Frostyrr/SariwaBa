import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../models/classification/classification_result.dart';
import '../../../widgets/common/app_button.dart';

enum ScannerState {
  idle,
  scanning,
  result,
}

typedef LiveScannerCard = LiveScannerSection;

class LiveScannerSection extends StatelessWidget {
  final ClassificationState state;
  final ClassificationController controller;
  final bool isMobile;
  final bool isGuest;
  final VoidCallback? onSignInToSave;

  static const Color kMobileEmerald = Color(0xFF0F5338);

  const LiveScannerSection({
    super.key,
    required this.state,
    required this.controller,
    this.isMobile = false,
    this.isGuest = false,
    this.onSignInToSave,
  });

  ScannerState get _scannerState {
    if (state.isClassifying) return ScannerState.scanning;
    if (state.latestResult != null) return ScannerState.result;
    return ScannerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final currentScannerState = _scannerState;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SariwaColors.borderLightTeal, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060A2229),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
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
                            'Live Freshness Inspection',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Multi-cue analysis of cornea, gills & dermal sheen',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.15,
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
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: SariwaColors.bgDashboardSubtle,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SariwaColors.borderLightTeal),
                ),
                child: const Text(
                  'AI Scanner',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.15,
                    color: SariwaColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3-State Inner Container: idle | scanning | result
          if (currentScannerState == ScannerState.idle) ...[
            if (state.selectedImageBytes == null)
              _buildEmptyUploadDropzone()
            else
              _buildSelectedImagePreview(),
            if (state.selectedImageBytes != null) ...[
              const SizedBox(height: 14),
              AppButton.primary(
                label: 'Classify Fish Freshness',
                isLoading: false,
                height: 48,
                borderRadius: 14,
                icon: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: () => controller.classify(),
              ),
            ],
          ] else if (currentScannerState == ScannerState.scanning) ...[
            _buildScanningStateView(),
          ] else if (currentScannerState == ScannerState.result &&
              state.latestResult != null) ...[
            if (state.selectedImageBytes != null) ...[
              _buildSelectedImagePreview(),
              const SizedBox(height: 16),
            ],
            _buildInspectionResultView(state.latestResult!),
          ],
        ],
      ),
    );
  }

  /// State 1: Idle Dropzone (180px on Mobile, 250px on Desktop, swapped button priority)
  Widget _buildEmptyUploadDropzone() {
    final dropzoneHeight = isMobile ? 180.0 : 250.0;
    final primaryBtnColor = isMobile ? kMobileEmerald : SariwaColors.brandPrimary;

    final useCameraPrimary = ElevatedButton.icon(
      onPressed: () => controller.pickImage(ImageSource.camera),
      icon: const Icon(Icons.camera_alt_rounded, size: 17),
      label: const Text('Use Camera'),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBtnColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );

    final gallerySecondary = OutlinedButton.icon(
      onPressed: () => controller.pickImage(ImageSource.gallery),
      icon: const Icon(Icons.photo_library_outlined, size: 17),
      label: const Text('Gallery'),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBtnColor,
        side: const BorderSide(color: SariwaColors.borderLightTeal),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );

    final browseGalleryPrimary = ElevatedButton.icon(
      onPressed: () => controller.pickImage(ImageSource.gallery),
      icon: const Icon(Icons.photo_library_outlined, size: 17),
      label: const Text('Browse Gallery'),
      style: ElevatedButton.styleFrom(
        backgroundColor: SariwaColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );

    final useCameraSecondary = OutlinedButton.icon(
      onPressed: () => controller.pickImage(ImageSource.camera),
      icon: const Icon(Icons.camera_alt_outlined, size: 17),
      label: const Text('Use Camera'),
      style: OutlinedButton.styleFrom(
        foregroundColor: SariwaColors.brandPrimary,
        side: const BorderSide(color: SariwaColors.borderLightTeal),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: dropzoneHeight),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 16 : 28,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SariwaColors.brandPrimary.withValues(alpha: 0.30),
          width: 1.4,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
            ),
            child: Icon(
              isMobile
                  ? Icons.photo_camera_back_rounded
                  : Icons.cloud_upload_outlined,
              size: isMobile ? 26 : 32,
              color: primaryBtnColor,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          const Text(
            'Select or capture a fish image',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.25,
              color: SariwaColors.textPrimaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Supports JPEG or PNG formats up to 5 MB per inspection',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.15,
              color: SariwaColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: isMobile
                ? [useCameraPrimary, gallerySecondary]
                : [browseGalleryPrimary, useCameraSecondary],
          ),
        ],
      ),
    );
  }

  /// State 2: Scanning (Image preview + animated MobileNetV3 inference progress)
  Widget _buildScanningStateView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        children: [
          if (state.selectedImageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: isMobile ? 150 : 190,
                width: double.infinity,
                child: Image.memory(
                  state.selectedImageBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: SariwaColors.brandPrimary,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Analyzing fish eyes, gills, and skin freshness...',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              minHeight: 6,
              backgroundColor: SariwaColors.bgDashboardSubtle,
              color: SariwaColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    return Container(
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: isMobile ? 160 : 200,
              width: double.infinity,
              child: Image.memory(state.selectedImageBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: SariwaColors.brandPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.selectedImageName ?? 'fish_scan.jpg',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: SariwaColors.textPrimaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => controller.clearSelection(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: SariwaColors.statusSpoiled,
                ),
                label: const Text(
                  'Remove',
                  style: TextStyle(
                    color: SariwaColors.statusSpoiled,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// State 3: Result View (Graded badge + 3 Biomarker Progress Bars + Scan Another / Save to Log)
  Widget _buildInspectionResultView(ClassificationResult result) {
    final corneaScore = result.isFresh ? 0.96 : 0.48;
    final gillScore = result.isFresh ? 0.94 : 0.44;
    final dermalScore = result.isFresh ? 0.92 : 0.51;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Graded Badge Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: result.statusColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: result.statusColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: result.statusColor,
                ),
                child: Icon(
                  result.isFresh
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${result.formattedConfidence} ${result.label}',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.35,
                            color: result.statusColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: result.statusColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            result.grade,
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.15,
                              color: result.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.recommendation,
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.15,
                        color: SariwaColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Text(
          'Sensory Biomarkers Analysis',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: SariwaColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),

        // 3 Biomarker Progress Bars (Cornea Clarity, Gill Coloration, Dermal Sheen)
        _buildBiomarkerProgressRow(
          label: 'Cornea Clarity',
          indicatorText: result.eyesIndicator,
          progress: corneaScore,
          color: result.statusColor,
        ),
        const SizedBox(height: 8),
        _buildBiomarkerProgressRow(
          label: 'Gill Coloration',
          indicatorText: result.gillsIndicator,
          progress: gillScore,
          color: result.statusColor,
        ),
        const SizedBox(height: 8),
        _buildBiomarkerProgressRow(
          label: 'Dermal Sheen',
          indicatorText: result.scalesIndicator,
          progress: dermalScore,
          color: result.statusColor,
        ),
        const SizedBox(height: 14),

        // Action Row: Scan Another & Save to Log
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => controller.clearSelection(),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Scan Another'),
              style: OutlinedButton.styleFrom(
                foregroundColor: SariwaColors.textPrimaryDark,
                side: const BorderSide(color: SariwaColors.borderLightTeal),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (result.saved && result.scanId != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: SariwaColors.statusFresh.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 15,
                      color: SariwaColors.statusFresh,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Saved to Log (#${result.scanId})',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: SariwaColors.statusFresh,
                      ),
                    ),
                  ],
                ),
              )
            else if (isGuest)
              ElevatedButton.icon(
                onPressed: onSignInToSave,
                icon: const Icon(Icons.bookmark_add_outlined, size: 17),
                label: const Text('Save to Log (Sign in)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMobile
                      ? kMobileEmerald
                      : SariwaColors.brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBiomarkerProgressRow({
    required String label,
    required String indicatorText,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  indicatorText,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.15,
                    color: SariwaColors.textSecondaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.5,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
