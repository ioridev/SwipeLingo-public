// lib/ui/widgets/subtitle_display_widget.dart
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_transliterate/jp_transliterate.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/video_player_provider.dart'; // VideoPlayerNotifier をインポート
import 'package:swipelingo/providers/home_providers.dart'; // userProvider をインポート
import 'package:swipelingo/providers/ruby_text_provider.dart'; // rubyTextSettingProvider をインポート
import 'package:swipelingo/services/furigana_service.dart'; // FuriganaService をインポート
import 'package:swipelingo/providers/budoux_provider.dart'; // tinySegmenterProvider をインポート

class SubtitleDisplayWidget extends ConsumerWidget {
  final String captionText;
  final bool isTranslated;
  final String videoUrl; // VideoPlayerNotifier を取得するために videoUrl を追加

  const SubtitleDisplayWidget({
    super.key,
    required this.captionText,
    required this.isTranslated,
    required this.videoUrl, // videoUrl を必須パラメータに追加
  });

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
  Widget build(BuildContext context, WidgetRef ref) {
    // VideoPlayerNotifier を取得
    final videoPlayerNotifier = ref.read(
      videoPlayerNotifierProvider(videoUrl).notifier,
    );
    final videoPlayerState = ref.watch(videoPlayerNotifierProvider(videoUrl));
    final rubyTextSetting = ref.watch(rubyTextSettingProvider);
    final l10n = AppLocalizations.of(context)!;

    if (captionText.isEmpty) {
      return const SizedBox.shrink();
    }

    // 字幕がロード失敗または翻訳中の場合の表示
    if (!isTranslated && (videoPlayerState.errorMessage != null || 
        captionText == l10n.captionLoadFailed)) {
      return Column(
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
      );
    }

    // 翻訳字幕のエラーの場合
    if (isTranslated && videoPlayerState.errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            videoPlayerState.errorMessage!,
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
      );
    }

    if ((captionText == l10n.translating ||
            captionText == l10n.waitingForTranslation) &&
        isTranslated) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final List<String> words;
    final userModel = ref.watch(userProvider).asData?.value;
    final tinySegmenter = ref.watch(tinySegmenterProvider);

    // isTranslated が false であり、かつターゲット言語が日本語の場合のみ形態素解析を行う
    if (!isTranslated && userModel?.targetLanguageCode == 'ja') {
      words = tinySegmenter.segment(captionText);
    } else {
      // それ以外の場合は、従来通りスペースで分割
      words = captionText.split(' ');
    }

    final bool isJapaneseSubtitle =
        !isTranslated && userModel?.targetLanguageCode == 'ja';

    // ルビ表示が有効で、日本語字幕で、漢字が含まれている場合
    if (rubyTextSetting.value == true && 
        isJapaneseSubtitle && 
        FuriganaService.containsKanji(captionText)) {
      
      return FutureBuilder<Map<String, TransliterationData>>(
        future: _generateWordTransliterations(words),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError || 
              !snapshot.hasData) {
            // ローディング中、エラー、またはデータなしの場合は通常の表示
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 0.0,
              runSpacing: 4.0,
              children: words.map<Widget>((word) {
                if (word.isEmpty) return const SizedBox.shrink();
                
                return GestureDetector(
                  onTap: () {
                    videoPlayerNotifier.selectWord(word);
                  },
                  child: Text(
                    word,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: NeumorphicTheme.defaultTextColor(context),
                    ),
                  ),
                );
              }).toList(),
            );
          }
          
          final wordTransliterations = snapshot.data!;
          
          // 各単語を個別のタップ可能なウィジェットとして表示
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 0.0,
            runSpacing: 4.0,
            crossAxisAlignment: WrapCrossAlignment.end, // ベースラインを揃える
            children: words.map<Widget>((word) {
              if (word.isEmpty) return const SizedBox.shrink();
              
              final transliteration = wordTransliterations[word];
              
              return GestureDetector(
                onTap: () {
                  videoPlayerNotifier.selectWord(word);
                },
                child: transliteration != null && FuriganaService.containsKanji(word)
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 2.0), // ルビ付き文字の下部に少しパディング
                        child: TransliterationText(
                          transliterations: [transliteration],
                          style: TextStyle(
                            fontSize: 16.0,
                            color: NeumorphicTheme.defaultTextColor(context),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 8.0), // ルビなし文字の上部にパディングを追加してルビ分の高さを補正
                        child: Text(
                          word,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: NeumorphicTheme.defaultTextColor(context),
                          ),
                        ),
                      ),
              );
            }).toList(),
          );
        },
      );
    }

    // 通常の表示（ルビなし）
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isJapaneseSubtitle ? 0.0 : 4.0,
      runSpacing: 4.0,
      children:
          words.map<Widget>((word) {
            if (word.isEmpty) return const SizedBox.shrink();

            return GestureDetector(
              onTap: () {
                // VideoPlayerNotifier の selectWord を呼び出す
                videoPlayerNotifier.selectWord(word);
              },
              child: Text(
                word,
                style: TextStyle(
                  fontSize: 16.0,
                  color:
                      isTranslated
                          ? Colors
                              .blueAccent // 翻訳された字幕の文字色を少し変更
                          : NeumorphicTheme.defaultTextColor(context),
                ),
              ),
            );
          }).toList(),
    );
  }
}
