import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'dart:async';
import '../../providers/video_list_providers.dart';
import '../../models/shared_video_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoListScreen extends ConsumerWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVideos = ref.watch(videoListProvider);
    final l10n = AppLocalizations.of(context)!; // AppLocalizations を取得

    return Scaffold(
      appBar: NeumorphicAppBar(
        leading: NeumorphicButton(
          padding: const EdgeInsets.all(8.0),
          style: const NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          child: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(l10n.learningDecksTitle), // 国際化対応
      ),
      body: asyncVideos.when(
        data: (List<SharedVideoModel> videoList) {
          if (videoList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.video_library_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noLearningDecks, // 国際化対応
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.createDeckFromYouTube, // 国際化対応
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    NeumorphicButton(
                      onPressed: () {
                        context.push('/mining');
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text(
                        l10n.createDeckFromVideoButton, // 国際化対応
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: videoList.length,
            itemBuilder: (context, index) {
              final video = videoList[index];
              return Neumorphic(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading:
                      video.thumbnailUrl.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: video.thumbnailUrl,
                            width: 80,
                            fit: BoxFit.cover,
                            errorWidget:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.video_library, size: 40),
                          )
                          : const Icon(Icons.video_library, size: 40),
                  title: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(video.channelName),
                  onTap: () {
                    context.push('/videos/${video.id}/learn');
                  },
                  trailing: NeumorphicButton(
                    padding: const EdgeInsets.all(8.0),
                    style: const NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.circle(),
                      color: Colors.redAccent,
                    ),
                    tooltip: l10n.deleteDeckTooltip, // 国際化対応
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(l10n.deleteDeckDialogTitle), // 国際化対応
                            content: Text(
                              l10n.deleteDeckDialogContent(
                                video.title,
                              ), // 国際化対応
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(l10n.cancelButton), // 国際化対応
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: Text(l10n.deleteButton), // 国際化対応
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        try {
                          await ref
                              .read(videoListProvider.notifier)
                              .deleteDeck(video.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.deckDeletedSuccessfully),
                              ), // 国際化対応
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.deckDeletionFailed(e.toString()),
                                ),
                              ), // 国際化対応
                            );
                          }
                        }
                      }
                    },
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorOccurred(error.toString()),
                      textAlign: TextAlign.center,
                    ), // 国際化対応
                    const SizedBox(height: 16),
                    NeumorphicButton(
                      onPressed: () {
                        ref.invalidate(videoListProvider);
                      },
                      child: Text(l10n.retryButton), // 国際化対応
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
