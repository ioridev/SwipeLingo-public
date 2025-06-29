import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:y_player/y_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;

import 'package:swipelingo/services/caption_service.dart';
import 'package:swipelingo/services/video_playback_service.dart';
import 'package:swipelingo/services/translation_payment_service.dart';
import 'package:swipelingo/services/dictionary_service.dart';
import 'package:swipelingo/repositories/firebase_repository.dart';
import 'package:swipelingo/providers/repository_providers.dart';
import 'package:swipelingo/models/user_model.dart';

class VideoPlayerState {
  final YPlayerController? playerController;
  final List<yt_explode.ClosedCaption> displayCaptions;
  final String displayLanguageCode;
  final List<yt_explode.ClosedCaption> sourceEnglishCaptions;
  final bool
  needsTranslation; // displayCaptions を targetLanguageCode に翻訳する必要があるか

  final int currentCaptionIndex;
  final int currentNativeCaptionIndex; // ★ ネイティブ言語字幕の現在のインデックスを追加
  final String
  currentCaptionText; // targetLanguageCode に翻訳済みの表示用テキスト or displayCaptions の原文
  final bool isLoadingCaptions;
  final String?
  currentNativeLanguageCaptionText; // displayCaptionsの原文をユーザーのnativeLanguageCodeに翻訳したもの
  final bool isTranslatingTarget;
  final bool isTranslatingNative;
  final String? videoId;
  final bool isPlaying;
  final String videoTitle;
  final String? errorMessage;
  final String? currentCaptionTextForError;
  final bool areAllCaptionsTranslated; // targetLanguageCodeへの全翻訳が完了したか
  final bool isTranslatingAllCaptions; // targetLanguageCodeへの全翻訳中か (バックグラウンド)
  final bool showNativeLanguageCaption;
  final bool shouldShowPaywall;
  final bool hasPaidForTranslationInSession;
  final bool shouldShowGemConsumptionConfirmDialog;
  final String? tappedWord;
  final String? tappedWordMeaning;
  final bool showWordMeaningPopup;
  final String? currentChannelId;
  final bool isCurrentChannelFavorite;
  final String targetLanguageCode;
  final String nativeLanguageCode;
  final bool videoHasNativeLanguageTrack; // 動画にネイティブ言語の字幕トラックが存在したか
  final List<yt_explode.ClosedCaption>?
  nativeLanguageCaptionsDirect; // 存在した場合のネイティブ字幕データ
  final bool areControlsVisible; // 動画コントロールが表示されているか

  VideoPlayerState({
    this.playerController,
    this.displayCaptions = const [],
    this.displayLanguageCode = '',
    this.sourceEnglishCaptions = const [],
    this.needsTranslation = false,
    this.currentCaptionIndex = -1,
    this.currentNativeCaptionIndex = -1, // ★ 初期値を追加
    this.currentCaptionText = '',
    this.isLoadingCaptions = true,
    this.currentNativeLanguageCaptionText,
    this.isTranslatingTarget = false,
    this.isTranslatingNative = false,
    this.videoId,
    this.isPlaying = true,
    this.videoTitle = '',
    this.errorMessage,
    this.currentCaptionTextForError,
    this.areAllCaptionsTranslated = false,
    this.isTranslatingAllCaptions = false,
    this.showNativeLanguageCaption = false,
    this.shouldShowPaywall = false,
    this.hasPaidForTranslationInSession = false,
    this.shouldShowGemConsumptionConfirmDialog = false,
    this.tappedWord,
    this.tappedWordMeaning,
    this.showWordMeaningPopup = false,
    this.currentChannelId,
    this.isCurrentChannelFavorite = false,
    this.targetLanguageCode = 'en',
    this.nativeLanguageCode = 'en',
    this.videoHasNativeLanguageTrack = false,
    this.nativeLanguageCaptionsDirect,
    this.areControlsVisible = false, // デフォルト値をfalseに設定
  });

