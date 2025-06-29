import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/mining_providers.dart';
import 'package:swipelingo/providers/subscription_provider.dart';
import 'package:swipelingo/providers/video_player_provider.dart'; // 新しいプロバイダーをインポート
import 'package:swipelingo/services/caption_service.dart';
import 'package:swipelingo/ui/widgets/dialogs_modals/caption_settings_modal.dart'; // 新しい共通モーダルをインポート

import 'package:swipelingo/ui/widgets/video_player_core_widget.dart'; // VideoPlayerCoreWidget をインポート
// import 'package:swipelingo/ui/widgets/video_viewer_app_bar.dart'; // VideoViewerAppBar をインポート (未使用なのでコメントアウト)
import 'package:swipelingo/ui/widgets/subtitle_area_widget.dart'; // SubtitleAreaWidget をインポート
import 'package:swipelingo/ui/widgets/action_buttons_panel_widget.dart'; // ActionButtonsPanelWidget をインポート
import 'package:swipelingo/ui/widgets/modals/related_videos_modal_widget.dart'; // RelatedVideosModalWidget をインポート
import 'package:swipelingo/ui/widgets/dialogs_modals/caption_tap_guide.dart'; // Caption Tap Guide をインポート
import 'package:swipelingo/ui/widgets/dialogs_modals/gem_consumption_confirm_dialog.dart'; // Gem Consumption Confirm Dialog をインポート
import 'package:swipelingo/ui/widgets/modals/paywall_modal_wrapper.dart'; // Paywall Modal Wrapper をインポート
import 'package:swipelingo/ui/widgets/dialogs_modals/word_meaning_dialog.dart'; // Word Meaning Dialog をインポート
import 'package:y_player/y_player.dart'; // YPlayerStatus を使用するためにインポート

class InAppVideoViewerScreen extends ConsumerStatefulWidget {
  // ★変更: ConsumerStatefulWidget
  final String videoUrl;
  const InAppVideoViewerScreen({super.key, required this.videoUrl});

  @override
  ConsumerState<InAppVideoViewerScreen> createState() => // ★追加
      _InAppVideoViewerScreenState();
}

