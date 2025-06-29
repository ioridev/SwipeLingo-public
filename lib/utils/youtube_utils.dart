import 'package:flutter/foundation.dart';

/// Extracts the YouTube video ID from various URL formats.
///
/// Supports standard URLs (youtube.com/watch?v=...), short URLs (youtu.be/...),
/// and embed URLs (youtube.com/embed/...).
/// Returns the video ID if found, otherwise null.
String? extractVideoId(String url) {
  if (url.isEmpty) {
    return null;
  }
  try {
    // Standard URL: https://www.youtube.com/watch?v=VIDEO_ID
    RegExp regExpWatch = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    Match? matchWatch = regExpWatch.firstMatch(url);
    if (matchWatch != null &&
        matchWatch.group(2) != null &&
        matchWatch.group(2)!.length == 11) {
      return matchWatch.group(2);
    }

    // Short URL: https://youtu.be/VIDEO_ID
    RegExp regExpShort = RegExp(
      r'^https?:\/\/(?:www\.)?youtu\.be\/([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
      multiLine: false,
    );
    Match? matchShort = regExpShort.firstMatch(url);
    if (matchShort != null &&
        matchShort.group(1) != null &&
        matchShort.group(1)!.length == 11) {
      return matchShort.group(1);
    }

    // Shorts URL: https://www.youtube.com/shorts/VIDEO_ID
    RegExp regExpShorts = RegExp(
      r'^https?:\/\/(?:www\.)?youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
      multiLine: false,
    );
    Match? matchShorts = regExpShorts.firstMatch(url);
    if (matchShorts != null &&
        matchShorts.group(1) != null &&
        matchShorts.group(1)!.length == 11) {
      return matchShorts.group(1);
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error extracting video ID: $e');
    }
    return null;
  }
  return null; // Return null if no valid ID is found
}

/// Generates the default thumbnail URL for a given YouTube video ID.
String getThumbnailUrl(String videoId) {
  return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg'; // mqdefault for better quality
}
