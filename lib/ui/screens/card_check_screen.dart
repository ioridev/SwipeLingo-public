// import 'package:flutter/material.dart'; // unnecessary_import: 削除
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Slidable をインポート
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'; // Neumorphic UI
import 'package:go_router/go_router.dart'; // Navigation
import 'package:swipelingo/l10n/app_localizations.dart';

import '../../models/firebase_card_model.dart'; // FirebaseCardModel をインポート
import '../../providers/card_check_providers.dart'; // Provider をインポート
import '../../providers/home_providers.dart'; // home_providers をインポート
import '../widgets/difficulty_indicator.dart'; // DifficultyIndicator をインポート

class CardCheckScreen extends ConsumerWidget {
  // MiningScreen から生成されたカード候補リストを受け取る想定
  final List<FirebaseCardModel> generatedCards; // FirebaseCardModel に変更

  const CardCheckScreen({super.key, required this.generatedCards});

  // カードプレビュー用の BottomSheet を表示する関数
  void _showPreviewBottomSheet(BuildContext context, FirebaseCardModel card) {
    // FirebaseCardModel に変更
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(
                  context,
                )!.originalTextWithLanguage(card.sourceLanguage),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(card.front), // 変更: originalSentence -> front
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(
                  context,
                )!.translationWithLanguage(card.targetLanguage),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(card.back), // 変更: translatedSentence -> back
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // .family を使って Provider を初期化
    final provider = cardCheckNotifierProvider(generatedCards);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // 難易度でソート (difficulty が null の場合は最後に配置)
    final sortedCards = List<FirebaseCardModel>.from(state.generatedCards)
      ..sort((a, b) {
        if (a.difficulty == null && b.difficulty == null) return 0;
        if (a.difficulty == null) return 1; // a (null) を後ろに
        if (b.difficulty == null) return -1; // b (null) を後ろに
        return a.difficulty!.compareTo(b.difficulty!); // 順にする
      });

    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(
          AppLocalizations.of(context)!.selectConversationsToLearn(
            state.selectedCardIds.length,
            sortedCards.length,
          ),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 16),
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.selectAll,
            icon: const Icon(Icons.select_all),
            onPressed: notifier.selectAll,
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.deselectAll,
            icon: const Icon(Icons.deselect),
            onPressed: notifier.deselectAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: sortedCards.length,
              itemBuilder: (context, index) {
                final card = sortedCards[index];
                final isSelected = state.selectedCardIds.contains(card.id);

                return Slidable(
                  key: ValueKey(card.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed:
                            (_) => _showPreviewBottomSheet(context, card),
                        backgroundColor: NeumorphicTheme.accentColor(context),
                        foregroundColor: NeumorphicTheme.baseColor(context),
                        icon: Icons.visibility,
                        label: AppLocalizations.of(context)!.preview,
                      ),
                    ],
                  ),
                  child: Neumorphic(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    style: NeumorphicStyle(depth: isSelected ? -2 : 2),
                    child: CheckboxListTile(
                      title: Text(card.front), // maxLines削除
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(card.back), // maxLines削除
                          if (card.note != null && card.note!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Note: ${card.note}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        notifier.toggleCardSelection(card.id);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary:
                          card.difficulty != null
                              ? DifficultyIndicator(
                                // 変更: _DifficultyIndicator -> DifficultyIndicator
                                difficulty: card.difficulty!,
                              )
                              : null, // 難易度メーター
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalizations.of(context)!.aiGenerationNote,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      floatingActionButton: NeumorphicFloatingActionButton(
        tooltip: AppLocalizations.of(context)!.saveSelectedCardsTooltip,
        style: NeumorphicStyle(
          color:
              state.selectedCardIds.isEmpty
                  ? NeumorphicTheme.disabledColor(context) // 未選択時はグレーアウト
                  : NeumorphicTheme.accentColor(context),
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.circle(),
        ),
        onPressed: () async {
          if (state.selectedCardIds.isEmpty) {
            // チェックボックスがついていない状態で保存を押された場合
            final confirmCancel = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.confirmTitle),
                  content: Text(
                    AppLocalizations.of(
                      context,
                    )!.confirmCancelWithoutSavingMessage,
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.noButton),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.yesButton),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                    ),
                  ],
                );
              },
            );
            if (confirmCancel == true && context.mounted) {
              context.go('/'); // ホームに戻る
            }
            return; // 何も保存しない
          }

          // 通常の保存処理
          if (!context.mounted) return;
          try {
            await notifier.saveSelectedCards();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.cardsSavedSuccessfullySnackbar(
                    state.selectedCardIds.length,
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            );
            if (context.mounted) {
              ref.invalidate(dueCardCountProvider);
              context.go('/');
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                      context,
                    )!.cardSaveErrorSnackbar(e.toString()),
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        },
        child: Icon(
          Icons.save,
          color:
              state.selectedCardIds.isEmpty
                  ? Colors
                      .grey // 未選択時はアイコンもグレー
                  : NeumorphicTheme.baseColor(context),
        ), // 通常はベースカラー
      ),
    );
  }
}

// _DifficultyIndicator と _DifficultyPainter は difficulty_indicator.dart に移動したため削除
