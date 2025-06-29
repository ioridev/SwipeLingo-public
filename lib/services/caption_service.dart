import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'caption_cache.dart';
import 'caption_translator.dart';
import 'caption_fetcher.dart';
import 'package:swipelingo/services/translation_payment_service.dart';
import 'package:swipelingo/providers/subscription_provider.dart';

/// 字幕サービスのメインオーケストレータ
/// 各専門クラスを組み合わせて字幕の取得・翻訳・キャッシュ管理を統合
class CaptionService {
  final CaptionCache _cache;
  late final CaptionTranslator _translator;
  late final CaptionFetcher _fetcher;
  final TranslationPaymentService Function() _getPaymentService;
  final bool Function() _getIsSubscribed;

  final StreamController<Map<String, dynamic>> _captionUpdateStreamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get captionUpdateStream =>
      _captionUpdateStreamController.stream;

  CaptionService({
    required yt_explode.YoutubeExplode ytExplode,
    required TranslationPaymentService Function() getPaymentService,
    required bool Function() getIsSubscribed,
  })  : _cache = CaptionCache(),
        _getPaymentService = getPaymentService,
        _getIsSubscribed = getIsSubscribed {
    _translator = CaptionTranslator(_cache);
    _fetcher = CaptionFetcher(
      ytExplode,
    );
  }

  /// 字幕取得戦略を設定
  void setFetchingStrategy(CaptionFetchingStrategy strategy) {
    _cache.fetchingStrategy = strategy;
    debugPrint('[CaptionService] Fetching strategy set to: $strategy');
  }

  /// 字幕の読み込み（メインエントリーポイント）
  Future<Map<String, dynamic>> loadCaptions(
    String videoId,
    String targetLanguageCode,
    String nativeLanguageCode,
  ) async {
    debugPrint(
      '[CaptionService.loadCaptions] Called. Strategy: ${_cache.fetchingStrategy}, Video: $videoId, Target: $targetLanguageCode, Native: $nativeLanguageCode',
    );

    try {
      // 標準実装は動作しないので、最初から代替実装を使用
      List<yt_explode.ClosedCaption> sourceEnglishCaptions = [];
      
      debugPrint('[CaptionService] Using alternative implementation directly');
      
      // まず代替実装で字幕が利用可能か確認
      final hasCaptionsAvailable = await _fetcher.hasCaptionsAvailableDirect(videoId);
      if (!hasCaptionsAvailable) {
        debugPrint('[CaptionService] No captions available via alternative implementation');
        return _createErrorResult(
          '字幕が見つかりませんでした。',
          '利用可能な字幕トラックがありません。',
          targetLanguageCode,
        );
      }
      
      // 利用可能な言語を取得
      final availableLanguages = await _fetcher.getAvailableLanguagesDirect(videoId);
      debugPrint('[CaptionService] Available languages: $availableLanguages');
      
      // 代替実装で英語字幕を取得
      final alternativeCaptions = await _fetcher.getCaptionTrackDirect(videoId, 'en');
      if (alternativeCaptions != null && alternativeCaptions.isNotEmpty) {
        sourceEnglishCaptions = alternativeCaptions;
        
        // ターゲット言語が英語の場合は翻訳不要
        if (targetLanguageCode == 'en') {
          return {
            'displayCaptions': sourceEnglishCaptions,
            'displayLanguageCode': 'en',
            'sourceEnglishCaptions': sourceEnglishCaptions,
            'needsTranslation': false,
            'errorMessage': null,
            'currentCaptionTextForError': '',
            'nativeLanguageTrackExists': false,
            'nativeLanguageCaptionsIfAvailable': null,
            'isNativeYouTubeAutoTranslated': false,
          };
        }
      } else {
        // 英語字幕が取得できない場合、ターゲット言語で直接取得を試みる
        final targetCaptions = await _fetcher.getCaptionTrackDirect(videoId, targetLanguageCode);
        if (targetCaptions != null && targetCaptions.isNotEmpty) {
          return {
            'displayCaptions': targetCaptions,
            'displayLanguageCode': targetLanguageCode,
            'sourceEnglishCaptions': targetCaptions,
            'needsTranslation': false,
            'errorMessage': null,
            'currentCaptionTextForError': '',
            'nativeLanguageTrackExists': false,
            'nativeLanguageCaptionsIfAvailable': null,
            'isNativeYouTubeAutoTranslated': false,
          };
        }
        
        // ターゲット言語も取得できない場合、利用可能な最初の言語を使用
        if (availableLanguages.isNotEmpty) {
          final fallbackLang = availableLanguages.first;
          final fallbackCaptions = await _fetcher.getCaptionTrackDirect(videoId, fallbackLang);
          if (fallbackCaptions != null && fallbackCaptions.isNotEmpty) {
            return {
              'displayCaptions': fallbackCaptions,
              'displayLanguageCode': fallbackLang,
              'sourceEnglishCaptions': fallbackCaptions,
              'needsTranslation': targetLanguageCode != fallbackLang,
              'errorMessage': null,
              'currentCaptionTextForError': '',
              'nativeLanguageTrackExists': false,
              'nativeLanguageCaptionsIfAvailable': null,
              'isNativeYouTubeAutoTranslated': false,
            };
          }
        }
      }
      
      // 字幕が取得できなかった場合のエラー処理
      if (sourceEnglishCaptions.isEmpty) {
        return _createErrorResult(
          '字幕が見つかりませんでした。',
          '利用可能な字幕トラックがありません。',
          targetLanguageCode,
        );
      }

      // 常に個別翻訳戦略を使用（XMLスクレイピングは動作しないため）
      return await _loadCaptionsViaIndividualTranslation(
        videoId,
        targetLanguageCode,
        sourceEnglishCaptions,
      );
    } catch (e) {
      debugPrint('[CaptionService] Error loading captions: $e');
      return _createErrorResult(
        '字幕の読み込みに失敗しました。',
        '字幕の読み込み中にエラーが発生しました: $e',
        targetLanguageCode,
      );
    }
  }

