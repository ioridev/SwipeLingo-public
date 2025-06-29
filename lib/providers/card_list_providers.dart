import 'dart:async'; // StackTrace のために追加

import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth をインポート
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart'; // 不要になる可能性
import '../models/firebase_card_model.dart'; // Firebase用カードモデル
// import 'hive_providers.dart'; // 不要になる可能性
import '../repositories/firebase_repository.dart'; // FirebaseRepository
import 'repository_providers.dart'; // firebaseRepositoryProvider

// カードリストの状態と操作を管理する StateNotifier
class CardListNotifier
    extends StateNotifier<AsyncValue<List<FirebaseCardModel>>> {
  // モデルをFirebase用に変更
  final Ref _ref;
  final FirebaseRepository _firebaseRepository;
  StreamSubscription? _cardsSubscription;
  final String? _userId; // 現在のユーザーIDを保持

  CardListNotifier(this._ref)
    : _firebaseRepository = _ref.read(firebaseRepositoryProvider),
      _userId = FirebaseAuth.instance.currentUser?.uid, // 初期化時にユーザーIDを取得
      super(const AsyncValue.loading()) {
    if (_userId != null) {
      _subscribeToUserCards(_userId);
    } else {
      // ユーザーがログインしていない場合は空のデータを表示またはエラー表示
      state = AsyncValue.data([]); // または AsyncValue.error(...)
      // ログイン状態を監視する別のProviderに依存して、ログイン後に_subscribeToUserCardsを呼ぶなども検討可
    }
  }

  void _subscribeToUserCards(String userId) {
    _cardsSubscription?.cancel();
    state = const AsyncValue.loading();
    try {
      _cardsSubscription = _firebaseRepository
          .getUserCardsStream(userId)
          .listen(
            (cards) {
              // 必要に応じてソート
              cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              state = AsyncValue.data(cards);
            },
            onError: (e, stackTrace) {
              debugPrint("Error in user cards stream: $e");
              state = AsyncValue.error(e, stackTrace);
            },
          );
    } catch (e, stackTrace) {
      debugPrint("Error setting up user cards stream: $e");
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteCard(String cardId) async {
    if (_userId == null) {
      throw Exception("User not logged in. Cannot delete card.");
    }
    try {
      await _firebaseRepository.deleteUserCard(_userId, cardId);
      debugPrint("Card $cardId deleted successfully from Firestore.");
      // Streamが自動で更新するので、手動での状態更新は不要な場合が多い
    } catch (e) {
      debugPrint("Error deleting card $cardId: $e");
      throw Exception("Failed to delete card: $e");
    }
  }

  @override
  void dispose() {
    _cardsSubscription?.cancel();
    super.dispose();
  }
}

// StateNotifierProvider の定義
final cardListProvider = StateNotifierProvider<
  CardListNotifier,
  AsyncValue<List<FirebaseCardModel>>
>(
  // モデルをFirebase用に変更
  (ref) {
    return CardListNotifier(ref);
  },
);
