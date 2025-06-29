// lib/services/caption_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // HTTPリクエスト用
import 'package:xml/xml.dart' as xml_parser; // XMLパース用
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;
import 'package:translator/translator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Refのために追加
import 'package:shared_preferences/shared_preferences.dart'; // 設定永続化のため追加
import 'package:swipelingo/services/translation_payment_service.dart';
import 'package:swipelingo/providers/subscription_provider.dart'; // isSubscribedProvider

// 字幕取得戦略の定義
enum CaptionFetchingStrategy {
  xml, // 既存のXMLベースの方法 (YouTube自動翻訳XMLなど)
  individualTranslation; // 1文ずつ翻訳する方法

  // 文字列から enum 値への変換
  static CaptionFetchingStrategy fromString(String? value) {
    if (value == null) return CaptionFetchingStrategy.xml; // デフォルト値
    return CaptionFetchingStrategy.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CaptionFetchingStrategy.xml, // 見つからない場合もデフォルト
    );
  }
}

// キャッシュされた翻訳字幕の状態を管理するためのクラス (多言語対応)
class TranslatedCaptionCache {
  // { "originalEnglishText": { "targetLangCode": "translatedText" } }
  final Map<String, Map<String, String>> _cache = {};
  // { "targetLangCode": true/false }
  final Map<String, bool> _areAllCaptionsTranslatedForLang = {};
  final Map<String, bool> _isTranslatingAllCaptionsForLang = {};

  // 字幕取得戦略。デフォルトはXMLベース。
  // UIなどからこの値を変更する口は別途設ける想定。
  CaptionFetchingStrategy fetchingStrategy = CaptionFetchingStrategy.xml;

  String? get(String originalText, String targetLangCode) =>
      _cache[originalText]?[targetLangCode];

  void set(String originalText, String targetLangCode, String translatedText) {
    _cache.putIfAbsent(originalText, () => {})[targetLangCode] = translatedText;
  }

  bool containsKey(String originalText, String targetLangCode) =>
      _cache.containsKey(originalText) &&
      _cache[originalText]!.containsKey(targetLangCode);

  void clear() {
    _cache.clear();
    _areAllCaptionsTranslatedForLang.clear();
    _isTranslatingAllCaptionsForLang.clear();
  }

  bool areAllTranslated(String targetLangCode) =>
      _areAllCaptionsTranslatedForLang[targetLangCode] ?? false;

  void setAreAllTranslated(String targetLangCode, bool value) =>
      _areAllCaptionsTranslatedForLang[targetLangCode] = value;

  bool isTranslatingAll(String targetLangCode) =>
      _isTranslatingAllCaptionsForLang[targetLangCode] ?? false;

  void setIsTranslatingAll(String targetLangCode, bool value) =>
      _isTranslatingAllCaptionsForLang[targetLangCode] = value;

  Map<String, String> getCacheForLanguage(String targetLangCode) {
    final langCache = <String, String>{};
    _cache.forEach((originalText, translations) {
      if (translations.containsKey(targetLangCode)) {
        langCache[originalText] = translations[targetLangCode]!;
      }
    });
    return langCache;
  }
}

class CaptionService {
  final yt_explode.YoutubeExplode _ytExplode;
  final GoogleTranslator _translator = GoogleTranslator();
  final TranslatedCaptionCache _translatedCaptionsCache =
      TranslatedCaptionCache();
  final Ref _ref;
  final StreamController<Map<String, dynamic>> _captionUpdateStreamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get captionUpdateStream =>
      _captionUpdateStreamController.stream;

  CaptionService(this._ytExplode, this._ref);

  // 字幕取得戦略を設定するメソッド
  void setFetchingStrategy(CaptionFetchingStrategy strategy) {
    _translatedCaptionsCache.fetchingStrategy = strategy;
    // 必要であれば、ここで状態の変更を通知するロジックを追加できます。
    // 例えば、関連するProviderを再構築するなど。
    // 今回は直接キャッシュの値を変更するだけに留めます。
    debugPrint('[CaptionService] Fetching strategy set to: $strategy');
  }

