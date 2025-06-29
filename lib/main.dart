import 'dart:async'; // StreamSubscription のために追加
import 'dart:io' show Platform; // Add this line for Platform.isIOS/Android

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // RevenueCat SDK

import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:swipelingo/l10n/app_localizations.dart';
import 'firebase_options.dart'; // Firebase Options
import 'package:firebase_analytics/firebase_analytics.dart'; // Firebase Analytics をインポート
import 'repositories/firebase_repository.dart'; // FirebaseRepository のインポート
import 'models/firebase_card_model.dart'; // FirebaseCardModel をインポート
import './ui/screens/language_selection_screen.dart';
import './ui/screens/splash_screen.dart'; // SplashScreen のインポート

import 'ui/screens/home_screen.dart'; // 追加
import 'ui/screens/mining_screen.dart'; // 追加
import 'ui/screens/card_check_screen.dart'; // 追加
import 'ui/screens/flashcard_screen.dart'; // 変更: review_screen -> flashcard_screen
import 'ui/screens/video_list_screen.dart'; // 追加
import 'ui/screens/video_flashcard_screen.dart'; // 追加
import 'ui/screens/result_screen.dart'; // 追加: リザルト画面
import 'models/session_result.dart'; // 追加: SessionResult モデル
import 'ui/screens/settings_screen.dart'; // 追加: 設定画面
import 'ui/screens/card_list_screen.dart'; // 追加: カード管理画面
import 'ui/screens/paywall_screen.dart'; // 追加: Paywall画面
import 'ui/screens/video_search_results_screen.dart'; // 追加: 動画検索結果画面
import 'ui/screens/in_app_video_viewer_screen.dart'; // 追加: アプリ内動画プレイヤー画面
import 'ui/screens/reminder_settings_screen.dart'; // 追加: リマインダー設定画面
import 'ui/screens/notification_settings_screen.dart'; // 追加: 通知設定画面
import 'ui/screens/app_review_screen.dart'; // 追加: アプリレビュー画面
import 'ui/screens/favorite_channels_screen.dart'; // 追加: お気に入りチャンネル画面
import 'ui/screens/watch_history_screen.dart'; // 追加: 視聴履歴画面
import 'ui/screens/playlist_list_screen.dart'; // 追加: プレイリスト一覧画面
import 'ui/screens/playlist_detail_screen.dart'; // 追加: プレイリスト詳細画面
import 'ui/screens/channel_videos_screen.dart'; // 追加: チャンネル動画一覧画面
import 'package:app_tracking_transparency/app_tracking_transparency.dart'; // ATTパッケージ
import 'services/version_check_service.dart'; // 追加: Version Check サービス
import 'services/rewarded_ad_service.dart'; // リワード広告サービス
import 'services/notification_service.dart'; // 通知サービス
import 'package:y_player/y_player.dart'; // y_player の初期化に必要

// import 'providers/input_screen_providers.dart'; // 削除 (古い Provider)
import 'package:sentry_flutter/sentry_flutter.dart';
// 削除 (古い Provider)

