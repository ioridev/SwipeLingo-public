import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:swipelingo/models/user_model.dart';
import 'package:swipelingo/models/firebase_card_model.dart';
import 'package:swipelingo/models/firebase_daily_stat_model.dart';
import 'package:swipelingo/models/shared_video_model.dart';
import 'package:swipelingo/models/watch_history_model.dart';
import 'package:swipelingo/models/invitation_code_response.dart';
import 'package:swipelingo/models/playlist_model.dart';
import 'package:swipelingo/repositories/firebase_repository_error_handler.dart';

class FirebaseRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      if (userCredential.user != null) {
        await createUserDocumentIfNotExists(userCredential.user!);
      }
      return userCredential.user;
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'signInAnonymously',
        severity: ErrorSeverity.high,
      );
      rethrow; // 呼び出し元でエラーハンドリング可能にする
    }
  }

  Future<void> createUserDocumentIfNotExists(User user) async {
    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final doc = await userDocRef.get();

      if (!doc.exists) {
        final invitationCode =
            user.uid.length >= 8 ? user.uid.substring(0, 8) : user.uid;

        final newUser = UserModel(
          uid: user.uid,
          createdAt: DateTime.now(),
          invitationCode: invitationCode,
          // gemCount, hasUsedInvitationCode, currentStreak, longestStreak, lastLearningDate, isHiveDataMigrated はデフォルト値
        );
        await userDocRef.set(newUser.toJson());
        debugPrint('User document created for ${user.uid}');
      } else {
        debugPrint('User document already exists for ${user.uid}');
      }
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'createUserDocumentIfNotExists',
        severity: ErrorSeverity.high,
        extra: {'userId': user.uid},
      );
      rethrow;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'getUser',
        severity: ErrorSeverity.high,
        extra: {'userId': userId},
      );
      rethrow;
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      try {
        if (snapshot.exists) {
          return UserModel.fromJson(snapshot.data()!);
        }
        return null;
      } catch (e, stackTrace) {
        return FirebaseRepositoryErrorHandler.handleStreamError<UserModel?>(
          error: e,
          stackTrace: stackTrace,
          operation: 'getUserStream',
          defaultValue: null,
          severity: ErrorSeverity.high,
        );
      }
    });
  }

  Stream<UserModel?> currentUserDocumentStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      // ユーザーが認証されていない場合は、null を含むストリームを返すか、エラーを投げるか、
      // アプリケーションの要件に応じて適切な処理を行います。
      // ここでは null を含むストリームを返します。
      return Stream.value(null);
    }
    return getUserStream(userId);
  }

  Future<void> updateUserDocument(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      debugPrint('Failed to update user document for $userId: $e');
      rethrow; // エラーを呼び出し元に伝播させる
    }
  }

  Future<void> updateUserFCMToken(String userId, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('FCM token updated successfully for user $userId');
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'updateUserFCMToken',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId},
      );
    }
  }

  Future<ApplyInvitationCodeResponse> applyInvitationCode(
    String userId,
    String invitationCode,
  ) async {
    final currentUserDoc =
        await _firestore.collection('users').doc(userId).get();
    if (!currentUserDoc.exists) {
      return ApplyInvitationCodeResponse(
        status: ApplyInvitationCodeStatus.errorUserNotFound,
        displayMessage: '現在のユーザーが見つかりません。',
      );
    }
    final currentUserData = UserModel.fromJson(currentUserDoc.data()!);
    if (currentUserData.hasUsedInvitationCode) {
      return ApplyInvitationCodeResponse(
        status: ApplyInvitationCodeStatus.errorAlreadyUsed,
        displayMessage: '既に招待コードを使用しています。',
      );
    }

    final inviterQuery =
        await _firestore
            .collection('users')
            .where('invitationCode', isEqualTo: invitationCode)
            .limit(1)
            .get();

    if (inviterQuery.docs.isEmpty) {
      return ApplyInvitationCodeResponse(
        status: ApplyInvitationCodeStatus.errorInvalidCode,
        displayMessage: '招待コードが無効です。',
      );
    }

    final inviterDoc = inviterQuery.docs.first;
    final inviterData = UserModel.fromJson(inviterDoc.data());

    if (inviterData.uid == userId) {
      return ApplyInvitationCodeResponse(
        status: ApplyInvitationCodeStatus.errorSelfCode,
        displayMessage: '自分自身の招待コードは使用できません。',
      );
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final currentUserRef = _firestore.collection('users').doc(userId);
        final inviterRef = _firestore.collection('users').doc(inviterData.uid);

        final currentUserSnapshot = await transaction.get(currentUserRef);
        final inviterSnapshot = await transaction.get(inviterRef);

        if (!currentUserSnapshot.exists || !inviterSnapshot.exists) {
          throw Exception('ユーザーまたは招待者のデータが見つかりません。');
        }

        final currentGemCount =
            (currentUserSnapshot.data()?['gemCount'] ?? 0) as int;
        final inviterGemCount =
            (inviterSnapshot.data()?['gemCount'] ?? 0) as int;

        transaction.update(currentUserRef, {
          'hasUsedInvitationCode': true,
          'invitedBy': inviterData.uid,
          'gemCount': currentGemCount + 3,
        });

        transaction.update(inviterRef, {'gemCount': FieldValue.increment(3)});
      });
      return ApplyInvitationCodeResponse(
        status: ApplyInvitationCodeStatus.success,
        displayMessage: '招待コードが正常に適用されました。ジェムが3つ追加されました！',
      );
    } catch (e) {
      debugPrint('招待コード適用エラー: $e');
      return ApplyInvitationCodeResponse(
        status: ApplyInvitationCodeStatus.errorGeneric,
        displayMessage: '招待コードの適用中にエラーが発生しました。',
      );
    }
  }

  // --- Card Methods ---

  Future<void> addUserCard(String userId, FirebaseCardModel card) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('userCards')
          .doc(card.id)
          .set(card.toJson());
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'addUserCard',
        severity: ErrorSeverity.high,
        extra: {'userId': userId, 'cardId': card.id},
      );
      rethrow;
    }
  }

  Future<void> updateUserCard(String userId, FirebaseCardModel card) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('userCards')
          .doc(card.id)
          .update(card.toJson());
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'updateUserCard',
        severity: ErrorSeverity.high,
        extra: {'userId': userId, 'cardId': card.id},
      );
      rethrow;
    }
  }

  Future<void> deleteUserCard(String userId, String cardId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('userCards')
          .doc(cardId)
          .delete();
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'deleteUserCard',
        severity: ErrorSeverity.high,
        extra: {'userId': userId, 'cardId': cardId},
      );
      rethrow;
    }
  }

  Future<void> deleteAllCardsForVideo(String userId, String videoId) async {
    try {
      final cardsQuery =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('userCards')
              .where('videoId', isEqualTo: videoId)
              .get();

      if (cardsQuery.docs.isEmpty) {
        debugPrint(
          'No cards found for video $videoId and user $userId to delete.',
        );
        return;
      }

      final WriteBatch batch = _firestore.batch();
      for (final doc in cardsQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint(
        'Successfully deleted ${cardsQuery.docs.length} cards for video $videoId and user $userId.',
      );
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'deleteAllCardsForVideo',
        severity: ErrorSeverity.high,
        extra: {'userId': userId, 'videoId': videoId},
      );
      rethrow;
    }
  }

  Stream<List<FirebaseCardModel>> getUserCardsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('userCards')
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => FirebaseCardModel.fromJson(doc.data()))
                .toList();
          } catch (e, stackTrace) {
            return FirebaseRepositoryErrorHandler.handleStreamError<
              List<FirebaseCardModel>
            >(
              error: e,
              stackTrace: stackTrace,
              operation: 'getUserCardsStream',
              defaultValue: [],
              severity: ErrorSeverity.high,
            );
          }
        });
  }

  Stream<FirebaseCardModel?> getCardStream(String userId, String cardId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('userCards')
        .doc(cardId)
        .snapshots()
        .map((snapshot) {
          try {
            if (snapshot.exists) {
              return FirebaseCardModel.fromJson(snapshot.data()!);
            }
            return null;
          } catch (e, stackTrace) {
            return FirebaseRepositoryErrorHandler.handleStreamError<
              FirebaseCardModel?
            >(
              error: e,
              stackTrace: stackTrace,
              operation: 'getCardStream',
              defaultValue: null,
              severity: ErrorSeverity.high,
            );
          }
        });
  }

  // --- Daily Stat Methods ---

  Future<void> updateUserDailyStat(
    String userId,
    String dateString,
    FirebaseDailyStatModel stat,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('userDailyStats')
          .doc(dateString)
          .set(stat.toJson(), SetOptions(merge: true));
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'updateUserDailyStat',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId, 'dateString': dateString},
      );
      // 統計更新の失敗は致命的ではないため、rethrowしない
    }
  }

  Future<FirebaseDailyStatModel?> getUserDailyStat(
    String userId,
    String dateString,
  ) async {
    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('userDailyStats')
              .doc(dateString)
              .get();
      if (doc.exists) {
        return FirebaseDailyStatModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'getUserDailyStat',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId, 'dateString': dateString},
      );
      return null; // 統計取得失敗は致命的ではない
    }
  }

  Stream<List<FirebaseDailyStatModel>> getUserDailyStatsInRangeStream(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('userDailyStats')
        .where(
          'learnedDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('learnedDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('learnedDate', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => FirebaseDailyStatModel.fromJson(doc.data()))
                .toList();
          } catch (e, stackTrace) {
            return FirebaseRepositoryErrorHandler.handleStreamError<
              List<FirebaseDailyStatModel>
            >(
              error: e,
              stackTrace: stackTrace,
              operation: 'getUserDailyStatsInRangeStream',
              defaultValue: [],
              severity: ErrorSeverity.medium,
            );
          }
        });
  }

  // --- Shared Video Methods ---

  Future<void> addOrUpdateSharedVideo(SharedVideoModel video) async {
    try {
      final videoRef = _firestore.collection('videos').doc(video.id);
      final doc = await videoRef.get();

      if (doc.exists) {
        final existingData = SharedVideoModel.fromJson(doc.data()!);
        final Map<String, List<Map<String, dynamic>>> mergedCaptions = Map.from(
          existingData.captionsWithTimestamps,
        );

        video.captionsWithTimestamps.forEach((lang, newCaptions) {
          mergedCaptions[lang] = newCaptions;
        });

        await videoRef.update({
          'title': video.title,
          'channelName': video.channelName,
          'thumbnailUrl': video.thumbnailUrl,
          'url': video.url,
          'captionsWithTimestamps': mergedCaptions,
          'updatedAt': Timestamp.now(),
        });
      } else {
        await videoRef.set(video.copyWith(updatedAt: DateTime.now()).toJson());
      }
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'addOrUpdateSharedVideo',
        severity: ErrorSeverity.high,
        extra: {'videoId': video.id},
      );
      rethrow;
    }
  }

  Future<SharedVideoModel?> getSharedVideo(String videoId) async {
    try {
      final doc = await _firestore.collection('videos').doc(videoId).get();
      if (doc.exists) {
        return SharedVideoModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'getSharedVideo',
        severity: ErrorSeverity.high,
        extra: {'videoId': videoId},
      );
      return null; // 動画情報が存在しない場合もあるためnullを返す
    }
  }

  Stream<List<SharedVideoModel>> getSharedVideosStream() {
    return _firestore.collection('videos').snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => SharedVideoModel.fromJson(doc.data()))
            .toList();
      } catch (e, stackTrace) {
        return FirebaseRepositoryErrorHandler.handleStreamError<
          List<SharedVideoModel>
        >(
          error: e,
          stackTrace: stackTrace,
          operation: 'getSharedVideosStream',
          defaultValue: [],
          severity: ErrorSeverity.medium,
        );
      }
    });
  }

  Future<List<String>> getUserVideoIds(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('userCards')
              .get();
      // videoId が null でないものだけを抽出し、ユニークなIDのセットを作成
      final videoIds =
          snapshot.docs
              .map((doc) => doc.data()['videoId'] as String?)
              .where((videoId) => videoId != null)
              .cast<String>()
              .toSet()
              .toList();
      return videoIds;
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'getUserVideoIds',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId},
      );
      return [];
    }
  }

  Stream<List<String>> getUserVideoIdsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('userCards')
        .snapshots()
        .map((snapshot) {
          try {
            final videoIds =
                snapshot.docs
                    .map((doc) => doc.data()['videoId'] as String?)
                    .where((videoId) => videoId != null)
                    .cast<String>()
                    .toSet()
                    .toList();
            return videoIds;
          } catch (e, stackTrace) {
            return FirebaseRepositoryErrorHandler.handleStreamError<
              List<String>
            >(
              error: e,
              stackTrace: stackTrace,
              operation: 'getUserVideoIdsStream',
              defaultValue: [],
              severity: ErrorSeverity.medium,
            );
          }
        });
  }

  Stream<List<SharedVideoModel>> getSharedVideosByIdsStream(
    List<String> videoIds,
  ) {
    if (videoIds.isEmpty) {
      return Stream.value([]); // IDリストが空の場合は空のストリームを返す
    }
    // Firestoreの `in` クエリは最大30個の要素をサポート
    // 必要に応じてvideoIdsをチャンクに分割する
    List<Stream<List<SharedVideoModel>>> streams = [];
    for (var i = 0; i < videoIds.length; i += 30) {
      final chunk = videoIds.sublist(
        i,
        i + 30 > videoIds.length ? videoIds.length : i + 30,
      );
      streams.add(
        _firestore
            .collection('videos')
            .where(FieldPath.documentId, whereIn: chunk)
            .snapshots()
            .map((snapshot) {
              try {
                return snapshot.docs
                    .map((doc) => SharedVideoModel.fromJson(doc.data()))
                    .toList();
              } catch (e, stackTrace) {
                return FirebaseRepositoryErrorHandler.handleStreamError<
                  List<SharedVideoModel>
                >(
                  error: e,
                  stackTrace: stackTrace,
                  operation: 'getSharedVideosByIdsStream-chunk',
                  defaultValue: <SharedVideoModel>[],
                  severity: ErrorSeverity.medium,
                );
              }
            }),
      );
    }

    // 複数のストリームをマージする (ここでは簡略化のため最初のストリームのみを使用する例を示すが、
    // 実際には rxdart の CombineLatestStream や StreamGroup.merge を使うなど、
    // より堅牢な方法で複数のストリームの結果を結合する必要がある)
    // この例では、簡単のため、最初のチャンクのみを対象とします。
    // TODO: 複数のストリームを正しくマージする処理を実装する
    if (streams.isNotEmpty) {
      // rxdartのCombineLatestStreamなどを使って複数のストリームを結合する
      // 簡単のため、ここでは最初のストリームのみを返す (本番では修正が必要)
      // return streams.first;

      // 複数のストリームを結合するよりシンプルなアプローチとして、
      // videoIds の変更をトリガーに、都度 getSharedVideosByIds を呼び出す形も検討できる。
      // ここでは、Streamを返す形を維持しつつ、結合は呼び出し側で行うか、
      // もしくは、より高度なStream結合ライブラリの導入を検討する。
      //
      // 今回は、まず getSharedVideosByIds (Futureを返す) を実装し、
      // Provider側でそれをStreamに変換するアプローチを取る。
      // そのため、この getSharedVideosByIdsStream は一旦コメントアウトし、
      // 代わりに Future<List<SharedVideoModel>> getSharedVideosByIds(List<String> videoIds) を実装する。
      //
      // やはりStreamで返す方がリアルタイム性は高いので、
      // Streamを結合する方向で進める。
      // rxdart を使うのが一般的だが、依存を増やさないために、
      // videoIds の Stream をリッスンし、変更があるたびにクエリを発行し直す形にする。
      // そのため、このメソッドは videoIds のリストを直接受け取るのではなく、
      // videoIds の Stream を受け取るか、あるいは Provider 側で videoIds の Stream を監視し、
      // このメソッド (videoIds リストを引数に取る) を呼び出す形にする。
      //
      // ここでは、videoIds のリストを引数に取り、それに対応する動画のStreamを返す。
      // Provider側で、ユーザーのカードから得られる videoId のリストのStreamを監視し、
      // そのリストが変わるたびにこのメソッドを呼び出し、得られたStreamをlistenする。

      // Firestoreの `whereIn` は最大30要素まで。
      // 複数のクエリ結果を結合する必要がある。
      // Stream.fromFutures で複数のFutureを一つのStreamにまとめることができる。
      // ただし、これは各Futureが完了した時点で値を発行するため、
      // 全ての動画が揃うまで待つか、部分的に表示するか設計による。
      // ここでは、簡単のため、最初の30件のみを対象とするストリームを返す。
      // 本番環境では、ページネーションや、より洗練されたストリーム結合が必要。
      if (videoIds.length > 30) {
        debugPrint(
          "Warning: Too many video IDs for 'in' query. Returning first 30 results only.",
        );
      }
      final queryChunk = videoIds.take(30).toList();
      if (queryChunk.isEmpty) return Stream.value([]);

      return _firestore
          .collection('videos')
          .where(FieldPath.documentId, whereIn: queryChunk)
          .snapshots()
          .map((snapshot) {
            try {
              return snapshot.docs
                  .map((doc) => SharedVideoModel.fromJson(doc.data()))
                  .toList();
            } catch (e, stackTrace) {
              return FirebaseRepositoryErrorHandler.handleStreamError<
                List<SharedVideoModel>
              >(
                error: e,
                stackTrace: stackTrace,
                operation: 'getSharedVideosByIdsStream',
                defaultValue: <SharedVideoModel>[],
                severity: ErrorSeverity.medium,
              );
            }
          });
    }
    return Stream.value([]);
  }

  // --- User Profile Update Methods ---

  Future<void> updateUserStreaks(
    String userId, {
    int? currentStreak,
    int? longestStreak,
    DateTime? lastLearningDate,
    bool? isHiveDataMigrated,
  }) async {
    try {
      final Map<String, dynamic> dataToUpdate = {};
      if (currentStreak != null) {
        dataToUpdate['currentStreak'] = currentStreak;
      }
      if (longestStreak != null) {
        dataToUpdate['longestStreak'] = longestStreak;
      }
      if (lastLearningDate != null) {
        dataToUpdate['lastLearningDate'] = Timestamp.fromDate(lastLearningDate);
      }
      if (isHiveDataMigrated != null) {
        dataToUpdate['isHiveDataMigrated'] = isHiveDataMigrated;
      }

      if (dataToUpdate.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(dataToUpdate);
      }
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'updateUserStreaks',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId},
      );
      // ストリーク更新の失敗は致命的ではない
    }
  }

  Future<void> markHiveDataAsMigrated(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isHiveDataMigrated': true,
      });
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'markHiveDataAsMigrated',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId},
      );
    }
  }

  Future<void> decrementUserGem() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated to decrement gem.');
    }
    final userDocRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        transaction.update(userDocRef, {'gemCount': FieldValue.increment(-1)});
      });
      debugPrint('Gem decremented successfully for user $userId');
    } catch (e) {
      debugPrint('Error decrementing gem: $e');
      // エラーを再スローするか、適切に処理する
      rethrow;
    }
  }

  Future<void> incrementUserGem() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated to increment gem.');
    }
    final userDocRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        transaction.update(userDocRef, {'gemCount': FieldValue.increment(1)});
      });
      debugPrint('Gem incremented successfully for user $userId');
    } catch (e) {
      debugPrint('Error incrementing gem: $e');
      rethrow;
    }
  }

  Future<void> updateFavoriteChannel(
    String userId,
    String channelId,
    bool isFavorite,
  ) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      if (isFavorite) {
        await userDocRef.update({
          'favoriteChannelIds': FieldValue.arrayUnion([channelId]),
        });
      } else {
        await userDocRef.update({
          'favoriteChannelIds': FieldValue.arrayRemove([channelId]),
        });
      }
      debugPrint(
        'Favorite channel ${isFavorite ? "added" : "removed"}: $channelId for user $userId',
      );
    } catch (e) {
      debugPrint('Failed to update favorite channel: $e');
      rethrow;
    }
  }

  // --- Batch Write Methods for Data Migration ---

  Future<void> batchWriteUserCards(
    String userId,
    List<FirebaseCardModel> cards,
  ) async {
    if (cards.isEmpty) return;
    try {
      final WriteBatch batch = _firestore.batch();
      final userCardsCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('userCards');

      for (final card in cards) {
        final docRef = userCardsCollection.doc(card.id);
        batch.set(docRef, card.toJson());
      }
      await batch.commit();
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'batchWriteUserCards',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId, 'cardCount': cards.length},
      );
      rethrow; // バッチ処理の失敗は重要
    }
  }

  Future<void> batchWriteUserDailyStats(
    String userId,
    List<FirebaseDailyStatModel> stats,
  ) async {
    if (stats.isEmpty) return;
    try {
      final WriteBatch batch = _firestore.batch();
      final userDailyStatsCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('userDailyStats');

      for (final stat in stats) {
        final docRef = userDailyStatsCollection.doc(stat.dateString);
        batch.set(docRef, stat.toJson());
      }
      await batch.commit();
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'batchWriteUserDailyStats',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId, 'statCount': stats.length},
      );
      rethrow;
    }
  }

  Future<void> batchWriteSharedVideos(List<SharedVideoModel> videos) async {
    if (videos.isEmpty) return;
    try {
      final WriteBatch batch = _firestore.batch();
      final videosCollection = _firestore.collection('videos');

      for (final video in videos) {
        final docRef = videosCollection.doc(video.id);
        batch.set(docRef, video.toJson());
      }
      await batch.commit();
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'batchWriteSharedVideos',
        severity: ErrorSeverity.medium,
        extra: {'videoCount': videos.length},
      );
      rethrow;
    }
  }

  // --- Screenshot Methods ---
  Future<String?> uploadScreenshot({
    required String userId,
    required String cardId,
    required Uint8List imageBytes,
  }) async {
    try {
      // 画像を圧縮する
      final Uint8List compressedBytes =
          await FlutterImageCompress.compressWithList(
            imageBytes,
            // 480p程度に圧縮
            minHeight: 480,
            minWidth: 854,
            quality: 75, // 品質を少し下げる
            format: CompressFormat.jpeg,
          );

      final String filePath = 'user_screenshots/$userId/$cardId/screenshot.jpg';
      final firebase_storage.Reference ref = _storage.ref().child(filePath);

      final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
      );
      final firebase_storage.UploadTask uploadTask = ref.putData(
        compressedBytes, // 圧縮されたバイトデータを使用
        metadata,
      );

      final firebase_storage.TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'uploadScreenshot',
        severity: ErrorSeverity.high,
        extra: {'userId': userId, 'cardId': cardId},
      );
      return null; // スクリーンショットのアップロード失敗はユーザーにとって重要
    }
  }

  // --- Watch History Methods ---

  Future<void> addWatchHistory(
    String userId,
    String channelId,
    String videoId,
  ) async {
    try {
      final watchHistoryCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('watchHistory');

      // 新しい視聴履歴を追加
      await watchHistoryCollection.add({
        'channelId': channelId,
        'videoId': videoId,
        'watchedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'addWatchHistory',
        severity: ErrorSeverity.low,
        extra: {'userId': userId, 'channelId': channelId, 'videoId': videoId},
      );
    }
  }

  Future<bool> shouldRequestReview(String userId) async {
    try {
      debugPrint('shouldRequestReview called for user: $userId');

      // ユーザーのレビュー依頼フラグをチェック
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        debugPrint('User document does not exist');
        return false;
      }

      final userData = userDoc.data()!;
      final hasRequestedReview =
          userData['hasRequestedReview'] as bool? ?? false;
      debugPrint('hasRequestedReview: $hasRequestedReview');

      // 既にレビュー依頼済みの場合は表示しない
      if (hasRequestedReview) {
        debugPrint('User has already requested review');
        return false;
      }

      // 視聴履歴件数をチェック
      final watchHistorySnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('watchHistory')
              .get();

      final watchHistoryCount = watchHistorySnapshot.docs.length;
      debugPrint('Watch history count: $watchHistoryCount');

      final shouldShow = watchHistoryCount >= 10;
      debugPrint('Should show review request: $shouldShow');
      return shouldShow;
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'shouldRequestReview',
        severity: ErrorSeverity.low,
        extra: {'userId': userId},
      );
      return false;
    }
  }

  Future<void> markReviewRequested(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'hasRequestedReview': true,
      });
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'markReviewRequested',
        severity: ErrorSeverity.low,
        extra: {'userId': userId},
      );
    }
  }

  Stream<List<WatchHistory>> getWatchHistoryStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('watchHistory')
        .orderBy('watchedAt', descending: true)
        .limit(100) // 最新100件のみ取得
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => WatchHistory.fromFirestore(doc))
                .toList();
          } catch (e, stackTrace) {
            return FirebaseRepositoryErrorHandler.handleStreamError<
              List<WatchHistory>
            >(
              error: e,
              stackTrace: stackTrace,
              operation: 'getWatchHistoryStream',
              defaultValue: [],
              severity: ErrorSeverity.low,
            );
          }
        });
  }

  // --- Playlist Methods ---

  Future<String> createPlaylist({
    required String name,
    String description = '',
    PlaylistType type = PlaylistType.custom,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated to create playlist.');
    }

    try {
      final now = DateTime.now();
      // Firestoreのドキュメント参照を先に作成
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(); // 自動生成されたIDを持つドキュメント参照
      
      final playlistData = PlaylistModel(
        id: docRef.id, // 生成されたIDを使用
        name: name,
        description: description,
        type: type,
        videoIds: [], // 空のリストを明示的に設定
        videoCount: 0, // 0を明示的に設定
        createdAt: now,
        updatedAt: now,
      );

      final jsonData = playlistData.toJson();
      debugPrint('Saving playlist to Firestore: $jsonData');
      debugPrint('Playlist ID being saved: "${playlistData.id}" (length: ${playlistData.id.length})');
      
      // IDが空でないことを確認
      if (playlistData.id.isEmpty) {
        debugPrint('ERROR: Attempting to save playlist with empty ID!');
        throw Exception('Playlist ID cannot be empty');
      }
      
      await docRef.set(jsonData);

      // お気に入りと後で見るリストの場合、ユーザードキュメントも更新
      if (type == PlaylistType.favorites || type == PlaylistType.watchLater) {
        await _firestore.collection('users').doc(userId).update({
          type == PlaylistType.favorites
              ? 'favoritesPlaylistId'
              : 'watchLaterPlaylistId': docRef.id,
        });
      }

      return docRef.id;
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'createPlaylist',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId, 'playlistName': name, 'type': type.name},
      );
      rethrow;
    }
  }

  Future<PlaylistModel?> getPlaylist(String playlistId) async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .get();

      if (!doc.exists) {
        debugPrint('Playlist document does not exist: $playlistId');
        return null;
      }

      final data = doc.data()!;
      debugPrint('Retrieved playlist data from Firestore: $data');
      debugPrint('Document ID from Firestore: ${doc.id}');
      
      // Firestoreのデータにidが含まれているか確認
      final hasIdInData = data.containsKey('id');
      debugPrint('Has id field in Firestore data: $hasIdInData');
      if (hasIdInData) {
        debugPrint('ID value in Firestore data: ${data['id']}');
      }
      
      // idフィールドを明示的に追加（Firestoreのdoc.idを使用）
      final playlistDataWithId = {
        'id': doc.id,
        ...data,
      };
      debugPrint('Final playlist data with id: $playlistDataWithId');
      
      // 空のIDを持つプレイリストを修正（一時的な修正措置）
      if (hasIdInData && (data['id'] == null || data['id'] == '')) {
        debugPrint('WARNING: Fixing empty ID in Firestore document');
        try {
          await doc.reference.update({'id': doc.id});
          debugPrint('Successfully updated empty ID to: ${doc.id}');
        } catch (e) {
          debugPrint('Failed to update empty ID: $e');
        }
      }
      
      return PlaylistModel.fromJson(playlistDataWithId);
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'getPlaylist',
        severity: ErrorSeverity.low,
        extra: {'playlistId': playlistId},
      );
      rethrow;
    }
  }

  Stream<List<PlaylistModel>> getUserPlaylistsStream(String? userId) {
    userId ??= getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              // IDフィールドが空の場合は、ドキュメントIDを使用
              if (data['id'] == null || data['id'] == '') {
                debugPrint('Fixing empty ID for playlist in stream: ${doc.id}');
              }
              return PlaylistModel.fromJson({
                'id': doc.id,  // 常にドキュメントIDを使用
                ...data,
              });
            }).toList();
          } catch (e, stackTrace) {
            return FirebaseRepositoryErrorHandler.handleStreamError<
              List<PlaylistModel>
            >(
              error: e,
              stackTrace: stackTrace,
              operation: 'getUserPlaylistsStream',
              defaultValue: [],
              severity: ErrorSeverity.low,
            );
          }
        });
  }

  Future<void> addVideoToPlaylist({
    required String playlistId,
    required String videoId,
    String? note,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final playlistRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId);
      
      await _firestore.runTransaction((transaction) async {
        final playlistDoc = await transaction.get(playlistRef);
        if (!playlistDoc.exists) {
          throw Exception('Playlist not found');
        }

        final playlist = PlaylistModel.fromJson({
          'id': playlistDoc.id,
          ...playlistDoc.data()!,
        });

        if (playlist.videoIds.contains(videoId)) {
          throw Exception('Video already in playlist');
        }

        transaction.update(playlistRef, {
          'videoIds': FieldValue.arrayUnion([videoId]),
          'videoCount': FieldValue.increment(1),
          'updatedAt': Timestamp.now(),
        });

        // プレイリストアイテムをサブコレクションに追加
        final itemData = PlaylistItemModel(
          videoId: videoId,
          order: playlist.videoCount,
          addedAt: DateTime.now(),
          note: note,
        );

        final itemRef = playlistRef.collection('items').doc();
        transaction.set(itemRef, itemData.toJson());
      });
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'addVideoToPlaylist',
        severity: ErrorSeverity.medium,
        extra: {'playlistId': playlistId, 'videoId': videoId},
      );
      rethrow;
    }
  }

  Future<void> removeVideoFromPlaylist({
    required String playlistId,
    required String videoId,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final playlistRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId);
      
      await _firestore.runTransaction((transaction) async {
        // プレイリストから動画IDを削除
        transaction.update(playlistRef, {
          'videoIds': FieldValue.arrayRemove([videoId]),
          'videoCount': FieldValue.increment(-1),
          'updatedAt': Timestamp.now(),
        });

        // サブコレクションからアイテムを削除
        final itemsQuery = await playlistRef
            .collection('items')
            .where('videoId', isEqualTo: videoId)
            .get();

        for (final doc in itemsQuery.docs) {
          transaction.delete(doc.reference);
        }
      });
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'removeVideoFromPlaylist',
        severity: ErrorSeverity.medium,
        extra: {'playlistId': playlistId, 'videoId': videoId},
      );
      rethrow;
    }
  }

  Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .update(updateData);
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'updatePlaylist',
        severity: ErrorSeverity.low,
        extra: {'playlistId': playlistId},
      );
      rethrow;
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final playlistRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId);
      
      // サブコレクションのアイテムも削除
      final batch = _firestore.batch();
      
      // アイテムを削除
      final items = await playlistRef.collection('items').get();
      for (final doc in items.docs) {
        batch.delete(doc.reference);
      }
      
      // プレイリスト本体を削除
      batch.delete(playlistRef);
      
      await batch.commit();
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'deletePlaylist',
        severity: ErrorSeverity.medium,
        extra: {'playlistId': playlistId},
      );
      rethrow;
    }
  }

  Stream<bool> isVideoInPlaylistStream(String videoId, String playlistId) {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value(false);
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .doc(playlistId)
        .snapshots()
        .map((snapshot) {
          try {
            if (!snapshot.exists) return false;
            final data = snapshot.data();
            final videoIds = List<String>.from(data?['videoIds'] ?? []);
            return videoIds.contains(videoId);
          } catch (e, stackTrace) {
            debugPrint('Error checking video in playlist: $e');
            return false;
          }
        })
        .handleError((error, stackTrace) {
          FirebaseRepositoryErrorHandler.handleError(
            error: error,
            stackTrace: stackTrace,
            operation: 'isVideoInPlaylistStream',
            severity: ErrorSeverity.low,
            extra: {'videoId': videoId, 'playlistId': playlistId},
          );
          return false;
        });
  }

  Future<Map<String, PlaylistModel>> getUserSpecialPlaylists({
    String favoritesName = 'Favorites',
    String watchLaterName = 'Watch Later',
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      
      final favoritesId = userData?['favoritesPlaylistId'] as String?;
      final watchLaterId = userData?['watchLaterPlaylistId'] as String?;
      
      debugPrint('getUserSpecialPlaylists - User data: $userData');
      debugPrint('Favorites playlist ID: $favoritesId');
      debugPrint('Watch later playlist ID: $watchLaterId');
      
      final Map<String, PlaylistModel> result = {};
      
      // お気に入りプレイリストを取得/作成
      if (favoritesId != null) {
        final playlist = await getPlaylist(favoritesId);
        if (playlist != null) {
          result['favorites'] = playlist;
        }
      } else {
        // 存在しない場合は作成
        final id = await createPlaylist(
          name: favoritesName,
          type: PlaylistType.favorites,
        );
        debugPrint('Created favorites playlist with ID: $id');
        final playlist = await getPlaylist(id);
        if (playlist != null) {
          result['favorites'] = playlist;
        } else {
          debugPrint('Error: Failed to get favorites playlist after creation');
        }
      }
      
      // 後で見るプレイリストを取得/作成
      if (watchLaterId != null) {
        final playlist = await getPlaylist(watchLaterId);
        if (playlist != null) {
          result['watchLater'] = playlist;
        }
      } else {
        // 存在しない場合は作成
        final id = await createPlaylist(
          name: watchLaterName,
          type: PlaylistType.watchLater,
        );
        final playlist = await getPlaylist(id);
        if (playlist != null) {
          result['watchLater'] = playlist;
        }
      }
      
      return result;
    } catch (e, stackTrace) {
      FirebaseRepositoryErrorHandler.handleError(
        error: e,
        stackTrace: stackTrace,
        operation: 'getUserSpecialPlaylists',
        severity: ErrorSeverity.medium,
        extra: {'userId': userId},
      );
      rethrow;
    }
  }
}