  // 字幕の読み込み
  Future<Map<String, dynamic>> loadCaptions(
    String videoId,
    String targetLanguageCode, // ユーザーのターゲット言語
    String nativeLanguageCode, // ユーザーのネイティブ言語
  ) async {
    debugPrint(
      '[CaptionService.loadCaptions] Called. Current fetchingStrategy: ${_translatedCaptionsCache.fetchingStrategy}, Video ID: $videoId, TargetLang: $targetLanguageCode, NativeLang: $nativeLanguageCode',
    );
    List<yt_explode.ClosedCaption> displayCaptions = [];
    String displayLanguageCode = '';
    List<yt_explode.ClosedCaption> sourceEnglishCaptions = [];
    bool needsTranslation = false; // targetLanguageCode への翻訳が必要か
    String? errorMessage;
    String currentCaptionTextForError = '';

    bool nativeLanguageTrackExists = false;
    List<yt_explode.ClosedCaption>? nativeLanguageCaptionsIfAvailable;
    bool isNativeYouTubeAutoTranslated = false; // YouTube自動翻訳かのフラグ

    try {
      final manifest = await _ytExplode.videos.closedCaptions.getManifest(
        videoId,
      );

      if (manifest.tracks.isEmpty) {
        currentCaptionTextForError = '字幕が見つかりませんでした。';
        errorMessage = '利用可能な字幕トラックがありません。';
      } else {
        // 英語字幕の取得試行
        yt_explode.ClosedCaptionTrackInfo? trackInfoEn;
        try {
          trackInfoEn = manifest.tracks.firstWhere(
            (track) => track.language.code == 'en',
          );
        } on StateError {
          trackInfoEn = null;
        }
        if (trackInfoEn != null) {
          final enTrack = await _ytExplode.videos.closedCaptions.get(
            trackInfoEn,
          );
          sourceEnglishCaptions = enTrack.captions;
        }

        // fetchingStrategy に基づいて字幕取得ロジックを分岐
        if (_translatedCaptionsCache.fetchingStrategy ==
            CaptionFetchingStrategy.individualTranslation) {
          debugPrint('[CaptionService] Using individualTranslation strategy.');
          // ネイティブ言語関連の変数は初期値のまま (false, null) で、取得処理をスキップ
          nativeLanguageTrackExists = false;
          nativeLanguageCaptionsIfAvailable = null;
          isNativeYouTubeAutoTranslated = false;

          final result = await _getCaptionsViaIndividualTranslation(
            videoId,
            targetLanguageCode,
            sourceEnglishCaptions,
          );
          displayCaptions = result['displayCaptions'];
          displayLanguageCode = result['displayLanguageCode'];
          needsTranslation = result['needsTranslation'];
          errorMessage = result['errorMessage'];
          if (sourceEnglishCaptions.isEmpty && errorMessage == null) {
            currentCaptionTextForError = '英語の字幕が見つかりませんでした。翻訳できません。';
            errorMessage = '英語の字幕トラックが見つかりません。この動画では「強制的な翻訳字幕」は利用できません。';
          }
        } else {
          // CaptionFetchingStrategy.xml
          debugPrint(
            '[CaptionService] Using XML (or other) fetching strategy.',
          );
          // ネイティブ言語字幕の取得試行 (既存のロジック)
          if (nativeLanguageCode.isNotEmpty &&
              nativeLanguageCode != targetLanguageCode) {
            yt_explode.ClosedCaptionTrackInfo? trackInfoNative;
            try {
              trackInfoNative = manifest.tracks.firstWhere(
                (track) => track.language.code == nativeLanguageCode,
              );
            } on StateError {
              trackInfoNative = null;
            }

            if (trackInfoNative != null) {
              debugPrint(
                '[CaptionService] Found native original captions for NATIVE language: $nativeLanguageCode',
              );
              final nativeTrack = await _ytExplode.videos.closedCaptions.get(
                trackInfoNative,
              );
              nativeLanguageCaptionsIfAvailable = nativeTrack.captions;
              nativeLanguageTrackExists = true;
              isNativeYouTubeAutoTranslated = false;
            } else {
              // ネイティブ言語のオリジナル字幕なし -> YouTube自動翻訳を試行
              debugPrint(
                '[CaptionService] Native original captions for NATIVE ($nativeLanguageCode) not found. Trying YouTube auto-translation.',
              );
              if (trackInfoEn != null && // trackInfoEn は manifest から取得済み
                  nativeLanguageCode != trackInfoEn.language.code) {
                debugPrint(
                  '[CaptionService] Base for NATIVE auto-trans: ${trackInfoEn.language.code} -> $nativeLanguageCode. URL: ${trackInfoEn.url}',
                );
                try {
                  final url = Uri.parse(
                    '${trackInfoEn.url}&tlang=$nativeLanguageCode',
                  );
                  final response = await http.get(url);
                  debugPrint(
                    '[CaptionService] YouTube auto-trans to NATIVE response status: ${response.statusCode}',
                  );
                  if (response.statusCode == 200) {
                    debugPrint('[CaptionService] NATIVE auto-trans URL: $url');
                    debugPrint(
                      '[CaptionService] NATIVE auto-trans Response Body for $nativeLanguageCode (length: ${response.body.length}):\n${response.body}',
                    );
                    final parsed = await _parseAutoTranslatedXmlCaptions(
                      response.body,
                      nativeLanguageCode,
                    );
                    if (parsed.isNotEmpty) {
                      nativeLanguageCaptionsIfAvailable = parsed;
                      nativeLanguageTrackExists = true;
                      isNativeYouTubeAutoTranslated = true;
                      debugPrint(
                        '[CaptionService] Successfully got YouTube auto-translated captions for NATIVE ($nativeLanguageCode): ${parsed.length} lines.',
                      );
                    } else {
                      debugPrint(
                        '[CaptionService] YouTube auto-translation to NATIVE ($nativeLanguageCode) returned empty captions.',
                      );
                    }
                  } else {
                    debugPrint(
                      '[CaptionService] HTTP error ${response.statusCode} for YouTube auto-translation to NATIVE ($nativeLanguageCode).',
                    );
                  }
                } catch (e, s) {
                  debugPrint(
                    '[CaptionService] Error in YouTube auto-translation to NATIVE ($nativeLanguageCode): $e\n$s',
                  );
                }
              } else {
                debugPrint(
                  '[CaptionService] No suitable base (English track) or same lang for YouTube auto-translation to NATIVE ($nativeLanguageCode). English track available: ${trackInfoEn != null}',
                );
              }
            }
          }

          // ターゲット言語として表示する字幕の決定 (既存のロジック)
          yt_explode.ClosedCaptionTrackInfo? trackInfoForTargetDisplay;
          try {
            trackInfoForTargetDisplay = manifest.tracks.firstWhere(
              (track) => track.language.code == targetLanguageCode,
            );
          } on StateError {
            trackInfoForTargetDisplay = null;
          }

          if (trackInfoForTargetDisplay != null) {
            // ターゲット言語のネイティブ字幕がある場合
            final targetTrack = await _ytExplode.videos.closedCaptions.get(
              trackInfoForTargetDisplay,
            );
            displayCaptions = targetTrack.captions;
            displayLanguageCode = targetLanguageCode;
            needsTranslation = false;
          } else {
            // ターゲット言語のネイティブ字幕がない場合 (XML戦略)
            // trackInfoEn は manifest から取得済み
            if (sourceEnglishCaptions.isNotEmpty && // XML戦略でもソース英語字幕を優先的に使う
                targetLanguageCode != 'en') {
              // ターゲットが英語でない場合のみ翻訳を試みる
              debugPrint(
                '[CaptionService] Target native captions not found. Using XML fetching strategy for $targetLanguageCode.',
              );
              if (trackInfoEn != null) {
                // 英語トラックがあればそれをベースに翻訳
                try {
                  final url = Uri.parse(
                    '${trackInfoEn.url}&tlang=$targetLanguageCode',
                  );
                  final response = await http.get(url);
                  if (response.statusCode == 200) {
                    final parsedCaptions =
                        await _parseAutoTranslatedXmlCaptions(
                          response.body,
                          targetLanguageCode,
                        );
                    if (parsedCaptions.isNotEmpty) {
                      displayCaptions = parsedCaptions;
                      displayLanguageCode = targetLanguageCode;
                      needsTranslation = false;
                      _translatedCaptionsCache.setAreAllTranslated(
                        targetLanguageCode,
                        true,
                      );
                    } else {
                      debugPrint(
                        '[CaptionService] YouTube auto-translation XML to TARGET ($targetLanguageCode) returned empty captions. Falling back to English.',
                      );
                      displayCaptions = sourceEnglishCaptions;
                      displayLanguageCode = 'en';
                      needsTranslation = targetLanguageCode != 'en';
                    }
                  } else {
                    debugPrint(
                      '[CaptionService] HTTP error ${response.statusCode} for YouTube auto-translation XML to TARGET ($targetLanguageCode). Falling back to English.',
                    );
                    displayCaptions = sourceEnglishCaptions;
                    displayLanguageCode = 'en';
                    needsTranslation = targetLanguageCode != 'en';
                  }
                } catch (e, s) {
                  debugPrint(
                    '[CaptionService] Error in YouTube auto-translation XML to TARGET ($targetLanguageCode): $e\n$s. Attempting fallback to individualTranslation.',
                  );
                  // ★★★ XML取得失敗時のフォールバック処理 ★★★
                  if (sourceEnglishCaptions.isNotEmpty) {
                    debugPrint(
                      '[CaptionService] XML fetch failed for $targetLanguageCode. Attempting individualTranslation as fallback.',
                    );
                    final fallbackResult =
                        await _getCaptionsViaIndividualTranslation(
                          videoId,
                          targetLanguageCode,
                          sourceEnglishCaptions,
                        );
                    displayCaptions = fallbackResult['displayCaptions'];
                    displayLanguageCode = fallbackResult['displayLanguageCode'];
                    needsTranslation = fallbackResult['needsTranslation'];
                    // errorMessage はフォールバック処理内で設定されるため、ここでは上書きしないか、
                    // もしくはフォールバックが成功した場合は元のXMLエラーをクリアする
                    if (fallbackResult['errorMessage'] == null &&
                        displayCaptions.isNotEmpty) {
                      errorMessage = null; // フォールバック成功ならエラー解除
                    } else {
                      // フォールバックも失敗した場合、または英語字幕がなかった場合
                      errorMessage =
                          fallbackResult['errorMessage'] ?? // フォールバック時のエラー
                          'XML字幕取得と個別翻訳の両方に失敗しました。';
                    }
                  } else {
                    // XML取得に失敗し、かつ英語字幕もない場合
                    displayCaptions = []; // 空の字幕
                    displayLanguageCode = targetLanguageCode; // 表示言語はターゲットのまま
                    needsTranslation = false; // 翻訳対象がない
                    errorMessage = 'XML字幕の取得に失敗し、翻訳の元となる英語字幕も見つかりませんでした。';
                    currentCaptionTextForError = '字幕の取得に失敗しました。';
                  }
                }
              } else {
                // 英語トラックもない場合 (XML戦略で翻訳ベースがない)
                debugPrint(
                  '[CaptionService] English track not found for XML strategy to TARGET ($targetLanguageCode). Falling back.',
                );
                if (manifest.tracks.isNotEmpty) {
                  final fallbackTrackInfo = manifest.tracks.first;
                  final fallbackTrack = await _ytExplode.videos.closedCaptions
                      .get(fallbackTrackInfo);
                  displayCaptions = fallbackTrack.captions;
                  displayLanguageCode = fallbackTrackInfo.language.code;
                  needsTranslation = displayLanguageCode != targetLanguageCode;
                } else {
                  currentCaptionTextForError = '表示可能な字幕が見つかりませんでした。';
                  errorMessage = '表示可能な字幕トラックがありません。';
                }
              }
            } else if (sourceEnglishCaptions.isNotEmpty) {
              // ターゲットが英語の場合、またはXML戦略で翻訳不要と判断された場合
              displayCaptions = sourceEnglishCaptions;
              displayLanguageCode = 'en';
              needsTranslation = false;
            } else if (manifest.tracks.isNotEmpty) {
              // 英語字幕もないが、何かしらの字幕がある場合
              final fallbackTrackInfo = manifest.tracks.first;
              final fallbackTrack = await _ytExplode.videos.closedCaptions.get(
                fallbackTrackInfo,
              );
              displayCaptions = fallbackTrack.captions;
              displayLanguageCode = fallbackTrackInfo.language.code;
              needsTranslation = displayLanguageCode != targetLanguageCode;
              if (sourceEnglishCaptions.isEmpty) {
                //念のため
                sourceEnglishCaptions = fallbackTrack.captions;
              }
            } else {
              // 表示できる字幕が何もない
              currentCaptionTextForError = '表示可能な字幕が見つかりませんでした。';
              errorMessage = '表示可能な字幕トラックがありません。';
            }
          }
        }
        // ターゲット言語が日本語で、日本語字幕が見つからなかった場合の専用メッセージ
        if (targetLanguageCode == 'ja' &&
            displayCaptions.isEmpty &&
            (_translatedCaptionsCache.fetchingStrategy !=
                    CaptionFetchingStrategy.individualTranslation ||
                sourceEnglishCaptions.isEmpty)) {
          currentCaptionTextForError = '日本語字幕が見つかりませんでした。';
        }
      }
    } catch (e) {
      currentCaptionTextForError = '字幕の読み込みに失敗しました。';
      errorMessage = '字幕の読み込み中にエラーが発生しました: $e';
      debugPrint('Error loading captions: $e');
    }

    return {
      'displayCaptions': displayCaptions,
      'displayLanguageCode': displayLanguageCode,
      'sourceEnglishCaptions': sourceEnglishCaptions,
      'needsTranslation': needsTranslation, // target language への翻訳が必要か
      'errorMessage': errorMessage,
      'currentCaptionTextForError': currentCaptionTextForError,
      'nativeLanguageTrackExists': nativeLanguageTrackExists,
      'nativeLanguageCaptionsIfAvailable': nativeLanguageCaptionsIfAvailable,
      'isNativeYouTubeAutoTranslated': isNativeYouTubeAutoTranslated,
    };
  }

