import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/ui/widgets/subtitle_display_widget.dart';
import 'package:swipelingo/providers/video_player_provider.dart'; // VideoPlayerState を参照するため
import 'package:swipelingo/providers/mining_providers.dart'; // MiningState を参照するため

class SubtitleAreaWidget extends ConsumerWidget {
  final String videoUrl;
  // videoPlayerState と miningState は watch するので直接渡す必要はないかもしれないが、
  // このウィジェットが特定の videoUrl に紐づくことを明示するために videoUrl は渡す。
  // 親ウィジェットで watch した state を渡すパターンも考えられる。今回は Provider を直接 watch する。

  const SubtitleAreaWidget({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final videoPlayerState = ref.watch(videoPlayerNotifierProvider(videoUrl));
    final videoPlayerNotifier = ref.read(
      videoPlayerNotifierProvider(videoUrl).notifier,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child:
          videoPlayerState.isLoadingCaptions
              ? const Center(child: CircularProgressIndicator())
              : (videoPlayerState.errorMessage != null || 
                 videoPlayerState.currentCaptionText == l10n.captionLoadFailed)
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    videoPlayerState.errorMessage ?? l10n.captionLoadFailed,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16.0, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  NeumorphicButton(
                    onPressed: () {
                      videoPlayerNotifier.retryLoadCaptions();
                    },
                    child: Text(l10n.retryButton),
                  ),
                ],
              )
              : Column(
                // 字幕と翻訳字幕を縦に並べる
                children: [
                  SubtitleDisplayWidget(
                    captionText: videoPlayerState.currentCaptionText,
                    isTranslated: false,
                    videoUrl: videoUrl,
                  ),
                  if (videoPlayerState.showNativeLanguageCaption)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0), // 字幕間のスペース
                      child: SubtitleDisplayWidget(
                        captionText:
                            videoPlayerState.currentNativeLanguageCaptionText ??
                            '',
                        isTranslated: true,
                        videoUrl: videoUrl,
                      ),
                    ),
                ],
              ),
    );
  }
}
