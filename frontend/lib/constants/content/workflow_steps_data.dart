import 'package:cupertino_ui/cupertino_ui.dart';

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
      'SariwaBa checks visual appearance only — it cannot confirm food safety.';

  static const List<WorkflowStepModel> steps = [
    WorkflowStepModel(
      id: 'capture_upload',
      stepNumber: '01',
      stepTag: '01',
      title: 'Take or Upload a Photo',
      summary: 'Snap a clear close-up in bright, even light.',
      detailedInstruction:
          'Shoot in bright light without harsh flash glare, or pick a JPG, PNG, or HEIC photo.',
      metaRecord: 'Photo',
      icon: CupertinoIcons.camera,
    ),
    WorkflowStepModel(
      id: 'anatomy_selection',
      stepNumber: '02',
      stepTag: '02',
      title: 'Frame the Eye or Gill',
      summary: 'Keep Auto on, or pick Eye or Gill directly.',
      detailedInstruction:
          'Show a whole eye or lift the gill cover so the red gill tissue is visible.',
      metaRecord: 'Region',
      icon: CupertinoIcons.crop_rotate,
    ),
    WorkflowStepModel(
      id: 'ai_classification',
      stepNumber: '03',
      stepTag: '03',
      title: 'Check Freshness',
      summary: 'Tap Check freshness for an instant reading.',
      detailedInstruction:
          'Tap Check freshness while connected to the internet to analyze the region.',
      metaRecord: 'Check',
      icon: CupertinoIcons.sparkles,
    ),
    WorkflowStepModel(
      id: 'understanding_results',
      stepNumber: '04',
      stepTag: '04',
      title: 'Read the Result',
      summary: 'See Fresh or Not Fresh with a confidence score.',
      detailedInstruction:
          'Confidence shows how clear the visual match is, not a food-safety guarantee.',
      metaRecord: 'Score',
      icon: CupertinoIcons.checkmark_seal,
    ),
    WorkflowStepModel(
      id: 'classification_history',
      stepNumber: '05',
      stepTag: '05',
      title: 'Review Past Scans',
      summary: 'Filter scans or export CSV reports in History.',
      detailedInstruction:
          'Sign in with Google to sync across devices, or keep recent guest scans locally.',
      metaRecord: 'History',
      icon: CupertinoIcons.time,
    ),
  ];
}
