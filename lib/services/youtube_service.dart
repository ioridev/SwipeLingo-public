import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:googleapis_auth/auth_io.dart' as auth;
// import '../models/video.dart' as models; // Hiveモデルは不要に
import '../models/shared_video_model.dart'; // Firebase用モデルをインポート
import '../utils/youtube_utils.dart' as utils;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// TODO: YouTube Data APIキーを安全な方法で設定してください。
// 例: flutter_dotenv を使用して .env ファイルから読み込む
final _apiKey = dotenv.env['YOUTUBE_API_KEY'];
// const String _apiKey = 'YOUR_YOUTUBE_API_KEY'; // ここに実際のAPIキーを設定

// 追加: 検索結果とページネーショントークンを保持するクラス
class VideoSearchResponse {
  final List<SharedVideoModel> videos;
  final String? nextPageToken;
  final int? totalResults; // APIが提供する場合

  VideoSearchResponse({
    required this.videos,
    this.nextPageToken,
    this.totalResults,
  });
}

/// YouTube動画の情報と字幕を取得するサービスクラス。
class YoutubeService {
  final YoutubeExplode _yt;

  YoutubeService() : _yt = YoutubeExplode();

  /// 指定されたYouTube動画IDの字幕を取得します。
  ///
  /// [videoId] 字幕を取得したいYouTube動画のID。
  /// [languageCode] 優先する字幕の言語コード (例: 'en', 'ja')。指定しない場合は利用可能な最初のトラックを取得。
  ///
  /// 字幕が取得できた場合は字幕の文字列を返します。
  /// 字幕が存在しない、または取得に失敗した場合は例外をスローします。
  Future<String> getTranscript(String videoId, {String? languageCode}) async {
    try {
      final manifest = await _yt.videos.closedCaptions.getManifest(videoId);

      if (manifest.tracks.isEmpty) {
        throw Exception('No closed captions found for video ID: $videoId');
      }

      // 指定された言語コード、または利用可能な最初のトラックを選択
      ClosedCaptionTrackInfo? trackInfo;
      if (languageCode != null) {
        trackInfo = manifest.tracks.firstWhere(
          (track) => track.language.code == languageCode,
          orElse: () => manifest.tracks.first, // 見つからなければ最初のトラック
        );
      } else {
        trackInfo = manifest.tracks.first; // 指定がなければ最初のトラック
      }

      final track = await _yt.videos.closedCaptions.get(trackInfo);

      if (track.captions.isEmpty) {
        throw Exception(
          'Transcript is empty for video ID: $videoId (Language: ${trackInfo.language.code})',
        );
      }

      // 字幕テキストを結合
      final fullTranscript = track.captions
          .map((caption) => caption.text)
          .join(' ');
      return fullTranscript;
    } on VideoUnplayableException {
      // catch (e) を削除
      // debugPrint('Video $videoId is unplayable: $e'); // avoid_print: 削除
      throw Exception('Video is unplayable.');
    } on YoutubeExplodeException catch (e) {
      // youtube_explode_dartのその他のエラー
      // debugPrint('Failed to fetch transcript for video ID: $videoId. Error: $e'); // avoid_print: 削除
      throw Exception('Failed to fetch transcript: ${e.message}');
    } catch (e) {
      // その他の予期せぬエラー
      // debugPrint('An unexpected error occurred while fetching transcript for video ID: $videoId. Error: $e'); // avoid_print: 削除
      throw Exception(
        'An unexpected error occurred while fetching transcript.',
      );
    } finally {
      // YoutubeExplodeインスタンスを閉じる (必要に応じて)
      // 長時間実行されるアプリケーションでない場合は、毎回閉じる必要はないかもしれません。
      // _yt.close();
    }
  }