// GoRouterの設定 (Swipelingo用に変更)
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>(); // 追加
final _router = GoRouter(
  navigatorKey: navigatorKey, // 追加
  initialLocation: '/splash', // SplashScreen を初期ルートに変更
  observers: [
    // FirebaseAnalyticsObserver を追加
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(), // HomeScreen に変更
    ),
    GoRoute(
      path: '/language_selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/mining', // 新しいルート
      builder: (context, state) => const MiningScreen(),
      routes: [
        // ネストされたルートとして検索結果画面を追加
        GoRoute(
          path: 'search_results', // 親パスからの相対パス
          builder: (context, state) {
            final searchQuery = state.extra as String?;
            if (searchQuery != null) {
              return VideoSearchResultsScreen(searchQuery: searchQuery);
            }
            // searchQuery がない場合はエラー表示またはリダイレクト
            // ここではMiningScreenに戻すか、エラー画面を表示する
            // return const MiningScreen(); // もしくはエラー専用画面
            return Scaffold(
              appBar: AppBar(title: const Text('エラー')),
              body: const Center(child: Text('検索クエリが見つかりません。')),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/cards', // 新しいルート
      builder: (context, state) {
        // MiningScreen から渡されたカードリストを取得 (state.extra を想定)
        final List<FirebaseCardModel>? cards =
            state.extra as List<FirebaseCardModel>?; // FirebaseCardModel に変更
        if (cards != null) {
          return CardCheckScreen(generatedCards: cards);
        } else {
          return const CardCheckScreen(generatedCards: []);
        }
      },
    ),
    GoRoute(
      path: '/learn', // 新しいルート
      builder:
          (context, state) =>
              const FlashcardScreen(), // 変更: ReviewScreen -> FlashcardScreen
    ),
    GoRoute(
      // 追加: 動画一覧画面
      path: '/videos',
      builder: (context, state) => const VideoListScreen(),
    ),
    GoRoute(
      // 追加: 動画別学習画面
      path: '/videos/:videoId/learn',
      builder: (context, state) {
        final videoId = state.pathParameters['videoId'];
        if (videoId != null) {
          return VideoFlashcardScreen(videoId: videoId);
        } else {
          // エラーハンドリング: videoId がない場合はホームに戻るなど
          return const Scaffold(body: Center(child: Text('エラー: 動画IDが見つかりません')));
          // または context.go('/');
        }
      },
    ),
    GoRoute(
      // 追加: リザルト画面
      path: '/result',
      builder: (context, state) {
        final result = state.extra as SessionResult?;
        if (result != null) {
          return ResultScreen(sessionResult: result);
        } else {
          // エラーハンドリング: 結果がない場合はホームに戻るなど
          return const Scaffold(
            body: Center(child: Text('エラー: セッション結果が見つかりません')),
          );
          // または context.go('/');
        }
      },
    ),
    GoRoute(
      // 追加: 設定画面
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      // 追加: カード管理画面
      path: '/manage-cards', // 新しいパス
      builder: (context, state) => const CardListScreen(),
    ),
    GoRoute(
      // 追加: Paywall画面
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path:
          '/video-viewer/:videoId', // アプリ内動画プレイヤー画面のルート、videoId をパスパラメータとして受け取る
      builder: (context, state) {
        final videoId = state.pathParameters['videoId'];
        if (videoId != null) {
          // videoId を使って InAppVideoViewerScreen を表示
          // InAppVideoViewerScreen が videoId を直接受け取るように変更されているか、
          // videoId から動画URLを解決するロジックが必要
          return InAppVideoViewerScreen(
            videoUrl: 'https://www.youtube.com/watch?v=$videoId',
          ); // 仮のURL形式
        }
        // videoId がない場合はエラー表示またはリダイレクト
        return Scaffold(
          appBar: AppBar(title: const Text('エラー')),
          body: const Center(child: Text('動画IDが見つかりません。')),
        );
      },
    ),
    GoRoute(
      path: '/reminder-settings',
      builder: (context, state) => const ReminderSettingsScreen(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/app_review',
      builder: (context, state) => AppReviewScreen(), // const を削除
    ),
    GoRoute(
      path: '/favorite-channels',
      builder: (context, state) => const FavoriteChannelsScreen(),
    ),
    GoRoute(
      path: '/watch-history',
      builder: (context, state) => const WatchHistoryScreen(),
    ),
    GoRoute(
      path: '/channel/:channelId/videos',
      builder: (context, state) {
        final channelId = state.pathParameters['channelId'];
        final channelTitle = state.extra as String?;
        if (channelId != null && channelTitle != null) {
          return ChannelVideosScreen(
            channelId: channelId,
            channelTitle: channelTitle,
          );
        }
        // エラーハンドリング: 必要なパラメータがない場合はエラー画面など
        return Scaffold(
          appBar: AppBar(title: const Text('エラー')),
          body: const Center(child: Text('チャンネル情報が見つかりません。')),
        );
      },
    ),
    GoRoute(
      path: '/playlists',
      builder: (context, state) => const PlaylistListScreen(),
    ),
    GoRoute(
      path: '/playlist/:playlistId',
      builder: (context, state) {
        final playlistId = state.pathParameters['playlistId'];
        if (playlistId != null) {
          return PlaylistDetailScreen(playlistId: playlistId);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('エラー')),
          body: const Center(child: Text('プレイリストが見つかりません。')),
        );
      },
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  YPlayerInitializer.ensureInitialized(); // y_player の初期化処理を追加
  await Firebase.initializeApp(
    // Firebaseを初期化
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MobileAds.instance.initialize();
  await dotenv.load(fileName: ".env");

  await _configurePurchases(); // RevenueCat初期化

  // FirebaseRepository のインスタンスを作成し、匿名サインインとユーザードキュメント作成を実行
  final firebaseRepository = FirebaseRepository();
  try {
    final user = await firebaseRepository.signInAnonymously();
    if (user != null) {
      // メソッド名を createUserDocumentIfNotExists に変更
      await firebaseRepository.createUserDocumentIfNotExists(user);
      debugPrint(
        'Firebase anonymous sign-in and user document creation successful.',
      );
    } else {
      debugPrint('Firebase anonymous sign-in failed.');
    }
  } catch (e) {
    debugPrint('Error during Firebase initialization: $e');
  }

  // 元の ProviderScope に戻す (ProviderScope は既に存在)
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://6d7e3e8bc523d1190319ef5db623e656@o4509282410561536.ingest.us.sentry.io/4509282413707264';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner:
        () => runApp(SentryWidget(child: const ProviderScope(child: MyApp()))),
  );
  // TODO: Remove this line after sending the first sample event to sentry.
  await Sentry.captureException(StateError('This is a sample exception.'));
}

// RevenueCat SDK 初期化関数
Future<void> _configurePurchases() async {
  // TODO: デバッグログレベルは本番リリース前に調整してください
  await Purchases.setLogLevel(LogLevel.error);

  PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    // !! ここに実際の RevenueCat Android API キーを設定してください !!
    configuration = PurchasesConfiguration("goog_kAfJPOcNBdpwpacxjDtGDraYhRu");
  } else if (Platform.isIOS) {
    // !! ここに実際の RevenueCat iOS API キーを設定してください !!
    configuration = PurchasesConfiguration("appl_QwrYrxnHnFZabVVVBLKsdnnBuoT");
  } else {
    // Optional: handle other platforms or throw an error
    debugPrint("Unsupported platform for RevenueCat configuration.");
    return;
  }

  try {
    await Purchases.configure(configuration);
    debugPrint("RevenueCat SDK configured successfully."); // 設定成功ログ
  } catch (e) {
    debugPrint("Error configuring RevenueCat SDK: $e"); // エラーログ
  }
}

// ConsumerStatefulWidget に変更
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription? _intentDataStreamSubscription; // 追加
  // String? _initialSharedText; // unused_field: 削除

  @override
  void initState() {
    super.initState();
    _initReceiveSharingIntent(); // 追加
    _requestTrackingPermission(); // ATTダイアログ表示処理を呼び出し
    _checkAppUpdate(); // 追加: アプリケーションのアップデートを確認
    _loadInitialAds(); // リワード広告の初期ロード
    _initializeNotifications(); // 通知サービスの初期化

    // MyApp の initState でリスナーをセットアップ (UncontrolledProviderScope を使わない場合)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   setupVideoListListener(ref);
    // });

    // UncontrolledProviderScope を使わないので、リスナーセットアップ関連のコードは削除
  }

  Future<void> _loadInitialAds() async {
    // アプリ起動時にリワード広告をロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(rewardedAdServiceProvider.notifier).loadAd();
      }
    });
  }

  Future<void> _checkAppUpdate() async {
    // contextが利用可能になるのを待つ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        VersionCheckService().checkForUpdate(); // context を削除
      }
    });
  }

  Future<void> _initializeNotifications() async {
    // 通知サービスの初期化
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.initialize();
      }
    });
  }

  Future<void> _requestTrackingPermission() async {
    // ATTダイアログはiOS 14以上でのみ意味を持つ
    // また、シミュレータでは常に `TrackingStatus.notSupported` を返すことがある
    try {
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint('App Tracking Transparency status: $status');
      // status に応じて何か処理を行う場合はここに追加
      // 例: if (status == TrackingStatus.authorized) { /* 許可された場合の処理 */ }
    } catch (e) {
      debugPrint('Error requesting tracking authorization: $e');
    }
  }

  // _setupListeners メソッドを削除
  // void _setupListeners(WidgetRef ref) { ... }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel(); // 追加
    super.dispose();
  }

  // 共有インテントを処理するメソッドを追加
  Future<void> _initReceiveSharingIntent() async {
    // Try using media methods for text sharing
    // アプリ起動時に共有されたデータを取得
    try {
      final List<SharedMediaFile> initialMedia = // Nullable に変更
          await ReceiveSharingIntent.instance.getInitialMedia();
      // debugPrint('Initial Media: $initialMedia'); // avoid_print: 削除
      if (initialMedia.isNotEmpty) {
        // Null チェック追加
        // debugPrint('Initial Media[0] path: ${initialMedia.first.path}'); // avoid_print: 削除
        // debugPrint('Initial Media[0] type: ${initialMedia.first.type}'); // avoid_print: 削除
        // debugPrint('Initial Media[0] mimeType: ${initialMedia.first.mimeType}'); // avoid_print: 削除
        // Assuming text is shared via the path property of the first media file
        final sharedText = initialMedia.first.path;
        if (sharedText.isNotEmpty) {
          // Check if path is not empty
          // debugPrint('Setting initial shared text: $sharedText'); // avoid_print: 削除
          // setState(() { // _initialSharedText を使わないので不要
          //   _initialSharedText = sharedText;
          // });
          // 少し遅延させて Provider を更新 (Widget build 後に実行するため)
          Future.delayed(const Duration(milliseconds: 100), () {
            // debugPrint('Updating sharedUrlProvider with initial text: $sharedText'); // avoid_print: 削除
            // ref.read(sharedUrlProvider.notifier).state = sharedText; // 削除 (古い Provider)
            // TODO: 共有インテントで受け取った URL を MiningScreen に渡す方法を検討
            // 例: アプリ起動時に /mining に遷移し、URL を引数で渡す
            // context.push('/mining', extra: sharedText);
          });
        }
      }
    } catch (e) {
      // debugPrint("Error getting initial media: $e"); // avoid_print: 削除
    }

    // アプリが起動中に共有されたデータをリッスン
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> media) {
        // debugPrint('Media Stream received: $media'); // avoid_print: 削除
        if (media.isNotEmpty) {
          // debugPrint('Media Stream[0] path: ${media.first.path}'); // avoid_print: 削除
          // debugPrint('Media Stream[0] type: ${media.first.type}'); // avoid_print: 削除
          // debugPrint('Media Stream[0] mimeType: ${media.first.mimeType}'); // avoid_print: 削除
          // Assuming text is shared via the path property of the first media file
          final sharedText = media.first.path;
          if (sharedText.isNotEmpty) {
            // Check if path is not empty
            // debugPrint('Updating sharedUrlProvider with stream text: $sharedText'); // avoid_print: 削除
            // ref.read(sharedUrlProvider.notifier).state = sharedText; // 削除 (古い Provider)
            // 必要であれば特定の画面に遷移させるなどの処理を追加
            // 例: _router.go('/mining', extra: sharedText);
          }
        }
      },
      onError: (err) {
        // debugPrint("getMediaStream error: $err"); // avoid_print: 削除
        // エラーハンドリング
      },
    );
  }

  // ニューモフィズムのテーマデータ (変更なし)
  static const neumorphicLightTheme = NeumorphicThemeData(
    baseColor: Color(0xFFE0E5EC),
    lightSource: LightSource.topLeft,
    depth: 8,
    intensity: 0.7,
    accentColor: Colors.deepPurple,
    variantColor: Colors.black38,
    textTheme: TextTheme(
      // bodyLarge: TextStyle(color: Colors.black87),
      // bodyMedium: TextStyle(color: Colors.black54),
    ),
  );

  static const neumorphicDarkTheme = NeumorphicThemeData(
    baseColor: Color(0xFF3E3E3E),
    lightSource: LightSource.topLeft,
    depth: 4,
    intensity: 0.5,
    accentColor: Colors.deepPurpleAccent,
    variantColor: Colors.white70,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Swipelingo',
      themeMode: ThemeMode.light,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: neumorphicLightTheme.baseColor, // 背景色を合わせる
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: neumorphicDarkTheme.baseColor, // 背景色を合わせる
      ),
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,

      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      builder: (context, child) {
        return NeumorphicTheme(
          themeMode: ThemeMode.light,
          theme: neumorphicLightTheme, // 直接指定
          darkTheme: neumorphicDarkTheme, // 直接指定
          child: child ?? const SizedBox.shrink(), // child が null でないことを保証
        );
      },
    );
  }
}
