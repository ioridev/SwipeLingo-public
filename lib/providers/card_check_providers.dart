import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../models/card.dart' as hive_models; // Hiveモデルは不要に
import '../models/firebase_card_model.dart';
import 'repository_providers.dart'; // FirebaseRepository Provider をインポート
// import 'hive_providers.dart'; // Hive Box Providers は不要になる可能性
import '../repositories/firebase_repository.dart'; // FirebaseRepository をインポート

// --- State Notifier ---

/// CardCheckScreen の状態 (主に選択状態) を管理する StateNotifier
class CardCheckState {
  final List<FirebaseCardModel> generatedCards; // FirebaseCardModelのリストに変更
  final Set<String> selectedCardIds;

  CardCheckState({
    required this.generatedCards,
    this.selectedCardIds = const {},
  });

  CardCheckState copyWith({
    List<FirebaseCardModel>? generatedCards, // FirebaseCardModelのリストに変更
    Set<String>? selectedCardIds,
  }) {
    return CardCheckState(
      generatedCards: generatedCards ?? this.generatedCards,
      selectedCardIds: selectedCardIds ?? this.selectedCardIds,
    );
  }
}

class CardCheckNotifier extends StateNotifier<CardCheckState> {
  final Ref _ref;

  // generatedCards を初期値として受け取る
  final FirebaseRepository _firebaseRepository;

  CardCheckNotifier(
    this._ref,
    List<FirebaseCardModel> initialCards,
  ) // FirebaseCardModelのリストに変更
  : _firebaseRepository = _ref.read(firebaseRepositoryProvider),
      super(
        CardCheckState(
          generatedCards: initialCards,
          selectedCardIds: const {}, // デフォルトでオフにする
        ),
      );

  void toggleCardSelection(String cardId) {
    final currentSelection = Set<String>.from(state.selectedCardIds);
    if (currentSelection.contains(cardId)) {
      currentSelection.remove(cardId);
    } else {
      currentSelection.add(cardId);
    }
    state = state.copyWith(selectedCardIds: currentSelection);
  }

  void selectAll() {
    final allIds = state.generatedCards.map((card) => card.id).toSet();
    state = state.copyWith(selectedCardIds: allIds);
  }

  void deselectAll() {
    state = state.copyWith(selectedCardIds: {});
  }

  /// 選択されたカードを Hive に保存する
  Future<void> saveSelectedCards() async {
    final firebaseCardsToSave = // 変数名を変更し、型は既に List<FirebaseCardModel>
        state.generatedCards
            .where((card) => state.selectedCardIds.contains(card.id))
            .toList();

    if (firebaseCardsToSave.isEmpty) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not logged in.");
    }

    // HiveモデルからFirebaseモデルへの変換は不要 (既にFirebaseCardModelのため)

    try {
      // FirebaseRepository を使って Firestore に保存
      await _firebaseRepository.batchWriteUserCards(
        userId,
        firebaseCardsToSave, // そのまま渡す
      );
    } catch (e) {
      throw Exception("Failed to save cards to Firebase.");
    }
  }
}

// --- Providers ---

// StateNotifierProvider.family を使用して初期カードリストを渡す
final cardCheckNotifierProvider = StateNotifierProvider.family<
  CardCheckNotifier,
  CardCheckState,
  List<FirebaseCardModel> // FirebaseCardModelのリストに変更
>((ref, initialCards) {
  return CardCheckNotifier(ref, initialCards);
});

// Hive関連の古いコメントは削除
