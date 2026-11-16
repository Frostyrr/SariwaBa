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
      'SariwaBa? checks how a fish looks in a photo. It cannot confirm that a fish is safe to eat.';

  static const List<WorkflowStepModel> steps = [
    WorkflowStepModel(
      id: 'capture_upload',
      stepNumber: '01',
      stepTag: 'STEP 01 — CAPTURE OR UPLOAD',
      title: 'Capture or Upload a Fish Photo',
      summary:
          'Take a clear, focused photo of your fish in good lighting, or choose an existing photo (up to 5 MB) from your device.',
      detailedInstruction:
          'Upload a clear photo of a Tilapia eye or exposed gills. Choose a JPG, PNG, or HEIC image up to 5 MB.',
      metaRecord: 'CLEAR PHOTO • UP TO 5 MB',
      icon: CupertinoIcons.camera,
      practicalTips: [
        'Use bright, even lighting; avoid harsh camera flash glare on wet fish scales.',
        'Keep the camera steady so the photo stays sharp.',
        'Make the eye or exposed gills large enough to see clearly.',
      ],
    ),
    WorkflowStepModel(
      id: 'anatomy_selection',
      stepNumber: '02',
      stepTag: 'STEP 02 — CHOOSE PART',
      title: 'Choose Eye or Gills',
      summary:
          'Choose whether you want to inspect the fish eye (Mata) or the gills (Hasang). Focusing on one specific part gives you the most reliable check.',
      detailedInstruction:
          'Choose "Eye" for an eye photo or "Gill" for a photo of exposed gills. Match your selection to the photo.',
      metaRecord: 'EYE (MATA) • GILLS (HASANG)',
      icon: CupertinoIcons.crop_rotate,
      practicalTips: [
        'Include the whole eye in your photo.',
        'Lift the gill cover so the gills are clearly visible.',
        'Use the crop tool to frame the eye or gills.',
      ],
    ),
    WorkflowStepModel(
      id: 'ai_classification',
      stepNumber: '03',
      stepTag: 'STEP 03 — SMART SCAN',
      title: 'Check the Photo',
      summary:
          'SariwaBa? checks your photo and returns a Fresh or Not Fresh result.',
      detailedInstruction:
          'Select the check button and wait for your result. Keep your internet connection on.',
      metaRecord: 'PHOTO CHECK • INTERNET REQUIRED',
      icon: CupertinoIcons.sparkles,
      practicalTips: [
        'Wait for the check to finish before starting another scan.',
        'If the photo is unclear, try another photo with better lighting.',
        'Guests and signed-in users use the same photo checker.',
      ],
    ),
    WorkflowStepModel(
      id: 'understanding_results',
      stepNumber: '04',
      stepTag: 'STEP 04 — RESULTS',
      title: 'Understand Freshness & Confidence',
      summary:
          'See a Fresh or Not Fresh result and a confidence score.',
      detailedInstruction:
          'Confidence shows how strongly the checker favors its result. It is not a freshness grade or a guarantee of food safety.',
      metaRecord: 'RESULT • CONFIDENCE',
      icon: CupertinoIcons.checkmark_seal,
      practicalTips: [
        'The result applies to the photo you submitted.',
        'An unclear photo can affect the result.',
        'The app does not provide separate findings about eye color or gill texture.',
        'Even a high-confidence result cannot confirm food safety.',
      ],
    ),
    WorkflowStepModel(
      id: 'classification_history',
      stepNumber: '05',
      stepTag: 'STEP 05 — HISTORY',
      title: 'Review Your Scans',
      summary:
          'Sign in to review your saved scans across your devices.',
      detailedInstruction:
          'Open History to see saved photos, results, confidence scores, and dates. Search, filter, or delete scans there.',
      metaRecord: 'SAVED SCANS • HISTORY',
      icon: CupertinoIcons.time,
      practicalTips: [
        'Guests can review their latest 10 scans on this device.',
        'Sign in with Google to save future scans to your account.',
        'You can delete individual scans or clear your entire history at any time in Account Settings.',
      ],
    ),
  ];
}
