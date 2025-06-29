import 'dart:async'; // Completer のために追加
import 'package:flutter/foundation.dart'; // kDebugMode のために追加
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // RewardedAdService で利用
// import '../services/ad_manager.dart'; // RewardedAdService で利用
import '../services/rewarded_ad_service.dart'; // 新しいリワード広告サービス
import '../models/firebase_card_model.dart'; // Firebase用Cardモデルを直接使用
// import '../models/video.dart' as hive_video_models; // 不要になった
import '../models/shared_video_model.dart';
import '../services/youtube_service.dart';
import '../services/summary_service.dart';
import 'dart:convert';
import '../repositories/firebase_repository.dart';
import 'repository_providers.dart';
import '../models/user_model.dart'; // UserModel をインポート
import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    as yt_explode; // yt_explode をインポート

// --- Service Providers (他の場所で定義済みなら不要) ---
// final youtubeServiceProvider = Provider((ref) => YoutubeService());
// final summaryServiceProvider = Provider((ref) => SummaryService());

// --- State Notifiers ---

class MiningState {
  final String url;
  final bool isLoading;
  final double progress; // 0.0 〜 1.0
  final int generatedCardCount;
  final String? errorMessage;
  final List<FirebaseCardModel> generatedCards;

  // YouTube検索関連のState
  final bool isSearching;
  final String searchQuery;
  final List<SharedVideoModel> searchResults;
  final String? searchError;

  // 追加: 無限スクロール用の状態
  final String? nextPageToken;
  final bool isLoadingMore;
  final bool canLoadMore;
  final String? searchMoreError;

  static const String _debugDefaultUrl = '';
  // 'https://www.youtube.com/watch?v=W54Y0cn78NY';

  MiningState({
    this.url = kDebugMode ? _debugDefaultUrl : '',
    this.isLoading = false,
    this.progress = 0.0,
    this.generatedCardCount = 0,
    this.errorMessage,
    this.generatedCards = const [],
    this.isSearching = false,
    this.searchQuery = '',
    this.searchResults = const [],
    this.searchError,
    this.nextPageToken,
    this.isLoadingMore = false,
    this.canLoadMore = true, // 初期状態では読み込み可能と仮定
    this.searchMoreError,
  });

  MiningState copyWith({
    String? url,
    bool? isLoading,
    double? progress,
    int? generatedCardCount,
    String? errorMessage,
    bool clearError = false,
    List<FirebaseCardModel>? generatedCards,
    bool? isSearching,
    String? searchQuery,
    List<SharedVideoModel>? searchResults,
    String? searchError,
    bool clearSearchError = false,
    String? nextPageToken,
    bool? isLoadingMore,
    bool? canLoadMore,
    String? searchMoreError,
    bool clearSearchMoreError = false,
  }) {
    return MiningState(
      url: url ?? this.url,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      generatedCardCount: generatedCardCount ?? this.generatedCardCount,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      generatedCards: generatedCards ?? this.generatedCards,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      searchError: clearSearchError ? null : searchError ?? this.searchError,
      nextPageToken: nextPageToken ?? this.nextPageToken,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      searchMoreError:
          clearSearchMoreError ? null : searchMoreError ?? this.searchMoreError,
    );
  }
}

class MiningNotifier extends StateNotifier<MiningState> {
  final Ref _ref;
  final FirebaseRepository _firebaseRepository;

  MiningNotifier(this._ref)
    : _firebaseRepository = _ref.read(firebaseRepositoryProvider),
      super(MiningState());

  void setUrl(String url) {
    debugPrint(
      "[MiningNotifier setUrl] Received URL: $url. Current state.url: ${state.url}",
    );
    state = state.copyWith(url: url, clearError: true);
    debugPrint(
      "[MiningNotifier setUrl] State updated. New state.url: ${state.url}",
    );
  }

