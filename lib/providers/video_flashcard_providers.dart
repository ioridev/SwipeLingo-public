import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/firebase_daily_stat_model.dart';
import 'package:intl/intl.dart';
import '../models/firebase_card_model.dart';
import '../models/shared_video_model.dart';
import '../models/session_result.dart';
import '../services/srs.dart' as srs;
import 'flashcard_providers.dart' show CardFace, flutterTtsProvider;
import '../repositories/firebase_repository.dart';
import 'repository_providers.dart';
import 'base_flashcard_provider.dart';
// import 'card_list_providers.dart'; // Not directly used by VideoFlashcardNotifier for deletion

// --- State Notifier ---

class VideoFlashcardState with BaseFlashcardState {
  final String videoId;
  @override
  final List<FirebaseCardModel> videoCards;

  @override
  final int currentIndex;
  @override
  final CardFace currentFace;
  @override
  final bool isLoading;
  @override
  final String? errorMessage;
  final String videoTitle;
  @override
  final bool isSessionComplete;
  @override
  final SessionResult? sessionResult;
  @override
  final String? currentVideoThumbnailUrl;

  @override
  List<FirebaseCardModel> get cards => videoCards;

  VideoFlashcardState({
    required this.videoId,
    this.videoCards = const [],
    this.currentIndex = 0,
    this.currentFace = CardFace.front,
    this.isLoading = true,
    this.errorMessage,
    this.videoTitle = '',
    this.isSessionComplete = false,
    this.sessionResult,
    this.currentVideoThumbnailUrl,
  });

  VideoFlashcardState copyWith({
    List<FirebaseCardModel>? videoCards,
    int? currentIndex,
    CardFace? currentFace,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? videoTitle,
    bool? isSessionComplete,
    SessionResult? sessionResult,
    String? currentVideoThumbnailUrl,
  }) {
    return VideoFlashcardState(
      videoId: videoId,
      videoCards: videoCards ?? this.videoCards,
      currentIndex: currentIndex ?? this.currentIndex,
      currentFace: currentFace ?? this.currentFace,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      videoTitle: videoTitle ?? this.videoTitle,
      isSessionComplete: isSessionComplete ?? this.isSessionComplete,
      sessionResult: sessionResult ?? this.sessionResult,
      currentVideoThumbnailUrl:
          currentVideoThumbnailUrl ?? this.currentVideoThumbnailUrl,
    );
  }
}