  // ★★★ 新しいプライベートメソッド: individualTranslation戦略による字幕取得 ★★★
  Future<Map<String, dynamic>> _getCaptionsViaIndividualTranslation(
    String videoId, // videoId はログや将来的な拡張のために渡す
    String targetLanguageCode,
    List<yt_explode.ClosedCaption> sourceEnglishCaptions,
    // yt_explode.ClosedCaptionTrackInfo? trackInfoEn, // trackInfoEnは直接使わないので不要かも
  ) async {
    List<yt_explode.ClosedCaption> displayCaptions = [];
    String displayLanguageCode = '';
    bool needsTranslation = false;
    String? errorMessage;

    if (sourceEnglishCaptions.isNotEmpty) {
      displayLanguageCode = targetLanguageCode;
      needsTranslation = false; // 後でキャッシュ状況で再評価

      final paymentService = _ref.read(translationPaymentServiceProvider);
      final isSubscribed = _ref.read(isSubscribedProvider);
      bool canProceedWithTranslation = false;

      if (isSubscribed) {
        canProceedWithTranslation = true;
      } else {
        if (paymentService.hasPaidForTranslationInSession) {
          canProceedWithTranslation = true;
        } else {
          final gemConsumed = await paymentService.consumeGemForTranslation();
          if (gemConsumed) {
            canProceedWithTranslation = true;
          } else {
            errorMessage = '翻訳のためのジェムが不足しています。';
            debugPrint(
              '[CaptionService._getCaptionsViaIndividualTranslation] Gem consumption failed.',
            );
          }
        }
      }

      if (canProceedWithTranslation) {
        displayCaptions = [];
        for (final caption in sourceEnglishCaptions) {
          final cachedTranslation = _translatedCaptionsCache.get(
            caption.text,
            targetLanguageCode,
          );
          displayCaptions.add(
            yt_explode.ClosedCaption(
              cachedTranslation ?? caption.text,
              caption.offset,
              caption.duration,
              caption.parts,
            ),
          );
        }
        needsTranslation =
            !sourceEnglishCaptions.every(
              (cap) => _translatedCaptionsCache.containsKey(
                cap.text,
                targetLanguageCode,
              ),
            );

        _translateAllCaptionsInBackgroundWithNotification(
          sourceEnglishCaptions,
          'en', // individualTranslation は英語ベースを想定
          targetLanguageCode,
          true,
        );
      } else {
        displayCaptions = sourceEnglishCaptions;
        displayLanguageCode = 'en';
        needsTranslation = targetLanguageCode != 'en';
        errorMessage ??= '字幕の翻訳に失敗しました。ジェムを確認してください。';
      }
    } else {
      errorMessage = '翻訳の元となる英語字幕が見つかりません。';
      displayLanguageCode = targetLanguageCode; // 表示言語はターゲットのまま
      needsTranslation = false; // 翻訳対象がない
    }

    return {
      'displayCaptions': displayCaptions,
      'displayLanguageCode': displayLanguageCode,
      'needsTranslation': needsTranslation,
      'errorMessage': errorMessage,
      // 'sourceEnglishCaptions' は呼び出し元が持っているのでここでは返さない
      // 'currentCaptionTextForError' もここでは設定しない
    };
  }

