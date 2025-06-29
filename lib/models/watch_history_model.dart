import 'package:cloud_firestore/cloud_firestore.dart';

class WatchHistory {
  final String id; // Firestore document ID
  final String channelId;
  final String videoId;
  final Timestamp watchedAt;

  WatchHistory({
    required this.id,
    required this.channelId,
    required this.videoId,
    required this.watchedAt,
  });

  factory WatchHistory.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return WatchHistory(
      id: doc.id,
      channelId: data?['channelId'] as String? ?? '',
      videoId: data?['videoId'] as String? ?? '',
      watchedAt: data?['watchedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'channelId': channelId, 'videoId': videoId, 'watchedAt': watchedAt};
  }
}
