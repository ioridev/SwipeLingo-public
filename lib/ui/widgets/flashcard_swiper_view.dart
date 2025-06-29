import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
// import '../../models/card.dart' as models; // Hiveモデルは不要
import '../../models/firebase_card_model.dart'; // Firebase用モデルをインポート
import '../../providers/flashcard_providers.dart' show CardFace;
import './difficulty_indicator.dart'; // DifficultyIndicator をインポート
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:jp_transliterate/jp_transliterate.dart';
import '../../services/furigana_service.dart';
import '../../providers/ruby_text_provider.dart';
import '../../providers/budoux_provider.dart';
import '../../providers/home_providers.dart';

// 共通のカードスワイプUIウィジェット
class FlashcardSwiperView extends ConsumerStatefulWidget {
  final List<FirebaseCardModel> cards; // Firebaseモデルに変更
  final int currentIndex;
  final CardFace currentFace;
  final Function(bool) onSwipe; // スワイプ時のコールバック (bool: isCorrect)
  final Function() onFlip; // カードタップ時のコールバック
  final Function() onSpeak;
  final CardSwiperController controller;
  final String? thumbnailUrl; // サムネイルURLを引数に追加

  const FlashcardSwiperView({
    super.key,
    required this.cards,
    required this.currentIndex,
    required this.currentFace,
    required this.onSwipe,
    required this.onFlip,
    required this.onSpeak,
    required this.controller,
    this.thumbnailUrl, // コンストラクタに追加
  });

  @override
  ConsumerState<FlashcardSwiperView> createState() =>
      _FlashcardSwiperViewState();
}

class _FlashcardSwiperViewState extends ConsumerState<FlashcardSwiperView> {
  // CardSwiperController は StatefulWidget の外から渡されるため、ここでは管理しない

  // カードテキストをビルドするメソッド（ルビ対応）
  Widget _buildCardText(BuildContext context, String text, bool isFront) {
    final rubyTextSetting = ref.watch(rubyTextSettingProvider);
    final userModel = ref.watch(userProvider).asData?.value;
    final tinySegmenter = ref.watch(tinySegmenterProvider);
    
    // 表面で、日本語で、ルビ設定がONで、漢字が含まれている場合
    if (isFront && 
        userModel?.targetLanguageCode == 'ja' && 
        rubyTextSetting.value == true && 
        FuriganaService.containsKanji(text)) {
      
      final words = tinySegmenter.segment(text);
      
      return FutureBuilder<Map<String, TransliterationData>>(
        future: _generateWordTransliterations(words),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError || 
              !snapshot.hasData) {
            // ローディング中、エラー、またはデータなしの場合は通常の表示
            return Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NeumorphicTheme.defaultTextColor(context),
              ),
            );
          }
          
          final wordTransliterations = snapshot.data!;
          
