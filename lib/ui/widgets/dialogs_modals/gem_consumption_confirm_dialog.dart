import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/video_player_provider.dart';

class GemConsumptionConfirmDialog extends ConsumerWidget {
  final String videoUrl;

  const GemConsumptionConfirmDialog({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final videoPlayerNotifier = ref.read(
      videoPlayerNotifierProvider(videoUrl).notifier,
    );

    return AlertDialog(
      title: Text(l10n.confirmDialogTitle),
      content: Text(l10n.gemConsumptionConfirmation),
      actions: <Widget>[
        TextButton(
          child: Text(l10n.noButton),
          onPressed: () {
            Navigator.of(context).pop();
            videoPlayerNotifier.resetShowGemConsumptionConfirmDialog();
          },
        ),
        TextButton(
          child: Text(l10n.yesButton),
          onPressed: () {
            videoPlayerNotifier.confirmAndConsumeGemForTranslation();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// Helper function to show the dialog
Future<void> showGemConsumptionConfirmDialog(
  BuildContext context,
  String videoUrl,
) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return GemConsumptionConfirmDialog(videoUrl: videoUrl);
    },
  );
}
