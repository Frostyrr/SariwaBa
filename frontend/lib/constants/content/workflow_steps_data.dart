import 'package:flutter/cupertino.dart';

class WorkflowStepModel {
  final String id;
  final String stepNumber;
  final String stepTag;
  final String title;
  final String summary;
  final String detailedInstruction;
  final String metaRecord;
  final IconData icon;
  final List<String> practicalTips;

  const WorkflowStepModel({
    required this.id,
    required this.stepNumber,
    required this.stepTag,
    required this.title,
    required this.summary,
    required this.detailedInstruction,
    required this.metaRecord,
    required this.icon,
    this.practicalTips = const [],
  });
}

class WorkflowStepsData {
  const WorkflowStepsData._();

  static const String preliminaryDisclaimer =
      'SariwaBa? provides an AI-assisted visual freshness assessment and does not guarantee food safety, microbiological sterility, or absolute suitability for consumption. Always exercise organoleptic judgment and culinary prudence before preparing or eating seafood.';

  static const List<WorkflowStepModel> steps = [
    WorkflowStepModel(
      id: 'capture_upload',
      stepNumber: '01',
      stepTag: 'STEP 01 — CAPTURE OR UPLOAD',
      title: 'Capture or Upload a Fish Photo',
      summary:
          'Take a clear, focused photo of your fish in good lighting, or choose an existing photo (up to 5 MB) from your device.',
      detailedInstruction:
          'Position your camera 15–30 cm away from the fish. Tap or drag the image into the inspection zone. The system accepts JPG, JPEG, PNG, and HEIC files up to 5 MB with resolutions between 32x32 and 4096x4096 px.',
      metaRecord: 'CLEAR PHOTO • UP TO 5 MB',
      icon: CupertinoIcons.camera,
      practicalTips: [
        'Use bright, even lighting; avoid harsh camera flash glare on wet fish scales.',
        'Keep the camera steady to prevent motion blur and optical distortion.',
        'Ensure the anatomical feature fills at least 40% of the camera viewfinder.',
      ],
    ),
    WorkflowStepModel(
      id: 'anatomy_selection',
      stepNumber: '02',
      stepTag: 'STEP 02 — CHOOSE PART',
      title: 'Select Eye or Gill Region',
      summary:
          'Choose whether you want to inspect the fish eye (Mata) or the gills (Hasang). Focusing on one specific part gives you the most reliable check.',
      detailedInstruction:
          'Select "Eye" (default) to evaluate cornea transparency, pupil clarity, and sunkenness. Select "Gill" to evaluate branchial filament redness, slime consistency, and pallor.',
      metaRecord: 'EYE (MATA) • GILLS (HASANG)',
      icon: CupertinoIcons.crop_rotate,
      practicalTips: [
        'For Eye checks, photograph the whole cornea without cutting off the eye socket.',
        'For Gill checks, gently lift the opercular gill cover to expose the red gill filaments.',
        'Use the built-in ROI crop tool to precisely frame the targeted anatomical feature.',
      ],
    ),
    WorkflowStepModel(
      id: 'ai_classification',
      stepNumber: '03',
      stepTag: 'STEP 03 — SMART SCAN',
      title: 'AI Freshness Inference',
      summary:
          'Our smart AI examines key freshness signs in seconds—checking color vibrancy, clarity, and texture to see if the fish is fresh.',
      detailedInstruction:
          'The image is processed by our server-side MobileNetV3-Small neural network trained specifically on Tilapia organoleptic datasets, extracting high-level chromatic and textural feature representations.',
      metaRecord: 'INSTANT SCAN • COLOR & CLARITY',
      icon: CupertinoIcons.sparkles,
      practicalTips: [
        'Inference completes in approximately 30–60 milliseconds.',
        'No image alterations or destructive filters are applied during tensor normalization.',
        'Both guest and authenticated inspectors benefit from the same high-accuracy model.',
      ],
    ),
    WorkflowStepModel(
      id: 'understanding_results',
      stepNumber: '04',
      stepTag: 'STEP 04 — RESULTS',
      title: 'Understand Freshness & Confidence',
      summary:
          'Get a clear Fresh or Not Fresh verdict along with a confidence rating and practical advice on what to look for when buying.',
      detailedInstruction:
          'The model outputs a binary verdict ("Fresh" or "Not Fresh") accompanied by a confidence score (0%–100%). Scores above 85% indicate high certainty based on recognized optical freshness indicators.',
      metaRecord: 'CONFIDENCE SCORE • BUYER TIPS',
      icon: CupertinoIcons.checkmark_seal,
      practicalTips: [
        'Fresh Eye: Transparent, convex cornea with deep black pupil.',
        'Not Fresh Eye: Cloudy, sunken cornea with milky or dull pupil.',
        'Fresh Gill: Bright red or vibrant pink lamellae with clean, transparent mucus.',
        'Not Fresh Gill: Brownish, grey, or bleached filaments with turbid mucus and sour odor.',
      ],
    ),
    WorkflowStepModel(
      id: 'classification_history',
      stepNumber: '05',
      stepTag: 'STEP 05 — HISTORY & AUDITS',
      title: 'Review Classification History',
      summary:
          'Authenticated users can access, search, and manage their complete historical classification records across all their devices.',
      detailedInstruction:
          'Authenticated scans are securely linked to your account. View timestamps, confidence metrics, and original inspection photos in the History tab. You can filter by Freshness status, review individual details, or bulk delete records.',
      metaRecord: 'CLOUD SYNC • AUDIT HISTORY',
      icon: CupertinoIcons.time,
      practicalTips: [
        'Guest users have access to a local session cache of their last 10 scans.',
        'Sign in with Google to permanently preserve and cloud-sync your classification audit trail.',
        'You can delete individual scans or clear your entire history at any time in Account Settings.',
      ],
    ),
  ];
}
