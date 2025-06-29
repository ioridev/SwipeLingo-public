// lib/ui/widgets/create_card_from_subtitle_button.dart
import 'dart:typed_data'; // Uint8List のために追加
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    as yt_explode; // 追加
import 'package:swipelingo/models/firebase_card_model.dart';
import 'package:swipelingo/providers/repository_providers.dart';
import 'package:swipelingo/providers/video_player_provider.dart';
// import 'package:translator/translator.dart'; // _translateText は VideoPlayerNotifier 側にある想定なので不要かも
import 'package:swipelingo/services/caption_service.dart'; // CaptionService を使う場合
import 'package:uuid/uuid.dart';
// y_player と media_kit のインポートは video_player_provider 経由で解決されることを期待
// 必要であれば、YPlayerController と Player の具体的な型に合わせて追加する
// import 'package:y_player/y_player.dart'; // 例: YPlayerController のため
// import 'package:media_kit/media_kit.dart'; // 例: Player のため

class CreateCardFromSubtitleButton extends ConsumerStatefulWidget {
  final String videoUrl;

  const CreateCardFromSubtitleButton({super.key, required this.videoUrl});

  @override
  ConsumerState<CreateCardFromSubtitleButton> createState() =>
      _CreateCardFromSubtitleButtonState();
}