  // バックグラウンド翻訳と通知を行う新しいメソッド
  Future<void> _translateAllCaptionsInBackgroundWithNotification(
    List<yt_explode.ClosedCaption> sourceCaptions,
    String sourceLanguageCode,
    String targetLanguageCode,
    bool executeTranslation,
  ) async {
    // 元の translateAllCaptionsInBackground のロジックをここに移動し、
    // onUpdate の代わりに _captionUpdateStreamController を使用する
    if (!executeTranslation || sourceLanguageCode == targetLanguageCode) {
      _translatedCaptionsCache.setIsTranslatingAll(targetLanguageCode, false);
      _translatedCaptionsCache.setAreAllTranslated(targetLanguageCode, true);
      _notifyCaptionUpdate(
        targetLanguageCode,
        sourceCaptions,
        false, // isTranslating
        true, // areAllTranslated
      );
      return;
    }

    if (sourceCaptions.isEmpty ||
        _translatedCaptionsCache.isTranslatingAll(targetLanguageCode)) {
      _notifyCaptionUpdate(
        targetLanguageCode,
        sourceCaptions,
        _translatedCaptionsCache.isTranslatingAll(targetLanguageCode),
        _translatedCaptionsCache.areAllTranslated(targetLanguageCode),
      );
      return;
    }

    _translatedCaptionsCache.setIsTranslatingAll(targetLanguageCode, true);
    _translatedCaptionsCache.setAreAllTranslated(targetLanguageCode, false);
    _notifyCaptionUpdate(
      targetLanguageCode,
      sourceCaptions,
      true, // isTranslating
      false, // areAllTranslated
    );

    for (final caption in sourceCaptions) {
      if (_translatedCaptionsCache.containsKey(
        caption.text,
        targetLanguageCode,
      )) {
        continue;
      }
      try {
        final translation = await _translator.translate(
          caption.text,
          from: sourceLanguageCode,
          to: targetLanguageCode,
        );
        _translatedCaptionsCache.set(
          caption.text,
          targetLanguageCode,
          translation.text,
        );
      } catch (e) {
        _translatedCaptionsCache.set(caption.text, targetLanguageCode, '翻訳エラー');
        debugPrint(
          'Error translating caption in background: ${caption.text} from $sourceLanguageCode to $targetLanguageCode - $e',
        );
      }
      // 個々の翻訳完了ごとにも通知できるが、今回は全完了時のみとする
      // 必要であれば、ここで部分的な更新を通知するロジックを追加
    }

    _translatedCaptionsCache.setIsTranslatingAll(targetLanguageCode, false);
    _translatedCaptionsCache.setAreAllTranslated(targetLanguageCode, true);
    _notifyCaptionUpdate(
      targetLanguageCode,
      sourceCaptions,
      false, // isTranslating
      true, // areAllTranslated
    );
  }

