import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;

/// YouTube字幕取得の代替実装
/// GitHub Issue #349の解決策に基づく実装
class YouTubeTranscriptFetcher {
  static const String _userAgent = 
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';
  
  final http.Client _httpClient;

  YouTubeTranscriptFetcher({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  /// 動画IDから字幕を取得
  Future<List<yt_explode.ClosedCaption>> fetchTranscript(
    String videoId, {
    String? languageCode,
  }) async {
    try {
      debugPrint('[YouTubeTranscriptFetcher] Fetching transcript for video: $videoId, language: $languageCode');
      
      // まず動画ページのHTMLを取得
      final videoPageHtml = await _fetchVideoPage(videoId);
      
      // HTMLからAPIキーとInnerTubeデータを抽出
      final apiKey = _extractApiKey(videoPageHtml);
      if (apiKey == null) {
        throw Exception('Failed to extract API key');
      }
      
      // InnerTube APIを使用して字幕トラック情報を取得
      final captionTracks = await _fetchCaptionTracks(videoId, apiKey);
      
      // 利用可能な字幕トラックから指定言語または最初のトラックを選択
      final selectedTrack = _selectCaptionTrack(captionTracks, languageCode);
      if (selectedTrack == null) {
        throw Exception('No caption tracks available');
      }
      
      // 選択したトラックのXMLを取得してパース
      final captionXml = await _fetchCaptionXml(selectedTrack['baseUrl']);
      return _parseCaptionXml(captionXml);
      
    } catch (e, s) {
      debugPrint('[YouTubeTranscriptFetcher] Error fetching transcript: $e');
      debugPrint('[YouTubeTranscriptFetcher] Stack trace: $s');
      rethrow;
    }
  }

  /// 利用可能な字幕言語一覧を取得
  Future<List<Map<String, String>>> getAvailableLanguages(String videoId) async {
    try {
      final videoPageHtml = await _fetchVideoPage(videoId);
      final apiKey = _extractApiKey(videoPageHtml);
      if (apiKey == null) {
        throw Exception('Failed to extract API key');
      }
      
      final captionTracks = await _fetchCaptionTracks(videoId, apiKey);
      return captionTracks.map((track) => <String, String>{
        'code': track['languageCode']?.toString() ?? '',
        'name': track['name']?['simpleText']?.toString() ?? track['name']?['runs']?[0]?['text']?.toString() ?? '',
      }).toList();
      
    } catch (e) {
      debugPrint('[YouTubeTranscriptFetcher] Error getting available languages: $e');
      return [];
    }
  }
  
  /// 字幕が利用可能か確認
  Future<bool> hasCaptions(String videoId) async {
    try {
      final languages = await getAvailableLanguages(videoId);
      return languages.isNotEmpty;
    } catch (e) {
      debugPrint('[YouTubeTranscriptFetcher] Error checking captions availability: $e');
      return false;
    }
  }
  
  /// 特定の言語の字幕が利用可能か確認
  Future<bool> hasLanguageCaption(String videoId, String languageCode) async {
    try {
      final languages = await getAvailableLanguages(videoId);
      return languages.any((lang) => lang['code'] == languageCode);
    } catch (e) {
      debugPrint('[YouTubeTranscriptFetcher] Error checking language caption availability: $e');
      return false;
    }
  }

  /// 動画ページのHTMLを取得
  Future<String> _fetchVideoPage(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    final response = await _httpClient.get(
      Uri.parse(url),
      headers: {'User-Agent': _userAgent},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch video page: ${response.statusCode}');
    }
    
    return response.body;
  }

  /// HTMLからAPIキーを抽出
  String? _extractApiKey(String html) {
    final regex = RegExp(r'"INNERTUBE_API_KEY":"([^"]+)"');
    final match = regex.firstMatch(html);
    return match?.group(1);
  }

  /// InnerTube APIを使用して字幕トラック情報を取得
  Future<List<Map<String, dynamic>>> _fetchCaptionTracks(String videoId, String apiKey) async {
    final url = 'https://www.youtube.com/youtubei/v1/player?key=$apiKey';
    
    final body = jsonEncode({
      'videoId': videoId,
      'context': {
        'client': {
          'clientName': 'WEB',
          'clientVersion': '2.20210721.00.00',
        },
      },
    });
    
    final response = await _httpClient.post(
      Uri.parse(url),
      headers: {
        'User-Agent': _userAgent,
        'Content-Type': 'application/json',
      },
      body: body,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch caption tracks: ${response.statusCode}');
    }
    
    final data = jsonDecode(response.body);
    final captions = data['captions'];
    if (captions == null) {
      return [];
    }
    
    final captionTracks = captions['playerCaptionsTracklistRenderer']?['captionTracks'];
    if (captionTracks == null) {
      return [];
    }
    
    return List<Map<String, dynamic>>.from(captionTracks);
  }

  /// 字幕トラックを選択
  Map<String, dynamic>? _selectCaptionTrack(
    List<Map<String, dynamic>> tracks,
    String? languageCode,
  ) {
    if (tracks.isEmpty) return null;
    
    // 指定言語のトラックを探す
    if (languageCode != null) {
      for (final track in tracks) {
        if (track['languageCode'] == languageCode) {
          return track;
        }
      }
    }
    
    // 見つからない場合は最初のトラックを返す
    return tracks.first;
  }

  /// 字幕XMLを取得
  Future<String> _fetchCaptionXml(String url) async {
    final response = await _httpClient.get(
      Uri.parse(url),
      headers: {'User-Agent': _userAgent},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch caption XML: ${response.statusCode}');
    }
    
    return response.body;
  }

  /// 字幕XMLをパース
  List<yt_explode.ClosedCaption> _parseCaptionXml(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    final captions = <yt_explode.ClosedCaption>[];
    
    final textElements = document.findAllElements('text');
    for (final element in textElements) {
      final start = element.getAttribute('start');
      final dur = element.getAttribute('dur');
      final text = _decodeHtmlEntities(element.innerText);
      
      if (start != null && dur != null && text.isNotEmpty) {
        final startSeconds = double.tryParse(start);
        final durSeconds = double.tryParse(dur);
        
        if (startSeconds != null && durSeconds != null) {
          final offset = Duration(milliseconds: (startSeconds * 1000).round());
          final duration = Duration(milliseconds: (durSeconds * 1000).round());
          
          captions.add(yt_explode.ClosedCaption(
            text,
            offset,
            duration,
            const [],
          ));
        }
      }
    }
    
    return captions;
  }

  /// HTMLエンティティをデコード
  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  void dispose() {
    _httpClient.close();
  }
}