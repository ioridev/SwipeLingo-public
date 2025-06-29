import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/models/playlist_model.dart';
import 'package:swipelingo/models/shared_video_model.dart';
import 'package:swipelingo/providers/repository_providers.dart';
import 'package:swipelingo/repositories/firebase_repository.dart';

// ユーザーのプレイリスト一覧
final userPlaylistsStreamProvider = StreamProvider.autoDispose<List<PlaylistModel>>((ref) {
  final repository = ref.watch(firebaseRepositoryProvider);
  return repository.getUserPlaylistsStream(null); // 現在のユーザーのプレイリスト
});

// 特定のプレイリストの詳細
final playlistDetailProvider = FutureProvider.autoDispose.family<PlaylistModel?, String>((ref, playlistId) async {
  final repository = ref.watch(firebaseRepositoryProvider);
  return repository.getPlaylist(playlistId);
});

// プレイリスト内の動画一覧
final playlistVideosProvider = FutureProvider.autoDispose.family<List<SharedVideoModel>, String>((ref, playlistId) async {
  final repository = ref.watch(firebaseRepositoryProvider);
  final playlist = await repository.getPlaylist(playlistId);
  
  if (playlist == null || playlist.videoIds.isEmpty) {
    return [];
  }

  // 動画IDから動画情報を取得
  final videos = <SharedVideoModel>[];
  for (final videoId in playlist.videoIds) {
    final video = await repository.getSharedVideo(videoId);
    if (video != null) {
      videos.add(video);
    }
  }
  
  return videos;
});

// ユーザーの特別なプレイリスト（お気に入り、後で見る）
final userSpecialPlaylistsProvider = FutureProvider.autoDispose<Map<String, PlaylistModel>>((ref) async {
  final repository = ref.watch(firebaseRepositoryProvider);
  // TODO: ここで言語設定を取得して適切な名前を渡す
  return repository.getUserSpecialPlaylists();
});

// 動画がプレイリストに含まれているかの状態
final videoInPlaylistProvider = StreamProvider.autoDispose.family<bool, VideoPlaylistPair>((ref, pair) {
  final repository = ref.watch(firebaseRepositoryProvider);
  return repository.isVideoInPlaylistStream(pair.videoId, pair.playlistId);
});

// プレイリスト管理用のNotifier
class PlaylistNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseRepository _repository;
  
  PlaylistNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<String> createPlaylist({
    required String name,
    String description = '',
    PlaylistType type = PlaylistType.custom,
  }) async {
    state = const AsyncValue.loading();
    try {
      final playlistId = await _repository.createPlaylist(
        name: name,
        description: description,
        type: type,
      );
      state = const AsyncValue.data(null);
      return playlistId;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> addVideoToPlaylist({
    required String playlistId,
    required String videoId,
    String? note,
    SharedVideoModel? video,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 動画情報がある場合は、まずSharedVideoとして保存
      if (video != null) {
        await _repository.addOrUpdateSharedVideo(video);
      }
      
      await _repository.addVideoToPlaylist(
        playlistId: playlistId,
        videoId: videoId,
        note: note,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> removeVideoFromPlaylist({
    required String playlistId,
    required String videoId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.removeVideoFromPlaylist(
        playlistId: playlistId,
        videoId: videoId,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updatePlaylist(
        playlistId: playlistId,
        name: name,
        description: description,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deletePlaylist(playlistId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> toggleVideoInFavorites(String videoId, {SharedVideoModel? video}) async {
    state = const AsyncValue.loading();
    try {
      final specialPlaylists = await _repository.getUserSpecialPlaylists();
      final favoritesPlaylist = specialPlaylists['favorites'];
      
      if (favoritesPlaylist == null) return;
      
      if (favoritesPlaylist.videoIds.contains(videoId)) {
        await removeVideoFromPlaylist(
          playlistId: favoritesPlaylist.id,
          videoId: videoId,
        );
      } else {
        await addVideoToPlaylist(
          playlistId: favoritesPlaylist.id,
          videoId: videoId,
          video: video,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> toggleVideoInWatchLater(String videoId, {SharedVideoModel? video}) async {
    state = const AsyncValue.loading();
    try {
      final specialPlaylists = await _repository.getUserSpecialPlaylists();
      final watchLaterPlaylist = specialPlaylists['watchLater'];
      
      if (watchLaterPlaylist == null) return;
      
      if (watchLaterPlaylist.videoIds.contains(videoId)) {
        await removeVideoFromPlaylist(
          playlistId: watchLaterPlaylist.id,
          videoId: videoId,
        );
      } else {
        await addVideoToPlaylist(
          playlistId: watchLaterPlaylist.id,
          videoId: videoId,
          video: video,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final playlistNotifierProvider = StateNotifierProvider.autoDispose<PlaylistNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(firebaseRepositoryProvider);
  return PlaylistNotifier(repository);
});

// 動画とプレイリストのペア
class VideoPlaylistPair {
  final String videoId;
  final String playlistId;
  
  VideoPlaylistPair({required this.videoId, required this.playlistId});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoPlaylistPair &&
          runtimeType == other.runtimeType &&
          videoId == other.videoId &&
          playlistId == other.playlistId;

  @override
  int get hashCode => videoId.hashCode ^ playlistId.hashCode;
}