import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth をインポート
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart'; // UserModel
import 'repository_providers.dart'; // firebaseRepositoryProvider

// --- HomeScreen Specific Providers ---

/// レビューが必要なカード数を計算する StreamProvider
final dueCardCountProvider = StreamProvider<int>((ref) {
  final firebaseRepository = ref.watch(firebaseRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return Stream.value(0); // ユーザーがいない場合は0を返す
  }

  return firebaseRepository.getUserCardsStream(userId).map((cards) {
    final now = DateTime.now();
    return cards
        .where(
          (card) => card.nextReview == null || card.nextReview!.isBefore(now),
        )
        .length;
  });
});

/// 過去30日間の学習統計データを取得する Provider
final contributionDataProvider = StreamProvider<Map<DateTime, int>>((ref) {
  final firebaseRepository = ref.watch(firebaseRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return Stream.value({});
  }

  final today = DateTime.now();
  final thirtyDaysAgo = today.subtract(const Duration(days: 29)); // 今日を含む過去30日

  return firebaseRepository
      .getUserDailyStatsInRangeStream(userId, thirtyDaysAgo, today)
      .map((statsList) {
        final data = <DateTime, int>{};
        for (final stat in statsList) {
          // learnedDate は日付のみになっているはずだが、念のため日付部分のみを使用
          final dateOnly = DateTime(
            stat.learnedDate.year,
            stat.learnedDate.month,
            stat.learnedDate.day,
          );
          data[dateOnly] = (data[dateOnly] ?? 0) + stat.reviewedCount;
        }
        // ヒートマップ用に、データがない日も0として埋める
        for (var i = 0; i < 30; i++) {
          final date = DateTime(
            today.year,
            today.month,
            today.day,
          ).subtract(Duration(days: i));
          data.putIfAbsent(date, () => 0);
        }
        return data;
      });
});

/// 連続学習日数 (Streak) を計算する Provider
final streakProvider = StreamProvider<int>((ref) {
  final firebaseRepository = ref.watch(firebaseRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return Stream.value(0);
  }
  // UserModelの変更を監視するStreamを作成 (仮。実際にはFirestoreのStreamをリッスン)
  // ここではgetUserを定期的に呼ぶか、UserModelをStreamで提供する別のProviderが必要
  // 簡単のため、ここではFirestoreのユーザー情報を直接Streamで取得する形を想定
  // (FirebaseRepositoryに `Stream<UserModel?> getUserStream(String userId)` があると仮定)

  // 実際には FirebaseRepository に Stream<UserModel?> getUserStream(String userId) を実装し、
  // それを watch するのが望ましい。
  // ここでは、デモとして、ユーザーデータが更新されたことを何らかの形で検知した際に
  // 再評価されるような作りにする。
  // 例えば、他のProvider（例：authStateChangesProvider）に依存させるなど。
  // もしくは、FutureProviderにして、ref.watchで定期的にリフレッシュする。

  // UserModelのcurrentStreakを直接返す
  return ref.watch(firebaseRepositoryProvider).getUserStream(userId).map((
    userModel,
  ) {
    return userModel?.currentStreak ?? 0;
  });
});

/// 作成されたカードの総数を計算する StreamProvider
final totalCardCountProvider = StreamProvider<int>((ref) {
  final firebaseRepository = ref.watch(firebaseRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return Stream.value(0);
  }

  return firebaseRepository
      .getUserCardsStream(userId)
      .map((cards) => cards.length);
});

/// 現在のユーザーモデルを提供する StreamProvider
final userProvider = StreamProvider<UserModel?>((ref) {
  final firebaseRepository = ref.watch(firebaseRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return Stream.value(null); // ユーザーがいない場合は null を返す
  }

  return firebaseRepository.getUserStream(userId);
});

/// レビュー依頼を表示すべきかを判定する FutureProvider
final shouldShowReviewRequestProvider = FutureProvider<bool>((ref) async {
  final firebaseRepository = ref.watch(firebaseRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return false;
  }

  return await firebaseRepository.shouldRequestReview(userId);
});
