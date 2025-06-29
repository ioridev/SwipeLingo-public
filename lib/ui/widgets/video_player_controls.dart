// lib/ui/widgets/video_player_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/mining_providers.dart'; // MiningState をインポート
import 'package:swipelingo/providers/video_player_provider.dart';
import 'package:swipelingo/providers/subscription_provider.dart'; // Subscription provider をインポート
import 'package:swipelingo/services/caption_service.dart';
import 'package:swipelingo/ui/widgets/dialogs_modals/caption_settings_modal.dart'; // 新しい共通モーダルをインポート
import 'package:swipelingo/ui/widgets/gem_display_widget.dart'; // ジェム表示ウィジェット
import 'package:swipelingo/services/rewarded_ad_service.dart'; // リワード広告サービス
import 'package:swipelingo/providers/repository_providers.dart'; // FirebaseRepository provider

class VideoPlayerControls extends ConsumerWidget {
  final String videoUrl; // videoUrl を引数で受け取る

  const VideoPlayerControls({super.key, required this.videoUrl}); // コンストラクタを修正

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoPlayerState = ref.watch(videoPlayerNotifierProvider(videoUrl));
    final videoPlayerNotifier = ref.read(
      videoPlayerNotifierProvider(videoUrl).notifier,
    );
    final miningState = ref.watch(miningNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final isSubscribed = ref.watch(isSubscribedProvider); // 課金状況を取得
    final rewardedAdState = ref.watch(
      rewardedAdServiceProvider,
    ); // リワード広告の状態を取得

    return Container(
      color: NeumorphicTheme.of(context)!.current!.baseColor,
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 8.0,
        bottom:
            MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : 8.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeumorphicButton(
                  onPressed:
                      miningState.isLoading
                          ? null
                          : () {
                            if (videoPlayerState.currentCaptionIndex > 0) {
                              videoPlayerNotifier.seekToCaption(
                                videoPlayerState.currentCaptionIndex - 1,
                              );
                            } else if (videoPlayerState
                                .displayCaptions
                                .isNotEmpty) {
                              videoPlayerNotifier.seekToCaption(0);
                            }
                          },
                  child: const Icon(Icons.skip_previous),
                ),
                NeumorphicButton(
                  onPressed:
                      miningState.isLoading
                          ? null
                          : videoPlayerNotifier.playPause,
                  child: Icon(
                    videoPlayerState.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                NeumorphicButton(
                  onPressed:
                      miningState.isLoading
                          ? null
                          : () {
                            if (videoPlayerState.currentCaptionIndex <
                                videoPlayerState.displayCaptions.length - 1) {
                              videoPlayerNotifier.seekToCaption(
                                videoPlayerState.currentCaptionIndex + 1,
                              );
                            }
                          },
                  child: const Icon(Icons.skip_next),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左側の要素: ジェム表示 + ジェム獲得ボタン
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GemDisplayWidget(isSubscribed: isSubscribed),
                    if (rewardedAdState.isAdLoaded && !isSubscribed)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final adShownSuccessfully =
                                  await ref
                                      .read(rewardedAdServiceProvider.notifier)
                                      .showAd();
                              if (adShownSuccessfully) {
                                try {
                                  await ref
                                      .read(firebaseRepositoryProvider)
                                      .incrementUserGem();
                                  debugPrint(
                                    '[VideoPlayerControls] Gem incremented successfully after ad.',
                                  );
                                } catch (e) {
                                  debugPrint(
                                    '[VideoPlayerControls] Error incrementing gem: $e',
                                  );
                                }
                              } else {
                                debugPrint(
                                  '[VideoPlayerControls] Ad not shown successfully or skipped.',
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(15),
                            splashColor: Colors.amber.withOpacity(0.3),
                            highlightColor: Colors.amber.withOpacity(0.1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD54F),
                                    Color(0xFFFFB300),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add_circle,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.getMore,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                          offset: Offset(0.5, 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // 右側の要素: 設定アイコン + テキスト + スイッチ
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end, // テキストとスイッチを右寄せ
                  children: [
                    Text(l10n.showTranslatedSubtitles),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showCaptionSettingsModal(context, ref, videoUrl);
                          },
                          icon: Icon(
                            Icons.settings,
                            color:
                                NeumorphicTheme.of(
                                  context,
                                )!.current!.defaultTextColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeumorphicSwitch(
                          value: videoPlayerState.showNativeLanguageCaption,
                          onChanged:
                              miningState.isLoading
                                  ? null
                                  : (value) {
                                    videoPlayerNotifier
                                        .toggleNativeLanguageCaption(value);
                                  },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
