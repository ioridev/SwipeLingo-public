// lib/ui/widgets/generate_flashcards_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/mining_providers.dart';
import 'package:swipelingo/providers/video_player_provider.dart';

class GenerateFlashcardsButton extends ConsumerWidget {
  final String videoUrl;

  const GenerateFlashcardsButton({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoPlayerState = ref.watch(videoPlayerNotifierProvider(videoUrl));
    final miningState = ref.watch(miningNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return NeumorphicButton(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color:
            NeumorphicTheme.currentTheme(
              context,
            ).accentColor, // 背景色をアクセントカラーに設定
      ),
      onPressed:
          miningState.isLoading || videoPlayerState.isLoadingCaptions
              ? null
              : () {
                if (videoPlayerState.videoId == null ||
                    videoPlayerState.sourceEnglishCaptions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.noVideoInfoOrCaptions)),
                  );
                  return;
                }
                if (videoPlayerState.videoTitle.isEmpty ||
                    videoPlayerState.videoTitle == l10n.videoTitleUnknown) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.failedToGetVideoTitle)),
                  );
                  return;
                }

                debugPrint(
                  l10n.startingFlashcardGenerationWithIdAndTitle(
                    videoPlayerState.videoId ?? 'null',
                    videoPlayerState.videoTitle,
                  ),
                );
                if (videoPlayerState.videoId != null &&
                    videoPlayerState.sourceEnglishCaptions.isNotEmpty &&
                    videoPlayerState.videoTitle.isNotEmpty &&
                    videoPlayerState.videoTitle != l10n.videoTitleUnknown) {
                  ref
                      .read(miningNotifierProvider.notifier)
                      .generateFlashcardsFromCaptions(
                        videoPlayerState.sourceEnglishCaptions,
                        videoPlayerState.videoId!,
                        videoPlayerState.videoTitle,
                      );
                } else {
                  debugPrint(
                    l10n.missingInfoForFlashcardGeneration(
                      videoPlayerState.videoId ?? 'null',
                      videoPlayerState.sourceEnglishCaptions.isEmpty.toString(),
                      videoPlayerState.videoTitle,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.missingInfoReloadVideo)),
                  );
                }
              },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_fix_high, // 魔法の杖のアイコン
            color:
                NeumorphicTheme.isUsingDark(context)
                    ? Colors
                        .black // ダークモード時は黒
                    : Colors.white, // ライトモード時は白
          ),
          const SizedBox(width: 8.0),
          Text(
            miningState.isLoading
                ? (miningState.errorMessage ?? l10n.generatingFlashcards)
                : l10n.generateFlashcardsFromThisVideoButton,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  NeumorphicTheme.isUsingDark(context)
                      ? Colors
                          .black // ダークモード時は黒
                      : Colors.white, // ライトモード時は白
            ),
          ),
        ],
      ),
    );
  }
}