  // 翻訳更新を通知するヘルパーメソッド
  void _notifyCaptionUpdate(
    String targetLanguageCode,
    List<yt_explode.ClosedCaption> originalSourceCaptions,
    bool isTranslating,
    bool areAllTranslated,
  ) {
    final List<yt_explode.ClosedCaption> updatedDisplayCaptions = [];
    for (final caption in originalSourceCaptions) {
      final translatedText =
          _translatedCaptionsCache.get(caption.text, targetLanguageCode) ??
          (isTranslating ? caption.text : '翻訳エラー'); // 翻訳中なら原文、完了後でなければエラー
      updatedDisplayCaptions.add(
        yt_explode.ClosedCaption(
          translatedText,
          caption.offset,
          caption.duration,
          caption.parts,
        ),
      );
    }

    _captionUpdateStreamController.add({
      'displayCaptions': updatedDisplayCaptions,
      'displayLanguageCode': targetLanguageCode,
      'sourceEnglishCaptions': originalSourceCaptions, // 念のため元の英語字幕も渡す
      'needsTranslation': !areAllTranslated, // 全て翻訳済みでなければ true
      'isTranslating': isTranslating,
      'areAllTranslated': areAllTranslated,
      // errorMessage や nativeLanguage関連は loadCaptions の初期ロード時のものを使う想定
      // 必要であれば、ここでもエラーハンドリングを追加
    });
    debugPrint(
      '[CaptionService] Caption update notified via stream. Lang: $targetLanguageCode, AllTranslated: $areAllTranslated, IsTranslating: $isTranslating',
    );
  }