  /// 指定されたYouTube動画URLから動画情報と指定言語の字幕を取得します。
  ///
  /// [url] 動画のURL。
  /// [languageCode] 取得したい字幕の言語コード (例: 'en', 'ja')。
  ///
  /// 動画情報と英語のタイムスタンプ付き字幕を含む `SharedVideoModel` オブジェクトを返します。
  /// 情報取得に失敗した場合は例外をスローします。
  Future<SharedVideoModel> getVideoDetailsWithCaptions(String url) async {
    const languageCode = 'en'; // 英語字幕を固定で取得
    final videoId = utils.extractVideoId(url);
    if (videoId == null) {
      throw Exception('Invalid YouTube URL: $url');
    }

    try {
      // 1. 動画メタデータを取得
      final videoData = await _yt.videos.get(videoId);

      // 2. 字幕を取得
      final manifest = await _yt.videos.closedCaptions.getManifest(videoId);
      if (manifest.tracks.isEmpty) {
        throw Exception('No closed captions found for video ID: $videoId');
      }

      // 指定された言語コードのトラック情報を検索
      final trackInfo = manifest.tracks.firstWhere(
        (track) => track.language.code == languageCode,
        orElse: () => throw Exception('この動画には字幕がありません。英語字幕がある動画を入力してください。'),
      );

      final track = await _yt.videos.closedCaptions.get(trackInfo);

      // タイムスタンプ付き字幕データを Map のリストに変換
      final List<Map<String, dynamic>> captionsList =
          track.captions.map((caption) {
            return {
              'text': caption.text,
              // Duration を秒数 (double) に変換して保存
              'start': caption.offset.inMilliseconds / 1000.0,
              'end':
                  (caption.offset + caption.duration).inMilliseconds / 1000.0,
            };
          }).toList();

      if (captionsList.isEmpty) {
        throw Exception(
          'Caption list is empty for video ID: $videoId (Language: ${trackInfo.language.code})',
        );
      }

      // 3. SharedVideoModel オブジェクトを作成して返す
      return SharedVideoModel(
        id: videoId,
        url: url,
        title: videoData.title,
        channelName: videoData.author,
        thumbnailUrl: utils.getThumbnailUrl(videoId),
        createdAt: DateTime.now(), // 新規取得なので現在時刻
        updatedAt: DateTime.now(), // 新規取得なので現在時刻
        captionsWithTimestamps: {languageCode: captionsList},
        uploaderUid: null, // この時点ではアップローダー不明（呼び出し側で設定する）
      );
    } on VideoUnplayableException {
      // catch (e) を削除
      // debugPrint('Video $videoId is unplayable: $e'); // avoid_print: 削除
      throw Exception('Video is unplayable.');
    } on YoutubeExplodeException catch (e) {
      // debugPrint('Failed to fetch details/captions for video ID: $videoId. Error: $e'); // avoid_print: 削除
      throw Exception(
        'Failed to fetch video details or captions: ${e.message}',
      );
    } catch (e, s) {
      // ignore: avoid_print
      debugPrint(
        'An unexpected error occurred for video ID: $videoId. Error: $e',
      );
      // ignore: avoid_print
      debugPrint('Stack trace: $s');
      rethrow; // キャッチした例外をそのまま再スローする
    } finally {
      // _yt.close(); // 必要に応じて
    }
  }

