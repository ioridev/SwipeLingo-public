import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;
import 'youtube_transcript_fetcher.dart';

/// YouTube字幕の取得を担当するクラス
class CaptionFetcher {
  final yt_explode.YoutubeExplode _ytExplode;
  final YouTubeTranscriptFetcher _transcriptFetcher;
  
  CaptionFetcher(
    this._ytExplode,
  ) : _transcriptFetcher = YouTubeTranscriptFetcher();

  /// YouTube字幕マニフェストを取得
  Future<yt_explode.ClosedCaptionManifest> getCaptionManifest(
    String videoId,
  ) async {
    try {
      // まずyoutube_explode_dartの標準実装を試し、失敗したら代替実装を使用
      return await _ytExplode.videos.closedCaptions.getManifest(videoId);
    } catch (e) {
      debugPrint('[CaptionFetcher] Standard manifest fetch failed: $e');
      // マニフェスト取得が失敗した場合、エラーを再スロー
      // CaptionService側で代替実装にフォールバックする
      rethrow;
    }
  }

  /// 指定言語の字幕トラックを取得
  Future<List<yt_explode.ClosedCaption>?> getCaptionTrack(
    yt_explode.ClosedCaptionManifest manifest,
    String languageCode,
  ) async {
    // まず標準実装を試す
    try {
      yt_explode.ClosedCaptionTrackInfo? trackInfo;
      try {
        trackInfo = manifest.tracks.firstWhere(
          (track) => track.language.code == languageCode,
        );
      } on StateError {
        return null;
      }

      final track = await _ytExplode.videos.closedCaptions.get(trackInfo);
      return track.captions;
    } catch (e) {
      debugPrint('[CaptionFetcher] Standard caption fetch failed, using fallback: $e');
      // 標準実装が失敗した場合は代替実装を使用
      return null;
    }
  }

  /// YouTube自動翻訳字幕を取得（XMLスクレイピングは無効化）
  Future<List<yt_explode.ClosedCaption>?> getAutoTranslatedCaptions(
    yt_explode.ClosedCaptionTrackInfo baseTrackInfo,
    String targetLanguageCode,
    dynamic paymentService,
    bool isSubscribed,
  ) async {
    // XMLスクレイピングは無効化されました
    debugPrint('[CaptionFetcher] XML scraping is disabled. Returning null.');
    return null;
  }

  /// 英語字幕を基準とした自動翻訳字幕を取得（XMLスクレイピングは無効化）
  Future<List<yt_explode.ClosedCaption>?> getAutoTranslatedFromEnglish(
    yt_explode.ClosedCaptionManifest manifest,
    String targetLanguageCode,
    dynamic paymentService,
    bool isSubscribed,
  ) async {
    // XMLスクレイピングは無効化されました
    debugPrint('[CaptionFetcher] XML scraping is disabled. Returning null.');
    return null;
  }

  /// フォールバック字幕（利用可能な最初の字幕）を取得
  Future<Map<String, dynamic>?> getFallbackCaptions(
    yt_explode.ClosedCaptionManifest manifest,
    String targetLanguageCode,
  ) async {
    if (manifest.tracks.isEmpty) {
      return null;
    }

    final fallbackTrackInfo = manifest.tracks.first;
    final fallbackTrack = await _ytExplode.videos.closedCaptions.get(fallbackTrackInfo);
    
    return {
      'captions': fallbackTrack.captions,
      'languageCode': fallbackTrackInfo.language.code,
      'needsTranslation': fallbackTrackInfo.language.code != targetLanguageCode,
    };
  }

  /// 字幕が利用可能かチェック
  bool hasCaptionsAvailable(yt_explode.ClosedCaptionManifest manifest) {
    return manifest.tracks.isNotEmpty;
  }

  /// 指定言語の字幕が利用可能かチェック
  bool hasLanguageCaptionsAvailable(
    yt_explode.ClosedCaptionManifest manifest,
    String languageCode,
  ) {
    return manifest.tracks.any((track) => track.language.code == languageCode);
  }

  /// 利用可能な言語一覧を取得
  List<String> getAvailableLanguages(yt_explode.ClosedCaptionManifest manifest) {
    return manifest.tracks.map((track) => track.language.code).toSet().toList();
  }
  
  /// 代替実装を使用して字幕を取得（video IDのみ使用）
  Future<List<yt_explode.ClosedCaption>?> getCaptionTrackDirect(
    String videoId,
    String languageCode,
  ) async {
    try {
      debugPrint('[CaptionFetcher] Using alternative implementation for video: $videoId, language: $languageCode');
      final captions = await _transcriptFetcher.fetchTranscript(
        videoId,
        languageCode: languageCode,
      );
      return captions;
    } catch (e) {
      debugPrint('[CaptionFetcher] Alternative implementation also failed: $e');
      return null;
    }
  }
  
  /// 代替実装を使用して字幕が利用可能か確認
  Future<bool> hasCaptionsAvailableDirect(String videoId) async {
    try {
      debugPrint('[CaptionFetcher] Checking captions availability using alternative implementation');
      return await _transcriptFetcher.hasCaptions(videoId);
    } catch (e) {
      debugPrint('[CaptionFetcher] Error checking captions availability: $e');
      return false;
    }
  }
  
  /// 代替実装を使用して利用可能な言語一覧を取得
  Future<List<String>> getAvailableLanguagesDirect(String videoId) async {
    try {
      final languages = await _transcriptFetcher.getAvailableLanguages(videoId);
      return languages.map((lang) => lang['code'] ?? '').where((code) => code.isNotEmpty).toList();
    } catch (e) {
      debugPrint('[CaptionFetcher] Error getting available languages: $e');
      return [];
    }
  }
  
  void dispose() {
    _transcriptFetcher.dispose();
  }
}