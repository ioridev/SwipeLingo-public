import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/firebase_daily_stat_model.dart';
import '../models/firebase_card_model.dart'; // Firebase用モデルをインポート
// import '../models/stats.dart'; // Hiveモデルは不要
import '../services/srs.dart' as srs;
import 'package:intl/intl.dart';
// import 'hive_providers.dart'; // Hive Box Providers は不要
import '../repositories/firebase_repository.dart';
import 'repository_providers.dart';
import '../../models/session_result.dart';
// import 'card_list_providers.dart'; // cardListProviderのnotifierは直接使わない想定
import 'base_flashcard_provider.dart';

// --- TTS Provider ---
final flutterTtsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
    IosTextToSpeechAudioCategoryOptions.mixWithOthers,
  ]);
  return tts;
});

// --- State Notifier ---

enum CardFace { front, back }

class FlashcardState with BaseFlashcardState {
  @override
  final List<FirebaseCardModel> dueCards; // Firebaseモデルに変更

  @override
  final int currentIndex;
  @override
  final CardFace currentFace;
  @override
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  final bool isSessionComplete;
  @override
  final SessionResult? sessionResult;
  @override
  final String? currentVideoThumbnailUrl;

  @override
  List<FirebaseCardModel> get cards => dueCards; // Firebaseモデルに変更

  FlashcardState({
    this.dueCards = const [],
    this.currentIndex = 0,
    this.currentFace = CardFace.front,
    this.isLoading = true,
    this.errorMessage,
    this.isSessionComplete = false,
    this.sessionResult,
    this.currentVideoThumbnailUrl,
  });

  FlashcardState copyWith({
    List<FirebaseCardModel>? dueCards, // Firebaseモデルに変更
    int? currentIndex,
    CardFace? currentFace,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSessionComplete,
    SessionResult? sessionResult,
    String? currentVideoThumbnailUrl,
  }) {
    return FlashcardState(
      dueCards: dueCards ?? this.dueCards,
      currentIndex: currentIndex ?? this.currentIndex,
      currentFace: currentFace ?? this.currentFace,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSessionComplete: isSessionComplete ?? this.isSessionComplete,
      sessionResult: sessionResult ?? this.sessionResult,
      currentVideoThumbnailUrl:
          currentVideoThumbnailUrl ?? this.currentVideoThumbnailUrl,
    );
  }
}

class FlashcardNotifier extends BaseFlashcardNotifier<FlashcardState> {
  final FirebaseRepository _firebaseRepository;
  final String? _userId;

  final Map<String, bool> _sessionResults = {};
  List<FirebaseCardModel> _reviewedCardsInOrder = []; // Firebaseモデルに変更
  final Map<String, int> _ttsPlaybackCount = {}; // TTS再生回数を記録