  Future<void> startMining(String urlToMine) async {
    debugPrint(
      "[MiningNotifier] startMining INVOKED with urlToMine: '$urlToMine'. Current state.url before processing: '${state.url}', isLoading: ${state.isLoading}",
    );

    if (urlToMine.isEmpty) {
      debugPrint("[MiningNotifier] startMining ABORTED: urlToMine is empty.");
      state = state.copyWith(
        isLoading: false,
        errorMessage: "動画URLが指定されていません。",
        progress: 0.0,
        generatedCardCount: 0,
        generatedCards: [],
      );
      return;
    }
    if (state.isLoading) {
      debugPrint("[MiningNotifier] startMining ABORTED: Already isLoading.");
      return;
    }

    // 処理を開始する直前に、Providerの持つURL状態も引数のURLで確定させる
    state = state.copyWith(
      url: urlToMine, // Providerのstate.urlも引数で更新
      isLoading: true,
      progress: 0.0,
      generatedCardCount: 0,
      errorMessage: null,
      generatedCards: [],
      clearError: true,
    );
    debugPrint(
      "[MiningNotifier] State SET for mining. New state.url: '${state.url}', isLoading: ${state.isLoading}",
    );

    try {
      final youtubeService = _ref.read(youtubeServiceProvider);
      final summaryService = _ref.read(summaryServiceProvider);

      state = state.copyWith(
        progress: 0.1,
        errorMessage: 'Fetching video info & English captions...',
      );
      debugPrint(
        "[MiningNotifier] Fetching video details using url: '$urlToMine'",
      ); // ログで確認
      final fetchedVideoDetails = await youtubeService
          .getVideoDetailsWithCaptions(urlToMine); // ★引数 urlToMine を使用

      // --- 動画情報を Firebase に保存 ---
      try {
        final uploaderUid = FirebaseAuth.instance.currentUser?.uid;
        // YoutubeServiceから返されたモデルを元に、必要ならuploaderUidを付加して保存
        final videoToSave = fetchedVideoDetails.copyWith(
          uploaderUid:
              fetchedVideoDetails.uploaderUid ?? uploaderUid, // 既に設定されていなければ設定
          updatedAt: DateTime.now(), // 保存/更新時は常にupdatedAtを更新
        );
        await _firebaseRepository.addOrUpdateSharedVideo(videoToSave);
        debugPrint("Video info saved to Firebase: ${videoToSave.id}");
      } catch (e) {
        debugPrint("!!! Error saving video info to Firebase: $e");
      }

      final captionsData = fetchedVideoDetails.captionsWithTimestamps['en'];
      if (captionsData == null || captionsData.isEmpty) {
        throw Exception('Could not get English captions data.');
      }

      // 共通メソッドを呼び出し
      final generatedCards = await _generateFlashcardsFromCaptionsCore(
        captionsData, // 取得した字幕データを渡す
        fetchedVideoDetails.id, // videoId を渡す
      );

      state = state.copyWith(
        isLoading: false,
        progress: 1.0,
        generatedCards: generatedCards,
        generatedCardCount: generatedCards.length,
        errorMessage: 'Processing complete!',
      );
    } catch (e) {
      debugPrint("!!! Mining process failed: $e");
      state = state.copyWith(
        isLoading: false,
        progress: 0.0,
        errorMessage:
            e.toString().startsWith('Exception: ')
                ? e.toString().substring('Exception: '.length)
                : e.toString(),
      );
    }
  }

  // --- 共通化されたフラッシュカード生成処理 ---
  Future<List<FirebaseCardModel>> _generateFlashcardsFromCaptionsCore(
    List<Map<String, dynamic>> captionsData,
    String videoId,
  ) async {
    final summaryService = _ref.read(summaryServiceProvider);
    final userDoc = _ref.watch(userDocumentProvider).value;
    final nativeLanguageCode =
        userDoc?.nativeLanguageCode ?? 'en'; // デフォルトは 'en'
    final targetLanguageCode =
        userDoc?.targetLanguageCode ?? 'ja'; // デフォルトは 'ja'

    state = state.copyWith(
      progress: 0.3,
      errorMessage:
          'Requesting card generation ($targetLanguageCode from $nativeLanguageCode) from LLM...',
    );
    final cardsJsonString = await summaryService.generateMultipleFlashcards(
      captionsData,
      videoId,
      nativeLanguageCode,
      targetLanguageCode,
    );

    debugPrint("--- LLM Response Raw ---");
    debugPrint(cardsJsonString);
    debugPrint("------------------------");

    state = state.copyWith(
      progress: 0.8,
      errorMessage: 'Processing generated cards...',
    );
    final List<FirebaseCardModel> generatedCards = [];
    try {
      debugPrint("Attempting to decode JSON...");
      final jsonResponse = jsonDecode(cardsJsonString);
      debugPrint("JSON decoded successfully.");

      if (jsonResponse is Map &&
          jsonResponse.containsKey('card') &&
          jsonResponse['card'] is List) {
        final cardsList = jsonResponse['card'] as List;
        for (final cardData in cardsList) {
          if (cardData is Map &&
              cardData.containsKey('id') &&
              cardData.containsKey('front') &&
              cardData.containsKey('back')) {
            final id = cardData['id'] as String;
            final front = cardData['front'] as String;
            final back = cardData['back'] as String;
            final start = (cardData['start'] as num?)?.toDouble();
            final end = (cardData['end'] as num?)?.toDouble();
            final note = cardData['note'] as String?;
            final difficulty = (cardData['difficulty'] as num?)?.toDouble();

            final newCard = FirebaseCardModel(
              id: id,
              videoId: videoId,
              front: front,
              back: back,
              sourceLanguage: targetLanguageCode, // LLMが生成する front の言語
              targetLanguage: nativeLanguageCode, // LLMが生成する back の言語
              createdAt: DateTime.now(),
              start: start,
              end: end,
              note: note,
              difficulty: difficulty,
            );
            generatedCards.add(newCard);
          } else {
            // 不正なカードデータはスキップまたはログ記録
            debugPrint("Skipping invalid card data: $cardData");
          }
        }
      } else {
        debugPrint("LLM returned unexpected data format: $jsonResponse");
        throw Exception('LLM returned unexpected data format.');
      }
    } catch (e, stackTrace) {
      debugPrint("!!! Error processing generated cards: $e");
      debugPrint(stackTrace.toString());
      throw Exception('Failed to process generated cards.');
    }

    if (generatedCards.isEmpty) {
      throw Exception(
        'LLM could not generate any flashcards from the transcript.',
      );
    }
    return generatedCards;
  }
  // --- ここまで共通化されたフラッシュカード生成処理 ---