  // 全字幕のバックグラウンド翻訳 (元のメソッドは内部利用または削除検討)
  // このメソッドは直接呼び出されなくなる想定だが、互換性のため残すか、
  // _translateAllCaptionsInBackgroundWithNotification にロジックを統合し、
  // onUpdate を使う古い呼び出し箇所があればそちらを修正する。
  // 今回は新しいメソッド (_translateAllCaptionsInBackgroundWithNotification) を使うので、
  // このメソッドは直接は使われない。
  Future<void> translateAllCaptionsInBackground(
    List<yt_explode.ClosedCaption> sourceCaptions,
    String sourceLanguageCode,
    String targetLanguageCode, // 翻訳先の言語 (ユーザーターゲット or ユーザーネイティブ)
    bool executeTranslation, // 実際に翻訳を実行するかどうか
    Function(
      bool isTranslating,
      bool areAllTranslated,
      Map<String, String> updatedCacheForLang,
    )
    onUpdate,
  ) async {
    if (!executeTranslation || sourceLanguageCode == targetLanguageCode) {
      _translatedCaptionsCache.setIsTranslatingAll(targetLanguageCode, false);
      _translatedCaptionsCache.setAreAllTranslated(targetLanguageCode, true);
      onUpdate(
        false,
        true,
        _translatedCaptionsCache.getCacheForLanguage(targetLanguageCode),
      );
      return;
    }

    if (sourceCaptions.isEmpty ||
        _translatedCaptionsCache.isTranslatingAll(targetLanguageCode)) {
      onUpdate(
        _translatedCaptionsCache.isTranslatingAll(targetLanguageCode),
        _translatedCaptionsCache.areAllTranslated(targetLanguageCode),
        _translatedCaptionsCache.getCacheForLanguage(targetLanguageCode),
      );
      return;
    }
    _translatedCaptionsCache.setIsTranslatingAll(targetLanguageCode, true);
    _translatedCaptionsCache.setAreAllTranslated(targetLanguageCode, false);
    onUpdate(
      true,
      false,
      _translatedCaptionsCache.getCacheForLanguage(targetLanguageCode),
    );

    for (final caption in sourceCaptions) {
      if (_translatedCaptionsCache.containsKey(
        caption.text,
        targetLanguageCode,
      )) {
        continue;
      }
      try {
        final translation = await _translator.translate(
          caption.text,
          from: sourceLanguageCode,
          to: targetLanguageCode,
        );
        _translatedCaptionsCache.set(
          caption.text,
          targetLanguageCode,
          translation.text,
        );
      } catch (e) {
        _translatedCaptionsCache.set(caption.text, targetLanguageCode, '翻訳エラー');
        debugPrint(
          'Error translating caption in background: ${caption.text} from $sourceLanguageCode to $targetLanguageCode - $e',
        );
      }
    }

    _translatedCaptionsCache.setIsTranslatingAll(targetLanguageCode, false);
    _translatedCaptionsCache.setAreAllTranslated(targetLanguageCode, true);
    onUpdate(
      false,
      true,
      _translatedCaptionsCache.getCacheForLanguage(targetLanguageCode),
    );
  }