          // ルビ付きテキストを表示
          return DefaultTextStyle(
            style: TextStyle(
              fontSize: 24.0, // ベースのフォントサイズ
              height: 1.6, // 行間を調整してルビのスペースを確保
              color: NeumorphicTheme.defaultTextColor(context), // テーマに応じた適切な色
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 0.0,
              runSpacing: 8.0,
              crossAxisAlignment: WrapCrossAlignment.end, // 下部（ベースライン）で揃える
              children: words.map<Widget>((word) {
                if (word.isEmpty) return const SizedBox.shrink();
                
                final transliteration = wordTransliterations[word];
                
                if (transliteration != null && FuriganaService.containsKanji(word)) {
                  // ルビ付きテキスト全体をスケールして、ルビを相対的に小さく見せる
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Transform.scale(
                      scale: 0.55, // 全体を55%のサイズに（もっと小さく）
                      alignment: Alignment.bottomCenter,
                      child: TransliterationText(
                        transliterations: [transliteration],
                        style: TextStyle(
                          fontSize: 44.0, // ベースのフォントサイズをさらに大きくして、スケール後に24相当に
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 2.0), // ルビなし文字の上部にパディングを追加してルビ分の高さを補正
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 24.0,
                        color: NeumorphicTheme.defaultTextColor(context),
                      ),
                    ),
                  );
                }
              }).toList(),
            ),
          );
        },
      );
    }
    
    // 通常のテキスト表示
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: NeumorphicTheme.defaultTextColor(context),
      ),
    );
  }
  
  // 各単語に対してTransliterationDataを生成
  Future<Map<String, TransliterationData>> _generateWordTransliterations(
      List<String> words) async {
    final Map<String, TransliterationData> result = {};
    
    for (final word in words) {
      if (word.isNotEmpty && FuriganaService.containsKanji(word)) {
        try {
          result[word] = await FuriganaService.generateTransliterationData(word);
        } catch (e) {
          // エラーの場合はスキップ
        }
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // state や notifier はここでは直接参照せず、引数で渡されたものを使用
    final cards = widget.cards;
    final currentIndex = widget.currentIndex;
    final currentFace = widget.currentFace;
    final onSwipe = widget.onSwipe;
    final onFlip = widget.onFlip;
    final onSpeak = widget.onSpeak;
    final controller = widget.controller;
    final thumbnailUrl = widget.thumbnailUrl; // 引数を取得

    // カードがない場合は空のコンテナを表示 (呼び出し元でハンドリングされる想定)
    if (cards.isEmpty || currentIndex >= cards.length) {
      return const Center(
        child: Text("表示するカードがありません。"),
      ); // Or an empty Container
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeumorphicTheme.baseColor(context),
            NeumorphicTheme.baseColor(context).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: CardSwiper(
            controller: controller, // 渡されたコントローラーを使用
            cardsCount: cards.length,
            initialIndex: currentIndex,
            numberOfCardsDisplayed: math.min(cards.length, 3),
            backCardOffset: const Offset(0, 30),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            cardBuilder: (
              context,
              index,
              percentThresholdX,
              percentThresholdY,
            ) {
              // インデックス範囲チェック
              if (index >= cards.length) {
                return Container(); // 範囲外なら空のコンテナ
              }
              final card = cards[index];
              // final isFront = currentFace == CardFace.front; // 古いロジックをコメントアウトまたは削除

              // index が現在のカードの index と一致する場合のみ widget.currentFace を使い、
              // それ以外（後ろに見えるカードなど）は常に表を表示する
              final bool displayAsFront;
              if (index == widget.currentIndex) {
                displayAsFront = widget.currentFace == CardFace.front;
              } else {
                displayAsFront = true; // 後ろのカードは常に表
              }

              // スワイプの進行度に基づいて色を計算
              final double swipeProgress =
                  percentThresholdX.abs().toDouble(); // スワイプ進行度 (0.0 ~ 1.0)
              final Color baseColor = NeumorphicTheme.baseColor(
                context,
              ); // Neumorphicの基本色
              final Color targetColor;
              if (percentThresholdX > 0) {
                // 右スワイプ (正解) -> 緑っぽく
                // 右スワイプ (正解) -> ボタンのアイコン色 (緑) に少し近づける
                targetColor =
                    Color.lerp(
                      baseColor,
                      const Color.fromARGB(255, 148, 235, 186), // ボタンアイコンの色
                      swipeProgress * 0.001, // 変化を穏やかに (10%程度)
                    )!;
              } else if (percentThresholdX < 0) {
                // 左スワイプ (不正解) -> 赤っぽく
                // 左スワイプ (不正解) -> ボタンのアイコン色 (赤) に少し近づける
                targetColor =
                    Color.lerp(
                      baseColor,
                      const Color.fromARGB(255, 219, 110, 214), // ボタンアイコンの色
                      swipeProgress * 0.001, // 変化を穏やかに (10%程度)
                    )!;
              } else {
                targetColor = baseColor; // スワイプしていない場合は基本色
              }

              return GestureDetector(
                onTap: onFlip, // コールバックを呼び出し
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Neumorphic(
                      style: NeumorphicStyle(
                        depth: 12,
                        intensity: 0.8,
                        surfaceIntensity: 0.2,
                        color:
                            NeumorphicTheme.isUsingDark(context)
                                ? targetColor // ダークモード時はスワイプに応じた色をそのまま使用
                                : Color.lerp(
                                  targetColor,
                                  Colors.grey.shade300,
                                  0.1,
                                ), // ライトモード時は少し暗くする
                        lightSource: LightSource.topLeft,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          NeumorphicTheme.baseColor(context),
                          NeumorphicTheme.baseColor(context).withValues(alpha: 0.9),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 8),
                        // メインテキスト
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: (displayAsFront
                                    ? Theme.of(context).textTheme.headlineMedium
                                    : Theme.of(context).textTheme.headlineSmall
                                )?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  height: 1.4,
                                ) ?? const TextStyle(),
                                child: _buildCardText(
                                  context,
                                  displayAsFront ? card.front : card.back,
                                  displayAsFront,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // サムネイル表示
                        if ((card.screenshotUrl != null &&
                                card.screenshotUrl!.isNotEmpty) ||
                            (thumbnailUrl != null && thumbnailUrl.isNotEmpty))
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl:
                                    (card.screenshotUrl != null &&
                                            card.screenshotUrl!.isNotEmpty)
                                        ? card.screenshotUrl!
                                        : thumbnailUrl!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, error, stackTrace) =>
                                    Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // 難易度表示
                        if (displayAsFront && card.difficulty != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DifficultyIndicator(
                              difficulty: card.difficulty!,
                            ),
                          ),
                        // Note表示
                        if (!displayAsFront &&
                            card.note != null &&
                            card.note!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                card.note!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        // インストラクションテキスト
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                displayAsFront ? Icons.touch_app : Icons.swipe,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                displayAsFront
                                    ? l10n.tapToSeeAnswer
                                    : l10n.swipeToRate,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // スワイプ方向を示すアイコンオーバーレイ
                if (index == widget.currentIndex && swipeProgress > 0.1)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: math.min(swipeProgress * 2, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: percentThresholdX > 0
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: 0.8 + (swipeProgress * 0.4),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: (percentThresholdX > 0
                                            ? Colors.green
                                            : Colors.red)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                percentThresholdX > 0
                                    ? Icons.check_rounded
                                    : Icons.close_rounded,
                                size: 60,
                                color: percentThresholdX > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
            onSwipe: (previousIndex, currentSwipeIndex, direction) {
              // currentSwipeIndex はスワイプ後のインデックス (null になることがある)
              bool correct = direction == CardSwiperDirection.right;
              onSwipe(correct); // コールバックを呼び出し
              // スワイプアニメーションは常に許可
              return true;
            },
            onUndo: (previousIndex, currentIndex, direction) {
              // Undo は無効化
              return false;
            },
            isLoop: false,
          ),
        ),
          // アクションボタン
          Container(
            margin: const EdgeInsets.fromLTRB(32, 16, 32, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 不正解ボタン
                _buildActionButton(
                  context: context,
                  onPressed: () => controller.swipe(CardSwiperDirection.left),
                  icon: Icons.close_rounded,
                  color: Colors.red,
                  label: l10n.incorrectButton,
                ),
                // TTS ボタン
                _buildActionButton(
                  context: context,
                  onPressed: onSpeak,
                  icon: Icons.volume_up_rounded,
                  color: Theme.of(context).primaryColor,
                  label: l10n.voiceButton,
                  isSecondary: true,
                ),
                // 正解ボタン
                _buildActionButton(
                  context: context,
                  onPressed: () => controller.swipe(CardSwiperDirection.right),
                  icon: Icons.check_rounded,
                  color: Colors.green,
                  label: l10n.correctButton,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required String label,
    bool isSecondary = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSecondary ? 56 : 64,
            height: isSecondary ? 56 : 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSecondary
                    ? [
                        NeumorphicTheme.baseColor(context),
                        NeumorphicTheme.baseColor(context).withValues(alpha: 0.8),
                      ]
                    : [
                        color.withValues(alpha: 0.1),
                        color.withValues(alpha: 0.2),
                      ],
              ),
              borderRadius: BorderRadius.circular(isSecondary ? 28 : 32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 8,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: isSecondary ? 24 : 28,
              color: isSecondary ? NeumorphicTheme.defaultTextColor(context) : color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
