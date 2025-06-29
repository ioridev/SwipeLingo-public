import 'dart:async'; // StreamSubscription のために追加

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shared_video_model.dart';
import '../models/watch_history_model.dart'; // WatchHistoryモデルをインポート
import '../repositories/firebase_repository.dart';
import '../services/youtube_service.dart';
import 'repository_providers.dart';
import '../data/recommended_videos.dart';
import '../models/user_model.dart';

class VideoListNotifier
    extends StateNotifier<AsyncValue<List<SharedVideoModel>>> {
  final Ref _ref;
  final FirebaseRepository _firebaseRepository;
  StreamSubscription? _userVideoIdsSubscription;
  StreamSubscription? _videosSubscription;
  final String? _userId;

  VideoListNotifier(this._ref)
    : _firebaseRepository = _ref.read(firebaseRepositoryProvider),
      _userId = FirebaseAuth.instance.currentUser?.uid,
      super(const AsyncValue.loading()) {
    if (_userId != null) {
      _subscribeToUserVideoIds(_userId);
    } else {
      state = AsyncValue.data([]); // ユーザーがログインしていない場合は空のリスト
    }
  }

  void _subscribeToUserVideoIds(String userId) {
    _userVideoIdsSubscription?.cancel();
    state = const AsyncValue.loading();
    try {
      _userVideoIdsSubscription = _firebaseRepository
          .getUserVideoIdsStream(userId)
          .listen(
            (videoIds) {
              _subscribeToVideos(videoIds);
            },
            onError: (e, stackTrace) {
              debugPrint("Error in user video IDs stream: $e");
              state = AsyncValue.error(e, stackTrace);
            },
          );
    } catch (e, stackTrace) {
      debugPrint("Error setting up user video IDs stream: $e");
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void _subscribeToVideos(List<String> videoIds) {
    _videosSubscription?.cancel();
    if (videoIds.isEmpty) {
      state = AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      // getSharedVideosByIdsStream が List<String> を受け取るように変更したため、
      // 直接 videoIds を渡す。
      _videosSubscription = _firebaseRepository
          .getSharedVideosByIdsStream(videoIds)
          .listen(
            (videos) {
              videos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              state = AsyncValue.data(videos);
            },
            onError: (e, stackTrace) {
              debugPrint("Error in shared videos stream: $e");
              state = AsyncValue.error(e, stackTrace);
            },
          );
    } catch (e, stackTrace) {
      debugPrint("Error setting up shared videos stream: $e");
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteDeck(String videoId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not logged in.");
    }
    try {
      // Firestoreから動画情報を削除 (FirebaseRepositoryにメソッド追加が必要な場合)
      // await _firebaseRepository.deleteSharedVideo(videoId);
      debugPrint(
        "Video deletion from shared 'videos' collection is TBD/not implemented in this phase as per plan (usually admin only).",
      );

      // Firestoreから関連カードを削除
      await _firebaseRepository.deleteAllCardsForVideo(userId, videoId);

      debugPrint(
        "Deck (cards for video $videoId) deleted successfully for user $userId.",
      );
    } catch (e) {
      debugPrint("Error deleting deck $videoId: $e");
      throw Exception("Failed to delete deck: $e");
    }
  }

  @override
  void dispose() {
    _userVideoIdsSubscription?.cancel();
    _videosSubscription?.cancel();
    super.dispose();
  }
}

final videoListProvider = StateNotifierProvider<
  VideoListNotifier,
  AsyncValue<List<SharedVideoModel>>
>((ref) {
  return VideoListNotifier(ref);
});

// 関連動画の状態
enum RelatedVideosStatus { initial, loading, success, error }

@immutable
class RelatedVideosState {
  final RelatedVideosStatus status;
  final List<SharedVideoModel> videos;
  final String? errorMessage;
  final String? currentVideoId; // 現在再生中の動画ID（関連動画取得のトリガーとなった動画）

  const RelatedVideosState({
    this.status = RelatedVideosStatus.initial,
    this.videos = const [],
    this.errorMessage,
    this.currentVideoId,
  });

  RelatedVideosState copyWith({
    RelatedVideosStatus? status,
    List<SharedVideoModel>? videos,
    String? errorMessage,
    String? currentVideoId,
    bool resetErrorMessage = false,
  }) {
    return RelatedVideosState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      errorMessage:
          resetErrorMessage ? null : errorMessage ?? this.errorMessage,
      currentVideoId: currentVideoId ?? this.currentVideoId,
    );
  }
}

// 関連動画のNotifier
class RelatedVideosNotifier extends StateNotifier<RelatedVideosState> {
  final YoutubeService
  _youtubeService; // FirebaseRepository から YoutubeService に変更
  final String? _currentVideoIdToExclude; // 表示中の動画（これを除外する）

  RelatedVideosNotifier(
    this._youtubeService,
    this._currentVideoIdToExclude,
  ) // 引数を変更
  : super(const RelatedVideosState());

  Future<void> fetchRelatedVideos(String channelId) async {
    if (state.status == RelatedVideosStatus.loading) return;
    state = state.copyWith(
      status: RelatedVideosStatus.loading,
      currentVideoId: _currentVideoIdToExclude, // fetchが呼ばれた時点の動画IDを記録
      resetErrorMessage: true,
    );

    try {
      // YoutubeService のメソッドを呼び出すように変更
      final allVideosInChannel = await _youtubeService
          .getVideosByChannelIdFromApi(channelId);

      final relatedVideos =
          allVideosInChannel
              .where((video) => video.id != _currentVideoIdToExclude)
              .toList();

      // 例えば作成日時で降順ソートし、最大10件に制限
      relatedVideos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final limitedVideos = relatedVideos.take(10).toList();

      state = state.copyWith(
        status: RelatedVideosStatus.success,
        videos: limitedVideos,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Error fetching related videos for channel $channelId: $e\n$stackTrace',
      );
      state = state.copyWith(
        status: RelatedVideosStatus.error,
        errorMessage: '関連動画の取得に失敗しました。',
      );
    }
  }
}

// 関連動画のProvider
// Family Modifier を使用して、除外する現在の動画IDを渡す
final relatedVideosNotifierProvider = StateNotifierProvider.family<
  RelatedVideosNotifier,
  RelatedVideosState,
  String?
>((ref, currentVideoIdToExclude) {
  final youtubeService = ref.watch(
    youtubeServiceProvider,
  ); // youtubeServiceProvider を使用
  return RelatedVideosNotifier(youtubeService, currentVideoIdToExclude);
});

// おすすめ動画（静的＋お気に入りチャンネル）のNotifier
class RecommendedVideosNotifier
    extends StateNotifier<AsyncValue<List<SharedVideoModel>>> {
  final Ref _ref;
  final FirebaseRepository _firebaseRepository;
  final YoutubeService _youtubeService;
  final String? _userId;

  RecommendedVideosNotifier(this._ref)
    : _firebaseRepository = _ref.read(firebaseRepositoryProvider),
      _youtubeService = _ref.read(youtubeServiceProvider),
      _userId = FirebaseAuth.instance.currentUser?.uid,
      super(const AsyncValue.loading()) {
    fetchRecommendedVideos();
  }

  Future<void> fetchRecommendedVideos() async {
    state = const AsyncValue.loading();
    try {
      List<SharedVideoModel> recommendedFromHistory = [];
      List<SharedVideoModel> recommendedFromFavorites = [];
      List<SharedVideoModel> recommendedFromStatic = [];
      List<String> watchedVideoIds = [];
      UserModel? currentUser; // ユーザー情報を保持する変数

      if (_userId != null) {
        // 0. Firestoreからのデータ取得を並行化
        final List<dynamic> results = await Future.wait([
          // 型を List<dynamic> に変更
          _firebaseRepository.getWatchHistoryStream(_userId).first.catchError((
            e,
          ) {
            debugPrint("Error fetching watch history: $e");
            return <WatchHistory>[]; // クラス名を修正
          }),
          _firebaseRepository.getUserVideoIds(_userId).catchError((e) {
            debugPrint("Error fetching user card video IDs: $e");
            return <String>[]; // エラー時は空リスト
          }),
          _firebaseRepository.getUser(_userId).catchError((e) {
            debugPrint("Error fetching user data: $e");
            return null; // エラー時はnull
          }),
        ]);

        final List<WatchHistory> userWatchHistory =
            results[0] as List<WatchHistory>; // クラス名を修正
        final List<String> userCardVideoIds =
            results[1] as List<String>; // 正しい型にキャスト
        currentUser = results[2] as UserModel?;

        watchedVideoIds.addAll(userWatchHistory.map((wh) => wh.videoId));
        watchedVideoIds.addAll(userCardVideoIds);
        watchedVideoIds = watchedVideoIds.toSet().toList(); // 重複排除

        // 1. 視聴履歴ベースの推薦 (YouTube API呼び出しの並行化)
        if (userWatchHistory.isNotEmpty) {
          final List<String> recentChannelIds = // 型を明示
              userWatchHistory
                  .map((wh) => wh.channelId)
                  .toSet()
                  .take(8) // より多くのチャンネルから推薦動画を取得
                  .toList();

          final List<List<SharedVideoModel>>
          historyChannelVideosLists = await Future.wait(
            recentChannelIds.map((channelId) {
              // channelId は String として扱われる
              return _youtubeService
                  .getChannelUploadsExcludingWatched(
                    channelId,
                    5, // 各チャンネルから取得する動画数を増加
                  )
                  .catchError((e) {
                    debugPrint(
                      "Error fetching videos for watched channel $channelId: $e",
                    );
                    return <SharedVideoModel>[]; // エラー時は空リスト
                  });
            }).toList(),
          );
          recommendedFromHistory =
              historyChannelVideosLists.expand((list) => list).toList();
          recommendedFromHistory.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
        }

        // 2. お気に入りチャンネルベースの推薦 (YouTube API呼び出しの並行化)
        if (currentUser != null && currentUser.favoriteChannelIds.isNotEmpty) {
          final List<List<SharedVideoModel>>
          favoriteChannelVideosLists = await Future.wait(
            currentUser.favoriteChannelIds.map((channelId) {
              return _youtubeService
                  .getChannelUploadsExcludingWatched(
                    channelId,
                    5, // 各チャンネルから取得する動画数を増加
                  )
                  .catchError((e) {
                    debugPrint(
                      "Error fetching videos for favorite channel $channelId: $e",
                    );
                    return <SharedVideoModel>[]; // エラー時は空リスト
                  });
            }).toList(),
          );
          recommendedFromFavorites =
              favoriteChannelVideosLists.expand((list) => list).toList();
          recommendedFromFavorites.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
        }
      }

      // 3. 静的リストベースの推薦
      List<SharedVideoModel> sourceRecommendedVideos;
      // _userId が null でない場合、並行取得した currentUser を利用
      if (_userId != null && currentUser != null) {
        if (currentUser.targetLanguageCode == 'ja') {
          sourceRecommendedVideos = recommendedVideosJa;
        } else {
          sourceRecommendedVideos = recommendedVideos;
        }
      } else {
        // _userId が null の場合 (または currentUser が何らかの理由で null の場合)
        sourceRecommendedVideos = recommendedVideos;
      }
      recommendedFromStatic =
          sourceRecommendedVideos
              .map(
                (item) => SharedVideoModel(
                  id: item.id,
                  url: item.url,
                  title: item.title,
                  channelName: item.channelName,
                  thumbnailUrl: item.thumbnailUrl,
                  createdAt: item.createdAt,
                  updatedAt: item.updatedAt,
                  captionsWithTimestamps: item.captionsWithTimestamps ?? {},
                ),
              )
              .toList();
      recommendedFromStatic.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 推薦リストの統合と重複排除
      List<SharedVideoModel> finalRecommendedVideos = [];
      final Set<String> addedVideoIds = {};

      void addVideosToList(List<SharedVideoModel> videos) {
        for (var video in videos) {
          if (!addedVideoIds.contains(video.id) &&
              !watchedVideoIds.contains(video.id)) {
            finalRecommendedVideos.add(video);
            addedVideoIds.add(video.id);
          }
        }
      }

      addVideosToList(recommendedFromHistory);
      addVideosToList(recommendedFromFavorites);
      addVideosToList(recommendedFromStatic);

      // 最終的なリストを createdAt で再度ソートする必要はない（各リストはソート済みで、追加順で優先）
      // ただし、全体で一意なソート順が必要な場合はここでソートする。
      // 今回はカテゴリごとの優先度を維持するため、ここではソートしない。

      state = AsyncValue.data(finalRecommendedVideos.take(30).toList());
    } catch (e, stackTrace) {
      debugPrint("Error fetching recommended videos: $e \n$stackTrace");
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final recommendedVideosProvider = StateNotifierProvider<
  RecommendedVideosNotifier,
  AsyncValue<List<SharedVideoModel>>
>((ref) {
  return RecommendedVideosNotifier(ref);
});

// チャンネル動画一覧の状態
// RelatedVideosStatus と同様のものが使えるが、明確にするために別途定義しても良い
// ここでは AsyncValue<List<SharedVideoModel>> を直接使うため、状態クラスは不要

// チャンネル動画一覧のNotifier
class ChannelVideosNotifier
    extends StateNotifier<AsyncValue<List<SharedVideoModel>>> {
  final YoutubeService _youtubeService;
  final String _channelId;

  ChannelVideosNotifier(this._youtubeService, this._channelId)
    : super(const AsyncValue.loading()) {
    fetchChannelVideos();
  }

  Future<void> fetchChannelVideos() async {
    state = const AsyncValue.loading();
    try {
      final videos = await _youtubeService.getVideosByChannelIdFromApi(
        _channelId,
      );
      // 必要に応じてソートなどを行う
      videos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = AsyncValue.data(videos);
    } catch (e, stackTrace) {
      debugPrint(
        'Error fetching videos for channel $_channelId: $e\n$stackTrace',
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// チャンネル動画一覧のProvider
// Family Modifier を使用して、channelId を渡す
final channelVideosProvider = StateNotifierProvider.family<
  ChannelVideosNotifier,
  AsyncValue<List<SharedVideoModel>>,
  String
>((ref, channelId) {
  final youtubeService = ref.watch(youtubeServiceProvider);
  return ChannelVideosNotifier(youtubeService, channelId);
});
