import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @getMore.
  ///
  /// In en, this message translates to:
  /// **'Get'**
  String get getMore;

  /// No description provided for @learningMenu.
  ///
  /// In en, this message translates to:
  /// **'Learning Menu'**
  String get learningMenu;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get startLearning;

  /// No description provided for @dueCardsWaitingForReview.
  ///
  /// In en, this message translates to:
  /// **'{count} cards waiting for review'**
  String dueCardsWaitingForReview(int count);

  /// No description provided for @noScheduledCardsRandomMode.
  ///
  /// In en, this message translates to:
  /// **'No scheduled cards. Switching to random mode.'**
  String get noScheduledCardsRandomMode;

  /// No description provided for @countRetrievalError.
  ///
  /// In en, this message translates to:
  /// **'Error retrieving count'**
  String get countRetrievalError;

  /// No description provided for @createCardsFromVideo.
  ///
  /// In en, this message translates to:
  /// **'Create Cards from Video'**
  String get createCardsFromVideo;

  /// No description provided for @learnNewWordsFromYouTube.
  ///
  /// In en, this message translates to:
  /// **'Learn new words from YouTube'**
  String get learnNewWordsFromYouTube;

  /// No description provided for @cardDeckList.
  ///
  /// In en, this message translates to:
  /// **'Card Deck List'**
  String get cardDeckList;

  /// No description provided for @checkSavedVideoCards.
  ///
  /// In en, this message translates to:
  /// **'Check saved video cards'**
  String get checkSavedVideoCards;

  /// No description provided for @learningStats.
  ///
  /// In en, this message translates to:
  /// **'Learning Stats'**
  String get learningStats;

  /// No description provided for @learningStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days learning streak'**
  String learningStreakDays(int count);

  /// No description provided for @activityLast105Days.
  ///
  /// In en, this message translates to:
  /// **'Activity in the last 105 days'**
  String get activityLast105Days;

  /// No description provided for @activityRetrievalError.
  ///
  /// In en, this message translates to:
  /// **'Error retrieving activity'**
  String get activityRetrievalError;

  /// No description provided for @totalCardsLearned.
  ///
  /// In en, this message translates to:
  /// **'Total cards learned: {count}'**
  String totalCardsLearned(int count);

  /// No description provided for @cardCountRetrievalError.
  ///
  /// In en, this message translates to:
  /// **'Error retrieving card count'**
  String get cardCountRetrievalError;

  /// No description provided for @upgradeToSwipelingoPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Swipelingo Pro'**
  String get upgradeToSwipelingoPro;

  /// No description provided for @unlimitedGemsNoAdsAccessAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlimited gems, no ads, access all features'**
  String get unlimitedGemsNoAdsAccessAllFeatures;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @couldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch URL: {urlString}'**
  String couldNotLaunchUrl(String urlString);

  /// No description provided for @swipelingoPro.
  ///
  /// In en, this message translates to:
  /// **'Swipelingo Pro'**
  String get swipelingoPro;

  /// No description provided for @noOfferingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No offerings currently available. Please check your store settings or try again later.'**
  String get noOfferingsAvailable;

  /// No description provided for @noPackagesAvailableInOffering.
  ///
  /// In en, this message translates to:
  /// **'No purchase plans currently available.\\n(Offering \"{offeringIdentifier}\" did not include any plans)'**
  String noPackagesAvailableInOffering(String offeringIdentifier);

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// No description provided for @unlimitedGems.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Gems'**
  String get unlimitedGems;

  /// No description provided for @unlimitedTranslationSubtitles.
  ///
  /// In en, this message translates to:
  /// **'No limit on displaying translated subtitles'**
  String get unlimitedTranslationSubtitles;

  /// No description provided for @adsFree.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free'**
  String get adsFree;

  /// No description provided for @concentrateOnLearning.
  ///
  /// In en, this message translates to:
  /// **'Environment to concentrate on learning'**
  String get concentrateOnLearning;

  /// No description provided for @unlimitedCardCreation.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Card Creation'**
  String get unlimitedCardCreation;

  /// No description provided for @learnAsMuchAsYouWantDaily.
  ///
  /// In en, this message translates to:
  /// **'Learn as much as you want every day'**
  String get learnAsMuchAsYouWantDaily;

  /// No description provided for @premiumSupport.
  ///
  /// In en, this message translates to:
  /// **'Premium Support'**
  String get premiumSupport;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Receive priority support'**
  String get prioritySupport;

  /// No description provided for @selectBestPlanForYou.
  ///
  /// In en, this message translates to:
  /// **'Select the best plan for you'**
  String get selectBestPlanForYou;

  /// No description provided for @purchaseTermsDescription.
  ///
  /// In en, this message translates to:
  /// **'Purchases will be charged to your Apple ID account. Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period. You can manage subscriptions and turn off auto-renewal in your account settings.\\n\\n'**
  String get purchaseTermsDescription;

  /// No description provided for @termsOfUseEULA.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use (EULA)'**
  String get termsOfUseEULA;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @restoringPurchases.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases...'**
  String get restoringPurchases;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get purchasesRestored;

  /// No description provided for @restorePurchasesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases: {error}'**
  String restorePurchasesFailed(String error);

  /// No description provided for @restorePurchasesButton.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchasesButton;

  /// No description provided for @loadingPlans.
  ///
  /// In en, this message translates to:
  /// **'Loading plans...'**
  String get loadingPlans;

  /// No description provided for @failedToLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans.'**
  String get failedToLoadPlans;

  /// No description provided for @errorCode.
  ///
  /// In en, this message translates to:
  /// **'Error Code: {errorCode}'**
  String errorCode(String errorCode);

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details: {details}'**
  String details(String details);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @weeklyPlan.
  ///
  /// In en, this message translates to:
  /// **'Weekly Plan'**
  String get weeklyPlan;

  /// No description provided for @daysFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'With 3-day free trial'**
  String get daysFreeTrial;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

  /// No description provided for @annualPlan.
  ///
  /// In en, this message translates to:
  /// **'Annual Plan'**
  String get annualPlan;

  /// No description provided for @discountFromMonthly.
  ///
  /// In en, this message translates to:
  /// **'{discountPercentage}% off from monthly'**
  String discountFromMonthly(String discountPercentage);

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'per week'**
  String get perWeek;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @selectButton.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectButton;

  /// No description provided for @startingPurchaseProcess.
  ///
  /// In en, this message translates to:
  /// **'Starting purchase process...'**
  String get startingPurchaseProcess;

  /// No description provided for @purchaseCompletedThankYou.
  ///
  /// In en, this message translates to:
  /// **'Purchase completed! Thank you.'**
  String get purchaseCompletedThankYou;

  /// No description provided for @purchaseCompletedPlanNotActive.
  ///
  /// In en, this message translates to:
  /// **'Purchase completed, but the plan did not activate. Please contact support.'**
  String get purchaseCompletedPlanNotActive;

  /// No description provided for @purchaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled.'**
  String get purchaseCancelled;

  /// No description provided for @purchasePending.
  ///
  /// In en, this message translates to:
  /// **'Purchase process is pending. Please wait for approval from the store.'**
  String get purchasePending;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {errorMessage}'**
  String purchaseFailed(String errorMessage);

  /// No description provided for @unexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedErrorOccurred(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @yourInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Your Invitation Code'**
  String get yourInvitationCode;

  /// No description provided for @copyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButton;

  /// No description provided for @invitationCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invitation code copied'**
  String get invitationCodeCopied;

  /// No description provided for @invitationCodeAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'Invitation code has already been used'**
  String get invitationCodeAlreadyUsed;

  /// No description provided for @enterInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Invitation Code'**
  String get enterInvitationCode;

  /// No description provided for @invitationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCodeHint;

  /// No description provided for @applyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButton;

  /// No description provided for @errorDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {err}'**
  String errorDialogMessage(String err);

  /// No description provided for @rateTheApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateTheApp;

  /// No description provided for @reportBugsOrRequests.
  ///
  /// In en, this message translates to:
  /// **'Report Bugs/Requests'**
  String get reportBugsOrRequests;

  /// No description provided for @manageCards.
  ///
  /// In en, this message translates to:
  /// **'Manage Cards'**
  String get manageCards;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// No description provided for @ankiExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Anki Export (.csv)'**
  String get ankiExportCsv;

  /// No description provided for @settingsReminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get settingsReminderSettings;

  /// No description provided for @pleaseRateTheApp.
  ///
  /// In en, this message translates to:
  /// **'Please rate the app'**
  String get pleaseRateTheApp;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @reviewFeatureNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Review feature is not available.'**
  String get reviewFeatureNotAvailable;

  /// No description provided for @premiumFeatureOnly.
  ///
  /// In en, this message translates to:
  /// **'This feature is available for premium plan users only.'**
  String get premiumFeatureOnly;

  /// No description provided for @startingAnkiExport.
  ///
  /// In en, this message translates to:
  /// **'Starting Anki export process...'**
  String get startingAnkiExport;

  /// No description provided for @loginRequiredForExport.
  ///
  /// In en, this message translates to:
  /// **'Login is required for export.'**
  String get loginRequiredForExport;

  /// No description provided for @noCardsToExport.
  ///
  /// In en, this message translates to:
  /// **'There are no cards to export.'**
  String get noCardsToExport;

  /// No description provided for @ankiExportRequested.
  ///
  /// In en, this message translates to:
  /// **'Anki file export has been requested. Please select the Anki app from the share menu.'**
  String get ankiExportRequested;

  /// No description provided for @ankiExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export Anki file.'**
  String get ankiExportFailed;

  /// No description provided for @errorDuringAnkiExport.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during Anki export: {e}'**
  String errorDuringAnkiExport(String e);

  /// No description provided for @restoreCancelled.
  ///
  /// In en, this message translates to:
  /// **'Restore process cancelled.'**
  String get restoreCancelled;

  /// No description provided for @networkErrorPleaseCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred. Please check your connection.'**
  String get networkErrorPleaseCheckConnection;

  /// No description provided for @storeCommunicationError.
  ///
  /// In en, this message translates to:
  /// **'There was a problem communicating with the store. Please try again later.'**
  String get storeCommunicationError;

  /// No description provided for @userAuthenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'User authentication is required.'**
  String get userAuthenticationRequired;

  /// No description provided for @pleaseEnterInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the invitation code.'**
  String get pleaseEnterInvitationCode;

  /// No description provided for @selectVideo.
  ///
  /// In en, this message translates to:
  /// **'Select Video'**
  String get selectVideo;

  /// No description provided for @enterVideoUrlWithEnglishSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Enter the URL of a video with Japanese subtitles'**
  String get enterVideoUrlWithEnglishSubtitles;

  /// No description provided for @youtubeVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'YouTube Video URL'**
  String get youtubeVideoUrl;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @recommendedVideos.
  ///
  /// In en, this message translates to:
  /// **'Recommended Videos'**
  String get recommendedVideos;

  /// No description provided for @searchVideosOnYouTube.
  ///
  /// In en, this message translates to:
  /// **'Search Videos (YouTube)'**
  String get searchVideosOnYouTube;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @generateFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Generate Flashcards'**
  String get generateFlashcards;

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch Video'**
  String get watchVideo;

  /// No description provided for @generatingCards.
  ///
  /// In en, this message translates to:
  /// **'Generating cards...'**
  String get generatingCards;

  /// Number of cards being processed
  ///
  /// In en, this message translates to:
  /// **'Processing cards: {count}'**
  String processingCardCount(int count);

  /// No description provided for @exampleSearchQuery.
  ///
  /// In en, this message translates to:
  /// **'e.g., \"English conversation practice\"'**
  String get exampleSearchQuery;

  /// Number of search results
  ///
  /// In en, this message translates to:
  /// **'Search Results ({count})'**
  String searchResultsCount(int count);

  /// No description provided for @fetchingVideoInfoCaptions.
  ///
  /// In en, this message translates to:
  /// **'Fetching video info & English captions...'**
  String get fetchingVideoInfoCaptions;

  /// No description provided for @requestingCardGenerationJa.
  ///
  /// In en, this message translates to:
  /// **'Requesting card generation (JA) from LLM...'**
  String get requestingCardGenerationJa;

  /// No description provided for @processingGeneratedCards.
  ///
  /// In en, this message translates to:
  /// **'Processing generated cards...'**
  String get processingGeneratedCards;

  /// No description provided for @deleteCurrentCardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete current card'**
  String get deleteCurrentCardTooltip;

  /// No description provided for @deleteCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCardTitle;

  /// No description provided for @confirmDeleteCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{cardFront}\"? This action cannot be undone.'**
  String confirmDeleteCardMessage(String cardFront);

  /// No description provided for @deleteCardConfirmButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteCardConfirmButtonLabel;

  /// No description provided for @cardDeletedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Card deleted.'**
  String get cardDeletedSuccessMessage;

  /// No description provided for @cardDeletionFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete card: {error}'**
  String cardDeletionFailedMessage(String error);

  /// No description provided for @noCardsToReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no cards to review.'**
  String get noCardsToReviewMessage;

  /// No description provided for @createCardsFromVideoButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Cards from Video'**
  String get createCardsFromVideoButtonLabel;

  /// No description provided for @backToHomeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHomeButtonLabel;

  /// No description provided for @rateAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateAppTitle;

  /// No description provided for @thankYouForUsingSwipelingo.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using Swipelingo!'**
  String get thankYouForUsingSwipelingo;

  /// No description provided for @pleaseRateOurApp.
  ///
  /// In en, this message translates to:
  /// **'If you have a moment, please consider rating our app. Your warm reviews are a great encouragement to our development!'**
  String get pleaseRateOurApp;

  /// No description provided for @howIsYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How is your experience with the app?'**
  String get howIsYourExperience;

  /// No description provided for @writeReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReviewButton;

  /// No description provided for @laterButton.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterButton;

  /// No description provided for @learningDecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Decks'**
  String get learningDecksTitle;

  /// No description provided for @noLearningDecks.
  ///
  /// In en, this message translates to:
  /// **'No learning decks available.'**
  String get noLearningDecks;

  /// No description provided for @createDeckFromYouTube.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create a new deck from a YouTube video.'**
  String get createDeckFromYouTube;

  /// No description provided for @createDeckFromVideoButton.
  ///
  /// In en, this message translates to:
  /// **'Create Deck from Video'**
  String get createDeckFromVideoButton;

  /// No description provided for @deleteDeckTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Deck'**
  String get deleteDeckTooltip;

  /// No description provided for @deleteDeckDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Deck'**
  String get deleteDeckDialogTitle;

  /// No description provided for @deleteDeckDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{videoTitle}\" and all associated cards? This action cannot be undone.'**
  String deleteDeckDialogContent(String videoTitle);

  /// No description provided for @deckDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deck deleted successfully.'**
  String get deckDeletedSuccessfully;

  /// No description provided for @deckDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete deck: {error}'**
  String deckDeletionFailed(String error);

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(String error);

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @cardListTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Cards'**
  String get cardListTitle;

  /// No description provided for @noCardsFound.
  ///
  /// In en, this message translates to:
  /// **'No cards found.'**
  String get noCardsFound;

  /// No description provided for @generateNewCardsFromVideos.
  ///
  /// In en, this message translates to:
  /// **'Let\'s generate new cards from videos.'**
  String get generateNewCardsFromVideos;

  /// No description provided for @generateFromVideosButton.
  ///
  /// In en, this message translates to:
  /// **'Generate from Videos'**
  String get generateFromVideosButton;

  /// No description provided for @deleteCardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCardTooltip;

  /// No description provided for @deleteCardDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCardDialogTitle;

  /// No description provided for @deleteCardDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{cardFront}\"? This action cannot be undone.'**
  String deleteCardDialogContent(String cardFront);

  /// No description provided for @cardDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card deleted successfully.'**
  String get cardDeletedSuccess;

  /// No description provided for @cardDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete card: {error}'**
  String cardDeletionFailed(String error);

  /// No description provided for @sessionResults.
  ///
  /// In en, this message translates to:
  /// **'Session Results'**
  String get sessionResults;

  /// No description provided for @accuracyRate.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {accuracyPercentage}%'**
  String accuracyRate(Object accuracyPercentage);

  /// No description provided for @correctIncorrectCount.
  ///
  /// In en, this message translates to:
  /// **'Correct: {correctCount} / Incorrect: {incorrectCount}'**
  String correctIncorrectCount(Object correctCount, Object incorrectCount);

  /// No description provided for @reviewedCards.
  ///
  /// In en, this message translates to:
  /// **'Reviewed Cards:'**
  String get reviewedCards;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Title for search results screen
  ///
  /// In en, this message translates to:
  /// **'Search Results: \"{searchQuery}\"'**
  String searchResultsTitle(String searchQuery);

  /// Prefix for error messages
  ///
  /// In en, this message translates to:
  /// **'Error: {errorMessage}'**
  String errorPrefix(String errorMessage);

  /// Message displayed when no videos are found
  ///
  /// In en, this message translates to:
  /// **'No videos with English subtitles were found.'**
  String get noVideosFoundMessage;

  /// Tooltip for the play video button
  ///
  /// In en, this message translates to:
  /// **'Play video in app'**
  String get playVideoInAppTooltip;

  /// Title for confirmation dialogs
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmDialogTitle;

  /// Message to confirm flashcard generation
  ///
  /// In en, this message translates to:
  /// **'Generate flashcards for \"{videoTitle}\"?'**
  String confirmGenerateFlashcardsMessage(String videoTitle);

  /// Label for the generate button
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generateButtonLabel;

  /// No description provided for @gemConsumptionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'One gem will be consumed to enable translated subtitles. Are you sure?'**
  String get gemConsumptionConfirmation;

  /// No description provided for @noButton.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noButton;

  /// No description provided for @yesButton.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesButton;

  /// No description provided for @invalidYouTubeUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid YouTube URL.'**
  String get invalidYouTubeUrl;

  /// No description provided for @processingComplete.
  ///
  /// In en, this message translates to:
  /// **'Processing complete!'**
  String get processingComplete;

  /// No description provided for @videoPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Player'**
  String get videoPlayerTitle;

  /// No description provided for @videoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load video.'**
  String get videoLoadFailed;

  /// No description provided for @generatingFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Generating flashcards...'**
  String get generatingFlashcards;

  /// No description provided for @captionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load captions.'**
  String get captionLoadFailed;

  /// No description provided for @translating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translating;

  /// No description provided for @waitingForTranslation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for translation...'**
  String get waitingForTranslation;

  /// No description provided for @showTranslatedSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Show Translated Subtitles'**
  String get showTranslatedSubtitles;

  /// No description provided for @noVideoInfoOrCaptions.
  ///
  /// In en, this message translates to:
  /// **'No video information or captions available.'**
  String get noVideoInfoOrCaptions;

  /// No description provided for @videoTitleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Video title unknown'**
  String get videoTitleUnknown;

  /// No description provided for @failedToGetVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to get video title. Please try again.'**
  String get failedToGetVideoTitle;

  /// No description provided for @startingFlashcardGenerationWithIdAndTitle.
  ///
  /// In en, this message translates to:
  /// **'Starting flashcard generation. Video ID: {videoId}, Title: {title}'**
  String startingFlashcardGenerationWithIdAndTitle(
    String videoId,
    String title,
  );

  /// No description provided for @missingInfoForFlashcardGeneration.
  ///
  /// In en, this message translates to:
  /// **'Missing information for flashcard generation. (videoId: {videoId}, captions_empty: {captionsEmpty}, title: {title})'**
  String missingInfoForFlashcardGeneration(
    String videoId,
    String captionsEmpty,
    String title,
  );

  /// No description provided for @missingInfoReloadVideo.
  ///
  /// In en, this message translates to:
  /// **'Missing information to generate cards. Please reload the video or try again later.'**
  String get missingInfoReloadVideo;

  /// No description provided for @generateFlashcardsFromThisVideoButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Flashcards from This Video'**
  String get generateFlashcardsFromThisVideoButton;

  /// No description provided for @originalTextWithLanguage.
  ///
  /// In en, this message translates to:
  /// **'Original ({language}):'**
  String originalTextWithLanguage(String language);

  /// No description provided for @translationWithLanguage.
  ///
  /// In en, this message translates to:
  /// **'Translation ({language}):'**
  String translationWithLanguage(String language);

  /// No description provided for @selectConversationsToLearn.
  ///
  /// In en, this message translates to:
  /// **'Select conversations to learn ({selectedCount}/{totalCount})'**
  String selectConversationsToLearn(int selectedCount, int totalCount);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @aiGenerationNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Due to AI generation, both languages may occasionally be the same. In that case, please try another video.'**
  String get aiGenerationNote;

  /// No description provided for @saveSelectedCardsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save Selected Cards'**
  String get saveSelectedCardsTooltip;

  /// No description provided for @confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmTitle;

  /// No description provided for @confirmCancelWithoutSavingMessage.
  ///
  /// In en, this message translates to:
  /// **'Cancel without saving cards?'**
  String get confirmCancelWithoutSavingMessage;

  /// No description provided for @cardsSavedSuccessfullySnackbar.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 card saved!}other{{count} cards saved!}}'**
  String cardsSavedSuccessfullySnackbar(int count);

  /// No description provided for @cardSaveErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Error saving cards: {error}'**
  String cardSaveErrorSnackbar(String error);

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required. Please enable notifications from the app settings.'**
  String get notificationPermissionRequired;

  /// No description provided for @learningTimeNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s learning time!'**
  String get learningTimeNotificationTitle;

  /// No description provided for @learningTimeNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn new words with Swipelingo today 🚀'**
  String get learningTimeNotificationBody;

  /// No description provided for @dailyLearningReminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily Learning Reminder'**
  String get dailyLearningReminderChannelName;

  /// No description provided for @dailyLearningReminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'A reminder to encourage daily learning.'**
  String get dailyLearningReminderChannelDescription;

  /// No description provided for @reminderSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderSettingsTitle;

  /// No description provided for @maximizeLearningEffectTitle.
  ///
  /// In en, this message translates to:
  /// **'Maximize your learning effectiveness with daily study!'**
  String get maximizeLearningEffectTitle;

  /// No description provided for @maximizeLearningEffectBody.
  ///
  /// In en, this message translates to:
  /// **'Swipelingo encourages review at the optimal timing based on the forgetting curve. Set a reminder to build a study habit.'**
  String get maximizeLearningEffectBody;

  /// No description provided for @whenToRemind.
  ///
  /// In en, this message translates to:
  /// **'When would you like to be reminded?'**
  String get whenToRemind;

  /// Message shown when a reminder is successfully set, includes the time.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for {time}!'**
  String reminderSetSuccess(String time);

  /// No description provided for @setReminderButton.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminderButton;

  /// No description provided for @setReminderLaterButton.
  ///
  /// In en, this message translates to:
  /// **'Set Later'**
  String get setReminderLaterButton;

  /// No description provided for @videoFlashcardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Flashcards'**
  String get videoFlashcardsTitle;

  /// No description provided for @deleteCurrentVideoCardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete current card'**
  String get deleteCurrentVideoCardTooltip;

  /// No description provided for @deleteVideoCardDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteVideoCardDialogTitle;

  /// No description provided for @deleteVideoCardDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{cardFront}\"? This action cannot be undone.'**
  String deleteVideoCardDialogContent(String cardFront);

  /// No description provided for @videoFlashcardCancelButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get videoFlashcardCancelButtonLabel;

  /// No description provided for @videoFlashcardDeleteButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get videoFlashcardDeleteButtonLabel;

  /// No description provided for @videoCardDeletedSuccessfullySnackbar.
  ///
  /// In en, this message translates to:
  /// **'Card deleted successfully.'**
  String get videoCardDeletedSuccessfullySnackbar;

  /// No description provided for @videoCardDeletionFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete card: {error}'**
  String videoCardDeletionFailedSnackbar(String error);

  /// No description provided for @noCardsFoundForThisVideo.
  ///
  /// In en, this message translates to:
  /// **'No cards found for this video.'**
  String get noCardsFoundForThisVideo;

  /// No description provided for @backToVideoListButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Back to Video List'**
  String get backToVideoListButtonLabel;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @wordMeaningPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Word Meaning'**
  String get wordMeaningPopupTitle;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// Guidance message displayed when the user first opens the video player, explaining that they can tap words in the subtitles.
  ///
  /// In en, this message translates to:
  /// **'Tap a word in the subtitles to see its meaning.'**
  String get captionTapGuide;

  /// No description provided for @createCardFromSubtitleButton.
  ///
  /// In en, this message translates to:
  /// **'Create Card from Subtitle'**
  String get createCardFromSubtitleButton;

  /// No description provided for @failedToGetVideoId.
  ///
  /// In en, this message translates to:
  /// **'Failed to get video ID.'**
  String get failedToGetVideoId;

  /// No description provided for @noCaptionSelected.
  ///
  /// In en, this message translates to:
  /// **'No caption selected.'**
  String get noCaptionSelected;

  /// No description provided for @defaultCardBackText.
  ///
  /// In en, this message translates to:
  /// **'Enter translation or notes here'**
  String get defaultCardBackText;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated.'**
  String get userNotAuthenticated;

  /// No description provided for @cardCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Card created successfully!'**
  String get cardCreatedSuccessfully;

  /// No description provided for @failedToCreateCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to create card.'**
  String get failedToCreateCard;

  /// No description provided for @createCardConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Card Creation'**
  String get createCardConfirmationTitle;

  /// No description provided for @createCardConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to create a card with the following content?'**
  String get createCardConfirmationMessage;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @cancelButtonDialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonDialog;

  /// No description provided for @translatingText.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translatingText;

  /// No description provided for @translationFailedFallbackText.
  ///
  /// In en, this message translates to:
  /// **'Translation failed. Please edit manually later.'**
  String get translationFailedFallbackText;

  /// Title for the related videos section
  ///
  /// In en, this message translates to:
  /// **'Related Videos'**
  String get relatedVideosTitle;

  /// Message displayed when no related videos are found.
  ///
  /// In en, this message translates to:
  /// **'No related videos found.'**
  String get noRelatedVideos;

  /// Message displayed when loading related videos fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load related videos.'**
  String get failedToLoadRelatedVideos;

  /// No description provided for @learningTab.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learningTab;

  /// No description provided for @videoTab.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get videoTab;

  /// Button text to show other videos from the same channel
  ///
  /// In en, this message translates to:
  /// **'Other videos in this channel'**
  String get otherVideosInThisChannel;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @favoriteChannelsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Channels'**
  String get favoriteChannelsScreenTitle;

  /// No description provided for @noFavoriteChannelsYet.
  ///
  /// In en, this message translates to:
  /// **'No favorite channels yet.'**
  String get noFavoriteChannelsYet;

  /// No description provided for @watchHistoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch History'**
  String get watchHistoryScreenTitle;

  /// No description provided for @noWatchHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No watch history found.'**
  String get noWatchHistoryFound;

  /// No description provided for @reviewRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you enjoying Swipelingo?'**
  String get reviewRequestTitle;

  /// No description provided for @reviewRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Would you mind rating our app? Your feedback helps us improve.'**
  String get reviewRequestMessage;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// No description provided for @remindLater.
  ///
  /// In en, this message translates to:
  /// **'Remind Me Later'**
  String get remindLater;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No Thanks'**
  String get noThanks;

  /// No description provided for @loadingChannel.
  ///
  /// In en, this message translates to:
  /// **'Loading channel...'**
  String get loadingChannel;

  /// No description provided for @errorLoadingChannel.
  ///
  /// In en, this message translates to:
  /// **'Error loading channel: {channelId}'**
  String errorLoadingChannel(String channelId);

  /// No description provided for @channelNotFound.
  ///
  /// In en, this message translates to:
  /// **'Channel not found: {channelId}'**
  String channelNotFound(String channelId);

  /// No description provided for @noRecommendedVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No recommended videos found at the moment. Please check back later!'**
  String get noRecommendedVideosFound;

  /// No description provided for @noVideosInChannel.
  ///
  /// In en, this message translates to:
  /// **'There are no videos in this channel yet.'**
  String get noVideosInChannel;

  /// No description provided for @languageSelectionScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Learning Languages'**
  String get languageSelectionScreenTitle;

  /// No description provided for @selectYourNativeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your native language:'**
  String get selectYourNativeLanguage;

  /// No description provided for @selectLanguageToLearn.
  ///
  /// In en, this message translates to:
  /// **'Select the language you want to learn:'**
  String get selectLanguageToLearn;

  /// No description provided for @selectNativeLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Select Native Language'**
  String get selectNativeLanguageHint;

  /// No description provided for @selectLanguageToLearnHint.
  ///
  /// In en, this message translates to:
  /// **'Select Language to Learn'**
  String get selectLanguageToLearnHint;

  /// No description provided for @confirmAndStartButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Start'**
  String get confirmAndStartButton;

  /// No description provided for @pleaseSelectLanguages.
  ///
  /// In en, this message translates to:
  /// **'Please select both languages.'**
  String get pleaseSelectLanguages;

  /// No description provided for @nativeAndTargetMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'Native and target languages must be different.'**
  String get nativeAndTargetMustBeDifferent;

  /// No description provided for @settingsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully.'**
  String get settingsSavedSuccessfully;

  /// No description provided for @languageSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettingsSectionTitle;

  /// No description provided for @saveSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettingsButton;

  /// No description provided for @pleaseSelectBothLanguages.
  ///
  /// In en, this message translates to:
  /// **'Please select both your native and target languages.'**
  String get pleaseSelectBothLanguages;

  /// No description provided for @errorSavingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings: {error}'**
  String errorSavingSettings(String error);

  /// No description provided for @errorMessageAnErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorMessageAnErrorOccurred;

  /// No description provided for @enterVideoUrlWithJapaneseSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Enter the URL of a video with Japanese subtitles'**
  String get enterVideoUrlWithJapaneseSubtitles;

  /// No description provided for @searchVideosOnYouTubeWithJapaneseSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Search Videos with Japanese Subtitles (YouTube)'**
  String get searchVideosOnYouTubeWithJapaneseSubtitles;

  /// No description provided for @exampleSearchQueryJapanese.
  ///
  /// In en, this message translates to:
  /// **'e.g., \"Japanese conversation practice\"'**
  String get exampleSearchQueryJapanese;

  /// No description provided for @languageNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// No description provided for @languageNameJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageNameJapanese;

  /// No description provided for @wordLabelWithLanguage.
  ///
  /// In en, this message translates to:
  /// **'Word ({language})'**
  String wordLabelWithLanguage(String language);

  /// No description provided for @meaningLabelWithLanguage.
  ///
  /// In en, this message translates to:
  /// **'Meaning ({language})'**
  String meaningLabelWithLanguage(String language);

  /// No description provided for @frontLabel.
  ///
  /// In en, this message translates to:
  /// **'Front ({languageCode})'**
  String frontLabel(String languageCode);

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back ({languageCode})'**
  String backLabel(String languageCode);

  /// No description provided for @translationWillBeGenerated.
  ///
  /// In en, this message translates to:
  /// **'Translation will be generated'**
  String get translationWillBeGenerated;

  /// No description provided for @screenshotLabel.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get screenshotLabel;

  /// No description provided for @noScreenshotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No screenshot available'**
  String get noScreenshotAvailable;

  /// No description provided for @cardDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetailsTitle;

  /// No description provided for @cardFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get cardFrontLabel;

  /// No description provided for @cardBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cardBackLabel;

  /// No description provided for @cardScreenshotLabel.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get cardScreenshotLabel;

  /// No description provided for @watchVideoSegmentButton.
  ///
  /// In en, this message translates to:
  /// **'Watch in Video'**
  String get watchVideoSegmentButton;

  /// No description provided for @closeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButtonLabel;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @shareInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'Learn Japanese with YouTube! My invitation code: {invitationCode} {downloadPrompt} {storeUrl} #Swipelingo'**
  String shareInvitationMessage(
    String invitationCode,
    String downloadPrompt,
    String storeUrl,
  );

  /// No description provided for @downloadAppPrompt.
  ///
  /// In en, this message translates to:
  /// **'Download here:'**
  String get downloadAppPrompt;

  /// No description provided for @translationFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation failed. Searching with original text.'**
  String get translationFailed;

  /// Label for the toggle switch to enable/disable search with translation
  ///
  /// In en, this message translates to:
  /// **'Search with translation'**
  String get searchWithTranslation;

  /// No description provided for @aiExplainButton.
  ///
  /// In en, this message translates to:
  /// **'AI Explanation'**
  String get aiExplainButton;

  /// No description provided for @aiExplanationModalTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Explanation for \"{word}\"'**
  String aiExplanationModalTitle(String word);

  /// No description provided for @aiExplanationError.
  ///
  /// In en, this message translates to:
  /// **'Failed to get AI explanation. Please try again later.'**
  String get aiExplanationError;

  /// No description provided for @playerSettings.
  ///
  /// In en, this message translates to:
  /// **'Player Settings'**
  String get playerSettings;

  /// No description provided for @forceTranslatedCaptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show forcibly translated captions'**
  String get forceTranslatedCaptionsTitle;

  /// No description provided for @forceTranslatedCaptionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enabling this option will result in less natural translations, but it will display a 1:1 translation of the currently displayed subtitles, making it easier to understand the content of the displayed subtitles. Enable this when the update timing of the two subtitles is unnatural.'**
  String get forceTranslatedCaptionsDescription;

  /// No description provided for @notificationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was permanently denied. Please enable it in settings.'**
  String get notificationPermissionPermanentlyDenied;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Title for the ruby text display toggle switch in player settings
  ///
  /// In en, this message translates to:
  /// **'Show Ruby Text'**
  String get showRubyText;

  /// Description for the ruby text display toggle switch in player settings
  ///
  /// In en, this message translates to:
  /// **'Displays furigana (reading hints) above kanji characters'**
  String get showRubyTextDescription;

  /// Title for forced update dialog
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredTitle;

  /// Message for forced update dialog
  ///
  /// In en, this message translates to:
  /// **'A new version has been released. You need to update to the latest version to continue using the app.'**
  String get updateRequiredMessage;

  /// Button text for updating now
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNowButton;

  /// Title for optional update dialog
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailableTitle;

  /// Message for optional update dialog
  ///
  /// In en, this message translates to:
  /// **'A new version of Swipelingo is available. We recommend updating to the latest version to experience new features and improvements.'**
  String get updateAvailableMessage;

  /// Button text for updating
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// Button text for updating later
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLaterButton;

  /// No description provided for @videoLearning.
  ///
  /// In en, this message translates to:
  /// **'Video Learning'**
  String get videoLearning;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @youtubeUrlInput.
  ///
  /// In en, this message translates to:
  /// **'YouTube URL Input'**
  String get youtubeUrlInput;

  /// No description provided for @videoSearch.
  ///
  /// In en, this message translates to:
  /// **'Video Search'**
  String get videoSearch;

  /// No description provided for @watchHistory.
  ///
  /// In en, this message translates to:
  /// **'Watch History'**
  String get watchHistory;

  /// No description provided for @savedCards.
  ///
  /// In en, this message translates to:
  /// **'Saved Cards'**
  String get savedCards;

  /// No description provided for @loadingCards.
  ///
  /// In en, this message translates to:
  /// **'Loading cards...'**
  String get loadingCards;

  /// No description provided for @errorOccurredGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurredGeneric;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @letsLearnTogether.
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn together today'**
  String get letsLearnTogether;

  /// No description provided for @learningStatistics.
  ///
  /// In en, this message translates to:
  /// **'Learning Statistics'**
  String get learningStatistics;

  /// No description provided for @consecutiveLearningRecord.
  ///
  /// In en, this message translates to:
  /// **'Consecutive learning record'**
  String get consecutiveLearningRecord;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingData;

  /// No description provided for @errorOccurredWithMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurredWithMessage;

  /// No description provided for @channelErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load channel information'**
  String get channelErrorMessage;

  /// No description provided for @youtubeChannel.
  ///
  /// In en, this message translates to:
  /// **'YouTube Channel'**
  String get youtubeChannel;

  /// No description provided for @addFavoriteChannelsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your favorite YouTube channels to learn efficiently!'**
  String get addFavoriteChannelsMessage;

  /// No description provided for @noVideosInChannelMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no videos in this channel'**
  String get noVideosInChannelMessage;

  /// No description provided for @pleaseWaitForNewVideos.
  ///
  /// In en, this message translates to:
  /// **'Please wait for new videos to be added'**
  String get pleaseWaitForNewVideos;

  /// No description provided for @videosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} videos'**
  String videosCount(int count);

  /// No description provided for @favoriteChannelVideosList.
  ///
  /// In en, this message translates to:
  /// **'Favorite channel videos'**
  String get favoriteChannelVideosList;

  /// No description provided for @favoriteChannels.
  ///
  /// In en, this message translates to:
  /// **'Favorite\nChannels'**
  String get favoriteChannels;

  /// No description provided for @cardList.
  ///
  /// In en, this message translates to:
  /// **'Card\nList'**
  String get cardList;

  /// No description provided for @watchHistoryShort.
  ///
  /// In en, this message translates to:
  /// **'Watch\nHistory'**
  String get watchHistoryShort;

  /// No description provided for @videoLearningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn with YouTube videos!'**
  String get videoLearningSubtitle;

  /// Instruction shown on flashcard front side
  ///
  /// In en, this message translates to:
  /// **'Tap to see answer'**
  String get tapToSeeAnswer;

  /// Instruction shown on flashcard back side
  ///
  /// In en, this message translates to:
  /// **'Swipe to rate'**
  String get swipeToRate;

  /// Label for correct answer button
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctButton;

  /// Label for incorrect answer button
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrectButton;

  /// Label for text-to-speech button
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceButton;

  /// Title for notification settings screen
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Label for enabling notifications
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Description for notification settings
  ///
  /// In en, this message translates to:
  /// **'Get reminders to keep your learning streak going'**
  String get notificationDescription;

  /// Label for notification time section
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notificationTime;

  /// Label for notification types section
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// Label for daily reminder option
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// Description for daily reminder
  ///
  /// In en, this message translates to:
  /// **'Get a daily reminder to study'**
  String get dailyReminderDescription;

  /// Label for review reminder option
  ///
  /// In en, this message translates to:
  /// **'Review Reminder'**
  String get reviewReminder;

  /// Description for review reminder
  ///
  /// In en, this message translates to:
  /// **'Notify when cards are due for review'**
  String get reviewReminderDescription;

  /// Label for milestone notification option
  ///
  /// In en, this message translates to:
  /// **'Milestone Achievements'**
  String get milestoneNotification;

  /// Description for milestone notifications
  ///
  /// In en, this message translates to:
  /// **'Celebrate your learning milestones'**
  String get milestoneDescription;

  /// Label for new content notification option
  ///
  /// In en, this message translates to:
  /// **'New Content'**
  String get newContentNotification;

  /// Description for new content notifications
  ///
  /// In en, this message translates to:
  /// **'Get notified about new recommended videos'**
  String get newContentDescription;

  /// Label for test notification button
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get sendTestNotification;

  /// Message shown when test notification is sent
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get testNotificationSent;

  /// Error message when notification permission is denied
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied. Please enable it in settings.'**
  String get notificationPermissionDenied;

  /// Name for favorites playlist
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesPlaylist;

  /// Name for watch later playlist
  ///
  /// In en, this message translates to:
  /// **'Watch Later'**
  String get watchLaterPlaylist;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