class _InAppVideoViewerScreenState
    extends ConsumerState<InAppVideoViewerScreen> {
  // ★追加
  final bool _hasVideoEnded =
      false; // このフラグは残り時間での表示に変わるため、役割が変わるか不要になる可能性があります。
  bool _relatedVideosModalShown = false; // モーダルが一度表示されたかを管理するフラグ
  // final yt_explode.YoutubeExplode _ytExplode = yt_explode.YoutubeExplode(); // RelatedVideosModalWidget に移動
  // ProviderSubscription は VideoPlayerCoreWidget 内で管理されるか、別の方法でコントローラー準備を待つ

  @override
  void initState() {
    super.initState();
    _relatedVideosModalShown = false; // videoUrlが変わるたびにリセット
    // YoutubePlayerController関連の初期化はVideoPlayerCoreWidgetで行う
  }

  // _setupYoutubePlayerListener と _youtubePlayerListener は VideoPlayerCoreWidget に移行

  Future<void> _showRelatedVideosModal() async {
    print('--- _showRelatedVideosModal called (using new helper) ---');
    final currentVideoId =
        ref.read(videoPlayerNotifierProvider(widget.videoUrl)).videoId;
    if (currentVideoId == null) {
      print('Error in _showRelatedVideosModal: currentVideoId is null.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedToLoadRelatedVideos,
          ),
        ),
      );
      return;
    }
    // RelatedVideosModalWidget内のヘルパー関数を呼び出す
    await showRelatedVideosModal(context, currentVideoId);
    print('--- _showRelatedVideosModal (using new helper) finished ---');
  }

  // _fetchRelatedVideos は RelatedVideosModalWidget に移行

  @override
  void dispose() {
    // _ytExplode.close(); // RelatedVideosModalWidget に移動
    // _unlistenVideoPlayerProvider?.close(); // VideoPlayerCoreWidgetの管理方法による
    super.dispose();
  }

  // _showCaptionTapGuideIfNeeded は lib/ui/widgets/dialogs_modals/caption_tap_guide.dart に移動

  @override
  Widget build(BuildContext context) {
    // ★ WidgetRef ref を削除
    // Show caption tap guide on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _showCaptionTapGuideIfNeeded(context); // 古い呼び出しを削除
      showCaptionTapGuideIfNeeded(context); // 新しいヘルパー関数を呼び出し
    });

    final videoPlayerState = ref.watch(
      videoPlayerNotifierProvider(widget.videoUrl),
    ); // ★ widget.videoUrl
    final videoPlayerNotifier = ref.read(
      videoPlayerNotifierProvider(
        widget.videoUrl,
      ).notifier, // ★ widget.videoUrl
    );
    final isSubscribed = ref.watch(isSubscribedProvider);

    // playerControllerのリスナー設定は VideoPlayerCoreWidget で行う

    // Paywall display logic
    ref.listen<VideoPlayerState>(videoPlayerNotifierProvider(widget.videoUrl), (
      // ★ widget.videoUrl
      previous,
      next,
    ) {
      // Gem consumption confirmation dialog display logic
      if (next.shouldShowGemConsumptionConfirmDialog &&
          previous?.shouldShowGemConsumptionConfirmDialog != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showGemConsumptionConfirmDialog(context, widget.videoUrl);
        });
      }

      if (next.shouldShowPaywall && previous?.shouldShowPaywall != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showPaywallModal(context, widget.videoUrl);
        });
      }

      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        if (next.errorMessage ==
            AppLocalizations.of(context)!.invalidYouTubeUrl) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
            if (context.canPop()) {
              context.pop();
            }
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        }
      }
    });

    ref.listen<VideoPlayerState>(videoPlayerNotifierProvider(widget.videoUrl), (
      // ★ widget.videoUrl に修正
      previous,
      next,
    ) {
      if (next.showWordMeaningPopup && previous?.showWordMeaningPopup != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 現在の字幕と前の字幕を取得 (両方とも原文)
          String? originalCurrentCaptionText;
          if (next.currentCaptionIndex >= 0 &&
              next.displayCaptions.isNotEmpty &&
              next.currentCaptionIndex < next.displayCaptions.length) {
            originalCurrentCaptionText =
                next.displayCaptions[next.currentCaptionIndex].text;
          }

          String? previousCaptionText;
          if (next.currentCaptionIndex > 0 &&
              next.displayCaptions.isNotEmpty &&
              next.currentCaptionIndex - 1 < next.displayCaptions.length) {
            previousCaptionText =
                next.displayCaptions[next.currentCaptionIndex - 1].text;
          }

          showWordMeaningDialog(
            context: context,
            videoUrl: widget.videoUrl,
            tappedWord: next.tappedWord,
            tappedWordMeaning: next.tappedWordMeaning,
            currentSubtitle: originalCurrentCaptionText ?? '', // 現在の字幕 (原文)
            previousSubtitle: previousCaptionText, // 前の字幕 (原文)
          );
        });
      }
    });

    ref.listen<MiningState>(miningNotifierProvider, (previous, next) {
      final l10n = AppLocalizations.of(context)!;
      if (previous?.isLoading == true &&
          !next.isLoading &&
          (next.errorMessage == l10n.processingComplete ||
              next.errorMessage == 'Processing complete!') &&
          next.generatedCards.isNotEmpty) {
        context.push('/cards', extra: next.generatedCards);
      } else if (previous?.isLoading == true &&
          !next.isLoading &&
          next.errorMessage != null &&
          next.errorMessage != l10n.processingComplete &&
          next.errorMessage != 'Processing complete!') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    final miningState = ref.watch(miningNotifierProvider);

    if (false) {
      if (false) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: NeumorphicAppBar(title: Text(l10n.videoPlayerTitle)),
          body: const Center(child: CircularProgressIndicator()),
        );
      } else {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: NeumorphicAppBar(title: Text(l10n.videoPlayerTitle)),
          body: Center(
            child: Text(videoPlayerState.errorMessage ?? l10n.videoLoadFailed),
          ),
        );
      }
    }

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // appBar: VideoViewerAppBar( // AppBarを削除
      //   videoTitle: videoPlayerState.videoTitle,
      //   isSubscribed: isSubscribed,
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    videoPlayerNotifier.toggleControlsVisibility();
                  },
                  child: VideoPlayerCoreWidget(
                    videoUrl: widget.videoUrl,
                    onPlayerReady: (controller) {
                      // 必要に応じてコントローラーインスタンスを保持
                      // ただし、操作はVideoPlayerNotifierProvider経由で行うのが望ましい
                    },
                    onVideoProgress: (position, duration) {
                      if (duration > Duration.zero &&
                          position >= duration - const Duration(seconds: 10) &&
                          !_relatedVideosModalShown) {
                        print(
                          'Condition MET (from CoreWidget): remainingSeconds <= 10 && !_relatedVideosModalShown',
                        );
                        _showRelatedVideosModal();
                        if (mounted) {
                          setState(() {
                            _relatedVideosModalShown = true;
                          });
                        }
                      } else if (duration > Duration.zero &&
                          position < duration - const Duration(seconds: 10) &&
                          _relatedVideosModalShown) {
                        // 動画が巻き戻された場合などに対応
                        // if (mounted) {
                        //   setState(() {
                        //     _relatedVideosModalShown = false;
                        //   });
                        // }
                      }
                    },
                    onVideoEnded: (status) {
                      // 引数 status を追加
                      // 動画終了時の処理 (必要であれば)
                      // YPlayerStatus.stopped の場合のみ処理を実行するなど
                      if (status ==
                              ref
                                  .watch(
                                    videoPlayerNotifierProvider(
                                      widget.videoUrl,
                                    ),
                                  )
                                  .playerController
                                  ?.statusNotifier
                                  .value &&
                          status == YPlayerStatus.stopped) {
                        // YPlayerStatus.stopped をインポートまたは直接参照
                        // 例: _showRelatedVideosModal();
                      }
                    },
                  ),
                ),
                if ((videoPlayerState.areControlsVisible ?? false) ||
                    videoPlayerState.isLoadingCaptions ||
                    videoPlayerState.errorMessage != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      // Rowで囲んで複数のボタンを配置可能にする
                      children: [
                        NeumorphicButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                          style: const NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.circle(),
                            color: Colors.black54,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24.0,
                          ),
                        ),
                        const SizedBox(width: 8), // ボタン間のスペース
                        NeumorphicButton(
                          onPressed: () {
                            showCaptionSettingsModal(
                              context,
                              ref,
                              widget.videoUrl,
                            );
                          },
                          style: const NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.circle(),
                            color: Colors.black54,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [SubtitleAreaWidget(videoUrl: widget.videoUrl)],
                ),
              ),
            ),
            ActionButtonsPanelWidget(
              videoUrl: widget.videoUrl,
              onShowRelatedVideos: _showRelatedVideosModal,
            ),
          ],
        ),
      ),
    );
  }
}
