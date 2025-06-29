import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:swipelingo/models/playlist_model.dart';
import 'package:swipelingo/models/shared_video_model.dart';
import 'package:swipelingo/providers/playlist_providers.dart';
import 'package:swipelingo/providers/mining_providers.dart';
import 'package:swipelingo/utils/playlist_utils.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
  });

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  bool _isEditMode = false;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistAsync = ref.watch(playlistDetailProvider(widget.playlistId));
    final videosAsync = ref.watch(playlistVideosProvider(widget.playlistId));

    return playlistAsync.when(
      data: (playlist) {
        if (playlist == null) {
          return Scaffold(
            appBar: NeumorphicAppBar(
              title: const Text('Playlist Not Found'),
            ),
            body: const Center(
              child: Text('This playlist does not exist or has been deleted.'),
            ),
          );
        }

        _nameController.text = playlist.name;
        _descriptionController.text = playlist.description;

        return Scaffold(
          backgroundColor: NeumorphicTheme.baseColor(context),
          appBar: NeumorphicAppBar(
            title: _isEditMode
                ? TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Playlist name',
                    ),
                  )
                : Text(PlaylistUtils.getLocalizedPlaylistName(context, playlist)),
            actions: [
              if (playlist.type == PlaylistType.custom) ...[
                if (_isEditMode)
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _saveChanges(playlist),
                  )
                else
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          setState(() => _isEditMode = true);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, ref, playlist);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ],
          ),
          body: Column(
            children: [
              // プレイリスト情報
              if (_isEditMode || playlist.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isEditMode
                      ? TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        )
                      : Text(
                          playlist.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              
              // 動画数とアクションボタン
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${playlist.videoCount} videos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (playlist.videoCount > 0)
                      ElevatedButton.icon(
                        onPressed: () => _playAllVideos(context, playlist),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play All'),
                      ),
                  ],
                ),
              ),
              
              const Divider(height: 32),
              
              // 動画リスト
              Expanded(
                child: videosAsync.when(
                  data: (videos) {
                    if (videos.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No videos in this playlist',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add videos from the video player',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        return _buildVideoTile(context, video, playlist);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error loading videos: $error'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: NeumorphicAppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text('Error loading playlist: $error'),
        ),
      ),
    );
  }

  Widget _buildVideoTile(
    BuildContext context,
    SharedVideoModel video,
    PlaylistModel playlist,
  ) {
    return Dismissible(
      key: Key(video.id),
      direction: playlist.type == PlaylistType.custom
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (playlist.type != PlaylistType.custom) return false;
        
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove from playlist?'),
            content: Text('Remove "${video.title}" from this playlist?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          await ref.read(playlistNotifierProvider.notifier).removeVideoFromPlaylist(
            playlistId: playlist.id,
            videoId: video.id,
          );
        }
        
        return confirm ?? false;
      },
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            video.thumbnailUrl,
            width: 80,
            height: 45,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 45,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
        ),
        title: Text(
          video.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          video.channelName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          // ミニング画面に動画URLを設定してから遷移
          ref.read(miningNotifierProvider.notifier).setUrl(video.url);
          context.go('/mining');
        },
      ),
    );
  }

  void _saveChanges(PlaylistModel playlist) async {
    final notifier = ref.read(playlistNotifierProvider.notifier);
    
    try {
      await notifier.updatePlaylist(
        playlistId: playlist.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      
      setState(() => _isEditMode = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    PlaylistModel playlist,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist?'),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await ref.read(playlistNotifierProvider.notifier).deletePlaylist(playlist.id);
                
                if (mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playlist deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting playlist: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _playAllVideos(BuildContext context, PlaylistModel playlist) {
    if (playlist.videoIds.isNotEmpty) {
      // 最初の動画を開いて、プレイリストモードを有効にする
      // TODO: プレイリストモードの実装（動画IDからURLを取得する必要がある）
      context.go('/mining');
    }
  }
}