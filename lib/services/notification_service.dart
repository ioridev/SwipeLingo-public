import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../repositories/firebase_repository.dart';
import '../main.dart';
import '../providers/repository_providers.dart';

class NotificationService {
  final FirebaseRepository _firebaseRepository;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  NotificationService(this._firebaseRepository);
  
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _notificationTimeKey = 'notification_time';
  
  // 初期化
  Future<void> initialize() async {
    // Firebase Messagingの初期化
    await _initializeFirebaseMessaging();
    
    // ローカル通知の初期化
    await _initializeLocalNotifications();
    
    // FCMトークンの取得と保存
    await _updateFCMToken();
    
    // トークンリフレッシュ時の処理を設定
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      _updateFCMTokenWithValue(newToken);
    });
    
    // iOS: APNSトークンが後から利用可能になった場合の処理
    if (Platform.isIOS) {
      // 定期的にAPNSトークンをチェック（初回起動時対応）
      Timer.periodic(const Duration(seconds: 30), (timer) async {
        final userId = _firebaseRepository.getCurrentUserId();
        if (userId != null) {
          final user = await _firebaseRepository.getUser(userId);
          if (user?.fcmToken == null) {
            // FCMトークンがまだ保存されていない場合、再試行
            debugPrint('Retrying FCM token acquisition...');
            await _updateFCMToken();
          } else {
            // トークンが保存されたらタイマーを停止
            timer.cancel();
          }
        }
      });
    }
    
    // フォアグラウンドでのメッセージ受信設定
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // バックグラウンドメッセージハンドラーの設定
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  // Firebase Messagingの初期化
  Future<void> _initializeFirebaseMessaging() async {
    // iOS向けの通知許可リクエスト
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      // iOSでAPNSトークンの自動登録を有効にする
      await _firebaseMessaging.setAutoInitEnabled(true);
    }
    
    // Android向けの通知チャンネル設定
    if (Platform.isAndroid) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
  
  // ローカル通知の初期化
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );
    
    // Android通知チャンネルの作成
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }
  
  // Android通知チャンネルの作成
  Future<void> _createNotificationChannels() async {
    const dailyChannel = AndroidNotificationChannel(
      'daily_reminder',
      'デイリーリマインダー',
      description: '毎日の学習リマインダー通知',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    const reviewChannel = AndroidNotificationChannel(
      'review_reminder',
      '復習リマインダー',
      description: 'カードの復習時期をお知らせする通知',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    
    final plugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    await plugin?.createNotificationChannel(dailyChannel);
    await plugin?.createNotificationChannel(reviewChannel);
  }
  
  // FCMトークンの更新
  Future<void> _updateFCMToken() async {
    try {
      // iOSの場合、まずAPNSトークンの状態を確認
      if (Platform.isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNS token not available yet. This is normal for simulators or first launch.');
          // シミュレーターや初回起動時はAPNSトークンが取得できないことがある
          // 実機では通知権限の許可後に取得可能になる
          // ここではエラーとせず、後でトークンリフレッシュ時に再試行される
        } else {
          debugPrint('APNS token available: ${apnsToken.substring(0, 10)}...');
        }
      }
      
      // FCMトークンを取得（APNSトークンがなくても試行）
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM token obtained successfully');
        await _updateFCMTokenWithValue(token);
      } else {
        debugPrint('FCM token is null. Will retry on token refresh.');
      }
    } catch (e) {
      // エラーが発生してもアプリの動作は継続
      debugPrint('Failed to get FCM token: $e');
      if (e.toString().contains('apns-token-not-set')) {
        debugPrint('Note: APNS token is required for FCM on iOS. Ensure you are running on a real device with proper provisioning.');
      }
    }
  }
  
  // FCMトークンを値で更新
  Future<void> _updateFCMTokenWithValue(String token) async {
    try {
      final userId = _firebaseRepository.getCurrentUserId();
      if (userId != null) {
        await _firebaseRepository.updateUserFCMToken(userId, token);
      }
      debugPrint('FCM Token saved: $token');
    } catch (e) {
      debugPrint('Failed to update FCM token: $e');
    }
  }
  
  // フォアグラウンドでのメッセージ処理
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'SwipeLingo',
        body: notification.body ?? '',
        payload: data['deepLink'],
        channelId: data['type'] == 'review' ? 'review_reminder' : 'daily_reminder',
      );
    }
  }
  
  // ローカル通知の表示
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'daily_reminder',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'review_reminder' ? '復習リマインダー' : 'デイリーリマインダー',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // 通知タップ時の処理
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    
    // main.dartのnavigatorKeyを使用してNavigatorStateにアクセス
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      // GoRouterを使用してディープリンクで画面遷移
      context.go(payload);
    }
  }
  
  // 通知設定の取得
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }
  
  // 通知設定の保存
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
    
    if (!enabled) {
      // 通知を無効化した場合、バッジをクリア
      await _localNotifications.cancelAll();
      if (Platform.isIOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(badge: false);
      }
    }
  }
  
  // 通知時間の取得
  Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_notificationTimeKey) ?? '20:00';
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
  
  // 通知時間の保存
  Future<void> setNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_notificationTimeKey, timeString);
    
    // FirebaseRepositoryを通じて通知時間を更新
    try {
      final userId = _firebaseRepository.getCurrentUserId();
      if (userId != null) {
        await _firebaseRepository.updateUserDocument(userId, {
          'settings.preferredNotificationTime': timeString,
        });
      }
    } catch (e) {
      debugPrint('Failed to update notification time in Firebase: $e');
    }
  }
  
  // 通知権限の確認
  Future<bool> checkNotificationPermission() async {
    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } else {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
  }
  
  // 通知権限のリクエスト
  Future<bool> requestNotificationPermission() async {
    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } else {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
  }
}

// バックグラウンドメッセージハンドラー（トップレベル関数である必要がある）
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // バックグラウンドでの処理
  debugPrint('Handling background message: ${message.messageId}');
}

// NotificationServiceプロバイダー
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firebaseRepository = ref.watch(firebaseRepositoryProvider);
  return NotificationService(firebaseRepository);
});