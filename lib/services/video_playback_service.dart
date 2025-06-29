// lib/services/video_playback_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:y_player/y_player.dart'; // youtube_player_flutter から変更
import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    as yt_explode; // Videoクラスのため

class VideoPlaybackService {
  YPlayerController? _playerController; // YoutubePlayerController から変更
  final yt_explode.YoutubeExplode _ytExplode; // 動画タイトル取得のため
  Function(bool isPlaying)? _onPlayerStateChangeCallback;
  Function()? _onPlayerReadyCallback;
  bool _isPlayerReadyNotified = false; // onPlayerReadyが一度だけ呼ばれるようにするためのフラグ

  VideoPlaybackService(this._ytExplode);

  YPlayerController? get playerController =>
      _playerController; // YoutubePlayerController から変更

  Future<void> initializePlayer(
    String videoUrl, {
    Function(bool isPlaying)? onPlayerStateChange,
    Function()? onPlayerReady,
  }) async {
    _onPlayerStateChangeCallback = onPlayerStateChange;
    _onPlayerReadyCallback = onPlayerReady;
    _isPlayerReadyNotified = false; // 初期化時にリセット

    // YPlayerController の初期化
    _playerController = YPlayerController(
      onStateChanged: (status) {
        _onPlayerStateChangeCallback?.call(status == YPlayerStatus.playing);
        // YPlayerStatus.ready と YPlayerStatus.buffering は存在しないため、
        // isInitialized と playing/paused/loading で判断する
        if (!_isPlayerReadyNotified &&
            _playerController != null &&
            _playerController!.isInitialized &&
            (status == YPlayerStatus.playing ||
                status == YPlayerStatus.paused ||
                status == YPlayerStatus.loading)) {
          _onPlayerReadyCallback?.call();
          _isPlayerReadyNotified = true; // 通知済みフラグを立てる
        }
      },
      onProgressChanged: (position, duration) {
        // このサービスでは直接使用しないが、必要に応じて処理を追加可能
      },
    );

    try {
      // YPlayerController の initialize メソッドを呼び出す
      await _playerController!.initialize(
        videoUrl,
        // autoPlay は YPlayer ウィジェット側で制御するため、ここでは指定しない
        // aspectRatio も YPlayer ウィジェット側
        // chooseBestQuality も YPlayer ウィジェット側
      );
    } catch (e) {
      debugPrint('Error initializing YPlayerController: $e');
      throw Exception('YPlayerController の初期化に失敗しました: $e');
    }
  }

  // _playerListener は YPlayerController のコールバックに統合されたため不要

  Future<String> getVideoTitle(String videoId) async {
    try {
      final video = await _ytExplode.videos.get(videoId);
      return video.title;
    } catch (e) {
      debugPrint('Error loading video title in service: $e');
      return '動画タイトル不明';
    }
  }

  void play() {
    _playerController?.play();
  }

  void pause() {
    _playerController?.pause();
  }

  void seekTo(Duration position) {
    _playerController?.player.seek(position); // player.seek を使用
  }

  Duration getCurrentPosition() {
    return _playerController?.position ?? Duration.zero; // .value を削除
  }

  bool isPlaying() {
    return _playerController?.status == YPlayerStatus.playing; // 判定方法を変更
  }

  bool isReady() {
    return _playerController?.isInitialized ?? false; // 判定方法を変更
  }

  void dispose() {
    // removeListener は不要
    _playerController?.dispose();
    _playerController = null;
  }
}