  /// 個別翻訳戦略による字幕読み込み
  Future<Map<String, dynamic>> _loadCaptionsViaIndividualTranslation(
    String videoId,
    String targetLanguageCode,
    List<yt_explode.ClosedCaption> sourceEnglishCaptions,
  ) async {
    debugPrint('[CaptionService] Using individualTranslation strategy.');

    if (sourceEnglishCaptions.isEmpty) {
      return _createErrorResult(
        '英語の字幕が見つかりませんでした。翻訳できません。',
        '英語の字幕トラックが見つかりません。この動画では「強制的な翻訳字幕」は利用できません。',
        targetLanguageCode,
      );
    }

    final result = await _translator.getCaptionsViaIndividualTranslation(
      videoId,
      targetLanguageCode,
      sourceEnglishCaptions,
      _getPaymentService(),
      _getIsSubscribed(),
    );

    // バックグラウンド翻訳を開始
    if (result['errorMessage'] == null) {
      _translator.translateAllCaptionsWithStreamNotification(
        sourceEnglishCaptions,
        'en',
        targetLanguageCode,
        true, // 翻訳を実行する（内部で翻訳を取得）
        (updateData) => _captionUpdateStreamController.add(updateData),
      );
    }

    return {
      'displayCaptions': result['displayCaptions'],
      'displayLanguageCode': result['displayLanguageCode'],
      'sourceEnglishCaptions': sourceEnglishCaptions,
      'needsTranslation': result['needsTranslation'],
      'errorMessage': result['errorMessage'],
      'currentCaptionTextForError': result['errorMessage'] != null
          ? '字幕の取得に失敗しました。'
          : '',
      'nativeLanguageTrackExists': false,
      'nativeLanguageCaptionsIfAvailable': null,
      'isNativeYouTubeAutoTranslated': false,
    };
  }


