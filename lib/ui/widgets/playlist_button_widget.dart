import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:swipelingo/models/playlist_model.dart';
import 'package:swipelingo/models/shared_video_model.dart';
import 'package:swipelingo/providers/playlist_providers.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/utils/playlist_utils.dart';

class PlaylistButtonWidget extends ConsumerWidget {
  final SharedVideoModel video;
  final double size;

  const PlaylistButtonWidget({
    super.key,
    required this.video,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeumorphicButton(
      onPressed: () => _showPlaylistModal(context, ref),
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.circle(),
        depth: 2,
        lightSource: LightSource.topLeft,
        color: Colors.grey[300],
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(
        Icons.playlist_add,
        size: size * 0.6,
        color: Colors.grey[700],
      ),
    );
  }

  void _showPlaylistModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaylistSelectionModal(video: video),
    );
  }
}

class PlaylistSelectionModal extends ConsumerStatefulWidget {
  final SharedVideoModel video;

  const PlaylistSelectionModal({
    super.key,
    required this.video,
  });

  @override
  ConsumerState<PlaylistSelectionModal> createState() => _PlaylistSelectionModalState();
}

class _PlaylistSelectionModalState extends ConsumerState<PlaylistSelectionModal> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playlistsAsync = ref.watch(userPlaylistsStreamProvider);
    final specialPlaylistsAsync = ref.watch(userSpecialPlaylistsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add to Playlist',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: () => _showCreatePlaylistDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New Playlist'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // 特別なプレイリスト（お気に入り、後で見る）
                    specialPlaylistsAsync.when(
                      data: (specialPlaylists) {
                        debugPrint('Special playlists loaded: ${specialPlaylists.keys}');
                        specialPlaylists.forEach((key, playlist) {
                          debugPrint('$key playlist - ID: "${playlist.id}" (length: ${playlist.id.length}), Name: ${playlist.name}, Type: ${playlist.type}');
                          // ID が空かどうかの詳細なチェック
                          if (playlist.id.isEmpty) {
                            debugPrint('WARNING: Empty ID detected for $key playlist!');
                            debugPrint('Playlist object: ${playlist.toString()}');
                          }
                        });
                        
                        return Column(
                          children: [
                            if (specialPlaylists.containsKey('favorites'))
                              _buildPlaylistTile(
                                context,
                                specialPlaylists['favorites']!,
                                icon: Icons.favorite,
                                iconColor: Colors.red,
                              ),
                            if (specialPlaylists.containsKey('watchLater'))
                              _buildPlaylistTile(
                                context,
                                specialPlaylists['watchLater']!,
                                icon: Icons.watch_later,
                                iconColor: Colors.blue,
                              ),
                            const Divider(),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) {
                        debugPrint('Error loading special playlists: $error');
                        debugPrint('Stack trace: $stack');
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error loading playlists',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        );
                      },
                    ),
                    // カスタムプレイリスト
                    playlistsAsync.when(
                      data: (playlists) {
                        final customPlaylists = playlists
                            .where((p) => p.type == PlaylistType.custom)
                            .toList();
                        
                        if (customPlaylists.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No playlists yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }
                        
                        return Column(
                          children: customPlaylists
                              .map((playlist) => _buildPlaylistTile(context, playlist))
                              .toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaylistTile(
    BuildContext context,
    PlaylistModel playlist, {
    IconData? icon,
    Color? iconColor,
  }) {
    // プレイリストIDが空の場合はエラー表示
    if (playlist.id.isEmpty) {
      debugPrint('Error: Playlist ID is empty for playlist: ${playlist.name}');
      debugPrint('Playlist details:');
      debugPrint('  - name: ${playlist.name}');
      debugPrint('  - type: ${playlist.type}');
      debugPrint('  - videoCount: ${playlist.videoCount}');
      debugPrint('  - videoIds: ${playlist.videoIds}');
      debugPrint('  - createdAt: ${playlist.createdAt}');
      
      return ListTile(
        leading: Icon(
          icon ?? Icons.playlist_play,
          color: iconColor ?? Theme.of(context).primaryColor,
        ),
        title: Text(PlaylistUtils.getLocalizedPlaylistName(context, playlist)),
        subtitle: const Text(
          'Error: Invalid playlist',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    }
    
    final videoInPlaylistAsync = ref.watch(
      videoInPlaylistProvider(
        VideoPlaylistPair(
          videoId: widget.video.id,
          playlistId: playlist.id,
        ),
      ),
    );

    return videoInPlaylistAsync.when(
      data: (isInPlaylist) {
        return ListTile(
          leading: Icon(
            icon ?? Icons.playlist_play,
            color: iconColor ?? Theme.of(context).primaryColor,
          ),
          title: Text(PlaylistUtils.getLocalizedPlaylistName(context, playlist)),
          subtitle: playlist.description.isNotEmpty
              ? Text(
                  playlist.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: isInPlaylist
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
          onTap: () => _toggleVideoInPlaylist(playlist, isInPlaylist),
        );
      },
      loading: () => ListTile(
        leading: Icon(
          icon ?? Icons.playlist_play,
          color: iconColor ?? Theme.of(context).primaryColor,
        ),
        title: Text(PlaylistUtils.getLocalizedPlaylistName(context, playlist)),
        trailing: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stack) {
        debugPrint('Error loading playlist status: $error');
        debugPrint('Stack trace: $stack');
        return ListTile(
          leading: Icon(
            icon ?? Icons.playlist_play,
            color: iconColor ?? Theme.of(context).primaryColor,
          ),
          title: Text(PlaylistUtils.getLocalizedPlaylistName(context, playlist)),
          subtitle: Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        );
      },
    );
  }

  Future<void> _toggleVideoInPlaylist(PlaylistModel playlist, bool isInPlaylist) async {
    final notifier = ref.read(playlistNotifierProvider.notifier);
    
    try {
      if (isInPlaylist) {
        await notifier.removeVideoFromPlaylist(
          playlistId: playlist.id,
          videoId: widget.video.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed from ${playlist.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await notifier.addVideoToPlaylist(
          playlistId: playlist.id,
          videoId: widget.video.id,
          video: widget.video,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to ${playlist.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreatePlaylistDialog(
        onCreated: (playlistId) {
          // 作成後、その動画を新しいプレイリストに追加
          ref.read(playlistNotifierProvider.notifier).addVideoToPlaylist(
            playlistId: playlistId,
            videoId: widget.video.id,
          );
        },
      ),
    );
  }
}

class CreatePlaylistDialog extends ConsumerStatefulWidget {
  final Function(String playlistId)? onCreated;

  const CreatePlaylistDialog({
    super.key,
    this.onCreated,
  });

  @override
  ConsumerState<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends ConsumerState<CreatePlaylistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: const Text('Create New Playlist'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'Enter playlist name'
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter description'
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createPlaylist,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createPlaylist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final playlistId = await ref.read(playlistNotifierProvider.notifier).createPlaylist(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist "${_nameController.text}" created'),
          ),
        );
      }

      widget.onCreated?.call(playlistId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating playlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}