  // 現在の字幕のフォールバック翻訳
  Future<String> translateCurrentCaptionFallback(
    String captionTextToTranslate,
    String sourceLanguageCode,
    String targetLanguageCode, // 翻訳先の言語 (ユーザーターゲット or ユーザーネイティブ)
    bool executeTranslation, // 実際に翻訳を実行するかどうか
    String currentDisplayedOriginalCaption,
  ) async {
    if (!executeTranslation ||
        sourceLanguageCode == targetLanguageCode ||
        captionTextToTranslate.isEmpty) {
      return _translatedCaptionsCache.get(
            captionTextToTranslate,
            targetLanguageCode,
          ) ??
          captionTextToTranslate; // 翻訳不要なら原文
    }

    if (_translatedCaptionsCache.containsKey(
          captionTextToTranslate,
          targetLanguageCode,
        ) &&
        _translatedCaptionsCache.get(
              captionTextToTranslate,
              targetLanguageCode,
            ) !=
            '翻訳中...' &&
        _translatedCaptionsCache.get(
              captionTextToTranslate,
              targetLanguageCode,
            ) !=
            '翻訳エラー') {
      return _translatedCaptionsCache.get(
        captionTextToTranslate,
        targetLanguageCode,
      )!;
    }

    if (currentDisplayedOriginalCaption != captionTextToTranslate) {
      return _translatedCaptionsCache.get(
            captionTextToTranslate,
            targetLanguageCode,
          ) ??
          '翻訳待機中...';
    }

    _translatedCaptionsCache.set(
      captionTextToTranslate,
      targetLanguageCode,
      '翻訳中...',
    );

    try {
      final translation = await _translator.translate(
        captionTextToTranslate,
        from: sourceLanguageCode,
        to: targetLanguageCode,
      );
      _translatedCaptionsCache.set(
        captionTextToTranslate,
        targetLanguageCode,
        translation.text,
      );
      return translation.text;
    } catch (e) {
      _translatedCaptionsCache.set(
        captionTextToTranslate,
        targetLanguageCode,
        '翻訳エラー',
      );
      debugPrint(
        'Error translating caption (fallback) from $sourceLanguageCode to $targetLanguageCode: $e',
      );
      return '翻訳エラー';
    }
  }

  String? getTranslatedCaptionFromCache(
    String originalCaptionText,
    String targetLanguageCode,
  ) {
    return _translatedCaptionsCache.get(
      originalCaptionText,
      targetLanguageCode,
    );
  }

  bool areAllCaptionsTranslated(String targetLanguageCode) {
    return _translatedCaptionsCache.areAllTranslated(targetLanguageCode);
  }

  bool isTranslatingAllCaptions(String targetLanguageCode) {
    return _translatedCaptionsCache.isTranslatingAll(targetLanguageCode);
  }

  void clearCache() {
    _translatedCaptionsCache.clear();
  }

