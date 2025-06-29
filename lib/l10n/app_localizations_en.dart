// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get getMore => 'Get';

  @override
  String get learningMenu => 'Learning Menu';

  @override
  String get startLearning => 'Start Learning';

  @override
  String dueCardsWaitingForReview(int count) {
    return '$count cards waiting for review';
  }

  @override
  String get noScheduledCardsRandomMode =>
      'No scheduled cards. Switching to random mode.';

  @override
  String get countRetrievalError => 'Error retrieving count';

  @override
  String get createCardsFromVideo => 'Create Cards from Video';

  @override
  String get learnNewWordsFromYouTube => 'Learn new words from YouTube';

  @override
  String get cardDeckList => 'Card Deck List';

  @override
  String get checkSavedVideoCards => 'Check saved video cards';

  @override
  String get learningStats => 'Learning Stats';

  @override
  String learningStreakDays(int count) {
    return '$count days learning streak';
  }

  @override
  String get activityLast105Days => 'Activity in the last 105 days';

  @override
  String get activityRetrievalError => 'Error retrieving activity';

  @override
  String totalCardsLearned(int count) {
    return 'Total cards learned: $count';
  }

  @override
  String get cardCountRetrievalError => 'Error retrieving card count';

  @override
  String get upgradeToSwipelingoPro => 'Upgrade to Swipelingo Pro';

  @override
  String get unlimitedGemsNoAdsAccessAllFeatures =>
      'Unlimited gems, no ads, access all features';

  @override
  String get review => 'Review';

  @override
  String couldNotLaunchUrl(String urlString) {
    return 'Could not launch URL: $urlString';
  }

  @override
  String get swipelingoPro => 'Swipelingo Pro';

  @override
  String get noOfferingsAvailable =>
      'No offerings currently available. Please check your store settings or try again later.';

  @override
  String noPackagesAvailableInOffering(String offeringIdentifier) {
    return 'No purchase plans currently available.\\n(Offering \"$offeringIdentifier\" did not include any plans)';
  }

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get unlimitedGems => 'Unlimited Gems';

  @override
  String get unlimitedTranslationSubtitles =>
      'No limit on displaying translated subtitles';

  @override
  String get adsFree => 'Ad-Free';

  @override
  String get concentrateOnLearning => 'Environment to concentrate on learning';

  @override
  String get unlimitedCardCreation => 'Unlimited Card Creation';

  @override
  String get learnAsMuchAsYouWantDaily => 'Learn as much as you want every day';

  @override
  String get premiumSupport => 'Premium Support';

  @override
  String get prioritySupport => 'Receive priority support';

  @override
  String get selectBestPlanForYou => 'Select the best plan for you';

  @override
  String get purchaseTermsDescription =>
      'Purchases will be charged to your Apple ID account. Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period. You can manage subscriptions and turn off auto-renewal in your account settings.\\n\\n';

  @override
  String get termsOfUseEULA => 'Terms of Use (EULA)';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get restoringPurchases => 'Restoring purchases...';

  @override
  String get purchasesRestored => 'Purchases restored.';

  @override
  String restorePurchasesFailed(String error) {
    return 'Failed to restore purchases: $error';
  }

  @override
  String get restorePurchasesButton => 'Restore Purchases';

  @override
  String get loadingPlans => 'Loading plans...';

  @override
  String get failedToLoadPlans => 'Failed to load plans.';

  @override
  String errorCode(String errorCode) {
    return 'Error Code: $errorCode';
  }

  @override
  String details(String details) {
    return 'Details: $details';
  }

  @override
  String get retry => 'Retry';

  @override
  String get weeklyPlan => 'Weekly Plan';

  @override
  String get daysFreeTrial => 'With 3-day free trial';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get annualPlan => 'Annual Plan';

  @override
  String discountFromMonthly(String discountPercentage) {
    return '$discountPercentage% off from monthly';
  }

  @override
  String get recommended => 'Recommended';

  @override
  String get perWeek => 'per week';

  @override
  String get perMonth => 'per month';

  @override
  String get startNow => 'Start Now';

  @override
  String get selectButton => 'Select';

  @override
  String get startingPurchaseProcess => 'Starting purchase process...';

  @override
  String get purchaseCompletedThankYou => 'Purchase completed! Thank you.';

  @override
  String get purchaseCompletedPlanNotActive =>
      'Purchase completed, but the plan did not activate. Please contact support.';

  @override
  String get purchaseCancelled => 'Purchase cancelled.';

  @override
  String get purchasePending =>
      'Purchase process is pending. Please wait for approval from the store.';

  @override
  String purchaseFailed(String errorMessage) {
    return 'Purchase failed: $errorMessage';
  }

  @override
  String unexpectedErrorOccurred(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get yourInvitationCode => 'Your Invitation Code';

  @override
  String get copyButton => 'Copy';

  @override
  String get invitationCodeCopied => 'Invitation code copied';

  @override
  String get invitationCodeAlreadyUsed =>
      'Invitation code has already been used';

  @override
  String get enterInvitationCode => 'Enter Invitation Code';

  @override
  String get invitationCodeHint => 'Invitation Code';

  @override
  String get applyButton => 'Apply';

  @override
  String errorDialogMessage(String err) {
    return 'Error: $err';
  }

  @override
  String get rateTheApp => 'Rate the App';

  @override
  String get reportBugsOrRequests => 'Report Bugs/Requests';

  @override
  String get manageCards => 'Manage Cards';

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get ankiExportCsv => 'Anki Export (.csv)';

  @override
  String get settingsReminderSettings => 'Reminder Settings';

  @override
  String get pleaseRateTheApp => 'Please rate the app';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get submitButton => 'Submit';

  @override
  String get reviewFeatureNotAvailable => 'Review feature is not available.';

  @override
  String get premiumFeatureOnly =>
      'This feature is available for premium plan users only.';

  @override
  String get startingAnkiExport => 'Starting Anki export process...';

  @override
  String get loginRequiredForExport => 'Login is required for export.';

  @override
  String get noCardsToExport => 'There are no cards to export.';

  @override
  String get ankiExportRequested =>
      'Anki file export has been requested. Please select the Anki app from the share menu.';

  @override
  String get ankiExportFailed => 'Failed to export Anki file.';

  @override
  String errorDuringAnkiExport(String e) {
    return 'An error occurred during Anki export: $e';
  }

  @override
  String get restoreCancelled => 'Restore process cancelled.';

  @override
  String get networkErrorPleaseCheckConnection =>
      'A network error occurred. Please check your connection.';

  @override
  String get storeCommunicationError =>
      'There was a problem communicating with the store. Please try again later.';

  @override
  String get userAuthenticationRequired => 'User authentication is required.';

  @override
  String get pleaseEnterInvitationCode => 'Please enter the invitation code.';

  @override
  String get selectVideo => 'Select Video';

  @override
  String get enterVideoUrlWithEnglishSubtitles =>
      'Enter the URL of a video with Japanese subtitles';

  @override
  String get youtubeVideoUrl => 'YouTube Video URL';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get recommendedVideos => 'Recommended Videos';

  @override
  String get searchVideosOnYouTube => 'Search Videos (YouTube)';

  @override
  String get generating => 'Generating...';

  @override
  String get generateFlashcards => 'Generate Flashcards';

  @override
  String get watchVideo => 'Watch Video';

  @override
  String get generatingCards => 'Generating cards...';

  @override
  String processingCardCount(int count) {
    return 'Processing cards: $count';
  }

  @override
  String get exampleSearchQuery => 'e.g., \"English conversation practice\"';

  @override
  String searchResultsCount(int count) {
    return 'Search Results ($count)';
  }

  @override
  String get fetchingVideoInfoCaptions =>
      'Fetching video info & English captions...';

  @override
  String get requestingCardGenerationJa =>
      'Requesting card generation (JA) from LLM...';

  @override
  String get processingGeneratedCards => 'Processing generated cards...';

  @override
  String get deleteCurrentCardTooltip => 'Delete current card';

  @override
  String get deleteCardTitle => 'Delete Card';

  @override
  String confirmDeleteCardMessage(String cardFront) {
    return 'Delete \"$cardFront\"? This action cannot be undone.';
  }

  @override
  String get deleteCardConfirmButtonLabel => 'Delete';

  @override
  String get cardDeletedSuccessMessage => 'Card deleted.';

  @override
  String cardDeletionFailedMessage(String error) {
    return 'Failed to delete card: $error';
  }

  @override
  String get noCardsToReviewMessage => 'There are no cards to review.';

  @override
  String get createCardsFromVideoButtonLabel => 'Create Cards from Video';

  @override
  String get backToHomeButtonLabel => 'Back to Home';

  @override
  String get rateAppTitle => 'Rate App';

  @override
  String get thankYouForUsingSwipelingo => 'Thank you for using Swipelingo!';

  @override
  String get pleaseRateOurApp =>
      'If you have a moment, please consider rating our app. Your warm reviews are a great encouragement to our development!';

  @override
  String get howIsYourExperience => 'How is your experience with the app?';

  @override
  String get writeReviewButton => 'Write a Review';

  @override
  String get laterButton => 'Later';

  @override
  String get learningDecksTitle => 'Learning Decks';

  @override
  String get noLearningDecks => 'No learning decks available.';

  @override
  String get createDeckFromYouTube =>
      'Let\'s create a new deck from a YouTube video.';

  @override
  String get createDeckFromVideoButton => 'Create Deck from Video';

  @override
  String get deleteDeckTooltip => 'Delete Deck';

  @override
  String get deleteDeckDialogTitle => 'Delete Deck';

  @override
  String deleteDeckDialogContent(String videoTitle) {
    return 'Are you sure you want to delete \"$videoTitle\" and all associated cards? This action cannot be undone.';
  }

  @override
  String get deckDeletedSuccessfully => 'Deck deleted successfully.';

  @override
  String deckDeletionFailed(String error) {
    return 'Failed to delete deck: $error';
  }

  @override
  String errorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get retryButton => 'Retry';

  @override
  String get cardListTitle => 'Manage Cards';

  @override
  String get noCardsFound => 'No cards found.';

  @override
  String get generateNewCardsFromVideos =>
      'Let\'s generate new cards from videos.';

  @override
  String get generateFromVideosButton => 'Generate from Videos';

  @override
  String get deleteCardTooltip => 'Delete Card';

  @override
  String get deleteCardDialogTitle => 'Delete Card';

  @override
  String deleteCardDialogContent(String cardFront) {
    return 'Are you sure you want to delete \"$cardFront\"? This action cannot be undone.';
  }

  @override
  String get cardDeletedSuccess => 'Card deleted successfully.';

  @override
  String cardDeletionFailed(String error) {
    return 'Failed to delete card: $error';
  }

  @override
  String get sessionResults => 'Session Results';

  @override
  String accuracyRate(Object accuracyPercentage) {
    return 'Accuracy: $accuracyPercentage%';
  }

  @override
  String correctIncorrectCount(Object correctCount, Object incorrectCount) {
    return 'Correct: $correctCount / Incorrect: $incorrectCount';
  }

  @override
  String get reviewedCards => 'Reviewed Cards:';

  @override
  String get backToHome => 'Back to Home';

  @override
  String searchResultsTitle(String searchQuery) {
    return 'Search Results: \"$searchQuery\"';
  }

  @override
  String errorPrefix(String errorMessage) {
    return 'Error: $errorMessage';
  }

  @override
  String get noVideosFoundMessage =>
      'No videos with English subtitles were found.';

  @override
  String get playVideoInAppTooltip => 'Play video in app';

  @override
  String get confirmDialogTitle => 'Confirm';

  @override
  String confirmGenerateFlashcardsMessage(String videoTitle) {
    return 'Generate flashcards for \"$videoTitle\"?';
  }

  @override
  String get generateButtonLabel => 'Generate';

  @override
  String get gemConsumptionConfirmation =>
      'One gem will be consumed to enable translated subtitles. Are you sure?';

  @override
  String get noButton => 'No';

  @override
  String get yesButton => 'Yes';

  @override
  String get invalidYouTubeUrl => 'Invalid YouTube URL.';

  @override
  String get processingComplete => 'Processing complete!';

  @override
  String get videoPlayerTitle => 'Video Player';

  @override
  String get videoLoadFailed => 'Failed to load video.';

  @override
  String get generatingFlashcards => 'Generating flashcards...';

  @override
  String get captionLoadFailed => 'Failed to load captions.';

  @override
  String get translating => 'Translating...';

  @override
  String get waitingForTranslation => 'Waiting for translation...';

  @override
  String get showTranslatedSubtitles => 'Show Translated Subtitles';

  @override
  String get noVideoInfoOrCaptions =>
      'No video information or captions available.';

  @override
  String get videoTitleUnknown => 'Video title unknown';

  @override
  String get failedToGetVideoTitle =>
      'Failed to get video title. Please try again.';

  @override
  String startingFlashcardGenerationWithIdAndTitle(
    String videoId,
    String title,
  ) {
    return 'Starting flashcard generation. Video ID: $videoId, Title: $title';
  }

  @override
  String missingInfoForFlashcardGeneration(
    String videoId,
    String captionsEmpty,
    String title,
  ) {
    return 'Missing information for flashcard generation. (videoId: $videoId, captions_empty: $captionsEmpty, title: $title)';
  }

  @override
  String get missingInfoReloadVideo =>
      'Missing information to generate cards. Please reload the video or try again later.';

  @override
  String get generateFlashcardsFromThisVideoButton =>
      'Generate Flashcards from This Video';

  @override
  String originalTextWithLanguage(String language) {
    return 'Original ($language):';
  }

  @override
  String translationWithLanguage(String language) {
    return 'Translation ($language):';
  }

  @override
  String selectConversationsToLearn(int selectedCount, int totalCount) {
    return 'Select conversations to learn ($selectedCount/$totalCount)';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get preview => 'Preview';

  @override
  String get aiGenerationNote =>
      'Note: Due to AI generation, both languages may occasionally be the same. In that case, please try another video.';

  @override
  String get saveSelectedCardsTooltip => 'Save Selected Cards';

  @override
  String get confirmTitle => 'Confirm';

  @override
  String get confirmCancelWithoutSavingMessage =>
      'Cancel without saving cards?';

  @override
  String cardsSavedSuccessfullySnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards saved!',
      one: '1 card saved!',
    );
    return '$_temp0';
  }

  @override
  String cardSaveErrorSnackbar(String error) {
    return 'Error saving cards: $error';
  }

  @override
  String get notificationPermissionRequired =>
      'Notification permission is required. Please enable notifications from the app settings.';

  @override
  String get learningTimeNotificationTitle => 'It\'s learning time!';

  @override
  String get learningTimeNotificationBody =>
      'Let\'s learn new words with Swipelingo today 🚀';

  @override
  String get dailyLearningReminderChannelName => 'Daily Learning Reminder';

  @override
  String get dailyLearningReminderChannelDescription =>
      'A reminder to encourage daily learning.';

  @override
  String get reminderSettingsTitle => 'Reminder Settings';

  @override
  String get maximizeLearningEffectTitle =>
      'Maximize your learning effectiveness with daily study!';

  @override
  String get maximizeLearningEffectBody =>
      'Swipelingo encourages review at the optimal timing based on the forgetting curve. Set a reminder to build a study habit.';

  @override
  String get whenToRemind => 'When would you like to be reminded?';

  @override
  String reminderSetSuccess(String time) {
    return 'Reminder set for $time!';
  }

  @override
  String get setReminderButton => 'Set Reminder';

  @override
  String get setReminderLaterButton => 'Set Later';

  @override
  String get videoFlashcardsTitle => 'Video Flashcards';

  @override
  String get deleteCurrentVideoCardTooltip => 'Delete current card';

  @override
  String get deleteVideoCardDialogTitle => 'Delete Card';

  @override
  String deleteVideoCardDialogContent(String cardFront) {
    return 'Delete \"$cardFront\"? This action cannot be undone.';
  }

  @override
  String get videoFlashcardCancelButtonLabel => 'Cancel';

  @override
  String get videoFlashcardDeleteButtonLabel => 'Delete';

  @override
  String get videoCardDeletedSuccessfullySnackbar =>
      'Card deleted successfully.';

  @override
  String videoCardDeletionFailedSnackbar(String error) {
    return 'Failed to delete card: $error';
  }

  @override
  String get noCardsFoundForThisVideo => 'No cards found for this video.';

  @override
  String get backToVideoListButtonLabel => 'Back to Video List';

  @override
  String get deleteButton => 'Delete';

  @override
  String get wordMeaningPopupTitle => 'Word Meaning';

  @override
  String get closeButton => 'Close';

  @override
  String get captionTapGuide =>
      'Tap a word in the subtitles to see its meaning.';

  @override
  String get createCardFromSubtitleButton => 'Create Card from Subtitle';

  @override
  String get failedToGetVideoId => 'Failed to get video ID.';

  @override
  String get noCaptionSelected => 'No caption selected.';

  @override
  String get defaultCardBackText => 'Enter translation or notes here';

  @override
  String get userNotAuthenticated => 'User not authenticated.';

  @override
  String get cardCreatedSuccessfully => 'Card created successfully!';

  @override
  String get failedToCreateCard => 'Failed to create card.';

  @override
  String get createCardConfirmationTitle => 'Confirm Card Creation';

  @override
  String get createCardConfirmationMessage =>
      'Do you want to create a card with the following content?';

  @override
  String get createButton => 'Create';

  @override
  String get cancelButtonDialog => 'Cancel';

  @override
  String get translatingText => 'Translating...';

  @override
  String get translationFailedFallbackText =>
      'Translation failed. Please edit manually later.';

  @override
  String get relatedVideosTitle => 'Related Videos';

  @override
  String get noRelatedVideos => 'No related videos found.';

  @override
  String get failedToLoadRelatedVideos => 'Failed to load related videos.';

  @override
  String get learningTab => 'Learn';

  @override
  String get videoTab => 'Watch';

  @override
  String get otherVideosInThisChannel => 'Other videos in this channel';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get favoriteChannelsScreenTitle => 'Favorite Channels';

  @override
  String get noFavoriteChannelsYet => 'No favorite channels yet.';

  @override
  String get watchHistoryScreenTitle => 'Watch History';

  @override
  String get noWatchHistoryFound => 'No watch history found.';

  @override
  String get reviewRequestTitle => 'How are you enjoying Swipelingo?';

  @override
  String get reviewRequestMessage =>
      'Would you mind rating our app? Your feedback helps us improve.';

  @override
  String get rateNow => 'Rate Now';

  @override
  String get remindLater => 'Remind Me Later';

  @override
  String get noThanks => 'No Thanks';

  @override
  String get loadingChannel => 'Loading channel...';

  @override
  String errorLoadingChannel(String channelId) {
    return 'Error loading channel: $channelId';
  }

  @override
  String channelNotFound(String channelId) {
    return 'Channel not found: $channelId';
  }

  @override
  String get noRecommendedVideosFound =>
      'No recommended videos found at the moment. Please check back later!';

  @override
  String get noVideosInChannel => 'There are no videos in this channel yet.';

  @override
  String get languageSelectionScreenTitle => 'Select Learning Languages';

  @override
  String get selectYourNativeLanguage => 'Select your native language:';

  @override
  String get selectLanguageToLearn => 'Select the language you want to learn:';

  @override
  String get selectNativeLanguageHint => 'Select Native Language';

  @override
  String get selectLanguageToLearnHint => 'Select Language to Learn';

  @override
  String get confirmAndStartButton => 'Confirm and Start';

  @override
  String get pleaseSelectLanguages => 'Please select both languages.';

  @override
  String get nativeAndTargetMustBeDifferent =>
      'Native and target languages must be different.';

  @override
  String get settingsSavedSuccessfully => 'Settings saved successfully.';

  @override
  String get languageSettingsSectionTitle => 'Language Settings';

  @override
  String get saveSettingsButton => 'Save Settings';

  @override
  String get pleaseSelectBothLanguages =>
      'Please select both your native and target languages.';

  @override
  String errorSavingSettings(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get errorMessageAnErrorOccurred =>
      'An error occurred. Please try again.';

  @override
  String get enterVideoUrlWithJapaneseSubtitles =>
      'Enter the URL of a video with Japanese subtitles';

  @override
  String get searchVideosOnYouTubeWithJapaneseSubtitles =>
      'Search Videos with Japanese Subtitles (YouTube)';

  @override
  String get exampleSearchQueryJapanese =>
      'e.g., \"Japanese conversation practice\"';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameJapanese => 'Japanese';

  @override
  String wordLabelWithLanguage(String language) {
    return 'Word ($language)';
  }

  @override
  String meaningLabelWithLanguage(String language) {
    return 'Meaning ($language)';
  }

  @override
  String frontLabel(String languageCode) {
    return 'Front ($languageCode)';
  }

  @override
  String backLabel(String languageCode) {
    return 'Back ($languageCode)';
  }

  @override
  String get translationWillBeGenerated => 'Translation will be generated';

  @override
  String get screenshotLabel => 'Screenshot';

  @override
  String get noScreenshotAvailable => 'No screenshot available';

  @override
  String get cardDetailsTitle => 'Card Details';

  @override
  String get cardFrontLabel => 'Front';

  @override
  String get cardBackLabel => 'Back';

  @override
  String get cardScreenshotLabel => 'Screenshot';

  @override
  String get watchVideoSegmentButton => 'Watch in Video';

  @override
  String get closeButtonLabel => 'Close';

  @override
  String get followUs => 'Follow Us';

  @override
  String get shareButton => 'Share';

  @override
  String shareInvitationMessage(
    String invitationCode,
    String downloadPrompt,
    String storeUrl,
  ) {
    return 'Learn Japanese with YouTube! My invitation code: $invitationCode $downloadPrompt $storeUrl #Swipelingo';
  }

  @override
  String get downloadAppPrompt => 'Download here:';

  @override
  String get translationFailed =>
      'Translation failed. Searching with original text.';

  @override
  String get searchWithTranslation => 'Search with translation';

  @override
  String get aiExplainButton => 'AI Explanation';

  @override
  String aiExplanationModalTitle(String word) {
    return 'AI Explanation for \"$word\"';
  }

  @override
  String get aiExplanationError =>
      'Failed to get AI explanation. Please try again later.';

  @override
  String get playerSettings => 'Player Settings';

  @override
  String get forceTranslatedCaptionsTitle =>
      'Show forcibly translated captions';

  @override
  String get forceTranslatedCaptionsDescription =>
      'Enabling this option will result in less natural translations, but it will display a 1:1 translation of the currently displayed subtitles, making it easier to understand the content of the displayed subtitles. Enable this when the update timing of the two subtitles is unnatural.';

  @override
  String get notificationPermissionPermanentlyDenied =>
      'Notification permission was permanently denied. Please enable it in settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get showRubyText => 'Show Ruby Text';

  @override
  String get showRubyTextDescription =>
      'Displays furigana (reading hints) above kanji characters';

  @override
  String get updateRequiredTitle => 'Update Required';

  @override
  String get updateRequiredMessage =>
      'A new version has been released. You need to update to the latest version to continue using the app.';

  @override
  String get updateNowButton => 'Update Now';

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String get updateAvailableMessage =>
      'A new version of Swipelingo is available. We recommend updating to the latest version to experience new features and improvements.';

  @override
  String get updateButton => 'Update';

  @override
  String get updateLaterButton => 'Later';

  @override
  String get videoLearning => 'Video Learning';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get youtubeUrlInput => 'YouTube URL Input';

  @override
  String get videoSearch => 'Video Search';

  @override
  String get watchHistory => 'Watch History';

  @override
  String get savedCards => 'Saved Cards';

  @override
  String get loadingCards => 'Loading cards...';

  @override
  String get errorOccurredGeneric => 'An error occurred';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get letsLearnTogether => 'Let\'s learn together today';

  @override
  String get learningStatistics => 'Learning Statistics';

  @override
  String get consecutiveLearningRecord => 'Consecutive learning record';

  @override
  String get loadingData => 'Loading...';

  @override
  String get errorOccurredWithMessage => 'An error occurred';

  @override
  String get channelErrorMessage => 'Failed to load channel information';

  @override
  String get youtubeChannel => 'YouTube Channel';

  @override
  String get addFavoriteChannelsMessage =>
      'Add your favorite YouTube channels to learn efficiently!';

  @override
  String get noVideosInChannelMessage => 'There are no videos in this channel';

  @override
  String get pleaseWaitForNewVideos => 'Please wait for new videos to be added';

  @override
  String videosCount(int count) {
    return '$count videos';
  }

  @override
  String get favoriteChannelVideosList => 'Favorite channel videos';

  @override
  String get favoriteChannels => 'Favorite\nChannels';

  @override
  String get cardList => 'Card\nList';

  @override
  String get watchHistoryShort => 'Watch\nHistory';

  @override
  String get videoLearningSubtitle => 'Let\'s learn with YouTube videos!';

  @override
  String get tapToSeeAnswer => 'Tap to see answer';

  @override
  String get swipeToRate => 'Swipe to rate';

  @override
  String get correctButton => 'Correct';

  @override
  String get incorrectButton => 'Incorrect';

  @override
  String get voiceButton => 'Voice';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get notificationDescription =>
      'Get reminders to keep your learning streak going';

  @override
  String get notificationTime => 'Notification Time';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get dailyReminderDescription => 'Get a daily reminder to study';

  @override
  String get reviewReminder => 'Review Reminder';

  @override
  String get reviewReminderDescription =>
      'Notify when cards are due for review';

  @override
  String get milestoneNotification => 'Milestone Achievements';

  @override
  String get milestoneDescription => 'Celebrate your learning milestones';

  @override
  String get newContentNotification => 'New Content';

  @override
  String get newContentDescription =>
      'Get notified about new recommended videos';

  @override
  String get sendTestNotification => 'Send Test Notification';

  @override
  String get testNotificationSent => 'Test notification sent!';

  @override
  String get notificationPermissionDenied =>
      'Notification permission denied. Please enable it in settings.';

  @override
  String get favoritesPlaylist => 'Favorites';

  @override
  String get watchLaterPlaylist => 'Watch Later';
}