  Future<void> generateFlashcardsFromCaptions(
    List<yt_explode.ClosedCaption> captions,
    String videoId,
    String videoTitle, // 動画タイトルを追加
  ) async {
    if (state.isLoading) {
      debugPrint(
        "[MiningNotifier generateFlashcardsFromCaptions] ABORTED: Already isLoading.",
      );
      return;
    }
    state = state.copyWith(
      isLoading: true,
      progress: 0.0,
      generatedCardCount: 0,
      errorMessage: "リワード広告を準備しています...", // 初期メッセージ
      generatedCards: [],
      clearError: true,
    );

    // リワード広告の表示処理 (RewardedAdService を使用)
    state = state.copyWith(errorMessage: 'リワード広告を処理しています...'); // メッセージ変更
    final rewardedAdNotifier = _ref.read(rewardedAdServiceProvider.notifier);
    await rewardedAdNotifier.showAd();

    // 広告表示試行後、実際のフラッシュカード生成処理へ
    state = state.copyWith(
      isLoading: true, // isLoading は継続
      progress: 0.0, // progress をリセット
      generatedCardCount: 0,
      errorMessage: null, // エラーメッセージをクリア
      generatedCards: [],
      clearError: true,
    );
    debugPrint(
      "[MiningNotifier generateFlashcardsFromCaptions] State SET for mining. videoId: '$videoId', isLoading: ${state.isLoading}",
    );

    try {
      state = state.copyWith(
        progress: 0.1,
        errorMessage: 'Preparing captions for LLM...',
      );

      final captionsWithTimestamps =
          captions.map((caption) {
            return {
              'text': caption.text,
              'start': caption.offset.inMilliseconds / 1000.0,
              'end':
                  (caption.offset + caption.duration).inMilliseconds / 1000.0,
            };
          }).toList();

      if (captionsWithTimestamps.isEmpty) {
        throw Exception('No captions data provided.');
      }

      // --- 動画情報を Firebase に保存 ---
      try {
        final uploaderUid = FirebaseAuth.instance.currentUser?.uid;
        final videoToSave = SharedVideoModel(
          id: videoId,
          url: 'https://www.youtube.com/watch?v=$videoId', // videoIdからURLを生成
          title: videoTitle,
          thumbnailUrl: '', // InAppVideoViewerからは取得できない
          channelName: '', // InAppVideoViewerからは取得できない
          captionsWithTimestamps: {'en': captionsWithTimestamps}, // 保存する字幕データ
          uploaderUid: uploaderUid,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firebaseRepository.addOrUpdateSharedVideo(videoToSave);
        debugPrint(
          "Video info (from captions) saved to Firebase: ${videoToSave.id}",
        );
      } catch (e) {
        debugPrint(
          "!!! Error saving video info (from captions) to Firebase: $e",
        );
        // ここでのエラーはフラッシュカード生成を妨げない
      }
      // --- ここまで動画情報保存処理 ---

      final generatedCards = await _generateFlashcardsFromCaptionsCore(
        captionsWithTimestamps,
        videoId,
      );

      state = state.copyWith(
        isLoading: false,
        progress: 1.0,
        generatedCards: generatedCards,
        generatedCardCount: generatedCards.length,
        errorMessage: 'Processing complete!',
      );
    } catch (e) {
      debugPrint("!!! Mining process from captions failed: $e");
      state = state.copyWith(
        isLoading: false,
        progress: 0.0,
        errorMessage:
            e.toString().startsWith('Exception: ')
                ? e.toString().substring('Exception: '.length)
                : e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, clearSearchError: true);
  }

  Future<void> searchVideos() async {
    print(
      'MiningNotifier: searchVideos START - Using state.searchQuery: "${state.searchQuery}"',
    );
    if (state.searchQuery.isEmpty) {
      state = state.copyWith(
        searchResults: [],
        searchError: 'Please enter a search term.',
      );
      return;
    }
    state = state.copyWith(
      isSearching: true,
      searchError: null,
      searchResults: [], // 初期検索時は結果をクリア
      clearSearchError: true,
      nextPageToken: null, // 初期検索時は nextPageToken もクリア
      canLoadMore: true, // 初期検索時は読み込み可能と仮定
      isLoadingMore: false,
      searchMoreError: null,
      clearSearchMoreError: true,
    );

    try {
      final youtubeService = _ref.read(youtubeServiceProvider);
      final userDoc = _ref.watch(userDocumentProvider).value;
      final targetLanguageCode =
          userDoc?.targetLanguageCode ?? 'en'; // デフォルトは 'en'

      // YoutubeService から VideoSearchResponse を受け取るように変更
      final response = await youtubeService.searchVideosWithCaptions(
        state.searchQuery,
        targetLanguageCode: targetLanguageCode,
        // pageToken: null, // 初回検索なので不要
      );
      state = state.copyWith(
        isSearching: false,
        searchResults: response.videos,
        nextPageToken: response.nextPageToken,
        canLoadMore:
            response.nextPageToken != null && response.videos.isNotEmpty,
        searchError:
            response.videos.isEmpty ? 'No videos found with captions.' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        searchError:
            e.toString().startsWith('Exception: ')
                ? e.toString().substring('Exception: '.length)
                : e.toString(),
        canLoadMore: false, // エラー時はこれ以上読み込めない
      );
    }
  }

  Future<void> searchMoreVideos() async {
    if (state.isLoadingMore ||
        !state.canLoadMore ||
        state.nextPageToken == null) {
      return; // すでに読み込み中、またはこれ以上読み込めない、またはトークンがない場合は何もしない
    }

    state = state.copyWith(
      isLoadingMore: true,
      searchMoreError: null,
      clearSearchMoreError: true,
    );

    try {
      final youtubeService = _ref.read(youtubeServiceProvider);
      final userDoc = _ref.watch(userDocumentProvider).value;
      final targetLanguageCode = userDoc?.targetLanguageCode ?? 'en';

      final response = await youtubeService.searchVideosWithCaptions(
        state.searchQuery, // 現在の検索クエリを使用
        targetLanguageCode: targetLanguageCode,
        pageToken: state.nextPageToken, // 次のページのトークンを使用
      );

      final newVideos = response.videos;
      final currentVideos = List<SharedVideoModel>.from(state.searchResults);
      currentVideos.addAll(newVideos); // 既存のリストに新しい結果を追加

      state = state.copyWith(
        isLoadingMore: false,
        searchResults: currentVideos,
        nextPageToken: response.nextPageToken,
        canLoadMore: response.nextPageToken != null && newVideos.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        searchMoreError:
            e.toString().startsWith('Exception: ')
                ? e.toString().substring('Exception: '.length)
                : e.toString(),
        // canLoadMore: false, // エラーが発生しても、次の試行の可能性を残すため canLoadMore は変更しない
      );
    }
  }
}

// --- Providers ---

final miningNotifierProvider =
    StateNotifierProvider<MiningNotifier, MiningState>((ref) {
      return MiningNotifier(ref);
    });

final youtubeServiceProvider = Provider((ref) => YoutubeService());
final summaryServiceProvider = Provider((ref) => SummaryService());

final availableLanguagesProvider = Provider<List<String>>((ref) {
  return ['en', 'ja', 'es', 'fr', 'de'];
});