  Future<List<yt_explode.ClosedCaption>> _parseAutoTranslatedXmlCaptions(
    String xmlString,
    String languageCodeForThisXml, // ★引数に言語コードを追加
  ) async {
    // ジェム消費ロジック
    final paymentService = _ref.read(translationPaymentServiceProvider);
    final isSubscribed = _ref.read(isSubscribedProvider);

    bool canProceed = false;

    // ★変更点: このXMLに対応する言語の字幕が既に全て翻訳済みか確認
    if (_translatedCaptionsCache.areAllTranslated(languageCodeForThisXml)) {
      canProceed = true; // 既に翻訳済みならジェム消費不要
      debugPrint(
        '[_parseAutoTranslatedXmlCaptions] Captions for $languageCodeForThisXml are already marked as translated. Skipping gem consumption.',
      );
    } else {
      // 既存のジェム消費ロジック
      if (isSubscribed) {
        canProceed = true;
      } else {
        if (paymentService.hasPaidForTranslationInSession) {
          canProceed = true;
        } else {
          // 非購読者で、まだセッション内で支払っていない場合、ジェムを消費する
          final gemConsumed = await paymentService.consumeGemForTranslation();
          if (gemConsumed) {
            canProceed = true;
          } else {
            // ジェム消費失敗（残高不足など）
            debugPrint(
              '[_parseAutoTranslatedXmlCaptions] Gem consumption failed for $languageCodeForThisXml. Returning empty captions.',
            );
            return []; // 空のリストを返す
          }
        }
      }
    }

    if (!canProceed) {
      // このケースは上記ロジックで既に return [] されているはずだが念のため
      // (areAllTranslated が false で、かつジェム消費にも失敗した場合など)
      debugPrint(
        '[_parseAutoTranslatedXmlCaptions] Cannot proceed with parsing for $languageCodeForThisXml. Returning empty captions.',
      );
      return [];
    }

    // 元のパース処理
    debugPrint(
      '[_parseAutoTranslatedXmlCaptions] Called for lang "$languageCodeForThisXml" with XML string (length: ${xmlString.length})',
    );
    // XML内容の先頭部分をログに出力（長すぎる場合は省略）
    final previewLength = xmlString.length > 200 ? 200 : xmlString.length;
    debugPrint(
      '[_parseAutoTranslatedXmlCaptions] XML preview: ${xmlString.substring(0, previewLength)}',
    );

    final List<yt_explode.ClosedCaption> captions = [];
    if (xmlString.isEmpty || xmlString.trim().isEmpty) {
      // 空白のみの文字列もチェック
      debugPrint(
        '[_parseAutoTranslatedXmlCaptions] XML string is empty or whitespace only for lang "$languageCodeForThisXml", returning empty list.',
      );
      return captions;
    }
    try {
      final document = xml_parser.XmlDocument.parse(xmlString);
      final textElements = document.findAllElements('text');
      debugPrint(
        '[_parseAutoTranslatedXmlCaptions] Found ${textElements.length} <text> elements in XML.',
      );

      for (final element in textElements) {
        final startString = element.getAttribute('start');
        final durString = element.getAttribute('dur');
        final text = element.text;

        if (startString != null && durString != null && text.isNotEmpty) {
          final startSeconds = double.tryParse(startString);
          final durSeconds = double.tryParse(durString);

          if (startSeconds != null && durSeconds != null) {
            final offset = Duration(
              milliseconds: (startSeconds * 1000).round(),
            );
            final duration = Duration(
              milliseconds: (durSeconds * 1000).round(),
            );
            captions.add(
              yt_explode.ClosedCaption(
                text, // text
                offset, // offset
                duration, // duration
                const [], // parts (空の定数リスト)
              ),
            );
          } else {
            debugPrint(
              '[_parseAutoTranslatedXmlCaptions] Failed to parse start/dur seconds: start=$startString, dur=$durString for text: $text',
            );
          }
        } else {
          debugPrint(
            '[_parseAutoTranslatedXmlCaptions] Missing start/dur attribute or text is empty: start=$startString, dur=$durString, textIsEmpty=${text.isEmpty}',
          );
        }
      }
    } catch (e, s) {
      debugPrint(
        '[_parseAutoTranslatedXmlCaptions] Exception during XML parsing: $e',
      );
      debugPrint(
        '[_parseAutoTranslatedXmlCaptions] Stacktrace for XML parsing error: $s',
      );
    }
    debugPrint(
      '[_parseAutoTranslatedXmlCaptions] Parsed for lang "$languageCodeForThisXml". Returning ${captions.length} captions.',
    );
    return captions;
  }

  // StreamControllerを閉じるためのメソッド
  void dispose() {
    _captionUpdateStreamController.close();
  }
} // このカッコが CaptionService クラスの終わり

final captionServiceProvider = Provider.family<
  CaptionService,
  yt_explode.YoutubeExplode
>((ref, ytExplode) {
  final service = CaptionService(ytExplode, ref);
  // captionFetchingStrategyProvider の状態を監視し、変更があれば CaptionService に反映
  ref
      .watch(captionFetchingStrategyProvider)
      .when(
        data: (strategy) {
          service.setFetchingStrategy(strategy);
        },
        loading: () {
          // 初期読み込み中はデフォルト戦略を使用するか、何もしない
          // ここでは CaptionService のデフォルト戦略が使われることを期待
          // もしくは、明示的にデフォルトを設定する
          service.setFetchingStrategy(CaptionFetchingStrategy.xml);
        },
        error: (error, stackTrace) {
          // エラー発生時もデフォルト戦略を使用
          debugPrint(
            '[CaptionService] Error loading caption strategy: $error, defaulting to xml.',
          );
          service.setFetchingStrategy(CaptionFetchingStrategy.xml);
        },
      );

  ref.onDispose(() {
    service.dispose(); // Providerが破棄されるときにStreamControllerを閉じる
  });

  return service;
});

// 字幕取得戦略の状態を管理するAsyncNotifierProvider
final captionFetchingStrategyProvider = AsyncNotifierProvider<
  CaptionFetchingStrategyNotifier,
  CaptionFetchingStrategy
>(() {
  return CaptionFetchingStrategyNotifier();
});

class CaptionFetchingStrategyNotifier
    extends AsyncNotifier<CaptionFetchingStrategy> {
  static const _prefKey = 'captionFetchingStrategy';

  @override
  Future<CaptionFetchingStrategy> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStrategyName = prefs.getString(_prefKey);
    if (savedStrategyName != null) {
      return CaptionFetchingStrategy.fromString(savedStrategyName);
    }
    return CaptionFetchingStrategy.xml; // デフォルト値
  }

  Future<void> updateStrategy(CaptionFetchingStrategy newStrategy) async {
    state = AsyncValue.data(newStrategy); // 即時UI反映
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newStrategy.name);
    debugPrint('[CaptionService] Caption strategy saved: ${newStrategy.name}');
  }
}
