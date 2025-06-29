import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerWidgetのため
import 'package:go_router/go_router.dart'; // 画面遷移のため
import 'package:swipelingo/l10n/app_localizations.dart';
import '../../models/shared_video_model.dart'; // SharedVideoModel をインポート
import 'package:cached_network_image/cached_network_image.dart';

// RecommendedVideoItem クラスは SharedVideoModel を使用するため不要になる

class RecommendedVideosCarousel extends ConsumerWidget {
  final List<SharedVideoModel> videos;
  final bool isLoading;
  final String? errorMessage;
  final Function(String videoId)? onVideoTap;

  const RecommendedVideosCarousel({
    super.key,
    required this.videos,
    this.isLoading = false, // デフォルト値を設定
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            l10n.recommendedVideos,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        cs.CarouselSlider(
          options: cs.CarouselOptions(
            height: 208.0, // 少し高さを調整
            enlargeCenterPage: true,
            // autoPlay: videos.length > 1, // 1件の場合はオートプレイしない
            autoPlay: false, // 一旦オートプレイを無効化（ユーザー操作を優先）
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: videos.length > 1, // 1件の場合は無限スクロールしない
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.85, // 少し広げる
          ),
          items:
              videos.map((video) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        if (onVideoTap != null) {
                          onVideoTap!(video.id);
                        } else {
                          context.push('/video-viewer/${video.id}');
                        }
                      },
                      child: Neumorphic(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        style: NeumorphicStyle(
                          depth: 3, // 少し浅く
                          intensity: 0.7,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3, // 画像の比率を調整
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: video.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (context, error, stackTrace) =>
                                          const Center(
                                            child: Icon(
                                              Icons.ondemand_video,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2, // テキストエリアの比率を調整
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  bottom: 8.0,
                                ), // パディング調整
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center, // 中央寄せ
                                  children: [
                                    Text(
                                      video.title,
                                      style: const TextStyle(
                                        fontSize: 14, // フォントサイズ調整
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2, // 2行まで表示
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      video.channelName, // チャンネル名を表示
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
        ),
      ],
    );
  }
}
