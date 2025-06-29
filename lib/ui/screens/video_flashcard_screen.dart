import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import '../../providers/video_flashcard_providers.dart'; // 作成した Provider をインポート
import '../../providers/flashcard_providers.dart'
    show CardFace; // CardFace enum をインポート (コメント削除)
import '../../models/session_result.dart'; // SessionResult をインポート
import '../widgets/flashcard_swiper_view.dart'; // 共通ウィジェットをインポート
import '../widgets/session_loading_indicator.dart'; // ローディングウィジェットをインポート

// 既存の FlashcardScreen をベースにするか、新規作成するか検討
// ここでは新規作成とする

// StatefulWidget に変更して Controller を管理
class VideoFlashcardScreen extends ConsumerStatefulWidget {
  final String videoId;

  const VideoFlashcardScreen({super.key, required this.videoId});

  @override
  ConsumerState<VideoFlashcardScreen> createState() =>
      _VideoFlashcardScreenState();
}

class _VideoFlashcardScreenState extends ConsumerState<VideoFlashcardScreen> {
  final CardSwiperController _swiperController =
      CardSwiperController(); // Controller を作成

  @override
  void dispose() {
    _swiperController.dispose(); // Controller を破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref は ConsumerState からアクセス
    // .family を使って Provider を初期化・監視
    final provider = videoFlashcardNotifierProvider(
      widget.videoId,
    ); // widget.videoId を使用
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // Listen for completion or errors
    ref.listen<VideoFlashcardState>(provider, (previous, next) {
      // セッション完了 -> リザルト画面へ
      if (previous?.isSessionComplete == false &&
          next.isSessionComplete == true &&
          next.sessionResult != null) {
        debugPrint(
          "Navigating to /result (from VideoFlashcardScreen)...",
        ); // デバッグ用
        // 現在の画面を置き換える形で遷移 (戻るボタンで戻らないように)
        context.pushReplacement('/result', extra: next.sessionResult);
      }
      // エラーメッセージ表示 (完了メッセージは除く)
      else if (next.errorMessage != null &&
          !next.isSessionComplete &&
          previous?.errorMessage != next.errorMessage) {
        // mounted チェックを追加
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    });

    // 不要な Scaffold と SnackBar を削除 (L45-L52)

    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(
          state.videoTitle.isNotEmpty
              ? state.videoTitle
              : AppLocalizations.of(context)!.videoFlashcardsTitle,
        ), // 動画タイトル表示
        actions: [
          // --- 削除ボタンを追加 ---
          if (state.currentCard != null) // カードがある場合のみ表示
            IconButton(
              tooltip:
                  AppLocalizations.of(context)!.deleteCurrentVideoCardTooltip,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final cardToDelete = state.currentCard;
                if (cardToDelete == null) return;

                // 確認ダイアログを表示 (flashcard_screen.dart と同様)
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!.deleteVideoCardDialogTitle,
                      ),
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.deleteVideoCardDialogContent(cardToDelete.front),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.videoFlashcardCancelButtonLabel,
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.videoFlashcardDeleteButtonLabel,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );

                // ユーザーが削除を確認した場合
                if (confirm == true) {
                  try {
                    // Provider の deleteCurrentCard メソッドを呼び出す
                    await notifier.deleteCurrentCard();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.videoCardDeletedSuccessfullySnackbar,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.videoCardDeletionFailedSnackbar(e.toString()),
                          ),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          // --- 削除ボタンここまで ---
          // IconButton( // 再読み込みボタンは削除済み
          // ),
        ],
      ),
      body: Builder(
        // Use Builder for ScaffoldMessenger context
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // isSessionComplete フラグも考慮
          if (state.videoCards.isEmpty &&
              !state.isLoading &&
              !state.isSessionComplete) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.noCardsFoundForThisVideo,
                  ), // メッセージ修正
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed:
                        () => context.push('/videos'), // Go back to video list
                    child: Text(
                      AppLocalizations.of(context)!.backToVideoListButtonLabel,
                    ),
                  ),
                ],
              ),
            );
          }

          // セッション完了時はローディング表示など (listen で遷移するため)
          if (state.isSessionComplete) {
            return const SessionLoadingIndicator();
          }

          // 共通ウィジェットを使用
          return FlashcardSwiperView(
            cards: state.videoCards, // videoCards を渡す
            currentIndex: state.currentIndex,
            currentFace: state.currentFace,
            onSwipe: notifier.handleSwipe, // Notifier のメソッドを渡す
            onFlip: notifier.flipCard,
            onSpeak: notifier.speakCurrentCard,
            controller: _swiperController,
            thumbnailUrl: state.currentVideoThumbnailUrl, // サムネイルURLを渡す
          );
        },
      ),
    );
  }
}
