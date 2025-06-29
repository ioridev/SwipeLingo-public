import 'package:flutter/material.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/models/playlist_model.dart';

class PlaylistUtils {
  static String getLocalizedPlaylistName(BuildContext context, PlaylistModel playlist) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (playlist.type) {
      case PlaylistType.favorites:
        return l10n.favoritesPlaylist;
      case PlaylistType.watchLater:
        return l10n.watchLaterPlaylist;
      case PlaylistType.custom:
        return playlist.name;
    }
  }
  
  static IconData getPlaylistIcon(PlaylistType type) {
    switch (type) {
      case PlaylistType.favorites:
        return Icons.favorite;
      case PlaylistType.watchLater:
        return Icons.watch_later;
      case PlaylistType.custom:
        return Icons.playlist_play;
    }
  }
  
  static Color getPlaylistIconColor(PlaylistType type) {
    switch (type) {
      case PlaylistType.favorites:
        return Colors.red;
      case PlaylistType.watchLater:
        return Colors.blue;
      case PlaylistType.custom:
        return Colors.green;
    }
  }
}