  FlashcardNotifier(Ref ref)
    : _firebaseRepository = ref.read(firebaseRepositoryProvider),
      _userId = FirebaseAuth.instance.currentUser?.uid,
      super(ref, FlashcardState()) {
    if (_userId != null) {
      _loadDueCards(_userId);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "User not logged in.",
      );
    }
  }

  Future<void> _loadDueCards(String userId) async {
    _sessionResults.clear();
    _reviewedCardsInOrder = [];
    _ttsPlaybackCount.clear(); // TTS再生回数をリセット
    state = state.copyWith(
      isLoading: true,
      isSessionComplete: false,
      sessionResult: null,
      errorMessage: null,
      clearError: true,
      currentVideoThumbnailUrl: null,
    );
    try {
      // Firestoreからレビュー期日のカードを取得
      final allUserCards =
          await _firebaseRepository.getUserCardsStream(userId).first;
      final now = DateTime.now();
      final dueCards =
          allUserCards
              .where(
                (card) =>
                    card.nextReview == null || card.nextReview!.isBefore(now),
              )
              .toList();

      const reviewLimit = 20;
      List<FirebaseCardModel> cardsForSession;

      if (dueCards.isEmpty) {
        // 期日のカードがない場合、全てのカードからランダムに選択
        final allCardsCopy = List<FirebaseCardModel>.from(allUserCards);
        allCardsCopy.shuffle();
        cardsForSession = allCardsCopy.take(reviewLimit).toList();
      } else {
        // 期日のカードがある場合、シャッフルして制限
        dueCards.shuffle();
        cardsForSession = dueCards.take(reviewLimit).toList();
      }
      _reviewedCardsInOrder = List.from(cardsForSession);

      String? firstVideoThumbnailUrl;
      if (cardsForSession.isNotEmpty) {
        final firstCardVideoId = cardsForSession.first.videoId;
        final videoDoc = await _firebaseRepository.getSharedVideo(
          firstCardVideoId,
        );
        firstVideoThumbnailUrl = videoDoc?.thumbnailUrl;
      }

      state = state.copyWith(
        dueCards: cardsForSession,
        currentIndex: 0,
        currentFace: CardFace.front,
        isLoading: false,
        currentVideoThumbnailUrl: firstVideoThumbnailUrl,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to load cards. $e",
      );
    }
  }

  @override
  void flipCard() {
    state = state.copyWith(
      currentFace:
          state.currentFace == CardFace.front ? CardFace.back : CardFace.front,
    );
  }

  @override
  Future<void> handleSwipe(bool correct) async {
    if (_userId == null) {
      state = state.copyWith(errorMessage: "User not logged in.");
      return;
    }
    final currentCard = state.currentCard; // これは FirebaseCardModel
    if (currentCard == null) {
      return;
    }

    _sessionResults[currentCard.id] = correct;

    // 1. まずUIの状態を更新して次のカードへ（表面で表示されるようにする）
    _goToNextCard();

    // 2. その後、バックグラウンドでDB更新処理を行う
    try {
      final newStrength = srs.updateStrength(currentCard.strength, correct);
      final nextReviewDate = srs.calcNextReview(DateTime.now(), newStrength);
      final lastReviewedDate = DateTime.now();

      final updatedFirebaseCard = currentCard.copyWith(
        strength: newStrength,
        nextReview: nextReviewDate,
        lastReviewedAt: lastReviewedDate,
      );

      // updateUserCard と _updateStats を非同期で実行し、エラーをキャッチ
      _firebaseRepository
          .updateUserCard(_userId, updatedFirebaseCard)
          .catchError((e) {
            debugPrint("Error updating card in background: $e");
            // 必要に応じてユーザーにエラーを通知する state 更新
            // state = state.copyWith(errorMessage: "カードの更新に失敗しました: $e");
          });

      _updateStats(correct).catchError((e) {
        debugPrint("Error updating stats in background: $e");
        // 必要に応じてユーザーにエラーを通知する state 更新
        // state = state.copyWith(errorMessage: "統計情報の更新に失敗しました: $e");
      });
    } catch (e) {
      // _goToNextCard より前の同期処理でエラーが発生した場合の処理
      // (現状のコードでは _goToNextCard の前に同期的なエラーを発生させる処理は少ないが念のため)
      state = state.copyWith(errorMessage: "カード処理中にエラーが発生しました: $e");
    }
  }

  void _goToNextCard() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex < state.dueCards.length) {
      String? nextVideoThumbnailUrl;
      final nextCardVideoId = state.dueCards[nextIndex].videoId;
      // 非同期処理になるため、サムネイルはカード表示時に取得するか、
      // _loadDueCardsで全カードの動画情報を事前に取得しておくなどの工夫が必要。
      // ここでは一旦、現在のものを引き継ぐかnullにする。
      // 簡単のため、ここでは currentVideoThumbnailUrl は更新しない。
      // 必要であれば、_firebaseRepository.getSharedVideo(nextCardVideoId) を呼び出す。
      // state = state.copyWith(currentVideoThumbnailUrl: newThumbnailUrl); のように。

      state = state.copyWith(
        currentIndex: nextIndex,
        currentFace: CardFace.front,
      );
    } else {
      final result = SessionResult(
        reviewedCards: List<FirebaseCardModel>.from(
          _reviewedCardsInOrder,
        ), // 直接リストを渡す
        results: Map.unmodifiable(_sessionResults),
      );
      state = state.copyWith(
        currentIndex: 0,
        isLoading: false,
        isSessionComplete: true,
        sessionResult: result,
        errorMessage: null,
        clearError: true,
      );
    }
  }

  Future<void> _updateStats(bool correct) async {
    if (_userId == null) return;
    try {
      final today = DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd').format(today);
      FirebaseDailyStatModel? currentStat = await _firebaseRepository
          .getUserDailyStat(_userId, dateString);

      int newReviewedCount = (currentStat?.reviewedCount ?? 0) + 1;
      int newCorrectCount =
          (currentStat?.correctCount ?? 0) + (correct ? 1 : 0);

      final newStat = FirebaseDailyStatModel(
        dateString: dateString,
        reviewedCount: newReviewedCount,
        correctCount: newCorrectCount,
        learnedDate: DateTime(today.year, today.month, today.day),
      );
      await _firebaseRepository.updateUserDailyStat(
        _userId,
        dateString,
        newStat,
      );

      final userModel = await _firebaseRepository.getUser(_userId);
      if (userModel != null) {
        DateTime lastLearning = userModel.lastLearningDate ?? DateTime(1970);
        int currentStreak = userModel.currentStreak;
        int longestStreak = userModel.longestStreak;
        final todayDateOnly = DateTime(today.year, today.month, today.day);
        final lastLearningDateOnly = DateTime(
          lastLearning.year,
          lastLearning.month,
          lastLearning.day,
        );

        if (todayDateOnly.difference(lastLearningDateOnly).inDays == 1) {
          currentStreak++;
        } else if (todayDateOnly.isAfter(lastLearningDateOnly)) {
          currentStreak = 1;
        }
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
        await _firebaseRepository.updateUserStreaks(
          _userId,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          lastLearningDate: todayDateOnly,
        );
      }
    } catch (e) {
      debugPrint("Error updating stats to Firebase: $e");
    }
  }

  @override
  Future<void> speakCurrentCard() async {
    final card = state.currentCard;
    if (card == null) return;
    final tts = ref.read(flutterTtsProvider);
    final textToSpeak = card.front;
    const ttsLangCode = 'en-US';
    final cardId = card.id;

    // 再生回数を取得し、1増やす
    final playbackCount = (_ttsPlaybackCount[cardId] ?? 0) + 1;
    _ttsPlaybackCount[cardId] = playbackCount;

    // 再生速度を設定 (1回目: 0.5, 2回目以降: 0.25)
    final speechRate = playbackCount > 1 ? 0.25 : 0.5;

    try {
      await tts.setLanguage(ttsLangCode);
      await tts.setSpeechRate(speechRate); // 再生速度を設定
      await tts.speak(textToSpeak);
    } catch (e) {
      debugPrint("Error setting TTS language or speaking: $e");
      state = state.copyWith(errorMessage: "TTS Error: Could not speak text.");
    }
  }

  @override
  void refresh() {
    if (_userId != null) {
      _loadDueCards(_userId);
    }
  }

  @override
  Future<void> deleteCurrentCard() async {
    if (_userId == null) {
      state = state.copyWith(
        errorMessage: "User not logged in. Cannot delete card.",
      );
      return;
    }
    final cardToDelete = state.currentCard;
    if (cardToDelete == null) {
      state = state.copyWith(errorMessage: "削除対象のカードが見つかりません。");
      return;
    }

    final cardId = cardToDelete.id;
    final currentIdx = state.currentIndex;
    final currentDueCards = List<FirebaseCardModel>.from(state.dueCards);

    try {
      await _firebaseRepository.deleteUserCard(_userId, cardId);
      debugPrint("Card $cardId deleted from Firestore via FlashcardNotifier.");

      currentDueCards.removeWhere((card) => card.id == cardId);
      _reviewedCardsInOrder.removeWhere((card) => card.id == cardId);
      _sessionResults.remove(cardId);

      if (currentDueCards.isEmpty) {
        debugPrint("Session complete after deleting the last card.");
        final result = SessionResult(
          reviewedCards: _reviewedCardsInOrder, // 型をFirebaseCardModelに合わせる必要あり
          results: Map.unmodifiable(_sessionResults),
        );
        state = state.copyWith(
          dueCards: [],
          currentIndex: 0,
          isLoading: false,
          isSessionComplete: true,
          sessionResult: result,
          errorMessage: null,
          clearError: true,
        );
      } else {
        final nextIndex =
            (currentIdx >= currentDueCards.length)
                ? currentDueCards.length - 1
                : currentIdx;
        // サムネイル取得ロジックは _goToNextCard と同様の考慮が必要
        state = state.copyWith(
          dueCards: currentDueCards,
          currentIndex: nextIndex,
          currentFace: CardFace.front,
          errorMessage: null,
          clearError: true,
        );
      }
    } catch (e) {
      debugPrint("Error deleting current card $cardId: $e");
      state = state.copyWith(errorMessage: "カードの削除に失敗しました。");
    }
  }
}

final flashcardNotifierProvider =
    StateNotifierProvider<FlashcardNotifier, FlashcardState>((ref) {
      return FlashcardNotifier(ref);
    });
