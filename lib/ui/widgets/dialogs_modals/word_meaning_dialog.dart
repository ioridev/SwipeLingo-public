import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/video_player_provider.dart';
import 'package:swipelingo/services/summary_service.dart';
import '../../../providers/repository_providers.dart'; // userDocumentProvider のため
import '../../../models/user_model.dart'; // UserModel のため
import 'dart:ui' as ui;

// SummaryServiceのProvider
final summaryServiceProvider = Provider((ref) => SummaryService());

class WordMeaningDialog extends ConsumerStatefulWidget {
  final String videoUrl;
  final String? tappedWord;
  final String? tappedWordMeaning;
  final String currentSubtitle; // 現在の字幕
  final String? previousSubtitle; // 1つ前の字幕 (オプショナル)

  const WordMeaningDialog({
    super.key,
    required this.videoUrl,
    this.tappedWord,
    this.tappedWordMeaning,
    required this.currentSubtitle,
    this.previousSubtitle,
  });

  @override
  ConsumerState<WordMeaningDialog> createState() => _WordMeaningDialogState();
}

class _WordMeaningDialogState extends ConsumerState<WordMeaningDialog> {
  bool _isLoadingAiExplanation = false;

  Future<void> _fetchAiExplanation() async {
    if (widget.tappedWord == null || widget.tappedWord!.isEmpty) {
      return;
    }

    // previousSubtitle と currentSubtitle を結合
    String contextSentence;
    if (widget.previousSubtitle != null &&
        widget.previousSubtitle!.isNotEmpty) {
      contextSentence = "${widget.previousSubtitle}\n${widget.currentSubtitle}";
    } else {
      contextSentence = widget.currentSubtitle;
    }

    setState(() {
      _isLoadingAiExplanation = true;
    });

    final l10n = AppLocalizations.of(context)!;
    final userModel = ref.read(userDocumentProvider).value;
    final summaryService = ref.read(summaryServiceProvider);

    String wordLangCode = 'en'; // デフォルトは英語
    String nativeLangCode = 'ja'; // デフォルトは日本語

    if (userModel != null) {
      wordLangCode = userModel.targetLanguageCode;
      nativeLangCode = userModel.nativeLanguageCode;
    }

    try {
      final explanation = await summaryService.getWordExplanation(
        widget.tappedWord!,
        contextSentence, // 結合した字幕情報を渡す
        wordLangCode,
        nativeLangCode,
      );
      if (mounted) {
        setState(() {
          _isLoadingAiExplanation = false;
        });
        // ignore: use_build_context_synchronously
        _showAiExplanationModal(explanation);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAiExplanation = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.aiExplanationError)));
      }
    }
  }

  void _showAiExplanationModal(String explanation) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ドラッグハンドル
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // ヘッダー部分
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF8B5CF6),
                                                Color(0xFF7C3AED),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF8B5CF6)
                                                    .withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.aiExplanationModalTitle(
                                                  widget.tappedWord ?? '',
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'AI が詳しく解説します',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withOpacity(0.6),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // 説明文コンテンツ
                            Expanded(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.1),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        controller: scrollController,
                                        physics: const BouncingScrollPhysics(),
                                        child: SelectableText(
                                          explanation,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                height: 1.6,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 閉じるボタン
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF3B82F6),
                                          Color(0xFF2563EB),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF3B82F6)
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => Navigator.of(context).pop(),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Center(
                                          child: Text(
                                            l10n.closeButton,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userModel = ref.watch(userDocumentProvider).value;
    // final videoPlayerNotifier = ref.read(
    //   videoPlayerNotifierProvider(widget.videoUrl).notifier,
    // );

    String wordLangName = ''; // タップされた単語の言語 (学習対象言語)
    String meaningLangName = ''; // 表示される意味の言語 (母語)

    if (userModel != null) {
      if (userModel.targetLanguageCode == 'ja') {
        // 日本語学習者
        wordLangName = l10n.languageNameJapanese;
        meaningLangName = l10n.languageNameEnglish;
      } else {
        // 英語学習者 (targetLanguageCode == 'en' またはデフォルト)
        wordLangName = l10n.languageNameEnglish;
        meaningLangName = l10n.languageNameJapanese;
      }
    } else {
      // フォールバック (ユーザー情報がない場合)
      // word (引数) が英語、meaning (引数) が日本語と仮定
      wordLangName = l10n.languageNameEnglish;
      meaningLangName = l10n.languageNameJapanese;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 10,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // タイトル部分
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF10B981),
                                      Color(0xFF059669),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.translate,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.wordMeaningPopupTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // 単語セクション
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(20 * (1 - value), 0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.wordLabelWithLanguage(wordLangName),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.tappedWord ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // 意味セクション
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(20 * (1 - value), 0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.meaningLabelWithLanguage(
                                              meaningLangName),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.tappedWordMeaning ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // アクションボタン
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_isLoadingAiExplanation)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF8B5CF6),
                                              Color(0xFF7C3AED),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF8B5CF6)
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: (widget.tappedWord == null ||
                                                    widget.tappedWord!.isEmpty)
                                                ? null
                                                : _fetchAiExplanation,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.auto_awesome,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    l10n.aiExplainButton,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(width: 12),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: Text(l10n.closeButton),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper function to show the dialog with animation
Future<void> showWordMeaningDialog({
  required BuildContext context,
  required String videoUrl,
  required String? tappedWord,
  required String? tappedWordMeaning,
  required String currentSubtitle, // 現在の字幕
  String? previousSubtitle, // 1つ前の字幕 (オプショナル)
}) async {
  final videoPlayerNotifier = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(videoPlayerNotifierProvider(videoUrl).notifier);

  await showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return WordMeaningDialog(
        videoUrl: videoUrl,
        tappedWord: tappedWord,
        tappedWordMeaning: tappedWordMeaning,
        currentSubtitle: currentSubtitle,
        previousSubtitle: previousSubtitle,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
    barrierDismissible: true,
    barrierLabel: 'Word Meaning',
    barrierColor: Colors.black.withOpacity(0.5),
  ).then((_) {
    // ダイアログが閉じた後に実行
    if (ProviderScope.containerOf(
      context,
      listen: false,
    ).read(videoPlayerNotifierProvider(videoUrl)).showWordMeaningPopup) {
      videoPlayerNotifier.dismissWordMeaningPopup();
    }
  });
}
