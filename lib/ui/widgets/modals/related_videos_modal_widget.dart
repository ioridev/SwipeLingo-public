import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/video_list_providers.dart';
import 'package:swipelingo/ui/widgets/related_videos_widget.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;

class RelatedVideosModalWidget extends ConsumerStatefulWidget {
  final String currentVideoId;

  const RelatedVideosModalWidget({super.key, required this.currentVideoId});

  @override
  ConsumerState<RelatedVideosModalWidget> createState() =>
      _RelatedVideosModalWidgetState();
}

class _RelatedVideosModalWidgetState
    extends ConsumerState<RelatedVideosModalWidget> {
  final yt_explode.YoutubeExplode _ytExplode = yt_explode.YoutubeExplode();

  @override
  void initState() {
    super.initState();
    // Modalが表示された時点で関連動画の取得を開始
    // InAppVideoViewerScreenの_fetchRelatedVideosのロジックをここに移動または呼び出す
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRelatedVideosData();
    });
  }

  @override
  void dispose() {
    _ytExplode.close();
    super.dispose();
  }

  Future<void> _fetchRelatedVideosData() async {
    // InAppVideoViewerScreenの_fetchRelatedVideosのロジックを参考に実装
    // このモーダルウィジェットが直接チャンネルIDを取得し、プロバイダーに渡す
    print(
      '[RelatedVideosModalWidget] Fetching related videos for videoId: ${widget.currentVideoId}',
    );
    try {
      final video = await _ytExplode.videos.get(widget.currentVideoId);
      final channelId = video.channelId.value;
      print(
        '[RelatedVideosModalWidget] Fetched channelId: $channelId for videoId: ${widget.currentVideoId}',
      );

      await ref
          .read(relatedVideosNotifierProvider(widget.currentVideoId).notifier)
          .fetchRelatedVideos(channelId);
      print(
        '[RelatedVideosModalWidget] Finished calling relatedVideosNotifierProvider.fetchRelatedVideos',
      );
    } catch (e) {
      print(
        "[RelatedVideosModalWidget] Error fetching channelId or related videos: $e",
      );
      if (mounted) {
        ref
            .read(relatedVideosNotifierProvider(widget.currentVideoId).notifier)
            .state = ref
            .read(relatedVideosNotifierProvider(widget.currentVideoId).notifier)
            .state
            .copyWith(
              status: RelatedVideosStatus.error,
              errorMessage:
                  AppLocalizations.of(context)?.failedToLoadRelatedVideos ??
                  "Failed to load related videos.", // Fallback
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final relatedVideosState = ref.watch(
      relatedVideosNotifierProvider(widget.currentVideoId),
    );

    Widget content;
    if (relatedVideosState.status == RelatedVideosStatus.loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (relatedVideosState.status == RelatedVideosStatus.success) {
      if (relatedVideosState.videos.isNotEmpty) {
        content = RelatedVideosWidget(videos: relatedVideosState.videos);
      } else {
        content = Center(child: Text(l10n.noRelatedVideos));
      }
    } else if (relatedVideosState.status == RelatedVideosStatus.error) {
      content = Center(
        child: Text(
          relatedVideosState.errorMessage ?? l10n.failedToLoadRelatedVideos,
        ),
      );
    } else {
      // Initial state or other unhandled states
      content = const Center(child: CircularProgressIndicator());
    }

    return FractionallySizedBox(
      heightFactor: 0.6, // モーダルの高さを画面の60%に設定（調整可能）
      child: NeumorphicTheme(
        themeMode: NeumorphicTheme.of(context)!.themeMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.relatedVideosTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the modal (optional, can be called directly from InAppVideoViewerScreen)
Future<void> showRelatedVideosModal(
  BuildContext context,
  String currentVideoId,
) async {
  // InAppVideoViewerScreenの_showRelatedVideosModalの呼び出し部分のshowModalBottomSheetをここに移動
  // ただし、このヘルパー関数は必須ではなく、呼び出し側で直接 showModalBottomSheet しても良い
  print('[Helper] showRelatedVideosModal called for videoId: $currentVideoId');
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext modalContext) {
      return RelatedVideosModalWidget(currentVideoId: currentVideoId);
    },
  );
}