  /// 指定されたクエリでYouTube動画を検索し、英語字幕を持つ動画のリストを返します。
  ///
  /// [query] 検索クエリ。
  /// [targetLanguageCode] 関連性の高い動画を検索するための言語コード (例: 'en', 'ja')。
  ///
  /// 字幕を持つ動画の情報 (タイトル, ID, チャンネル名, サムネイルURL) を含む
  /// `SharedVideoModel` のリストを返します。
  /// 検索結果がない場合やエラーが発生した場合は、空のリストまたは例外をスローします。
  Future<VideoSearchResponse> searchVideosWithCaptions(
    String query, {
    String? targetLanguageCode, // ユーザーのターゲット言語設定 (オプショナルに変更)
    String? pageToken, // 追加: ページネーショントークン
  }) async {
    // APIキーが未設定または空の場合は警告を表示して空の結果を返す
    final currentApiKey = _apiKey; // ローカル変数にコピー
    if (currentApiKey == null ||
        currentApiKey.isEmpty ||
        currentApiKey == 'YOUR_YOUTUBE_API_KEY') {
      // ignore: avoid_print
      debugPrint(
        '警告: YouTube Data APIキーが設定されていないか、無効です。lib/services/youtube_service.dart の _apiKey を設定してください。',
      );
      return VideoSearchResponse(videos: [], nextPageToken: null);
    }

    final List<SharedVideoModel> results = [];
    const maxResults = 10; // 取得する動画の最大数 (APIのデフォルトは5、最大50程度)

    try {
      // APIキーを使用して認証クライアントを作成
      final httpClient = auth.clientViaApiKey(currentApiKey); // ローカル変数を使用
      final youtubeApi = youtube.YouTubeApi(httpClient);

      final searchResponse = await youtubeApi.search.list(
        ['snippet'], // partパラメータ
        q: query,
        type: ['video'],
        videoCaption: 'closedCaption', // 字幕ありの動画のみを検索
        relevanceLanguage: targetLanguageCode, // ユーザーのターゲット言語を使用 (null許容)
        maxResults: (maxResults * 3).clamp(1, 50), // 3分未満動画除外を考慮して3倍取得
        pageToken: pageToken, // 追加: ページトークンを渡す
      );

      if (searchResponse.items == null || searchResponse.items!.isEmpty) {
        return VideoSearchResponse(
          videos: [],
          nextPageToken: searchResponse.nextPageToken,
        );
      }

      // 動画IDのリストを作成
      final videoIds = searchResponse.items!
          .where((item) => item.id?.videoId != null)
          .map((item) => item.id!.videoId!)
          .toList();

      if (videoIds.isEmpty) {
        return VideoSearchResponse(
          videos: [],
          nextPageToken: searchResponse.nextPageToken,
        );
      }

      // videos.list APIで動画の詳細情報（duration含む）を取得
      final videosResponse = await youtubeApi.videos.list(
        ['snippet', 'contentDetails'],
        id: videoIds,
      );

      if (videosResponse.items != null) {
        for (final video in videosResponse.items!) {
          if (video.id != null &&
              video.snippet?.title != null &&
              video.snippet?.channelTitle != null &&
              video.contentDetails?.duration != null) {
            
            // ISO 8601 duration（例: PT1M30S）をパース
            final durationString = video.contentDetails!.duration!;
            final duration = _parseDuration(durationString);
            
            // 3分未満の動画を除外（語学学習に適した長さの動画のみを対象）
            if (duration != null && duration.inSeconds >= 180) {
              results.add(
                SharedVideoModel(
                  id: video.id!,
                  url: 'https://www.youtube.com/watch?v=${video.id}',
                  title: video.snippet!.title!,
                  channelName: video.snippet!.channelTitle!,
                  thumbnailUrl: utils.getThumbnailUrl(video.id!),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  captionsWithTimestamps: {},
                  uploaderUid: null,
                ),
              );
            }
          }
        }
      }
      return VideoSearchResponse(
        videos: results.take(maxResults).toList(), // 元のmaxResultsに制限
        nextPageToken: searchResponse.nextPageToken,
        totalResults: searchResponse.pageInfo?.totalResults,
      );
    } on youtube.DetailedApiRequestError catch (e) {
      throw Exception(
        'Failed to search videos (API Error): ${e.message ?? "Unknown API error"}',
      );
    } catch (e) {
      debugPrint(
        'An unexpected error occurred while searching videos for query: $query. Error: $e',
      );
      throw Exception('An unexpected error occurred while searching videos.');
    }
  }

  /// 指定されたチャンネルIDの動画リストをYouTube API経由で取得します。
  ///
  /// [channelId] 動画リストを取得したいチャンネルのID。
  ///
  /// 動画情報のリスト (`SharedVideoModel` のリスト) を返します。
  /// 動画が見つからない場合やエラーが発生した場合は、空のリストまたは例外をスローします。
  Future<List<SharedVideoModel>> getVideosByChannelIdFromApi(
    String channelId,
  ) async {
    final List<SharedVideoModel> results = [];

    try {
      // チャンネルのアップロード動画を取得
      // getUploadsFromPage は ChannelUploadsList を返す。これには動画のリストが含まれる。
      // ChannelUploadsList は実際には Stream<Video> を継承しているため、toList() でリストに変換できる。
      final videoList = await _yt.channels.getUploadsFromPage(channelId);

      if (videoList.isEmpty) {
        return []; // 動画がない場合は空のリストを返す
      }

      for (final videoData in videoList) {
        try {
          // 3分未満の動画を除外（語学学習に適した長さの動画のみを対象）
          if (videoData.duration != null && videoData.duration!.inSeconds >= 180) {
            results.add(
              SharedVideoModel(
                id: videoData.id.value,
                url: 'https://www.youtube.com/watch?v=${videoData.id.value}',
                title: videoData.title,
                channelName: videoData.author, // videoData からチャンネル名を取得
                thumbnailUrl: utils.getThumbnailUrl(videoData.id.value),
                createdAt:
                    videoData.uploadDate ?? DateTime.now(), // アップロード日があれば使用
                updatedAt: DateTime.now(), // APIから取得した時点
                captionsWithTimestamps: {}, // 関連動画では字幕データは不要
                uploaderUid: null,
              ),
            );
          }
        } on VideoUnplayableException {
          // この動画は再生不可なのでスキップ
          continue;
        } on YoutubeExplodeException {
          // 個々の動画処理でエラーが発生した場合もスキップ
          continue;
        }
      }
      return results;
    } on YoutubeExplodeException catch (e) {
      // チャンネル動画の取得自体に失敗した場合
      // debugPrint('Failed to fetch videos for channel ID: $channelId. Error: $e');
      throw Exception('Failed to fetch videos for channel: ${e.message}');
    } catch (e) {
      // その他の予期せぬエラー
      throw Exception(
        'An unexpected error occurred while fetching videos for channel.',
      );
    }
  }