  /// エラー結果の生成
  Map<String, dynamic> _createErrorResult(
    String currentCaptionTextForError,
    String errorMessage,
    String targetLanguageCode,
  ) {
    return {
      'displayCaptions': <yt_explode.ClosedCaption>[],
      'displayLanguageCode': targetLanguageCode,
      'sourceEnglishCaptions': <yt_explode.ClosedCaption>[],
      'needsTranslation': false,
      'errorMessage': errorMessage,
      'currentCaptionTextForError': currentCaptionTextForError,
      'nativeLanguageTrackExists': false,
      'nativeLanguageCaptionsIfAvailable': null,
      'isNativeYouTubeAutoTranslated': false,
    };
  }


  // 以下、従来のAPIとの互換性のためのデリゲートメソッド

  /// 全字幕のバックグラウンド翻訳
  Future<void> translateAllCaptionsInBackground(
    List<yt_explode.ClosedCaption> sourceCaptions,
    String sourceLanguageCode,
    String targetLanguageCode,
    bool executeTranslation,
    Function(bool isTranslating, bool areAllTranslated, Map<String, String> updatedCacheForLang) onUpdate,
  ) async {
    return _translator.translateAllCaptionsInBackground(
      sourceCaptions,
      sourceLanguageCode,
      targetLanguageCode,
      executeTranslation,
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
    return _translator.translateCurrentCaptionFallback(
      captionTextToTranslate,
      sourceLanguageCode,
      targetLanguageCode,
      executeTranslation,
      currentDisplayedOriginalCaption,
    );
  }

  /// キャッシュから翻訳取得
  String? getTranslatedCaptionFromCache(String originalCaptionText, String targetLanguageCode) {
    return _cache.get(originalCaptionText, targetLanguageCode);
  }

  /// 全翻訳完了チェック
  bool areAllCaptionsTranslated(String targetLanguageCode) {
    return _cache.areAllTranslated(targetLanguageCode);
  }

  /// 翻訳中チェック
  bool isTranslatingAllCaptions(String targetLanguageCode) {
    return _cache.isTranslatingAll(targetLanguageCode);
  }

  /// キャッシュクリア
  void clearCache() {
    _cache.clear();
  }

  /// リソース解放
  void dispose() {
    _captionUpdateStreamController.close();
    _fetcher.dispose();
  }
}

// プロバイダー定義
final captionServiceProvider = Provider.family<CaptionService, yt_explode.YoutubeExplode>((ref, ytExplode) {
  final service = CaptionService(
    ytExplode: ytExplode,
    getPaymentService: () => ref.read(translationPaymentServiceProvider),
    getIsSubscribed: () => ref.read(isSubscribedProvider),
  );
  
  // 字幕取得戦略を初期設定（watchを使わない）
  ref.read(captionFetchingStrategyProvider).when(
    data: (strategy) => service.setFetchingStrategy(strategy),
    loading: () => service.setFetchingStrategy(CaptionFetchingStrategy.individualTranslation),
    error: (error, stackTrace) {
      debugPrint('[CaptionService] Error loading caption strategy: $error, defaulting to individualTranslation.');
      service.setFetchingStrategy(CaptionFetchingStrategy.individualTranslation);
    },
  );

  ref.onDispose(() => service.dispose());
  return service;
});

// 字幕取得戦略の状態管理
final captionFetchingStrategyProvider = AsyncNotifierProvider<CaptionFetchingStrategyNotifier, CaptionFetchingStrategy>(() {
  return CaptionFetchingStrategyNotifier();
});

class CaptionFetchingStrategyNotifier extends AsyncNotifier<CaptionFetchingStrategy> {
  static const _prefKey = 'captionFetchingStrategy';

  @override
  Future<CaptionFetchingStrategy> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStrategyName = prefs.getString(_prefKey);
    if (savedStrategyName != null) {
      return CaptionFetchingStrategy.fromString(savedStrategyName);
    }
    return CaptionFetchingStrategy.individualTranslation;
  }

  Future<void> updateStrategy(CaptionFetchingStrategy newStrategy) async {
    state = AsyncValue.data(newStrategy);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newStrategy.name);
    debugPrint('[CaptionService] Caption strategy saved: ${newStrategy.name}');
  }
}