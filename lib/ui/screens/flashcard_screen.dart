import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart'; // Swiper をインポート
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'; // Neumorphic UI
import 'package:go_router/go_router.dart'; // Navigation
import 'package:swipelingo/l10n/app_localizations.dart';

import '../../providers/flashcard_providers.dart'; // インポートパスを更新
import '../widgets/flashcard_swiper_view.dart'; // 共通ウィジェットをインポート
import '../widgets/session_loading_indicator.dart'; // ローディングウィジェットをインポート

// StatefulWidget に変更して Controller を管理
class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  final CardSwiperController _swiperController =
      CardSwiperController(); // Controller を作成

  @override
  void dispose() {
    _swiperController.dispose(); // Controller を破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Add this line
    // ref は ConsumerState からアクセス
    final state = ref.watch(flashcardNotifierProvider); // Provider 名を更新
    final notifier = ref.read(
      flashcardNotifierProvider.notifier,
    ); // Provider 名を更新
    // final theme = NeumorphicTheme.currentTheme(context); // unused_local_variable: 削除

    // Listen for state changes (completion, errors, and index changes)
    ref.listen<FlashcardState>(flashcardNotifierProvider, (previous, next) {
      // State 名と Provider 名を更新
      // セッション完了 -> リザルト画面へ
      if (previous?.isSessionComplete == false &&
          next.isSessionComplete == true &&
          next.sessionResult != null) {
        debugPrint("Navigating to /result (from FlashcardScreen)..."); // デバッグ用
        context.go('/result', extra: next.sessionResult);
      }
      // エラーメッセージ表示 (完了メッセージは除く)
      else if (next.errorMessage != null &&
          !next.isSessionComplete &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      // 古い完了処理 (削除)
      // else if (previous?.isLoading == false && next.errorMessage == 'Review complete!') { ... }
    });

    // return Scaffold( // 不要な Scaffold 開始を削除
    //        SnackBar( // 不要な SnackBar を削除
    //          content: Text(next.errorMessage!),
    //          backgroundColor: Colors.redAccent,
    //        ),
    //      );
    //    }
    // }); // ref.listen の閉じ括弧は残す

    return Scaffold(
      // 正しい Scaffold 開始
      appBar: NeumorphicAppBar(
        title: state.dueCards.isNotEmpty
            ? Row(
                children: [
                  Text(
                    '${state.currentIndex + 1}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (state.currentIndex + 1) / state.dueCards.length,
                        backgroundColor: Colors.grey.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${state.dueCards.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              )
                : const Text('Swipelingo'), // カードがない場合はタイトルを表示
        centerTitle: false,
        actions: [
          // --- 削除ボタンを追加 ---
          if (state.currentCard != null) // カードがある場合のみ表示
            IconButton(
              tooltip: l10n.deleteCurrentCardTooltip,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final cardToDelete = state.currentCard;
                if (cardToDelete == null) return; //念のため

                // 確認ダイアログを表示
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(l10n.deleteCardTitle),
                      content: Text(
                        l10n.confirmDeleteCardMessage(cardToDelete.front),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(l10n.cancelButton),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: Text(l10n.deleteCardConfirmButtonLabel),
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
                        SnackBar(content: Text(l10n.cardDeletedSuccessMessage)),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.cardDeletionFailedMessage(e.toString()),
                          ),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          // --- 削除ボタンここまで ---
          // IconButton( // 再読み込みボタンを削除
          //   tooltip: 'カードを再読み込み',
          //   icon: const Icon(Icons.refresh),
          //   onPressed: notifier.refresh, // リロード機能
          // ),
        ],
      ),
      body: Builder(
        // Use Builder to get context for ScaffoldMessenger if needed inside body
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // isSessionComplete フラグも考慮
          if (state.dueCards.isEmpty &&
              !state.isLoading &&
              !state.isSessionComplete) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.noCardsToReviewMessage), // メッセージ修正
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed: () {
                      // 動画登録・マイニング画面へ遷移
                      context.push('/mining');
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      l10n.createCardsFromVideoButtonLabel,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed: () => context.go('/'),
                    child: Text(l10n.backToHomeButtonLabel),
                  ),
                ],
              ),
            );
          }

          // セッション完了時はローディング表示など (listen で遷移するため)
          if (state.isSessionComplete) {
            // 結果が実際に sessionResult にセットされてから遷移するので、
            // ここではローディングインジケーターを表示する
            return const SessionLoadingIndicator();
          }

          // 共通ウィジェットを使用
          return FlashcardSwiperView(
            cards: state.dueCards, // dueCards を渡す
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