  /// 指定されたチャンネルIDの動画リストを、指定された件数だけYouTube API経由で取得します。
  ///
  /// [channelId] 動画リストを取得したいチャンネルのID。
  /// [count] 取得する動画の最大件数。
  ///
  /// 動画情報のリスト (`SharedVideoModel` のリスト) を返します。
  /// 動画が見つからない場合やエラーが発生した場合は、空のリストまたは例外をスローします。
  Future<List<SharedVideoModel>> getLimitedChannelUploads(
    String channelId,
    int count,
  ) async {
    final List<SharedVideoModel> results = [];

    try {
      // チャンネルのアップロード動画をStreamとして取得し、指定件数だけ取り出す
      final videoStream = _yt.channels.getUploads(ChannelId(channelId));
      final videoList = await videoStream.take(count).toList();

      if (videoList.isEmpty) {
        return []; // 動画がない場合は空のリストを返す
      }

      for (final videoData in videoList) {
        try {
          // 3分未満の動画を除外（語学学習に適した長さの動画のみを対象）
          if (videoData.duration != null && videoData.duration!.inSeconds >= 180) {
            results.add(
              SharedVideoModel(
                id: videoData.id.value,
                url: 'https://www.youtube.com/watch?v=${videoData.id.value}',
                title: videoData.title,
                channelName: videoData.author,
                thumbnailUrl: utils.getThumbnailUrl(videoData.id.value),
                createdAt: videoData.uploadDate ?? DateTime.now(),
                updatedAt: DateTime.now(),
                captionsWithTimestamps: {},
                uploaderUid: null,
              ),
            );
          }
        } on VideoUnplayableException {
          continue;
        } on YoutubeExplodeException {
          continue;
        }
      }
      return results;
    } on YoutubeExplodeException catch (e) {
      // debugPrint('Failed to fetch limited videos for channel ID: $channelId. Error: $e');
      throw Exception(
        'Failed to fetch limited videos for channel: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'An unexpected error occurred while fetching limited videos for channel.',
      );
    }
  }