class VideoFlashcardNotifier
    extends BaseFlashcardNotifier<VideoFlashcardState> {
  final String _videoId;
  final FirebaseRepository _firebaseRepository;
  final String? _userId;

  final Map<String, bool> _sessionResults = {};
  List<FirebaseCardModel> _reviewedCardsInOrder = [];

  VideoFlashcardNotifier(Ref ref, this._videoId)
    : _firebaseRepository = ref.read(firebaseRepositoryProvider),
      _userId = FirebaseAuth.instance.currentUser?.uid,
      super(ref, VideoFlashcardState(videoId: _videoId)) {
    if (_userId != null) {
      _loadVideoCards(_userId);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "User not logged in.",
      );
    }
  }

  Future<void> _loadVideoCards(String userId) async {
    _sessionResults.clear();
    _reviewedCardsInOrder = [];
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearError: true,
      isSessionComplete: false,
      sessionResult: null,
    );
    try {
      final allUserCards =
          await _firebaseRepository.getUserCardsStream(userId).first;
      final videoCards =
          allUserCards.where((card) => card.videoId == _videoId).toList();
      videoCards.shuffle();

      final videoDoc = await _firebaseRepository.getSharedVideo(_videoId);
      final videoTitle = videoDoc?.title ?? 'Unknown Video';
      final firstVideoThumbnailUrl = videoDoc?.thumbnailUrl;

      _reviewedCardsInOrder = List.from(videoCards);

      state = state.copyWith(
        videoCards: videoCards,
        currentIndex: 0,
        currentFace: CardFace.front,
        isLoading: false,
        videoTitle: videoTitle,
        currentVideoThumbnailUrl: firstVideoThumbnailUrl,
      );
    } catch (e) {
      debugPrint("Error loading video cards for $_videoId: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to load cards for this video. $e",
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
    final currentCard = state.currentCard;
    if (currentCard == null) {
      return;
    }

    _sessionResults[currentCard.id] = correct;

    try {
      final newStrength = srs.updateStrength(currentCard.strength, correct);
      final nextReviewDate = srs.calcNextReview(DateTime.now(), newStrength);
      final lastReviewedDate = DateTime.now();

      final updatedFirebaseCard = currentCard.copyWith(
        strength: newStrength,
        nextReview: nextReviewDate,
        lastReviewedAt: lastReviewedDate,
      );

      await _firebaseRepository.updateUserCard(_userId, updatedFirebaseCard);
      _updateStats(correct); // await を削除
      _goToNextCard();
    } catch (e) {
      debugPrint("Error updating card after swipe (video): $e");
      state = state.copyWith(
        errorMessage: "Failed to update card review status. $e",
      );
    }
  }

  void _goToNextCard() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex < state.videoCards.length) {
      state = state.copyWith(
        currentIndex: nextIndex,
        currentFace: CardFace.front,
      );
    } else {
      final result = SessionResult(
        reviewedCards: List<FirebaseCardModel>.from(_reviewedCardsInOrder),
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
      debugPrint(
        "Error updating stats to Firebase (VideoFlashcardNotifier): $e",
      );
    }
  }

  @override
  Future<void> speakCurrentCard() async {
    final card = state.currentCard;
    if (card == null) return;
    final tts = ref.read(flutterTtsProvider);
    final textToSpeak = card.front;
    const ttsLangCode = 'en-US';
    try {
      await tts.setLanguage(ttsLangCode);
      await tts.speak(textToSpeak);
    } catch (e) {
      debugPrint("Error setting TTS language or speaking (video): $e");
      state = state.copyWith(errorMessage: "TTS Error: Could not speak text.");
    }
  }

  @override
  void refresh() {
    if (_userId != null) {
      _loadVideoCards(_userId);
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
    final currentVideoCards = List<FirebaseCardModel>.from(state.videoCards);

    try {
      await _firebaseRepository.deleteUserCard(_userId, cardId);
      debugPrint(
        "Card $cardId deleted from Firestore via VideoFlashcardNotifier.",
      );

      currentVideoCards.removeWhere((card) => card.id == cardId);
      _reviewedCardsInOrder.removeWhere((card) => card.id == cardId);
      _sessionResults.remove(cardId);

      if (currentVideoCards.isEmpty) {
        debugPrint("Session complete after deleting the last card (video).");
        final result = SessionResult(
          reviewedCards: _reviewedCardsInOrder,
          results: Map.unmodifiable(_sessionResults),
        );
        state = state.copyWith(
          videoCards: [],
          currentIndex: 0,
          isLoading: false,
          isSessionComplete: true,
          sessionResult: result,
          errorMessage: null,
          clearError: true,
        );
      } else {
        final nextIndex =
            (currentIdx >= currentVideoCards.length)
                ? currentVideoCards.length - 1
                : currentIdx;
        state = state.copyWith(
          videoCards: currentVideoCards,
          currentIndex: nextIndex,
          currentFace: CardFace.front,
          errorMessage: null,
          clearError: true,
        );
      }
    } catch (e) {
      debugPrint("Error deleting current card $cardId (video): $e");
      state = state.copyWith(errorMessage: "カードの削除に失敗しました。");
    }
  }
}

final videoFlashcardNotifierProvider = StateNotifierProvider.family<
  VideoFlashcardNotifier,
  VideoFlashcardState,
  String
>((ref, videoId) {
  return VideoFlashcardNotifier(ref, videoId);
});
