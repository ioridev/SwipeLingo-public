import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:y_player/y_player.dart'; // youtube_player_flutter から変更
import 'package:swipelingo/providers/video_player_provider.dart';

// コールバックの型定義
typedef OnPlayerReady =
    void Function(YPlayerController controller); // YoutubePlayerController から変更
typedef OnVideoProgress = void Function(Duration position, Duration duration);
typedef OnVideoEnded =
    void Function(YPlayerStatus status); // 引数を YPlayerStatus に変更

class VideoPlayerCoreWidget extends ConsumerStatefulWidget {
  final String videoUrl;
  final OnPlayerReady? onPlayerReady;
  final OnVideoProgress? onVideoProgress;
  final OnVideoEnded? onVideoEnded;

  const VideoPlayerCoreWidget({
    super.key,
    required this.videoUrl,
    this.onPlayerReady,
    this.onVideoProgress,
    this.onVideoEnded,
  });

  @override
  ConsumerState<VideoPlayerCoreWidget> createState() =>
      _VideoPlayerCoreWidgetState();
}

class _VideoPlayerCoreWidgetState extends ConsumerState<VideoPlayerCoreWidget> {
  YPlayerController? _yPlayerController; // YoutubePlayerController から変更

  @override
  void initState() {
    super.initState();
    // VideoPlayerNotifierProvider からコントローラーを取得するロジックは YPlayer の onControllerReady で処理
    // _waitForControllerInitialization(); // YPlayerのコールバックで代替するため不要
  }

  // _waitForControllerInitialization, _addPlayerListener, _playerListener は YPlayer のコールバックで代替するため削除

  @override
  void dispose() {
    // _yPlayerController?.dispose(); // YPlayerController のライフサイクルは YPlayer ウィジェットが管理する場合がある
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // VideoPlayerNotifierProvider から playerController を watch する
    // YPlayer ウィジェット自体がコントローラーを内部で管理し、onControllerReady で渡してくれる
    // Provider から取得したコントローラーを YPlayer に渡す必要はない

    // final videoPlayerState = ref.watch(videoPlayerNotifierProvider(widget.videoUrl));
    // _yPlayerController = videoPlayerState.playerController;

    // if (_yPlayerController == null && !videoPlayerState.isLoadingCaptions) {
    //   // コントローラーがまだ準備できていないが、字幕ロード中でない場合（エラーの可能性など）
    //   // または、YPlayerが内部でコントローラーを初期化中の場合
    //   // YPlayerウィジェットが自身のローディング状態を持つため、ここではシンプルなローディング表示で良いかもしれない
    //   return const Center(child: CircularProgressIndicator());
    // }

    return YPlayer(
      key: ValueKey(widget.videoUrl), // URLが変更されたときにウィジェットを再構築するため
      youtubeUrl: widget.videoUrl,
      aspectRatio: 16 / 9, // 必要に応じて調整
      autoPlay: false, // 再生開始は VideoPlayerNotifier で制御
      onControllerReady: (controller) {
        _yPlayerController = controller;
        debugPrint(
            '[${DateTime.now()}] VideoPlayerCoreWidget.onControllerReady: Controller ready. Instance: $controller, Video URL: ${widget.videoUrl}');
        widget.onPlayerReady?.call(controller);
        // Provider のコントローラーを更新する
        ref
            .read(videoPlayerNotifierProvider(widget.videoUrl).notifier)
            .setPlayerController(controller);
      },
      onStateChanged: (status) {
        debugPrint(
            '[${DateTime.now()}] VideoPlayerCoreWidget.onStateChanged: Status changed to $status. Video URL: ${widget.videoUrl}');
        if (status == YPlayerStatus.stopped) {
          // YPlayerStatus.ended から YPlayerStatus.stopped に変更
          widget.onVideoEnded?.call(status);
        }
        // 他のステータス変更時の処理 (例: エラーハンドリング)
        if (status == YPlayerStatus.error) {
          // TODO: YPlayerController からエラー詳細を取得する方法を調査する
          // final errorMessage = _yPlayerController?.value.errorDescription ?? 'Unknown error';
          debugPrint(
              '[${DateTime.now()}] VideoPlayerCoreWidget.onStateChanged: YPlayerStatus.error. Video URL: ${widget.videoUrl}');
          // エラー処理 (例: SnackBar表示やエラー画面への遷移)
          // debugPrint("YPlayer error occurred in VideoPlayerCoreWidget"); // より詳細なログに置き換え
        }
      },
      onProgressChanged: (position, duration) {
        widget.onVideoProgress?.call(position, duration);
      },
      color: Theme.of(context).colorScheme.secondary, // コントロールの基本色
      loadingWidget: const Center(child: CircularProgressIndicator()),
      placeholder: const SizedBox.shrink(), // または適切なプレースホルダー
      errorWidget: Center(
        child: Text(
          '動画の読み込みに失敗しました。',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      // YPlayer は MaterialVideoControlsTheme を内部で使用するため、
      // 詳細なプログレスバーの色設定などは YPlayer の color プロパティや、
      // YPlayer を MaterialVideoControlsTheme でラップすることで行う。
      // 例:
      // normalTheme: MaterialVideoControlsThemeData(
      //   seekBarPlayedColor: Theme.of(context).colorScheme.secondary,
      //   seekBarHandleColor: Theme.of(context).colorScheme.secondary,
      // ),
    );
  }
}
