import 'package:flutter/foundation.dart';

/// 字幕取得戦略の定義
enum CaptionFetchingStrategy {
  xml, // 既存のXMLベースの方法（無効化済み）
  individualTranslation; // 1文ずつ翻訳する方法（デフォルト）

  /// 文字列から enum 値への変換
  static CaptionFetchingStrategy fromString(String? value) {
    if (value == null) return CaptionFetchingStrategy.individualTranslation; // デフォルト値
    return CaptionFetchingStrategy.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CaptionFetchingStrategy.individualTranslation, // 見つからない場合もデフォルト
    );
  }
}

/// キャッシュされた翻訳字幕の状態を管理するクラス (多言語対応)
class CaptionCache {
  /// { "originalEnglishText": { "targetLangCode": "translatedText" } }
  final Map<String, Map<String, String>> _cache = {};
  
  /// { "targetLangCode": true/false }
  final Map<String, bool> _areAllCaptionsTranslatedForLang = {};
  final Map<String, bool> _isTranslatingAllCaptionsForLang = {};

  /// 字幕取得戦略。デフォルトは個別翻訳。
  CaptionFetchingStrategy fetchingStrategy = CaptionFetchingStrategy.individualTranslation;

  /// キャッシュから翻訳済みテキストを取得
  String? get(String originalText, String targetLangCode) =>
      _cache[originalText]?[targetLangCode];

  /// キャッシュに翻訳済みテキストを保存
  void set(String originalText, String targetLangCode, String translatedText) {
    _cache.putIfAbsent(originalText, () => {})[targetLangCode] = translatedText;
  }

  /// 指定されたテキストと言語の翻訳がキャッシュに存在するかチェック
  bool containsKey(String originalText, String targetLangCode) =>
      _cache.containsKey(originalText) &&
      _cache[originalText]!.containsKey(targetLangCode);

  /// 全キャッシュをクリア
  void clear() {
    _cache.clear();
    _areAllCaptionsTranslatedForLang.clear();
    _isTranslatingAllCaptionsForLang.clear();
  }

  /// 指定言語の全字幕が翻訳済みかチェック
  bool areAllTranslated(String targetLangCode) =>
      _areAllCaptionsTranslatedForLang[targetLangCode] ?? false;

  /// 指定言語の全字幕翻訳完了状態を設定
  void setAreAllTranslated(String targetLangCode, bool value) =>
      _areAllCaptionsTranslatedForLang[targetLangCode] = value;

  /// 指定言語の字幕を翻訳中かチェック
  bool isTranslatingAll(String targetLangCode) =>
      _isTranslatingAllCaptionsForLang[targetLangCode] ?? false;

  /// 指定言語の字幕翻訳中状態を設定
  void setIsTranslatingAll(String targetLangCode, bool value) =>
      _isTranslatingAllCaptionsForLang[targetLangCode] = value;

  /// 指定言語のキャッシュをMap形式で取得
  Map<String, String> getCacheForLanguage(String targetLangCode) {
    final langCache = <String, String>{};
    _cache.forEach((originalText, translations) {
      if (translations.containsKey(targetLangCode)) {
        langCache[originalText] = translations[targetLangCode]!;
      }
    });
    return langCache;
  }

  /// デバッグ用: キャッシュの統計情報を出力
  void logCacheStats() {
    debugPrint('[CaptionCache] Total cached original texts: ${_cache.length}');
    for (final lang in _areAllCaptionsTranslatedForLang.keys) {
      final count = getCacheForLanguage(lang).length;
      final allTranslated = areAllTranslated(lang);
      final isTranslating = isTranslatingAll(lang);
      debugPrint('[CaptionCache] Lang: $lang, Cached: $count, AllTranslated: $allTranslated, IsTranslating: $isTranslating');
    }
  }
}