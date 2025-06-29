import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // 追加
import 'package:swipelingo/models/shared_video_model.dart';
// import 'package:swipelingo/ui/screens/in_app_video_viewer_screen.dart'; // GoRouter経由なので不要になる可能性
import 'package:cached_network_image/cached_network_image.dart';

class RelatedVideosWidget extends ConsumerWidget {
  final List<SharedVideoModel> videos;

  const RelatedVideosWidget({super.key, required this.videos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (videos.isEmpty) {
      return const Center(child: Text('関連動画はありません。'));
    }

    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final thumbnailUrl = video.thumbnailUrl;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: InkWell(
            onTap: () {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder:
              //         (context) => InAppVideoViewerScreen(videoUrl: video.url),
              //   ),
              // );
              context.replace('/video-viewer/${video.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    width: 120,
                    height: 67.5, // 16:9 アスペクト比
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 67.5,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video.channelName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
          ),
        );
      },
    );
  }
}
