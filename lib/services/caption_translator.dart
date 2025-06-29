import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;
import 'caption_cache.dart';
import 'package:swipelingo/services/translation_payment_service.dart';

/// 字幕翻訳処理を担当するクラス
class CaptionTranslator {
  final GoogleTranslator _translator = GoogleTranslator();
  final CaptionCache _cache;

  CaptionTranslator(this._cache);

  /// バックグラウンドで全字幕を翻訳し、完了時にコールバックを呼び出す
  Future<void> translateAllCaptionsInBackground(
    List<yt_explode.ClosedCaption> sourceCaptions,
    String sourceLanguageCode,
    String targetLanguageCode,
    bool executeTranslation,
    Function(
      bool isTranslating,
      bool areAllTranslated,
      Map<String, String> updatedCacheForLang,
    ) onUpdate,
  ) async {
    if (!executeTranslation || sourceLanguageCode == targetLanguageCode) {
      _cache.setIsTranslatingAll(targetLanguageCode, false);
      _cache.setAreAllTranslated(targetLanguageCode, true);
      onUpdate(
        false,
        true,
        _cache.getCacheForLanguage(targetLanguageCode),
      );
      return;
    }

    if (sourceCaptions.isEmpty || _cache.isTranslatingAll(targetLanguageCode)) {
      onUpdate(
        _cache.isTranslatingAll(targetLanguageCode),
        _cache.areAllTranslated(targetLanguageCode),
        _cache.getCacheForLanguage(targetLanguageCode),
      );
      return;
    }

    _cache.setIsTranslatingAll(targetLanguageCode, true);
    _cache.setAreAllTranslated(targetLanguageCode, false);
    onUpdate(
      true,
      false,
      _cache.getCacheForLanguage(targetLanguageCode),
    );

    for (final caption in sourceCaptions) {
      if (_cache.containsKey(caption.text, targetLanguageCode)) {
        continue;
      }
      try {
        final translation = await _translator.translate(
          caption.text,
          from: sourceLanguageCode,
          to: targetLanguageCode,
        );
        _cache.set(
          caption.text,
          targetLanguageCode,
          translation.text,
        );
      } catch (e) {
        _cache.set(caption.text, targetLanguageCode, '翻訳エラー');
        debugPrint(
          '[CaptionTranslator] Error translating caption in background: ${caption.text} from $sourceLanguageCode to $targetLanguageCode - $e',
        );
      }
    }

    _cache.setIsTranslatingAll(targetLanguageCode, false);
    _cache.setAreAllTranslated(targetLanguageCode, true);
    onUpdate(
      false,
      true,
      _cache.getCacheForLanguage(targetLanguageCode),
    );
  }

  /// バックグラウンドで全字幕を翻訳し、ストリーム経由で通知
  Future<void> translateAllCaptionsWithStreamNotification(
    List<yt_explode.ClosedCaption> sourceCaptions,
    String sourceLanguageCode,
    String targetLanguageCode,
    bool executeTranslation,
    Function(Map<String, dynamic>) onUpdate,
  ) async {
    if (!executeTranslation || sourceLanguageCode == targetLanguageCode) {
      _cache.setIsTranslatingAll(targetLanguageCode, false);
      _cache.setAreAllTranslated(targetLanguageCode, true);
      _notifyTranslationUpdate(
        sourceCaptions,
        targetLanguageCode,
        false, // isTranslating
        true, // areAllTranslated
        onUpdate,
      );
      return;
    }

    if (sourceCaptions.isEmpty || _cache.isTranslatingAll(targetLanguageCode)) {
      _notifyTranslationUpdate(
        sourceCaptions,
        targetLanguageCode,
        _cache.isTranslatingAll(targetLanguageCode),
        _cache.areAllTranslated(targetLanguageCode),
        onUpdate,
      );
      return;
    }

    _cache.setIsTranslatingAll(targetLanguageCode, true);
    _cache.setAreAllTranslated(targetLanguageCode, false);
    _notifyTranslationUpdate(
      sourceCaptions,
      targetLanguageCode,
      true, // isTranslating
      false, // areAllTranslated
      onUpdate,
    );

    for (final caption in sourceCaptions) {
      if (_cache.containsKey(caption.text, targetLanguageCode)) {
        continue;
      }
      try {
        final translation = await _translator.translate(
          caption.text,
          from: sourceLanguageCode,
          to: targetLanguageCode,
        );
        _cache.set(
          caption.text,
          targetLanguageCode,
          translation.text,
        );
      } catch (e) {
        _cache.set(caption.text, targetLanguageCode, '翻訳エラー');
        debugPrint(
          '[CaptionTranslator] Error translating caption in background: ${caption.text} from $sourceLanguageCode to $targetLanguageCode - $e',
        );
      }
    }

    _cache.setIsTranslatingAll(targetLanguageCode, false);
    _cache.setAreAllTranslated(targetLanguageCode, true);
    _notifyTranslationUpdate(
      sourceCaptions,
      targetLanguageCode,
      false, // isTranslating
      true, // areAllTranslated
      onUpdate,
    );
  }

