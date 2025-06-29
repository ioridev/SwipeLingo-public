import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/ui/widgets/create_card_from_subtitle_button.dart';
import 'package:swipelingo/ui/widgets/generate_flashcards_button.dart';
import 'package:swipelingo/ui/widgets/video_player_controls.dart';
import 'package:swipelingo/ui/widgets/playlist_button_widget.dart';
import 'package:swipelingo/providers/video_player_provider.dart';
import 'package:swipelingo/models/shared_video_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;

class ActionButtonsPanelWidget extends ConsumerStatefulWidget {
  final String videoUrl;
  final VoidCallback onShowRelatedVideos;

  const ActionButtonsPanelWidget({
    super.key,
    required this.videoUrl,
    required this.onShowRelatedVideos,
  });

  @override
  ConsumerState<ActionButtonsPanelWidget> createState() =>
      _ActionButtonsPanelWidgetState();
}

class _ActionButtonsPanelWidgetState
    extends ConsumerState<ActionButtonsPanelWidget> {
  final yt_explode.YoutubeExplode _ytExplode = yt_explode.YoutubeExplode();
  yt_explode.Channel? _channelInfo;
  bool _isLoadingChannel = false;

  @override
  void dispose() {
    _ytExplode.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final videoPlayerState = ref.watch(
      videoPlayerNotifierProvider(widget.videoUrl),
    );
    final videoPlayerNotifier = ref.read(
      videoPlayerNotifierProvider(widget.videoUrl).notifier,
    );

    // チャンネル情報を取得
    if (videoPlayerState.currentChannelId != null &&
        _channelInfo == null &&
        !_isLoadingChannel) {
      _fetchChannelInfo(videoPlayerState.currentChannelId!);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 8.0,
        bottom:
            MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : 8.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: CreateCardFromSubtitleButton(videoUrl: widget.videoUrl),
          ),
          VideoPlayerControls(videoUrl: widget.videoUrl),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: _buildChannelInfoPanel(
              context,
              videoPlayerState,
              videoPlayerNotifier,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: GenerateFlashcardsButton(videoUrl: widget.videoUrl),
          ),

          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Future<void> _fetchChannelInfo(String channelId) async {
    if (_isLoadingChannel) return;

    setState(() {
      _isLoadingChannel = true;
    });

    try {
      final channelInfo = await _ytExplode.channels.get(
        yt_explode.ChannelId(channelId),
      );

      if (mounted) {
        setState(() {
          _channelInfo = channelInfo;
          _isLoadingChannel = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingChannel = false;
        });
      }
      debugPrint('Error fetching channel info: $e');
    }
  }

  Widget _buildChannelInfoPanel(
    BuildContext context,
    VideoPlayerState videoPlayerState,
    VideoPlayerNotifier videoPlayerNotifier,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 2,
        intensity: 0.7,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // チャンネルアイコン
          GestureDetector(
            onTap:
                videoPlayerState.currentChannelId != null
                    ? widget.onShowRelatedVideos
                    : null,
            child:
                _isLoadingChannel
                    ? const CircleAvatar(
                      radius: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : _channelInfo != null && _channelInfo!.logoUrl.isNotEmpty
                    ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(_channelInfo!.logoUrl),
                    )
                    : const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
          ),
          const SizedBox(width: 12),

          // チャンネル名と「他の動画を見る」テキスト
          Expanded(
            child: GestureDetector(
              onTap:
                  videoPlayerState.currentChannelId != null
                      ? widget.onShowRelatedVideos
                      : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _channelInfo?.title ??
                        (videoPlayerState.videoTitle ?? "Channel"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.otherVideosInThisChannel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // お気に入りボタン
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: NeumorphicButton(
              style: NeumorphicStyle(
                depth: 2,
                intensity: 0.6,
                boxShape: NeumorphicBoxShape.circle(),
              ),
              padding: const EdgeInsets.all(8),
              onPressed:
                  videoPlayerState.currentChannelId == null
                      ? null
                      : () => videoPlayerNotifier.toggleFavoriteChannel(),
              child: Icon(
                videoPlayerState.isCurrentChannelFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    videoPlayerState.isCurrentChannelFavorite
                        ? Colors.redAccent
                        : NeumorphicTheme.defaultTextColor(context),
                size: 20,
              ),
            ),
          ),
          
          // プレイリストボタン
          if (videoPlayerState.videoTitle != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: PlaylistButtonWidget(
                video: SharedVideoModel(
                  id: _extractVideoId(widget.videoUrl),
                  url: widget.videoUrl,
                  title: videoPlayerState.videoTitle ?? '',
                  channelName: _channelInfo?.title ?? '',
                  thumbnailUrl: 'https://img.youtube.com/vi/${_extractVideoId(widget.videoUrl)}/hqdefault.jpg',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                size: 35,
              ),
            ),
        ],
      ),
    );
  }
  
  String _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    
    // youtube.com/watch?v=VIDEO_ID
    if (uri.host.contains('youtube.com') && uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v']!;
    }
    
    // youtu.be/VIDEO_ID
    if (uri.host == 'youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : url;
    }
    
    return url;
  }
}