  VideoPlayerState copyWith({
    YPlayerController? playerController,
    List<yt_explode.ClosedCaption>? displayCaptions,
    String? displayLanguageCode,
    List<yt_explode.ClosedCaption>? sourceEnglishCaptions,
    bool? needsTranslation,
    int? currentCaptionIndex,
    int? currentNativeCaptionIndex, // ★ copyWith に追加
    String? currentCaptionText,
    bool? isLoadingCaptions,
    String? currentNativeLanguageCaptionText,
    bool? clearCurrentNativeLanguageCaptionText,
    bool? isTranslatingTarget,
    bool? isTranslatingNative,
    String? videoId,
    bool? isPlaying,
    String? videoTitle,
    String? errorMessage,
    String? currentCaptionTextForError,
    bool clearErrorMessage = false,
    bool? areAllCaptionsTranslated,
    bool? isTranslatingAllCaptions,
    bool? showNativeLanguageCaption,
    bool? shouldShowPaywall,
    bool? hasPaidForTranslationInSession,
    bool? shouldShowGemConsumptionConfirmDialog,
    String? tappedWord,
    String? tappedWordMeaning,
    bool? showWordMeaningPopup,
    String? currentChannelId,
    bool? isCurrentChannelFavorite,
    String? targetLanguageCode,
    String? nativeLanguageCode,
    bool? videoHasNativeLanguageTrack,
    List<yt_explode.ClosedCaption>? nativeLanguageCaptionsDirect,
    bool clearNativeLanguageCaptionsDirect = false,
    bool? areControlsVisible,
  }) {
    return VideoPlayerState(
      playerController: playerController ?? this.playerController,
      displayCaptions: displayCaptions ?? this.displayCaptions,
      displayLanguageCode: displayLanguageCode ?? this.displayLanguageCode,
      sourceEnglishCaptions:
          sourceEnglishCaptions ?? this.sourceEnglishCaptions,
      needsTranslation: needsTranslation ?? this.needsTranslation,
      currentCaptionIndex: currentCaptionIndex ?? this.currentCaptionIndex,
      currentNativeCaptionIndex:
          currentNativeCaptionIndex ??
          this.currentNativeCaptionIndex, // ★ copyWith に追加
      currentCaptionText: currentCaptionText ?? this.currentCaptionText,
      isLoadingCaptions: isLoadingCaptions ?? this.isLoadingCaptions,
      currentNativeLanguageCaptionText:
          clearCurrentNativeLanguageCaptionText == true
              ? null
              : currentNativeLanguageCaptionText ??
                  this.currentNativeLanguageCaptionText,
      isTranslatingTarget: isTranslatingTarget ?? this.isTranslatingTarget,
      isTranslatingNative: isTranslatingNative ?? this.isTranslatingNative,
      videoId: videoId ?? this.videoId,
      isPlaying: isPlaying ?? this.isPlaying,
      videoTitle: videoTitle ?? this.videoTitle,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      currentCaptionTextForError:
          currentCaptionTextForError ?? this.currentCaptionTextForError,
      areAllCaptionsTranslated:
          areAllCaptionsTranslated ?? this.areAllCaptionsTranslated,
      isTranslatingAllCaptions:
          isTranslatingAllCaptions ?? this.isTranslatingAllCaptions,
      showNativeLanguageCaption:
          showNativeLanguageCaption ?? this.showNativeLanguageCaption,
      shouldShowPaywall: shouldShowPaywall ?? this.shouldShowPaywall,
      hasPaidForTranslationInSession:
          hasPaidForTranslationInSession ?? this.hasPaidForTranslationInSession,
      shouldShowGemConsumptionConfirmDialog:
          shouldShowGemConsumptionConfirmDialog ??
          this.shouldShowGemConsumptionConfirmDialog,
      tappedWord: tappedWord ?? this.tappedWord,
      tappedWordMeaning: tappedWordMeaning ?? this.tappedWordMeaning,
      showWordMeaningPopup: showWordMeaningPopup ?? this.showWordMeaningPopup,
      currentChannelId: currentChannelId ?? this.currentChannelId,
      isCurrentChannelFavorite:
          isCurrentChannelFavorite ?? this.isCurrentChannelFavorite,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      nativeLanguageCode: nativeLanguageCode ?? this.nativeLanguageCode,
      videoHasNativeLanguageTrack:
          videoHasNativeLanguageTrack ?? this.videoHasNativeLanguageTrack,
      nativeLanguageCaptionsDirect:
          clearNativeLanguageCaptionsDirect
              ? null
              : nativeLanguageCaptionsDirect ??
                  this.nativeLanguageCaptionsDirect,
      areControlsVisible: areControlsVisible ?? this.areControlsVisible,
    );
  }
}

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  final String _initialVideoUrl;
  final Ref _ref;
  final yt_explode.YoutubeExplode _ytExplode = yt_explode.YoutubeExplode();

  late final CaptionService _captionService;
  late final VideoPlaybackService _videoPlaybackService;
  late final TranslationPaymentService _translationPaymentService;
  late final DictionaryService _dictionaryService;
  late final FirebaseRepository _firebaseRepository;
  UserModel? _currentUser;
  bool _watchHistoryAdded = false; //視聴履歴が記録されたかどうかのフラグ

  Timer? _captionTimer;

  VideoPlayerNotifier(this._initialVideoUrl, this._ref)
    : super(VideoPlayerState()) {
    _captionService = _ref.read(captionServiceProvider(_ytExplode));
    _videoPlaybackService = VideoPlaybackService(_ytExplode);
    _translationPaymentService = _ref.read(translationPaymentServiceProvider);
    _dictionaryService = _ref.read(dictionaryServiceProvider);
    _firebaseRepository = _ref.read(firebaseRepositoryProvider);

    _initialize();
  }

  Future<void> _initialize() async {
    _watchHistoryAdded = false;
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier._initialize: Start. Initial URL: $_initialVideoUrl',
    );
    try {
      await _dictionaryService.initialize();
      final initialShowNative =
          await _translationPaymentService
              .getInitialShowTranslatedCaptionSetting();

      final userId = _firebaseRepository.getCurrentUserId();
      if (userId != null) {
        _currentUser = await _firebaseRepository.getUser(userId);
      }
      final targetLang = _currentUser?.targetLanguageCode ?? 'en';
      final nativeLang = _currentUser?.nativeLanguageCode ?? 'en';
      state = state.copyWith(
        targetLanguageCode: targetLang,
        nativeLanguageCode: nativeLang,
        showNativeLanguageCaption: initialShowNative,
      );
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier._initialize: User and language settings loaded. Target: $targetLang, Native: $nativeLang, ShowNative: $initialShowNative',
      );

      String? videoId;
      String? channelId;
      try {
        final videoObject = await _ytExplode.videos.get(_initialVideoUrl);
        videoId = videoObject.id.value;
        channelId = videoObject.channelId.value;
        debugPrint(
          '[${DateTime.now()}] VideoPlayerNotifier._initialize: Video ID and Channel ID fetched. VideoID: $videoId, ChannelID: $channelId',
        );
      } catch (e) {
        debugPrint(
          '[${DateTime.now()}] VideoPlayerNotifier._initialize: Error fetching video/channel ID for URL: $_initialVideoUrl. Error: $e',
        );
        state = state.copyWith(
          isLoadingCaptions: false,
          errorMessage: '無効なYouTube URLです。詳細: $e',
        );
        return;
      }

      bool isFavorite = false;
      if (userId != null && _currentUser != null) {
        isFavorite = _currentUser!.favoriteChannelIds.contains(channelId);
      }

      state = state.copyWith(
        videoId: videoId,
        currentChannelId: channelId,
        isLoadingCaptions: true,
        hasPaidForTranslationInSession:
            _translationPaymentService.hasPaidForTranslationInSession,
        isCurrentChannelFavorite: isFavorite,
      );
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier._initialize: State updated with videoId: $videoId. isLoadingCaptions: ${state.isLoadingCaptions}',
      );
    } catch (e) {
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier._initialize: General error during initialization. Error: $e',
      );
      state = state.copyWith(
        isLoadingCaptions: false,
        errorMessage: '初期化中にエラーが発生しました: $e',
      );
    }
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier._initialize: End. isLoadingCaptions: ${state.isLoadingCaptions}, errorMessage: ${state.errorMessage}',
    );
  }

  void setPlayerController(YPlayerController controller) {
    final oldController = state.playerController;
    final bool hadListener =
        oldController?.statusNotifier.hasListeners ?? false;
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier.setPlayerController: Called. New Controller: $controller, Old Controller: $oldController, Old controller had listener: $hadListener, Video ID: ${state.videoId}',
    );

    oldController?.statusNotifier.removeListener(_handlePlayerStatusChange);
    final bool listenerRemoved =
        oldController == null || !oldController.statusNotifier.hasListeners;
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier.setPlayerController: Listener removed from old controller (if existed). Listener removed successfully: $listenerRemoved',
    );

    state = state.copyWith(playerController: controller);
    controller.statusNotifier.addListener(_handlePlayerStatusChange);
    final bool listenerAdded = controller.statusNotifier.hasListeners;
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier.setPlayerController: Listener added to new controller. Listener added successfully: $listenerAdded. Current isPlaying state: ${state.isPlaying}',
    );

    _handlePlayerStatusChange(); // 初期状態を反映

    if (state.isPlaying) {
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier.setPlayerController: Attempting to play video as isPlaying is true.',
      );
      // controller.play(); // Modified to add delay
      Future.delayed(const Duration(seconds: 3), () {
        // mounted check is not applicable for StateNotifier, using controller status check instead.
        // Also, use state.playerController as 'controller' might be out of scope or changed.
        if (mounted &&
            state.playerController != null &&
            state.playerController!.isInitialized &&
            state.playerController!.status != YPlayerStatus.playing) {
          state.playerController!.play();
          debugPrint(
            "[Delayed Play] Video ID: ${state.videoId} - Play initiated after delay in setPlayerController.",
          );
        }
      });
    }

    if (state.videoId != null &&
        state.displayCaptions.isEmpty &&
        state.isLoadingCaptions) {
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier.setPlayerController: Conditions met to load video details and captions for videoId: ${state.videoId}. DisplayCaptions empty: ${state.displayCaptions.isEmpty}, isLoadingCaptions: ${state.isLoadingCaptions}',
      );
      // 字幕読み込み処理は非同期で実行
      _loadVideoDetailsAndCaptions(state.videoId!);
    } else {
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier.setPlayerController: Conditions NOT met to load video details. VideoId: ${state.videoId}, DisplayCaptions empty: ${state.displayCaptions.isEmpty}, isLoadingCaptions: ${state.isLoadingCaptions}',
      );
    }
    _startCaptionListener();
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier.setPlayerController: Caption listener started.',
    );
  }

  void _handlePlayerStatusChange() {
    if (state.playerController != null) {
      final currentStatus = state.playerController!.status;
      final isCurrentlyPlaying = currentStatus == YPlayerStatus.playing;
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier._handlePlayerStatusChange: Called. Current player status: $currentStatus, isCurrentlyPlaying: $isCurrentlyPlaying, state.isPlaying: ${state.isPlaying}, Video ID: ${state.videoId}',
      );
      if (state.isPlaying != isCurrentlyPlaying) {
        // state = state.copyWith(isPlaying: isCurrentlyPlaying);
        // isPlaying の状態は playPause() で明示的に管理するため、ここでは直接変更しない方針の可能性あり。
        // ログで状態の変化を追跡する。
        debugPrint(
          '[${DateTime.now()}] VideoPlayerNotifier._handlePlayerStatusChange: Player playing status ($isCurrentlyPlaying) differs from state.isPlaying (${state.isPlaying}). Not updating state.isPlaying here.',
        );
      }

      // 視聴履歴の追加
      if (isCurrentlyPlaying &&
          !_watchHistoryAdded &&
          state.videoId != null &&
          state.currentChannelId != null) {
        final userId = _firebaseRepository.getCurrentUserId();
        if (userId != null) {
          try {
            _firebaseRepository.addWatchHistory(
              userId,
              state.currentChannelId!,
              state.videoId!,
            );
            _watchHistoryAdded = true;
            debugPrint(
              '[${DateTime.now()}] VideoPlayerNotifier._handlePlayerStatusChange: Watch history added for video ${state.videoId}, channel ${state.currentChannelId}, user $userId',
            );
          } catch (e) {
            debugPrint(
              '[${DateTime.now()}] VideoPlayerNotifier._handlePlayerStatusChange: Error adding watch history: $e',
            );
          }
        }
      }
    } else {
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier._handlePlayerStatusChange: Called but playerController is null. Video ID: ${state.videoId}',
      );
    }
  }

  Future<void> _loadVideoDetailsAndCaptions(String videoId) async {
    _watchHistoryAdded = false;
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier._loadVideoDetailsAndCaptions: Start. Video ID: $videoId, TargetLang: ${state.targetLanguageCode}, NativeLang: ${state.nativeLanguageCode}, isLoadingCaptions: ${state.isLoadingCaptions}',
    );
    state = state.copyWith(isLoadingCaptions: true); // 明示的にローディング開始
    try {
      final title = await _videoPlaybackService.getVideoTitle(videoId);
      state = state.copyWith(videoTitle: title);
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier._loadVideoDetailsAndCaptions: Video title fetched: $title',
      );

      final captionData = await _captionService.loadCaptions(
        videoId,
        state.targetLanguageCode,
        state.nativeLanguageCode,
      );
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier._loadVideoDetailsAndCaptions: Captions loaded. DisplayLang: ${captionData['displayLanguageCode']}, NeedsTranslation: ${captionData['needsTranslation']}, NativeTrackExists: ${captionData['nativeLanguageTrackExists']}, Error: ${captionData['errorMessage']}',
      );

      state = state.copyWith(
        displayCaptions: captionData['displayCaptions'],
        displayLanguageCode: captionData['displayLanguageCode'],
        sourceEnglishCaptions: captionData['sourceEnglishCaptions'],
        needsTranslation: captionData['needsTranslation'],
        videoHasNativeLanguageTrack: captionData['nativeLanguageTrackExists'],
        nativeLanguageCaptionsDirect:
            captionData['nativeLanguageCaptionsIfAvailable'],
        isLoadingCaptions: false, // ローディング完了
        errorMessage: captionData['errorMessage'],
        currentCaptionTextForError: captionData['currentCaptionTextForError'],
        currentCaptionText:
            captionData['errorMessage'] != null ||
                    captionData['currentCaptionTextForError'] != null
                ? (captionData['currentCaptionTextForError'] ?? '')
                : '',
      );

      if (state.needsTranslation) {
        debugPrint(
          '[${DateTime.now()}] VideoPlayerNotifier._loadVideoDetailsAndCaptions: Needs translation for target language. Starting background translation.',
        );
        _translateAllCaptionsInBackgroundIfNeeded(isForTargetLanguage: true);
      }
      if (state.showNativeLanguageCaption &&
          !state.videoHasNativeLanguageTrack &&
          state.displayLanguageCode != state.nativeLanguageCode) {
        debugPrint(
          '[${DateTime.now()}] VideoPlayerNotifier._loadVideoDetailsAndCaptions: Needs translation for native language. Starting background translation.',
        );
        _translateAllCaptionsInBackgroundIfNeeded(isForTargetLanguage: false);
      }
    } catch (e, s) {
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier._loadVideoDetailsAndCaptions: Error loading video details or captions. Video ID: $videoId, Error: $e, Stack: $s',
      );
      state = state.copyWith(
        isLoadingCaptions: false,
        errorMessage: '動画情報の読み込みに失敗しました: $e',
      );
    }
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier._loadVideoDetailsAndCaptions: End. Video ID: $videoId, isLoadingCaptions: ${state.isLoadingCaptions}, errorMessage: ${state.errorMessage}',
    );
  }

  Future<void> retryLoadCaptions() async {
    _watchHistoryAdded = false;
    if (state.videoId != null) {
      _captionService.clearCache();
      state = state.copyWith(
        isLoadingCaptions: true,
        errorMessage: null,
        clearErrorMessage: true,
        currentCaptionText: '',
        currentCaptionTextForError: null,
        displayCaptions: [],
        displayLanguageCode: '',
        sourceEnglishCaptions: [],
        needsTranslation: false,
        areAllCaptionsTranslated: false,
        isTranslatingAllCaptions: false,
        currentNativeLanguageCaptionText: null,
        clearCurrentNativeLanguageCaptionText: true,
        isTranslatingTarget: false,
        isTranslatingNative: false,
        videoHasNativeLanguageTrack: false,
        nativeLanguageCaptionsDirect: null,
        clearNativeLanguageCaptionsDirect: true,
      );
      await _loadVideoDetailsAndCaptions(state.videoId!);
    }
  }

  Future<void> _translateAllCaptionsInBackgroundIfNeeded({
    required bool isForTargetLanguage,
  }) async {
    final String langToTranslateTo =
        isForTargetLanguage
            ? state.targetLanguageCode
            : state.nativeLanguageCode;
    final bool translationIsNeededForThisCall;
    List<yt_explode.ClosedCaption> captionsToTranslateSource;

    if (isForTargetLanguage) {
      translationIsNeededForThisCall =
          state.needsTranslation; // displayCaptions を targetLanguageCode に
      captionsToTranslateSource =
          state.displayCaptions; // displayCaptions を targetLanguageCode に
    } else {
      // For native language
      // ネイティブ言語への翻訳が必要なのは、動画にネイティブトラックがなく、表示言語がネイティブ言語と異なる場合
      translationIsNeededForThisCall =
          !state.videoHasNativeLanguageTrack &&
          state.displayLanguageCode != state.nativeLanguageCode;
      // 翻訳元は、ターゲット言語表示に使っている displayCaptions (これが英語の場合が多い)
      captionsToTranslateSource = state.displayCaptions;
    }

    if (!translationIsNeededForThisCall || captionsToTranslateSource.isEmpty) {
      if (isForTargetLanguage) {
        state = state.copyWith(
          isTranslatingAllCaptions: false,
          areAllCaptionsTranslated: true,
        );
      }
      return;
    }

    if (_captionService.isTranslatingAllCaptions(langToTranslateTo) ||
        _captionService.areAllCaptionsTranslated(langToTranslateTo)) {
      if (isForTargetLanguage) {
        state = state.copyWith(
          isTranslatingAllCaptions: _captionService.isTranslatingAllCaptions(
            langToTranslateTo,
          ),
          areAllCaptionsTranslated: _captionService.areAllCaptionsTranslated(
            langToTranslateTo,
          ),
        );
      }
      return;
    }
    if (isForTargetLanguage) {
      state = state.copyWith(
        isTranslatingAllCaptions: true,
        areAllCaptionsTranslated: false,
      );
    } else {
      // ネイティブ言語の isTranslatingAll は state に持たないのでUI更新は onUpdate で行う
    }

    final sourceLangForThisTranslation =
        state.displayLanguageCode; // displayCaptions の言語

    await _captionService.translateAllCaptionsInBackground(
      captionsToTranslateSource,
      sourceLangForThisTranslation,
      langToTranslateTo,
      true, // 常に翻訳を実行（内部で翻訳を取得）
      (isTranslating, areAllTranslated, updatedCache) {
        if (isForTargetLanguage) {
          state = state.copyWith(
            isTranslatingAllCaptions: isTranslating,
            areAllCaptionsTranslated: areAllTranslated,
          );
          if (areAllTranslated && state.currentCaptionIndex != -1) {
            _updateCurrentTargetLanguageCaptionText();
          }
        } else {
          // For native language
          if (areAllTranslated &&
              state.currentCaptionIndex != -1 &&
              state.showNativeLanguageCaption) {
            _updateCurrentNativeLanguageCaptionText();
          }
        }
      },
    );
  }

  void _startCaptionListener() {
    _captionTimer?.cancel();
    _captionTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _captionListener();
    });
  }

  void _captionListener() {
    if (state.playerController == null ||
        !state.playerController!.isInitialized) {
      return;
    }

    final currentPlayerPosition = state.playerController!.position;

    // ターゲット言語字幕の処理
    if (state.displayCaptions.isNotEmpty) {
      int newTargetCaptionIndex = -1;
      for (int i = 0; i < state.displayCaptions.length; i++) {
        final caption = state.displayCaptions[i];
        if (currentPlayerPosition >= caption.offset &&
            currentPlayerPosition <= caption.offset + caption.duration) {
          newTargetCaptionIndex = i;
          break;
        }
      }

      if (newTargetCaptionIndex != -1 &&
          state.currentCaptionIndex != newTargetCaptionIndex) {
        final originalTextOfCurrentDisplayCaption =
            state.displayCaptions[newTargetCaptionIndex].text;
        _updateCurrentTargetLanguageCaptionText(
          newOriginalText: originalTextOfCurrentDisplayCaption,
        );
        state = state.copyWith(currentCaptionIndex: newTargetCaptionIndex);

        // ターゲット字幕が更新されたら、翻訳が必要なネイティブ字幕も更新を試みる
        if (state.showNativeLanguageCaption &&
            !state.videoHasNativeLanguageTrack) {
          _updateCurrentNativeLanguageCaptionText(
            newOriginalText: originalTextOfCurrentDisplayCaption,
          );
        }
      } else if (newTargetCaptionIndex == -1 &&
          state.currentCaptionIndex != -1) {
        // 字幕がなくなった場合 (ターゲット)
        state = state.copyWith(
          currentCaptionIndex: -1,
          currentCaptionText: '',
          isTranslatingTarget: false,
        );
        // ターゲット字幕がなくなったら、翻訳ベースのネイティブ字幕もクリア
        if (state.showNativeLanguageCaption &&
            !state.videoHasNativeLanguageTrack) {
          state = state.copyWith(
            currentNativeLanguageCaptionText: null,
            clearCurrentNativeLanguageCaptionText: true,
            isTranslatingNative: false,
          );
        }
      }
    } else {
      // displayCaptions が空の場合、ターゲット関連の字幕情報をクリア
      if (state.currentCaptionIndex != -1 ||
          state.currentCaptionText.isNotEmpty) {
        state = state.copyWith(
          currentCaptionIndex: -1,
          currentCaptionText: '',
          isTranslatingTarget: false,
        );
      }
    }

    // ネイティブ言語字幕の処理 (動画にネイティブトラックがある場合)
    if (state.showNativeLanguageCaption &&
        state.videoHasNativeLanguageTrack &&
        state.nativeLanguageCaptionsDirect != null &&
        state.nativeLanguageCaptionsDirect!.isNotEmpty) {
      int newNativeCaptionIndex = -1;
      for (int i = 0; i < state.nativeLanguageCaptionsDirect!.length; i++) {
        final caption = state.nativeLanguageCaptionsDirect![i];
        if (currentPlayerPosition >= caption.offset &&
            currentPlayerPosition <= caption.offset + caption.duration) {
          newNativeCaptionIndex = i;
          break;
        }
      }

      if (newNativeCaptionIndex != -1 &&
          state.currentNativeCaptionIndex != newNativeCaptionIndex) {
        state = state.copyWith(
          currentNativeCaptionIndex: newNativeCaptionIndex,
        );
        // newOriginalText は渡さず、内部で currentNativeCaptionIndex を使うようにする
        _updateCurrentNativeLanguageCaptionText();
      } else if (newNativeCaptionIndex == -1 &&
          state.currentNativeCaptionIndex != -1) {
        // 字幕がなくなった場合 (ネイティブトラック)
        state = state.copyWith(
          currentNativeCaptionIndex: -1,
          currentNativeLanguageCaptionText: null,
          clearCurrentNativeLanguageCaptionText: true,
          isTranslatingNative: false,
        );
      }
    } else if (state.showNativeLanguageCaption &&
        state.videoHasNativeLanguageTrack &&
        (state.nativeLanguageCaptionsDirect == null ||
            state.nativeLanguageCaptionsDirect!.isEmpty)) {
      // ネイティブトラックがあるはずなのにデータがない場合、ネイティブ字幕情報をクリア
      if (state.currentNativeCaptionIndex != -1 ||
          state.currentNativeLanguageCaptionText != null) {
        state = state.copyWith(
          currentNativeCaptionIndex: -1,
          currentNativeLanguageCaptionText: null,
          clearCurrentNativeLanguageCaptionText: true,
          isTranslatingNative: false,
        );
      }
    }

    // 両方の字幕がなくなった場合の最終クリア処理
    if (state.currentCaptionIndex == -1 &&
        state.currentNativeCaptionIndex == -1 &&
        (state.currentCaptionText.isNotEmpty ||
            state.currentNativeLanguageCaptionText != null)) {
      state = state.copyWith(
        currentCaptionText: '',
        currentNativeLanguageCaptionText: null,
        clearCurrentNativeLanguageCaptionText: true,
        isTranslatingTarget: false,
        isTranslatingNative: false,
      );
    }
  }

  void _updateCurrentTargetLanguageCaptionText({
    String? newOriginalText,
  }) async {
    final textToProcess =
        newOriginalText ??
        (state.currentCaptionIndex != -1 &&
                state.currentCaptionIndex < state.displayCaptions.length
            ? state.displayCaptions[state.currentCaptionIndex].text
            : '');
    if (textToProcess.isEmpty) {
      state = state.copyWith(
        currentCaptionText: '',
        isTranslatingTarget: false,
      );
      return;
    }

    if (state.needsTranslation) {
      state = state.copyWith(isTranslatingTarget: true);
      final translated = await _captionService.translateCurrentCaptionFallback(
        textToProcess,
        state.displayLanguageCode,
        state.targetLanguageCode,
        true,
        textToProcess,
      );
      if (mounted &&
          (newOriginalText == null ||
              (state.currentCaptionIndex != -1 &&
                  state.currentCaptionIndex < state.displayCaptions.length &&
                  state.displayCaptions[state.currentCaptionIndex].text ==
                      textToProcess))) {
        state = state.copyWith(
          currentCaptionText: translated,
          isTranslatingTarget: false,
        );
      } else if (mounted) {
        state = state.copyWith(isTranslatingTarget: false);
      }
    } else {
      state = state.copyWith(
        currentCaptionText: textToProcess,
        isTranslatingTarget: false,
      );
    }
  }

  void _updateCurrentNativeLanguageCaptionText({
    String? newOriginalText,
  }) async {
    if (!state.showNativeLanguageCaption) {
      state = state.copyWith(
        currentNativeLanguageCaptionText: null,
        clearCurrentNativeLanguageCaptionText: true,
        isTranslatingNative: false,
      );
      return;
    }

    // 動画にネイティブ字幕がある場合はそれを使う (currentNativeCaptionIndex を参照)
    if (state.videoHasNativeLanguageTrack &&
        state.nativeLanguageCaptionsDirect != null &&
        state.currentNativeCaptionIndex != -1 &&
        state.currentNativeCaptionIndex <
            state.nativeLanguageCaptionsDirect!.length) {
      state = state.copyWith(
        currentNativeLanguageCaptionText:
            state
                .nativeLanguageCaptionsDirect![state.currentNativeCaptionIndex]
                .text,
        isTranslatingNative: false,
      );
      return;
    }

    // 動画にネイティブ字幕トラックがない、またはインデックスが無効な場合は翻訳を試みる
    // 翻訳の原文はターゲット言語の現在の字幕 (newOriginalText があればそれ、なければ currentCaptionIndex から)
    final textToTranslate =
        newOriginalText ??
        (state.currentCaptionIndex != -1 &&
                state.currentCaptionIndex < state.displayCaptions.length
            ? state.displayCaptions[state.currentCaptionIndex].text
            : '');

    if (textToTranslate.isEmpty) {
      state = state.copyWith(
        currentNativeLanguageCaptionText: null,
        clearCurrentNativeLanguageCaptionText: true,
        isTranslatingNative: false,
      );
      return;
    }

    if (state.displayLanguageCode == state.nativeLanguageCode) {
      // 表示言語が既にネイティブ言語 (displayCaptions がネイティブ言語のはず)
      // このケースは videoHasNativeLanguageTrack が false の場合に到達する可能性がある
      state = state.copyWith(
        currentNativeLanguageCaptionText: textToTranslate,
        isTranslatingNative: false,
      );
    } else {
      // 表示言語とネイティブ言語が異なるので翻訳
      state = state.copyWith(isTranslatingNative: true);
      final translated = await _captionService.translateCurrentCaptionFallback(
        textToTranslate, // 翻訳対象のテキスト
        state.displayLanguageCode, // 翻訳元の言語 (displayCaptionsの言語)
        state.nativeLanguageCode, // 翻訳先の言語
        true, // 翻訳を実行するか
        textToTranslate, // 翻訳対象の原文 (キャッシュキーなどに使われる)
      );

      // 翻訳結果を適用する際、現在の原文が翻訳対象の原文と一致するか確認
      // (非同期処理中に字幕が切り替わっている可能性があるため)
      final currentOriginalForTarget =
          (state.currentCaptionIndex != -1 &&
                  state.currentCaptionIndex < state.displayCaptions.length)
              ? state.displayCaptions[state.currentCaptionIndex].text
              : '';

      if (mounted && textToTranslate == currentOriginalForTarget) {
        state = state.copyWith(
          currentNativeLanguageCaptionText: translated,
          isTranslatingNative: false,
        );
      } else if (mounted) {
        // 翻訳したが、既に表示すべき原文が変わっている場合は、翻訳中フラグだけ下げる
        state = state.copyWith(isTranslatingNative: false);
      }
    }
  }
  // ★ _updateCurrentNativeLanguageCaptionText メソッドの終了

  // ▼ ここから下のメソッド群は VideoPlayerNotifier クラスの直下に配置されるべき

  void seekToCaption(int index) {
    if (state.playerController != null &&
        index >= 0 &&
        index < state.displayCaptions.length) {
      state.playerController!.player.seek(state.displayCaptions[index].offset);
      if (index < state.displayCaptions.length) {
        final originalText = state.displayCaptions[index].text;
        _updateCurrentTargetLanguageCaptionText(newOriginalText: originalText);
        state = state.copyWith(currentCaptionIndex: index); // ターゲットのインデックスを更新

        if (state.showNativeLanguageCaption) {
          if (state.videoHasNativeLanguageTrack &&
              state.nativeLanguageCaptionsDirect != null &&
              state.nativeLanguageCaptionsDirect!.isNotEmpty) {
            // ネイティブトラックがある場合、対応するインデックスを探す
            // (ここでは単純にターゲットと同じインデックスを使うが、理想は時間ベースで再検索)
            // ただし、_captionListenerに任せる方がシンプルかもしれない。
            // 今回は、_updateCurrentNativeLanguageCaptionTextを引数なしで呼び、
            // 内部でcurrentNativeCaptionIndex（未更新の可能性あり）を使うか、
            // もしくは、ここで新しいネイティブインデックスを計算してstateにセットする。
            // より確実なのは、_captionListenerに任せることだが、即時性を考えるとここで処理する。
            // 簡単のため、ここではターゲットのインデックスをそのままネイティブにも適用しようと試みるが、
            // これは根本的な解決にはならない。
            // 正しくは、シーク後の再生時間からネイティブ字幕のインデックスを再計算すべき。
            // しかし、今回の修正範囲では _update を引数なしで呼ぶに留める。
            // _captionListener が次のフレームで正しいインデックスを見つけることを期待。
            // もしくは、ここで明示的にネイティブのインデックスも更新する。
            int newNativeIndex = -1;
            final seekPosition = state.displayCaptions[index].offset;
            for (
              int i = 0;
              i < state.nativeLanguageCaptionsDirect!.length;
              i++
            ) {
              final nativeCap = state.nativeLanguageCaptionsDirect![i];
              if (seekPosition >= nativeCap.offset &&
                  seekPosition <= nativeCap.offset + nativeCap.duration) {
                newNativeIndex = i;
                break;
              }
            }
            // もし厳密に時間で一致するものがなければ、一番近いものを探すなどのロジックも考えられるが、
            // ここでは一致がなければ更新しない、またはターゲットに追従する形とする。
            // 今回は、_updateCurrentNativeLanguageCaptionTextを引数なしで呼び、
            // _captionListenerが次の更新で正しいインデックスをcurrentNativeCaptionIndexにセットし、
            // それを_updateCurrentNativeLanguageCaptionTextが利用することを期待する。
            // そのため、ここでは _updateCurrentNativeLanguageCaptionText の呼び出し方を変更する。
            state = state.copyWith(
              currentNativeCaptionIndex:
                  newNativeIndex != -1
                      ? newNativeIndex
                      : state.currentNativeCaptionIndex,
            );
            _updateCurrentNativeLanguageCaptionText(); // 引数なしで呼び出し
          } else {
            // 翻訳の場合
            _updateCurrentNativeLanguageCaptionText(
              newOriginalText: originalText,
            );
          }
        }
      }
    }
  }

  void playPause() {
    if (state.playerController == null) return;
    final currentStatus = state.playerController!.status;
    if (currentStatus == YPlayerStatus.playing) {
      state.playerController!.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      state.playerController!.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  Future<void> toggleNativeLanguageCaption(bool show) async {
    if (!show) {
      state = state.copyWith(
        showNativeLanguageCaption: false,
        currentNativeLanguageCaptionText: null,
        clearCurrentNativeLanguageCaptionText: true,
        isTranslatingNative: false,
        shouldShowPaywall: false,
        shouldShowGemConsumptionConfirmDialog: false,
      );
      return;
    }

    if (state.displayCaptions.isEmpty) {
      if (state.showNativeLanguageCaption) {
        state = state.copyWith(
          showNativeLanguageCaption: false,
          currentNativeLanguageCaptionText: null,
          clearCurrentNativeLanguageCaptionText: true,
          isTranslatingNative: false,
        );
      }
      return;
    }

    // ネイティブ言語字幕を表示しようとしている
    // 動画自体にネイティブ言語の字幕トラックがあればGem消費なし
    if (state.videoHasNativeLanguageTrack) {
      state = state.copyWith(showNativeLanguageCaption: true);
      _updateCurrentNativeLanguageCaptionText(); // ネイティブ字幕データを表示
      // 必要ならバックグラウンドで全ネイティブ字幕を取得 (ただし nativeLanguageCaptionsDirect があれば不要)
      if (state.nativeLanguageCaptionsDirect == null ||
          state.nativeLanguageCaptionsDirect!.isEmpty) {
        _translateAllCaptionsInBackgroundIfNeeded(
          isForTargetLanguage: false,
        ); // これは実質、機械翻訳ではなくネイティブトラック取得になるべきだが、CaptionServiceの責務
      }
      return;
    }

    // 動画にネイティブ言語字幕がなく、機械翻訳が必要な場合
    final decision = await _translationPaymentService.decideTranslationAction(
      wantsToShowTranslatedCaption: true,
      hasNativeJapaneseSubtitles: false, // 動画にネイティブトラックがないので常にfalse
    );

    switch (decision) {
      case TranslationPaymentDecision.allow:
        state = state.copyWith(
          showNativeLanguageCaption: true,
          shouldShowPaywall: false,
          shouldShowGemConsumptionConfirmDialog: false,
          hasPaidForTranslationInSession:
              _translationPaymentService.hasPaidForTranslationInSession,
        );
        _updateCurrentNativeLanguageCaptionText();
        // 機械翻訳が必要なのでバックグラウンドで全翻訳
        _translateAllCaptionsInBackgroundIfNeeded(isForTargetLanguage: false);
        break;
      case TranslationPaymentDecision.showConfirmation:
        state = state.copyWith(
          shouldShowGemConsumptionConfirmDialog: true,
          shouldShowPaywall: false,
        );
        break;
      case TranslationPaymentDecision.showPaywall:
        state = state.copyWith(
          shouldShowPaywall: true,
          shouldShowGemConsumptionConfirmDialog: false,
        );
        break;
      case TranslationPaymentDecision.blocked:
        state = state.copyWith(
          showNativeLanguageCaption: false,
          currentNativeLanguageCaptionText: null,
          clearCurrentNativeLanguageCaptionText: true,
          isTranslatingNative: false,
          shouldShowPaywall: false,
          shouldShowGemConsumptionConfirmDialog: false,
        );
        break;
    }
  }

  void resetShouldShowPaywall() {
    state = state.copyWith(shouldShowPaywall: false);
  }

  void resetShowGemConsumptionConfirmDialog() {
    state = state.copyWith(shouldShowGemConsumptionConfirmDialog: false);
  }

  Future<void> confirmAndConsumeGemForTranslation() async {
    final success = await _translationPaymentService.consumeGemForTranslation();

    if (success) {
      state = state.copyWith(
        showNativeLanguageCaption: true,
        hasPaidForTranslationInSession:
            _translationPaymentService.hasPaidForTranslationInSession,
        shouldShowGemConsumptionConfirmDialog: false,
        shouldShowPaywall: false,
      );
      _updateCurrentNativeLanguageCaptionText();
      // Gem消費したので機械翻訳が必要なケースのはず
      if (!state.videoHasNativeLanguageTrack &&
          state.displayLanguageCode != state.nativeLanguageCode) {
        _translateAllCaptionsInBackgroundIfNeeded(isForTargetLanguage: false);
      }
    } else {
      state = state.copyWith(
        shouldShowPaywall: true,
        shouldShowGemConsumptionConfirmDialog: false,
      );
    }
  }

  void selectWord(String word) {
    final meaning = _dictionaryService.searchWord(word, targetLanguageCode: state.targetLanguageCode);
    state = state.copyWith(
      tappedWord: word,
      tappedWordMeaning: meaning ?? '意味が見つかりませんでした。',
      showWordMeaningPopup: true,
    );
  }

  void dismissWordMeaningPopup() {
    state = state.copyWith(
      showWordMeaningPopup: false,
      tappedWord: null,
      tappedWordMeaning: null,
    );
  }

  Future<void> toggleFavoriteChannel() async {
    if (state.currentChannelId == null) return;

    final firebaseRepository = _ref.read(firebaseRepositoryProvider);
    final userId = firebaseRepository.getCurrentUserId();

    if (userId == null) {
      // ユーザーがログインしていない場合などのエラーハンドリング
      state = state.copyWith(errorMessage: 'お気に入り機能を利用するにはログインが必要です。');
      return;
    }

    final newFavoriteState = !state.isCurrentChannelFavorite;
    try {
      await firebaseRepository.updateFavoriteChannel(
        userId,
        state.currentChannelId!,
        newFavoriteState,
      );
      state = state.copyWith(isCurrentChannelFavorite: newFavoriteState);
    } catch (e) {
      state = state.copyWith(errorMessage: 'お気に入り状態の更新に失敗しました: $e');
      // 元の状態に戻すか、エラーメッセージを表示したままにするか検討
    }
  }

  void toggleControlsVisibility() {
    state = state.copyWith(areControlsVisible: !state.areControlsVisible);
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier.toggleControlsVisibility: Toggled. New state: ${state.areControlsVisible}',
    );
  }


  Future<void> refreshCaptions() async {
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier.refreshCaptions: Start. Video ID: ${state.videoId}',
    );
    if (state.videoId == null) {
      debugPrint(
        '[${DateTime.now()}] VideoPlayerNotifier.refreshCaptions: Video ID is null. Cannot refresh.',
      );
      return;
    }

    // キャッシュをクリア
    _captionService.clearCache();

    // 状態をリセットして再読み込みを促す
    // isLoadingCaptions を true にし、既存の字幕関連情報をクリア
    state = state.copyWith(
      isLoadingCaptions: true,
      displayCaptions: [],
      sourceEnglishCaptions: [],
      needsTranslation: false,
      currentCaptionIndex: -1,
      currentCaptionText: '',
      currentNativeLanguageCaptionText: null,
      clearCurrentNativeLanguageCaptionText: true,
      areAllCaptionsTranslated: false,
      isTranslatingAllCaptions: false,
      videoHasNativeLanguageTrack: false,
      nativeLanguageCaptionsDirect: null,
      clearNativeLanguageCaptionsDirect: true,
      errorMessage: null, // エラーメッセージもクリア
      clearErrorMessage: true,
      currentCaptionTextForError: null,
    );
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier.refreshCaptions: State reset. isLoadingCaptions: ${state.isLoadingCaptions}',
    );

    // 字幕とビデオ詳細を再読み込み
    // _loadVideoDetailsAndCaptions は内部で isLoadingCaptions を false にする
    await _loadVideoDetailsAndCaptions(state.videoId!);
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier.refreshCaptions: End. isLoadingCaptions: ${state.isLoadingCaptions}, errorMessage: ${state.errorMessage}',
    );
  }

  @override
  void dispose() {
    _captionTimer?.cancel();
    state.playerController?.statusNotifier.removeListener(
      _handlePlayerStatusChange,
    );
    _videoPlaybackService.dispose();
    _captionService.clearCache();

    // Reset session payment status when the player is disposed
    _ref
        .read(translationPaymentServiceProvider)
        .resetPaidForTranslationInSession();

    _ytExplode.close();
    super.dispose();
    debugPrint(
      '[${DateTime.now()}] VideoPlayerNotifier.dispose: Disposed for videoId: ${state.videoId}',
    );
  }
}

final videoPlayerNotifierProvider = StateNotifierProvider.autoDispose
    .family<VideoPlayerNotifier, VideoPlayerState, String>((ref, videoUrl) {
      final notifier = VideoPlayerNotifier(videoUrl, ref);
      return notifier;
    });
