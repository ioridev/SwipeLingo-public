import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:swipelingo/models/playlist_model.dart';
import 'package:swipelingo/providers/playlist_providers.dart';
import 'package:swipelingo/utils/playlist_utils.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/ui/widgets/playlist_button_widget.dart';

class PlaylistListScreen extends ConsumerWidget {
  const PlaylistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final playlistsAsync = ref.watch(userPlaylistsStreamProvider);
    final specialPlaylistsAsync = ref.watch(userSpecialPlaylistsProvider);

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      appBar: NeumorphicAppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePlaylistDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userPlaylistsStreamProvider);
          ref.invalidate(userSpecialPlaylistsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 特別なプレイリスト
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Playlists',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    specialPlaylistsAsync.when(
                      data: (specialPlaylists) {
                        return Column(
                          children: [
                            if (specialPlaylists.containsKey('favorites'))
                              _buildPlaylistTile(
                                context,
                                ref,
                                specialPlaylists['favorites']!,
                                icon: Icons.favorite,
                                iconColor: Colors.red,
                              ),
                            if (specialPlaylists.containsKey('watchLater'))
                              _buildPlaylistTile(
                                context,
                                ref,
                                specialPlaylists['watchLater']!,
                                icon: Icons.watch_later,
                                iconColor: Colors.blue,
                              ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading special playlists: $error',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // カスタムプレイリスト
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Playlists',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    playlistsAsync.when(
                      data: (playlists) {
                        final customPlaylists = playlists
                            .where((p) => p.type == PlaylistType.custom)
                            .toList();
                        
                        if (customPlaylists.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No custom playlists yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }
                        
                        return Column(
                          children: customPlaylists
                              .map((playlist) => _buildPlaylistTile(
                                    context,
                                    ref,
                                    playlist,
                                  ))
                              .toList(),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading playlists: $error',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistTile(
    BuildContext context,
    WidgetRef ref,
    PlaylistModel playlist, {
    IconData? icon,
    Color? iconColor,
  }) {
    // デバッグ情報を表示
    if (playlist.id.isEmpty) {
      return ListTile(
        leading: Icon(
          icon ?? Icons.playlist_play,
          color: Colors.red,
        ),
        title: Text(PlaylistUtils.getLocalizedPlaylistName(context, playlist)),
        subtitle: Text(
          'Error: Empty ID - Type: ${playlist.type}',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    }

    return ListTile(
      leading: Icon(
        icon ?? Icons.playlist_play,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      title: Text(PlaylistUtils.getLocalizedPlaylistName(context, playlist)),
      subtitle: Text(
        '${playlist.videoCount} videos • ID: ${playlist.id}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/playlists/${playlist.id}'),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreatePlaylistDialog(
        onCreated: (playlistId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist created')),
          );
        },
      ),
    );
  }
}