  /// 指定されたチャンネルIDの動画リストを、指定された件数だけYouTube API経由で取得し、視聴済みの動画を除外します。
  ///
  /// [channelId] 動画リストを取得したいチャンネルのID。
  /// [count] 取得する動画の最大件数。
  /// [watchedVideoIds] 除外する視聴済み動画のIDリスト。
  ///
  /// 動画情報のリスト (`SharedVideoModel` のリスト) を返します。
  /// 動画が見つからない場合やエラーが発生した場合は、空のリストまたは例外をスローします。
  Future<List<SharedVideoModel>> getChannelUploadsExcludingWatched(
    String channelId,
    int count,
  ) async {
    final List<SharedVideoModel> results = [];
    // APIキーが未設定または空の場合は警告を表示して空の結果を返す
    final currentApiKey = _apiKey; // ローカル変数にコピー
    if (currentApiKey == null ||
        currentApiKey.isEmpty ||
        currentApiKey == 'YOUR_YOUTUBE_API_KEY') {
      debugPrint(
        '警告: YouTube Data APIキーが設定されていないか、無効です。lib/services/youtube_service.dart の _apiKey を設定してください。',
      );
      return [];
    }

    try {
      final httpClient = auth.clientViaApiKey(currentApiKey);
      final youtubeApi = youtube.YouTubeApi(httpClient);

      // 1. チャンネルIDからUploadsプレイリストIDを取得
      final channelsResponse = await youtubeApi.channels.list(
        ['contentDetails'],
        id: [channelId],
      );

      if (channelsResponse.items == null || channelsResponse.items!.isEmpty) {
        debugPrint('Channel not found or no content details: $channelId');
        return [];
      }
      final uploadsPlaylistId =
          channelsResponse
              .items!
              .first
              .contentDetails
              ?.relatedPlaylists
              ?.uploads;

      if (uploadsPlaylistId == null) {
        debugPrint('Uploads playlist ID not found for channel: $channelId');
        return [];
      }

      // 2. Uploadsプレイリストから最新の動画を取得 (3分未満動画除外を考慮し、多めに取得)
      // APIのmaxResultsの上限は50
      final int itemsToFetch = (count * 3).clamp(1, 50); // 3分未満動画除外を考慮して3倍取得
      final playlistItemsResponse = await youtubeApi.playlistItems.list(
        ['snippet'],
        playlistId: uploadsPlaylistId,
        maxResults: itemsToFetch,
      );

      if (playlistItemsResponse.items == null ||
          playlistItemsResponse.items!.isEmpty) {
        return [];
      }

      // 3. 動画IDのリストを作成して、duration情報を取得
      final videoIds = playlistItemsResponse.items!
          .where((item) => item.snippet?.resourceId?.videoId != null)
          .map((item) => item.snippet!.resourceId!.videoId!)
          .toList();

      if (videoIds.isEmpty) {
        return [];
      }

      // 4. videos.list APIで動画の詳細情報（duration含む）を取得
      final videosResponse = await youtubeApi.videos.list(
        ['snippet', 'contentDetails'],
        id: videoIds,
      );

      if (videosResponse.items == null || videosResponse.items!.isEmpty) {
        return [];
      }

      // 5. ショート動画をフィルタリングして結果を作成
      for (final video in videosResponse.items!) {
        if (video.id != null &&
            video.snippet?.title != null &&
            video.snippet?.channelTitle != null &&
            video.snippet?.publishedAt != null &&
            video.contentDetails?.duration != null) {
          
          // ISO 8601 duration（例: PT1M30S）をパース
          final durationString = video.contentDetails!.duration!;
          final duration = _parseDuration(durationString);
          
          // 3分未満の動画を除外（語学学習に適した長さの動画のみを対象）
          if (duration != null && duration.inSeconds >= 180) {
            results.add(
              SharedVideoModel(
                id: video.id!,
                url: 'https://www.youtube.com/watch?v=${video.id}',
                title: video.snippet!.title!,
                channelName: video.snippet!.channelTitle!,
                thumbnailUrl: utils.getThumbnailUrl(video.id!),
                createdAt: video.snippet!.publishedAt!,
                updatedAt: DateTime.now(),
                captionsWithTimestamps: {},
                uploaderUid: null,
              ),
            );
          }
        }
        
        // 必要な件数に達したら終了
        if (results.length >= count) {
          break;
        }
      }

      return results.take(count).toList();
    } on youtube.DetailedApiRequestError catch (e) {
      debugPrint(
        'Failed to fetch channel uploads (API Error) for $channelId: ${e.message ?? "Unknown API error"}',
      );
      throw Exception(
        'Failed to fetch channel uploads (API Error): ${e.message ?? "Unknown API error"}',
      );
    } catch (e, s) {
      debugPrint(
        'An unexpected error occurred while fetching channel uploads for $channelId: $e',
      );
      debugPrint('Stack trace: $s');
      throw Exception(
        'An unexpected error occurred while fetching channel uploads.',
      );
    }
  }

  /// ISO 8601 duration文字列をDurationオブジェクトに変換
  /// 例: "PT1M30S" -> Duration(minutes: 1, seconds: 30)
  Duration? _parseDuration(String isoDuration) {
    try {
      final RegExp regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
      final match = regex.firstMatch(isoDuration);
      
      if (match == null) return null;
      
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
      
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } catch (e) {
      debugPrint('Failed to parse duration: $isoDuration');
      return null;
    }
  }

}
