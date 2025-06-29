import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';

import '../../providers/mining_providers.dart'; // MiningState を参照するため
import '../../providers/repository_providers.dart';
import '../../models/user_model.dart';

class VideoUrlInputField extends ConsumerWidget {
  final TextEditingController urlController;
  final Function(String) onUrlChanged;
  final VoidCallback onPaste;
  final bool isLoading;
  final String? errorMessage;

  const VideoUrlInputField({
    super.key,
    required this.urlController,
    required this.onUrlChanged,
    required this.onPaste,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userModel = ref.watch(userDocumentProvider).value;

    String hintText = l10n.enterVideoUrlWithEnglishSubtitles; // デフォルト
    if (userModel != null) {
      if (userModel.targetLanguageCode == 'ja') {
        hintText = l10n.enterVideoUrlWithJapaneseSubtitles; // 新規キー
      }
    }

    // MiningScreen から errorMessage の判定ロジックを流用
    final showError =
        errorMessage != null &&
        errorMessage != 'Processing complete!' &&
        errorMessage != '処理完了！' &&
        errorMessage != l10n.fetchingVideoInfoCaptions &&
        errorMessage != l10n.requestingCardGenerationJa &&
        errorMessage != l10n.processingGeneratedCards &&
        !isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hintText, style: TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Neumorphic(
                child: TextField(
                  controller: urlController,
                  onChanged: onUrlChanged,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: l10n.youtubeVideoUrl,
                    hintText: hintText, // ここを修正
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.url,
                ),
              ),
            ),
            const SizedBox(width: 8),
            NeumorphicButton(
              padding: const EdgeInsets.all(12.0),
              style: const NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
              ),
              onPressed: isLoading ? null : onPaste,
              tooltip: l10n.pasteFromClipboard,
              child: const Icon(Icons.content_paste, size: 20),
            ),
          ],
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.redAccent[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