  /// 現在の字幕のフォールバック翻訳
  Future<String> translateCurrentCaptionFallback(
    String captionTextToTranslate,
    String sourceLanguageCode,
    String targetLanguageCode,
    bool executeTranslation,
    String currentDisplayedOriginalCaption,
  ) async {
    if (!executeTranslation ||
        sourceLanguageCode == targetLanguageCode ||
        captionTextToTranslate.isEmpty) {
      return _cache.get(captionTextToTranslate, targetLanguageCode) ??
          captionTextToTranslate; // 翻訳不要なら原文
    }

    if (_cache.containsKey(captionTextToTranslate, targetLanguageCode) &&
        _cache.get(captionTextToTranslate, targetLanguageCode) != '翻訳中...' &&
        _cache.get(captionTextToTranslate, targetLanguageCode) != '翻訳エラー') {
      return _cache.get(captionTextToTranslate, targetLanguageCode)!;
    }

    if (currentDisplayedOriginalCaption != captionTextToTranslate) {
      return _cache.get(captionTextToTranslate, targetLanguageCode) ??
          '翻訳待機中...';
    }

    _cache.set(captionTextToTranslate, targetLanguageCode, '翻訳中...');

    try {
      final translation = await _translator.translate(
        captionTextToTranslate,
        from: sourceLanguageCode,
        to: targetLanguageCode,
      );
      _cache.set(
        captionTextToTranslate,
        targetLanguageCode,
        translation.text,
      );
      return translation.text;
    } catch (e) {
      _cache.set(captionTextToTranslate, targetLanguageCode, '翻訳エラー');
      debugPrint(
        '[CaptionTranslator] Error translating caption (fallback) from $sourceLanguageCode to $targetLanguageCode: $e',
      );
      return '翻訳エラー';
    }
  }

  /// 個別翻訳戦略で字幕を取得
  Future<Map<String, dynamic>> getCaptionsViaIndividualTranslation(
    String videoId,
    String targetLanguageCode,
    List<yt_explode.ClosedCaption> sourceEnglishCaptions,
    TranslationPaymentService paymentService,
    bool isSubscribed,
  ) async {
    List<yt_explode.ClosedCaption> displayCaptions = [];
    String displayLanguageCode = '';
    bool needsTranslation = false;
    String? errorMessage;

    if (sourceEnglishCaptions.isNotEmpty) {
      displayLanguageCode = targetLanguageCode;
      needsTranslation = false; // 後でキャッシュ状況で再評価

      // 字幕取得時にはジェムを消費せず、常に翻訳を許可する
      bool canProceedWithTranslation = true;

      if (canProceedWithTranslation) {
        displayCaptions = [];
        for (final caption in sourceEnglishCaptions) {
          final cachedTranslation = _cache.get(
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
        needsTranslation = !sourceEnglishCaptions.every(
          (cap) => _cache.containsKey(cap.text, targetLanguageCode),
        );
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
    };
  }

  /// 翻訳更新を通知するヘルパーメソッド
  void _notifyTranslationUpdate(
    List<yt_explode.ClosedCaption> originalSourceCaptions,
    String targetLanguageCode,
    bool isTranslating,
    bool areAllTranslated,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    final List<yt_explode.ClosedCaption> updatedDisplayCaptions = [];
    for (final caption in originalSourceCaptions) {
      final translatedText =
          _cache.get(caption.text, targetLanguageCode) ??
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

    onUpdate({
      'displayCaptions': updatedDisplayCaptions,
      'displayLanguageCode': targetLanguageCode,
      'sourceEnglishCaptions': originalSourceCaptions, // 念のため元の英語字幕も渡す
      'needsTranslation': !areAllTranslated, // 全て翻訳済みでなければ true
      'isTranslating': isTranslating,
      'areAllTranslated': areAllTranslated,
    });
    debugPrint(
      '[CaptionTranslator] Caption update notified via stream. Lang: $targetLanguageCode, AllTranslated: $areAllTranslated, IsTranslating: $isTranslating',
    );
  }

  /// 翻訳権限をチェック（ジェム消費はしない）
  Future<bool> checkTranslationPermission(
    String languageCode,
    TranslationPaymentService paymentService,
    bool isSubscribed,
  ) async {
    // 既に翻訳済みならOK
    if (_cache.areAllTranslated(languageCode)) {
      debugPrint(
        '[CaptionTranslator] Captions for $languageCode are already translated.',
      );
      return true;
    }

    if (isSubscribed) {
      return true;
    }

    if (paymentService.hasPaidForTranslationInSession) {
      return true;
    }

    // 非購読者でセッション内で支払っていない場合でも、
    // ここではジェムを消費せずに翻訳を許可する
    // （ジェム消費は翻訳字幕を表示する時に行う）
    debugPrint(
      '[CaptionTranslator] Allowing translation for $languageCode without gem consumption.',
    );
    return true;
  }
}