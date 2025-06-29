// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get helloWorld => 'こんにちは世界！';

  @override
  String get getMore => '獲得';

  @override
  String get learningMenu => '学習メニュー';

  @override
  String get startLearning => '学習開始';

  @override
  String dueCardsWaitingForReview(int count) {
    return '$count 件のカードが復習待ち';
  }

  @override
  String get noScheduledCardsRandomMode => '復習予定のカードがないため、ランダムに出題します。';

  @override
  String get countRetrievalError => '件数取得エラー';

  @override
  String get createCardsFromVideo => '動画からカードを生成';

  @override
  String get learnNewWordsFromYouTube => 'YouTubeから新しい単語を学ぼう';

  @override
  String get cardDeckList => 'カードデッキ一覧';

  @override
  String get checkSavedVideoCards => '保存された動画カードを確認';

  @override
  String get learningStats => '学習の統計';

  @override
  String learningStreakDays(int count) {
    return '$count 日連続学習中';
  }

  @override
  String get activityLast105Days => '過去105日間のアクティビティ';

  @override
  String get activityRetrievalError => 'アクティビティ取得エラー';

  @override
  String totalCardsLearned(int count) {
    return '総学習カード数: $count';
  }

  @override
  String get cardCountRetrievalError => 'カード数取得エラー';

  @override
  String get upgradeToSwipelingoPro => 'Swipelingo Proにアップグレード';

  @override
  String get unlimitedGemsNoAdsAccessAllFeatures => '無制限のジェム、広告なし、すべての機能にアクセス';

  @override
  String get review => '復習';

  @override
  String couldNotLaunchUrl(String urlString) {
    return 'URLを開けませんでした: $urlString';
  }

  @override
  String get swipelingoPro => 'Swipelingo Pro';

  @override
  String get noOfferingsAvailable =>
      '現在利用可能なオファリングがありません。ストアの設定を確認するか、時間をおいて再度お試しください。';

  @override
  String noPackagesAvailableInOffering(String offeringIdentifier) {
    return '現在利用可能な購入プランがありません。\\n(オファリング 「$offeringIdentifier」 にはプランが含まれていませんでした)';
  }

  @override
  String get premiumFeatures => 'プレミアム特典';

  @override
  String get unlimitedGems => '無制限のジェム';

  @override
  String get unlimitedTranslationSubtitles => '翻訳字幕の表示回数制限なし';

  @override
  String get adsFree => '広告非表示';

  @override
  String get concentrateOnLearning => '学習に集中できる環境';

  @override
  String get unlimitedCardCreation => '無制限のカード生成';

  @override
  String get learnAsMuchAsYouWantDaily => '毎日好きなだけ学習を進められます';

  @override
  String get premiumSupport => 'プレミアムサポート';

  @override
  String get prioritySupport => '優先的なサポートを受けられます';

  @override
  String get selectBestPlanForYou => 'あなたに最適なプランを選択';

  @override
  String get purchaseTermsDescription =>
      '購入はApple IDアカウントに請求されます。現在の期間が終了する少なくとも24時間前に自動更新をオフにしない限り、サブスクリプションは自動的に更新されます。アカウント設定でサブスクリプションの管理や自動更新のオフが可能です。\\n\\n';

  @override
  String get termsOfUseEULA => '利用規約 (EULA)';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get restoringPurchases => '購入情報を復元しています...';

  @override
  String get purchasesRestored => '購入情報が復元されました。';

  @override
  String restorePurchasesFailed(String error) {
    return '購入情報の復元に失敗しました: $error';
  }

  @override
  String get restorePurchasesButton => '購入を復元する';

  @override
  String get loadingPlans => 'プラン情報を読み込み中...';

  @override
  String get failedToLoadPlans => 'プランの読み込みに失敗しました。';

  @override
  String errorCode(String errorCode) {
    return 'エラーコード: $errorCode';
  }

  @override
  String details(String details) {
    return '詳細: $details';
  }

  @override
  String get retry => '再試行';

  @override
  String get weeklyPlan => '週間プラン';

  @override
  String get daysFreeTrial => '3日間の無料体験付き';

  @override
  String get monthlyPlan => '月間プラン';

  @override
  String get annualPlan => '年間プラン';

  @override
  String discountFromMonthly(String discountPercentage) {
    return '月額より$discountPercentage%オフ';
  }

  @override
  String get recommended => 'おすすめ';

  @override
  String get perWeek => '週あたり';

  @override
  String get perMonth => '月あたり';

  @override
  String get startNow => '今すぐ始める';

  @override
  String get selectButton => '選択する';

  @override
  String get startingPurchaseProcess => '購入処理を開始します...';

  @override
  String get purchaseCompletedThankYou => '購入が完了しました！ありがとうございます。';

  @override
  String get purchaseCompletedPlanNotActive =>
      '購入は完了しましたが、プランが有効になりませんでした。サポートにお問い合わせください。';

  @override
  String get purchaseCancelled => '購入がキャンセルされました。';

  @override
  String get purchasePending => '購入処理が保留中です。ストアからの承認をお待ちください。';

  @override
  String purchaseFailed(String errorMessage) {
    return '購入に失敗しました: $errorMessage';
  }

  @override
  String unexpectedErrorOccurred(String error) {
    return '予期せぬエラーが発生しました: $error';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get yourInvitationCode => 'あなたの招待コード';

  @override
  String get copyButton => 'コピー';

  @override
  String get invitationCodeCopied => '招待コードをコピーしました';

  @override
  String get invitationCodeAlreadyUsed => '招待コードは既に使用済みです';

  @override
  String get enterInvitationCode => '招待コードを入力';

  @override
  String get invitationCodeHint => '招待コード';

  @override
  String get applyButton => '適用する';

  @override
  String errorDialogMessage(String err) {
    return 'エラー: $err';
  }

  @override
  String get rateTheApp => 'アプリを評価';

  @override
  String get reportBugsOrRequests => '不具合・要望を報告';

  @override
  String get manageCards => 'カード管理';

  @override
  String get premiumPlan => 'プレミアムプラン';

  @override
  String get ankiExportCsv => 'Ankiエクスポート (.csv)';

  @override
  String get settingsReminderSettings => 'リマインダー設定';

  @override
  String get pleaseRateTheApp => 'アプリを評価してください';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get submitButton => '送信';

  @override
  String get reviewFeatureNotAvailable => 'レビュー機能を利用できません。';

  @override
  String get premiumFeatureOnly => 'この機能はプレミアムプランのユーザーのみ利用可能です。';

  @override
  String get startingAnkiExport => 'Ankiエクスポート処理を開始します...';

  @override
  String get loginRequiredForExport => 'エクスポートにはログインが必要です。';

  @override
  String get noCardsToExport => 'エクスポートするカードがありません。';

  @override
  String get ankiExportRequested =>
      'Ankiファイルのエクスポートが要求されました。共有メニューからAnkiアプリを選択してください。';

  @override
  String get ankiExportFailed => 'Ankiファイルのエクスポートに失敗しました。';

  @override
  String errorDuringAnkiExport(String e) {
    return 'Ankiエクスポート中にエラーが発生しました: $e';
  }

  @override
  String get restoreCancelled => '復元処理がキャンセルされました。';

  @override
  String get networkErrorPleaseCheckConnection =>
      'ネットワークエラーが発生しました。接続を確認してください。';

  @override
  String get storeCommunicationError => 'ストアとの通信に問題が発生しました。時間をおいて再度お試しください。';

  @override
  String get userAuthenticationRequired => 'ユーザー認証が必要です。';

  @override
  String get pleaseEnterInvitationCode => '招待コードを入力してください。';

  @override
  String get selectVideo => '動画選択';

  @override
  String get enterVideoUrlWithEnglishSubtitles => '英語字幕がある動画のURLを入力';

  @override
  String get youtubeVideoUrl => 'YouTube動画のURL';

  @override
  String get pasteFromClipboard => 'クリップボードから貼り付け';

  @override
  String get recommendedVideos => 'おすすめ動画';

  @override
  String get searchVideosOnYouTube => '動画を検索 (YouTube)';

  @override
  String get generating => '生成中...';

  @override
  String get generateFlashcards => 'フラッシュカードを生成';

  @override
  String get watchVideo => '動画を見る';

  @override
  String get generatingCards => 'カード生成中...';

  @override
  String processingCardCount(int count) {
    return '処理中のカード: $count';
  }

  @override
  String get exampleSearchQuery => '例: \"English conversation practice\"';

  @override
  String searchResultsCount(int count) {
    return '検索結果 ($count件)';
  }

  @override
  String get fetchingVideoInfoCaptions => '動画情報と英語字幕を取得中...';

  @override
  String get requestingCardGenerationJa => 'LLMにカード生成をリクエスト中 (JA)...';

  @override
  String get processingGeneratedCards => '生成されたカードを処理中...';

  @override
  String get deleteCurrentCardTooltip => '現在のカードを削除';

  @override
  String get deleteCardTitle => 'カードの削除';

  @override
  String confirmDeleteCardMessage(String cardFront) {
    return '「$cardFront」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get deleteCardConfirmButtonLabel => '削除';

  @override
  String get cardDeletedSuccessMessage => 'カードを削除しました。';

  @override
  String cardDeletionFailedMessage(String error) {
    return 'カードの削除に失敗しました: $error';
  }

  @override
  String get noCardsToReviewMessage => 'レビューするカードはありません。';

  @override
  String get createCardsFromVideoButtonLabel => '動画からカードを作成';

  @override
  String get backToHomeButtonLabel => 'ホームに戻る';

  @override
  String get rateAppTitle => 'アプリを評価';

  @override
  String get thankYouForUsingSwipelingo => 'Swipelingoをご利用いただきありがとうございます！';

  @override
  String get pleaseRateOurApp =>
      'もしよろしければ、アプリの評価にご協力いただけると嬉しいです。皆様からの温かいレビューが、私たちの開発の大きな励みになります！';

  @override
  String get howIsYourExperience => 'アプリの使い心地はいかがですか？';

  @override
  String get writeReviewButton => 'レビューを書く';

  @override
  String get laterButton => '後で';

  @override
  String get learningDecksTitle => '学習デッキ一覧';

  @override
  String get noLearningDecks => '学習デッキがありません。';

  @override
  String get createDeckFromYouTube => 'YouTube動画から新しいデッキを作成しましょう。';

  @override
  String get createDeckFromVideoButton => '動画からデッキを作成';

  @override
  String get deleteDeckTooltip => 'デッキを削除';

  @override
  String get deleteDeckDialogTitle => 'デッキの削除';

  @override
  String deleteDeckDialogContent(String videoTitle) {
    return '「$videoTitle」と関連する全てのカードを削除しますか？この操作は元に戻せません。';
  }

  @override
  String get deckDeletedSuccessfully => 'デッキを削除しました。';

  @override
  String deckDeletionFailed(String error) {
    return 'デッキの削除に失敗しました: $error';
  }

  @override
  String errorOccurred(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get retryButton => '再試行';

  @override
  String get cardListTitle => 'カード管理';

  @override
  String get noCardsFound => 'カードがありません。';

  @override
  String get generateNewCardsFromVideos => '動画から新しいカードを生成しましょう。';

  @override
  String get generateFromVideosButton => '動画から生成する';

  @override
  String get deleteCardTooltip => 'カードを削除';

  @override
  String get deleteCardDialogTitle => 'カードの削除';

  @override
  String deleteCardDialogContent(String cardFront) {
    return '「$cardFront」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get cardDeletedSuccess => 'カードを削除しました。';

  @override
  String cardDeletionFailed(String error) {
    return 'カードの削除に失敗しました: $error';
  }

  @override
  String get sessionResults => 'セッション結果';

  @override
  String accuracyRate(Object accuracyPercentage) {
    return '正答率: $accuracyPercentage%';
  }

  @override
  String correctIncorrectCount(Object correctCount, Object incorrectCount) {
    return '正解: $correctCount / 不正解: $incorrectCount';
  }

  @override
  String get reviewedCards => 'レビューしたカード:';

  @override
  String get backToHome => 'ホームに戻る';

  @override
  String searchResultsTitle(String searchQuery) {
    return '検索結果: \"$searchQuery\"';
  }

  @override
  String errorPrefix(String errorMessage) {
    return 'エラー: $errorMessage';
  }

  @override
  String get noVideosFoundMessage => '英語字幕付きの動画は見つかりませんでした。';

  @override
  String get playVideoInAppTooltip => '動画をアプリ内で再生';

  @override
  String get confirmDialogTitle => '確認';

  @override
  String confirmGenerateFlashcardsMessage(String videoTitle) {
    return '「$videoTitle」でフラッシュカードを生成しますか？';
  }

  @override
  String get generateButtonLabel => '生成する';

  @override
  String get gemConsumptionConfirmation => '翻訳字幕を有効にするにはジェムが1つ消費されます。よろしいですか？';

  @override
  String get noButton => 'いいえ';

  @override
  String get yesButton => 'はい';

  @override
  String get invalidYouTubeUrl => '無効なYouTube URLです。';

  @override
  String get processingComplete => '処理完了！';

  @override
  String get videoPlayerTitle => '動画プレイヤー';

  @override
  String get videoLoadFailed => '動画の読み込みに失敗しました。';

  @override
  String get generatingFlashcards => 'フラッシュカード生成中...';

  @override
  String get captionLoadFailed => '字幕の読み込みに失敗しました。';

  @override
  String get translating => '翻訳中...';

  @override
  String get waitingForTranslation => '翻訳待機中...';

  @override
  String get showTranslatedSubtitles => '翻訳字幕を表示する';

  @override
  String get noVideoInfoOrCaptions => '動画情報または字幕がありません。';

  @override
  String get videoTitleUnknown => '動画タイトル不明';

  @override
  String get failedToGetVideoTitle => '動画タイトルを取得できませんでした。再度お試しください。';

  @override
  String startingFlashcardGenerationWithIdAndTitle(
    String videoId,
    String title,
  ) {
    return 'フラッシュカード生成処理を開始します。 Video ID: $videoId, Title: $title';
  }

  @override
  String missingInfoForFlashcardGeneration(
    String videoId,
    String captionsEmpty,
    String title,
  ) {
    return 'フラッシュカード生成に必要な情報が不足しています。(videoId: $videoId, captions_empty: $captionsEmpty, title: $title)';
  }

  @override
  String get missingInfoReloadVideo =>
      'カード生成に必要な情報が不足しています。動画を再読み込みするか、しばらく待ってから再度お試しください。';

  @override
  String get generateFlashcardsFromThisVideoButton => 'AIでおまかせカード生成';

  @override
  String originalTextWithLanguage(String language) {
    return '原文 ($language):';
  }

  @override
  String translationWithLanguage(String language) {
    return '翻訳 ($language):';
  }

  @override
  String selectConversationsToLearn(int selectedCount, int totalCount) {
    return '覚えたい会話を選択 ($selectedCount/$totalCount)';
  }

  @override
  String get selectAll => 'すべて選択';

  @override
  String get deselectAll => 'すべて解除';

  @override
  String get preview => 'プレビュー';

  @override
  String get aiGenerationNote =>
      '注: AI生成のため、まれに両方の言語が同じになっている場合があります。その場合は別の動画でお試し下さい。';

  @override
  String get saveSelectedCardsTooltip => '選択したカードを保存';

  @override
  String get confirmTitle => '確認';

  @override
  String get confirmCancelWithoutSavingMessage => 'カードを保存せず中止しますか？';

  @override
  String cardsSavedSuccessfullySnackbar(int count) {
    return '$count 枚のカードを保存しました！';
  }

  @override
  String cardSaveErrorSnackbar(String error) {
    return 'カード保存エラー: $error';
  }

  @override
  String get notificationPermissionRequired => '通知の許可が必要です。アプリ設定から通知を許可してください。';

  @override
  String get learningTimeNotificationTitle => '学習の時間です！';

  @override
  String get learningTimeNotificationBody => '今日もSwipelingoで新しい単語を覚えましょう🚀';

  @override
  String get dailyLearningReminderChannelName => 'デイリー学習リマインダー';

  @override
  String get dailyLearningReminderChannelDescription => '毎日の学習を促すリマインダーです。';

  @override
  String get reminderSettingsTitle => 'リマインダー設定';

  @override
  String get maximizeLearningEffectTitle => '毎日の学習で効果を最大化しましょう！';

  @override
  String get maximizeLearningEffectBody =>
      'Swipelingoは忘却曲線に基づいた最適なタイミングで復習を促します。リマインダーを設定して、学習習慣を身につけましょう。';

  @override
  String get whenToRemind => 'いつリマインドしますか？';

  @override
  String reminderSetSuccess(String time) {
    return '$timeにリマインダーを設定しました！';
  }

  @override
  String get setReminderButton => '設定する';

  @override
  String get setReminderLaterButton => '後で設定する';

  @override
  String get videoFlashcardsTitle => '動画フラッシュカード';

  @override
  String get deleteCurrentVideoCardTooltip => '現在のカードを削除';

  @override
  String get deleteVideoCardDialogTitle => 'カードの削除';

  @override
  String deleteVideoCardDialogContent(String cardFront) {
    return '「$cardFront」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get videoFlashcardCancelButtonLabel => 'キャンセル';

  @override
  String get videoFlashcardDeleteButtonLabel => '削除';

  @override
  String get videoCardDeletedSuccessfullySnackbar => 'カードを削除しました。';

  @override
  String videoCardDeletionFailedSnackbar(String error) {
    return 'カードの削除に失敗しました: $error';
  }

  @override
  String get noCardsFoundForThisVideo => 'この動画のカードが見つかりません。';

  @override
  String get backToVideoListButtonLabel => '動画一覧に戻る';

  @override
  String get deleteButton => '削除';

  @override
  String get wordMeaningPopupTitle => '単語の意味';

  @override
  String get closeButton => '閉じる';

  @override
  String get captionTapGuide => '字幕の単語をタップすると意味が表示されます。';

  @override
  String get createCardFromSubtitleButton => '字幕からカード作成';

  @override
  String get failedToGetVideoId => '動画IDの取得に失敗しました。';

  @override
  String get noCaptionSelected => '字幕が選択されていません。';

  @override
  String get defaultCardBackText => 'ここに翻訳やメモを入力';

  @override
  String get userNotAuthenticated => 'ユーザーが認証されていません。';

  @override
  String get cardCreatedSuccessfully => 'カードを作成しました！';

  @override
  String get failedToCreateCard => 'カードの作成に失敗しました。';

  @override
  String get createCardConfirmationTitle => 'カード作成確認';

  @override
  String get createCardConfirmationMessage => '以下の内容でカードを作成しますか？';

  @override
  String get createButton => '作成';

  @override
  String get cancelButtonDialog => 'キャンセル';

  @override
  String get translatingText => '翻訳中...';

  @override
  String get translationFailedFallbackText => '翻訳に失敗しました。後ほど手動で編集してください。';

  @override
  String get relatedVideosTitle => '関連動画';

  @override
  String get noRelatedVideos => '関連動画は見つかりませんでした。';

  @override
  String get failedToLoadRelatedVideos => '関連動画の読み込みに失敗しました。';

  @override
  String get learningTab => '学習';

  @override
  String get videoTab => '動画';

  @override
  String get otherVideosInThisChannel => 'このチャンネルの他の動画';

  @override
  String get addToFavorites => 'お気に入りに追加';

  @override
  String get removeFromFavorites => 'お気に入りから削除';

  @override
  String get favoriteChannelsScreenTitle => 'お気に入りチャンネル';

  @override
  String get noFavoriteChannelsYet => 'お気に入りチャンネルはまだありません。';

  @override
  String get watchHistoryScreenTitle => '視聴履歴';

  @override
  String get noWatchHistoryFound => '視聴履歴がありません。';

  @override
  String get reviewRequestTitle => 'Swipelingoはいかがですか？';

  @override
  String get reviewRequestMessage => 'アプリの評価をお願いします。あなたのフィードバックが改善に役立ちます。';

  @override
  String get rateNow => '今すぐ評価';

  @override
  String get remindLater => '後で通知';

  @override
  String get noThanks => 'いいえ';

  @override
  String get loadingChannel => 'チャンネル情報を読み込み中...';

  @override
  String errorLoadingChannel(String channelId) {
    return 'チャンネル情報の読み込みエラー: $channelId';
  }

  @override
  String channelNotFound(String channelId) {
    return 'チャンネルが見つかりません: $channelId';
  }

  @override
  String get noRecommendedVideosFound => '現在おすすめの動画はありません。時間をおいて再度ご確認ください。';

  @override
  String get noVideosInChannel => 'このチャンネルにはまだ動画がありません。';

  @override
  String get languageSelectionScreenTitle => '学習言語の選択';

  @override
  String get selectYourNativeLanguage => 'あなたの母語を選択してください:';

  @override
  String get selectLanguageToLearn => '学習したい言語を選択してください:';

  @override
  String get selectNativeLanguageHint => '母語を選択';

  @override
  String get selectLanguageToLearnHint => '学習言語を選択';

  @override
  String get confirmAndStartButton => '決定して開始';

  @override
  String get pleaseSelectLanguages => '両方の言語を選択してください。';

  @override
  String get nativeAndTargetMustBeDifferent => '母語と学習言語は異なるものを選択してください。';

  @override
  String get settingsSavedSuccessfully => '設定を保存しました。';

  @override
  String get languageSettingsSectionTitle => '言語設定';

  @override
  String get saveSettingsButton => '設定を保存';

  @override
  String get pleaseSelectBothLanguages => '母語と学習言語の両方を選択してください。';

  @override
  String errorSavingSettings(String error) {
    return '設定の保存中にエラーが発生しました: $error';
  }

  @override
  String get errorMessageAnErrorOccurred => 'エラーが発生しました。もう一度お試しください。';

  @override
  String get enterVideoUrlWithJapaneseSubtitles => '日本語字幕がある動画のURLを入力';

  @override
  String get searchVideosOnYouTubeWithJapaneseSubtitles =>
      '日本語字幕で動画を検索 (YouTube)';

  @override
  String get exampleSearchQueryJapanese => '例: \"日本語会話練習\"';

  @override
  String get languageNameEnglish => '英語';

  @override
  String get languageNameJapanese => '日本語';

  @override
  String wordLabelWithLanguage(String language) {
    return '単語 ($language)';
  }

  @override
  String meaningLabelWithLanguage(String language) {
    return '意味 ($language)';
  }

  @override
  String frontLabel(String languageCode) {
    return '表面 ($languageCode)';
  }

  @override
  String backLabel(String languageCode) {
    return '裏面 ($languageCode)';
  }

  @override
  String get translationWillBeGenerated => '翻訳が生成されます';

  @override
  String get screenshotLabel => 'スクリーンショット';

  @override
  String get noScreenshotAvailable => 'スクリーンショットなし';

  @override
  String get cardDetailsTitle => 'カード詳細';

  @override
  String get cardFrontLabel => '表面';

  @override
  String get cardBackLabel => '裏面';

  @override
  String get cardScreenshotLabel => 'スクリーンショット';

  @override
  String get watchVideoSegmentButton => '動画で確認する';

  @override
  String get closeButtonLabel => '閉じる';

  @override
  String get followUs => 'フォローする';

  @override
  String get shareButton => '共有';

  @override
  String shareInvitationMessage(
    String invitationCode,
    String downloadPrompt,
    String storeUrl,
  ) {
    return 'Youtubeで英語を学ぼう！招待コード：$invitationCode $downloadPrompt $storeUrl #Swipelingo';
  }

  @override
  String get downloadAppPrompt => 'ダウンロードはこちら:';

  @override
  String get translationFailed => '翻訳に失敗しました。元のテキストで検索します。';

  @override
  String get searchWithTranslation => '翻訳して検索';

  @override
  String get aiExplainButton => 'AI解説';

  @override
  String aiExplanationModalTitle(String word) {
    return '「$word」のAI解説';
  }

  @override
  String get aiExplanationError => 'AI解説の取得に失敗しました。時間をおいて再度お試しください。';

  @override
  String get playerSettings => 'プレイヤー設定';

  @override
  String get forceTranslatedCaptionsTitle => '強制的な翻訳字幕を表示する';

  @override
  String get forceTranslatedCaptionsDescription =>
      'このオプションを有効にすると翻訳の自然さは失われますが、現在表示されている字幕と1:1の翻訳字幕が表示されるため、表示されている字幕の内容が理解しやすくなります。2つの字幕の更新タイミングが不自然な場合などに有効にしてください。';

  @override
  String get notificationPermissionPermanentlyDenied =>
      '通知の許可が永続的に拒否されました。設定から有効にしてください。';

  @override
  String get openSettings => '設定を開く';

  @override
  String get showRubyText => 'ルビ表示';

  @override
  String get showRubyTextDescription => '漢字にふりがなを表示します';

  @override
  String get updateRequiredTitle => 'アップデートが必要です';

  @override
  String get updateRequiredMessage =>
      '新バージョンがリリースされました。アプリを継続して使用するには最新版へのアップデートが必要です。';

  @override
  String get updateNowButton => '今すぐアップデート';

  @override
  String get updateAvailableTitle => 'アップデートのお知らせ';

  @override
  String get updateAvailableMessage =>
      'SwipeLingoの新バージョンが利用可能です。新機能や改善点を体験するために最新版へのアップデートをおすすめします。';

  @override
  String get updateButton => 'アップデートする';

  @override
  String get updateLaterButton => 'あとで';

  @override
  String get videoLearning => '動画学習';

  @override
  String get quickActions => 'クイックアクション';

  @override
  String get youtubeUrlInput => 'YouTube URL入力';

  @override
  String get videoSearch => '動画検索';

  @override
  String get watchHistory => '視聴履歴';

  @override
  String get savedCards => '保存されたカード';

  @override
  String get loadingCards => 'カードを読み込み中...';

  @override
  String get errorOccurredGeneric => 'エラーが発生しました';

  @override
  String get welcomeBack => 'おかえりなさい！';

  @override
  String get letsLearnTogether => '今日も一緒に学習しましょう';

  @override
  String get learningStatistics => '学習統計';

  @override
  String get consecutiveLearningRecord => '連続学習記録';

  @override
  String get loadingData => '読み込み中...';

  @override
  String get errorOccurredWithMessage => 'エラーが発生しました';

  @override
  String get channelErrorMessage => 'チャンネル情報を読み込めませんでした';

  @override
  String get youtubeChannel => 'YouTube チャンネル';

  @override
  String get addFavoriteChannelsMessage =>
      'お気に入りのYouTubeチャンネルを追加して\n効率的に学習しましょう！';

  @override
  String get noVideosInChannelMessage => 'このチャンネルには動画がありません';

  @override
  String get pleaseWaitForNewVideos => '新しい動画が追加されるまでお待ちください';

  @override
  String videosCount(int count) {
    return '$count本の動画';
  }

  @override
  String get favoriteChannelVideosList => 'お気に入りチャンネルの動画一覧';

  @override
  String get favoriteChannels => 'お気に入り\nチャンネル';

  @override
  String get cardList => 'カード\n一覧';

  @override
  String get watchHistoryShort => '視聴\n履歴';

  @override
  String get videoLearningSubtitle => 'YouTubeで楽しく学習しよう';

  @override
  String get tapToSeeAnswer => 'タップで答えを見る';

  @override
  String get swipeToRate => 'スワイプして評価する';

  @override
  String get correctButton => '正解';

  @override
  String get incorrectButton => '不正解';

  @override
  String get voiceButton => '音声';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get enableNotifications => '通知を有効にする';

  @override
  String get notificationDescription => '学習習慣を維持するためのリマインダーを受け取る';

  @override
  String get notificationTime => '通知時刻';

  @override
  String get notificationTypes => '通知の種類';

  @override
  String get dailyReminder => 'デイリーリマインダー';

  @override
  String get dailyReminderDescription => '毎日の学習リマインダーを受け取る';

  @override
  String get reviewReminder => '復習リマインダー';

  @override
  String get reviewReminderDescription => '復習が必要なカードがある時に通知';

  @override
  String get milestoneNotification => 'マイルストーン達成';

  @override
  String get milestoneDescription => '学習の節目をお祝いする通知';

  @override
  String get newContentNotification => '新着コンテンツ';

  @override
  String get newContentDescription => '新しいおすすめ動画の通知を受け取る';

  @override
  String get sendTestNotification => 'テスト通知を送信';

  @override
  String get testNotificationSent => 'テスト通知を送信しました！';

  @override
  String get notificationPermissionDenied => '通知の許可が拒否されました。設定から有効にしてください。';

  @override
  String get favoritesPlaylist => 'お気に入り';

  @override
  String get watchLaterPlaylist => '後で見る';
}
