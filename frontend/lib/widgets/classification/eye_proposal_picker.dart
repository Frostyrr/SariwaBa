import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../services/classification/classification_service.dart';

Future<EyeCropProposal?> showEyeProposalPicker(
  BuildContext context,
  Uint8List photo,
  List<EyeCropProposal> proposals,
) {
  return showDialog<EyeCropProposal>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Choose an eye on the photo'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 440),
        child: Stack(
          children: [
            Image.memory(photo),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    for (final (index, proposal) in proposals.indexed)
                      Positioned(
                        left: (proposal.eyeCenter.dx * constraints.maxWidth - 20)
                            .clamp(0.0, (constraints.maxWidth - 40).clamp(0.0, double.infinity)),
                        top: (proposal.eyeCenter.dy * constraints.maxHeight - 20)
                            .clamp(0.0, (constraints.maxHeight - 40).clamp(0.0, double.infinity)),
                        child: IconButton.filled(
                          tooltip: 'Choose eye ${index + 1}',
                          onPressed: () => Navigator.of(dialogContext).pop(proposal),
                          icon: const Icon(Icons.remove_red_eye_outlined),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Crop manually'),
        ),
      ],
    ),
  );
}
