import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerWidgetのため
import 'package:go_router/go_router.dart'; // 画面遷移のため
import 'package:swipelingo/l10n/app_localizations.dart';
import '../../models/shared_video_model.dart'; // SharedVideoModel をインポート
import 'package:cached_network_image/cached_network_image.dart';

class RecommendedVideosList extends ConsumerWidget {
  final List<SharedVideoModel> videos;
  final bool isLoading;
  final String? errorMessage;
  final Function(String videoId)? onVideoTap;

  const RecommendedVideosList({
    super.key,
    required this.videos,
    this.isLoading = false,
    this.errorMessage,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return Center(child: Text(l10n.noRecommendedVideosFound));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 8.0,
          ),
          child: Text(
            l10n.recommendedVideos,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          separatorBuilder:
              (context, index) => Divider(
                height: 16,
                thickness: 0.5,
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
          itemBuilder: (context, index) {
            final video = videos[index];
            return InkWell(
              onTap: () {
                if (onVideoTap != null) {
                  onVideoTap!(video.id);
                } else {
                  context.push('/video-viewer/${video.id}');
                }
              },
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120, // サムネイルの幅
                      height: 67.5, // 16:9 アスペクト比
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: video.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                width: 120,
                                height: 67.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.3),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                width: 120,
                                height: 67.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.3),
                                child: Icon(
                                  Icons.ondemand_video,
                                  size: 32,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.5),
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.3, // 行間調整
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            video.channelName,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              height: 1.3, // 行間調整
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