class _CreateCardFromSubtitleButtonState
    extends ConsumerState<CreateCardFromSubtitleButton> {
  bool _isProcessingCardCreation = false; // ボタン自体の処理中フラグ
  Uint8List? _capturedScreenshotBytes; // スクリーンショットのバイトデータ

  // 翻訳処理は CaptionService を介して行うことを検討
  Future<String> _fetchBackTextForDialog(
    BuildContext context,
    VideoPlayerState videoPlayerState,
    String userNativeLanguageCode,
    String fallbackText,
  ) async {
    if (videoPlayerState.currentCaptionIndex < 0 ||
        videoPlayerState.currentCaptionIndex >=
            videoPlayerState.displayCaptions.length) {
      return fallbackText; // Or empty string
    }

    final originalCaptionForCardFront =
        videoPlayerState
            .displayCaptions[videoPlayerState.currentCaptionIndex]
            .text;
    final originalLanguageOfDisplayCaption =
        videoPlayerState.displayLanguageCode;

    // 2. 機械翻訳を行う (displayCaptions の原文をネイティブ言語へ)
    //    currentCaptionText は既にターゲット言語に翻訳されている可能性があるので、
    //    翻訳元としては displayCaptions[currentIndex].text と displayLanguageCode を使うのが正確。
    if (originalLanguageOfDisplayCaption.isNotEmpty &&
        originalLanguageOfDisplayCaption != userNativeLanguageCode) {
      try {
        // CaptionServiceのインスタンスを取得して翻訳を実行
        // この部分は VideoPlayerNotifier にある翻訳ロジックを呼び出すか、
        // CaptionService を直接使う形にする。ここでは CaptionService を直接使う例。
        final captionService = ref.read(
          captionServiceProvider(yt_explode.YoutubeExplode()),
        ); // ytExplodeインスタンスが必要

        // translateCurrentCaptionFallback はUI表示中の原文を前提としているため、
        // ここでは直接翻訳APIを叩くか、CaptionServiceに汎用的な翻訳メソッドを用意する。
        // 今回は、仮で CaptionService の既存メソッドを使うが、引数調整が必要。
        // 実際には、翻訳元テキスト、翻訳元言語、翻訳先言語を渡せるメソッドが望ましい。

        // 翻訳元は displayCaptions の現在のもの
        final textToTranslate = originalCaptionForCardFront;
        final sourceLang = originalLanguageOfDisplayCaption;

        // 既存の translateCurrentCaptionFallback を使う場合、第4引数 executeTranslation は true
        // 第5引数 currentDisplayedOriginalCaption は textToTranslate と同じで良い
        final translated = await captionService.translateCurrentCaptionFallback(
          textToTranslate,
          sourceLang,
          userNativeLanguageCode,
          true, // execute translation
          textToTranslate,
        );
        return translated;
      } catch (e) {
        debugPrint('ダイアログ用裏面テキスト翻訳エラー: $e');
        return fallbackText;
      }
    }
    // 翻訳不要（表示言語が既にネイティブ言語）または翻訳元言語不明
    return originalCaptionForCardFront;
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayerState = ref.watch(
      videoPlayerNotifierProvider(widget.videoUrl),
    );
    final l10n = AppLocalizations.of(context)!;
    final userDoc = ref.watch(userDocumentProvider).value;
    final userNativeLanguageCode = userDoc?.nativeLanguageCode ?? 'en';
    final userTargetLanguageCode = userDoc?.targetLanguageCode ?? 'ja';

    // currentCaptionText はターゲット言語に翻訳済みの可能性があるため、
    // カードの表には displayCaptions の原文（ターゲット言語でない場合もある）を使うのが適切か、
    // それとも currentCaptionText（ターゲット言語に寄せたもの）を使うか定義による。
    // ここでは、UIに表示されているメイン字幕 (currentCaptionText) をカードの表とする。
    final cardFrontText = videoPlayerState.currentCaptionText;

    return NeumorphicButton(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color: Colors.black,
      ),
      onPressed:
          cardFrontText.isEmpty || // cardFrontText を使用
                  videoPlayerState.isLoadingCaptions ||
                  _isProcessingCardCreation
              ? null
              : () async {
                final l10nDialog = AppLocalizations.of(context)!;
                final videoId = videoPlayerState.videoId;

                if (videoId == null || videoId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10nDialog.failedToGetVideoId)),
                  );
                  return;
                }

                if (cardFrontText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10nDialog.noCaptionSelected)),
                  );
                  return;
                }

                // スクリーンショット撮影と裏面テキストの準備
                setState(() {
                  _isProcessingCardCreation = true;
                  _capturedScreenshotBytes = null; // 以前のスクリーンショットをクリア
                });

                String initialBackText = l10nDialog.translatingText;
                bool backTextReady = false;
                bool screenshotReady = false;

                try {
                  // 1. スクリーンショット撮影
                  final currentPlayerController =
                      videoPlayerState.playerController;
                  if (currentPlayerController != null) {
                    try {
                      _capturedScreenshotBytes = await currentPlayerController
                          .player
                          .screenshot(format: 'image/jpeg');
                      if (_capturedScreenshotBytes == null) {
                        debugPrint('スクリーンショットの撮影に失敗しました (nullが返されました)。');
                      }
                    } catch (e) {
                      debugPrint('スクリーンショットの撮影中にエラーが発生しました: $e');
                      _capturedScreenshotBytes = null;
                    }
                  } else {
                    debugPrint(
                      'PlayerControllerまたはPlayerがnullのため、スクリーンショットをスキップします。',
                    );
                  }
                  screenshotReady = true;

                  // 2. 裏面テキストの取得
                  initialBackText = await _fetchBackTextForDialog(
                    context,
                    videoPlayerState,
                    userNativeLanguageCode,
                    l10nDialog.translationFailedFallbackText,
                  );
                  backTextReady = true;
                } catch (e) {
                  debugPrint('データ準備中にエラー: $e');
                  // エラーが発生した場合でも、ダイアログは表示する
                  // initialBackText はデフォルトのままか、エラーメッセージに設定
                  initialBackText = l10nDialog.translationFailedFallbackText;
                  backTextReady = true; // エラーでも準備完了とする
                  // screenshotReady はその時点での状態を維持
                } finally {
                  if (mounted) {
                    // 両方の処理が終わってから _isProcessingCardCreation を false にする
                    // ただし、ダイアログ表示までは true のままにしておく
                    // ダイアログ表示後に false にするのは、ダイアログ内の「作成」ボタンの処理のため
                    // ここでは setState は不要かもしれない。showDialog の後で管理する。
                  }
                }

                if (!mounted) return;

                // 両方の準備ができてからダイアログを表示
                // _isProcessingCardCreation はダイアログ表示直前まで true のまま
                // ダイアログ表示後に false にするのは、ダイアログ内の「作成」ボタンの処理のため
                // ここで false にすると、ダイアログ表示前にボタンが有効になってしまう可能性がある
                // 実際には、showDialog の完了を待ってから false にする方が適切かもしれないが、
                // ユーザーがダイアログを操作している間はボタンは無効のままが良い。
                // なので、ダイアログ内の「作成」ボタンが押された後の finally で false にする。
                // ここでは、ダイアログ表示の準備ができたので、一旦 false にする。
                // ただし、ダイアログ内の処理中は再度 true にする必要がある。
                // 仕様変更：_isProcessingCardCreation はダイアログ表示後、
                // 「作成」ボタンが押されるまで false のままで良い。
                // 「作成」ボタンが押されたら再度 true にする。
                // なので、ここでの setState は不要。

                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    final dialogL10n = AppLocalizations.of(dialogContext)!;
                    final backTextController = TextEditingController(
                      text: initialBackText,
                    );

                    // ダイアログ表示時に _isProcessingCardCreation を false に戻す
                    // ただし、これはダイアログ内の「作成」ボタンの処理とは別
                    // ここで false にすると、ダイアログ表示中に親ボタンが押せてしまう
                    // やはり、_isProcessingCardCreation の管理は複雑なので、
                    // ダイアログ表示の準備が完了したら、一旦 false にする。
                    // そして、ダイアログ内の「作成」ボタンが押されたら、再度 true にする。
                    // この builder が呼ばれる前に _isProcessingCardCreation を false にする。
                    // → onPressed の try-finally の finally で false にする。

                    return AlertDialog(
                      title: Text(dialogL10n.createCardConfirmationTitle),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${dialogL10n.frontLabel(userTargetLanguageCode.toUpperCase())}:",
                            ),
                            Text(
                              '"$cardFrontText"',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${dialogL10n.backLabel(userNativeLanguageCode.toUpperCase())}:",
                            ),
                            if (!backTextReady)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l10nDialog.translatingText),
                                  ],
                                ),
                              )
                            else
                              Neumorphic(
                                style: NeumorphicStyle(
                                  depth:
                                      -(NeumorphicTheme.embossDepth(
                                            dialogContext,
                                          ) ??
                                          4.0),
                                  boxShape: NeumorphicBoxShape.stadium(),
                                ),
                                child: TextField(
                                  controller: backTextController,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: dialogL10n.defaultCardBackText,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              "${dialogL10n.screenshotLabel}:",
                            ), // スクリーンショットラベル
                            const SizedBox(height: 8),
                            if (_capturedScreenshotBytes != null)
                              Center(
                                // 中央寄せ
                                child: ConstrainedBox(
                                  // 最大高さを設定
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  child: Image.memory(
                                    _capturedScreenshotBytes!,
                                  ),
                                ),
                              )
                            else if (_isProcessingCardCreation &&
                                !screenshotReady) // 撮影試行中
                              const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else // スクリーンショットなし、または撮影失敗
                              Center(
                                child: Text(dialogL10n.noScreenshotAvailable),
                              ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          child: Text(dialogL10n.cancelButtonDialog),
                        ),
                        TextButton(
                          onPressed: () async {
                            // OKボタン押下時は、TextFieldの内容をカード裏面とする
                            final finalBackText = backTextController.text;
                            Navigator.of(
                              dialogContext,
                            ).pop(true); // まずダイアログを閉じる

                            // カード作成処理
                            if (mounted) {
                              // setState(() { // この setState は不要、親の onPressed で管理
                              //   _isProcessingCardCreation = true;
                              // });
                            }
                            try {
                              final newCard = FirebaseCardModel(
                                id: const Uuid().v4(),
                                videoId: videoId,
                                front: cardFrontText,
                                back: finalBackText,
                                sourceLanguage: userTargetLanguageCode,
                                targetLanguage: userNativeLanguageCode,
                                createdAt: DateTime.now(),
                              );

                              String? uploadedImageUrl;
                              final userId =
                                  ref
                                      .read(firebaseRepositoryProvider)
                                      .getCurrentUserId();

                              if (_capturedScreenshotBytes != null &&
                                  userId != null) {
                                try {
                                  uploadedImageUrl = await ref
                                      .read(firebaseRepositoryProvider)
                                      .uploadScreenshot(
                                        userId: userId,
                                        cardId: newCard.id,
                                        imageBytes: _capturedScreenshotBytes!,
                                      );
                                } catch (e) {
                                  debugPrint(
                                    'スクリーンショットのアップロード中にエラーが発生しました: $e',
                                  );
                                  uploadedImageUrl = null;
                                }
                              }

                              FirebaseCardModel finalCard = newCard;
                              if (uploadedImageUrl != null) {
                                finalCard = newCard.copyWith(
                                  screenshotUrl: uploadedImageUrl,
                                );
                              }

                              if (userId == null) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        dialogL10n
                                            .userNotAuthenticated, // dialogL10n を使用
                                      ),
                                    ),
                                  );
                                }
                                return; // ここで処理を中断
                              }

                              await ref
                                  .read(firebaseRepositoryProvider)
                                  .addUserCard(userId, finalCard);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      dialogL10n
                                          .cardCreatedSuccessfully, // dialogL10n を使用
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('カード作成エラー: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      dialogL10n
                                          .failedToCreateCard, // dialogL10n を使用
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              // この finally はダイアログ内の「作成」ボタンの処理の finally
                              // 親の onPressed の finally で _isProcessingCardCreation を false にする
                              // if (mounted) {
                              //   setState(() {
                              //     _isProcessingCardCreation = false;
                              //   });
                              // }
                            }
                          },
                          child: Text(dialogL10n.createButton),
                        ),
                      ],
                    );
                  },
                );
                // ダイアログが閉じた後に _isProcessingCardCreation を false にする
                // confirmed の結果に関わらず実行
                if (mounted) {
                  setState(() {
                    _isProcessingCardCreation = false;
                  });
                }
              },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_card,
            color:
                NeumorphicTheme.isUsingDark(context)
                    ? Colors.black
                    : Colors.white,
          ),
          const SizedBox(width: 8.0),
          Text(
            l10n.createCardFromSubtitleButton,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  NeumorphicTheme.isUsingDark(context)
                      ? Colors.black
                      : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
