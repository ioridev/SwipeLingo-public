import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart'; // permission_handler をインポート

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  TimeOfDay? _selectedTime; // 選択された時間を保持

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones(); // タイムゾーンデータの初期化
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // アプリアイコンを指定

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification: (id, title, body, payload) async {
            // iOS 10 未満の処理
          },
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        // 通知をタップした際の処理
      },
    );
  }

  Future<bool> _requestPermissions() async {
    // iOSの権限リクエスト
    final bool? iosResult = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    debugPrint("iOS Notification permission result: $iosResult");

    // Androidの権限リクエスト
    bool androidPermissionsGranted = true;
    if (Theme.of(context).platform == TargetPlatform.android) {
      final scheduleExactAlarmStatus =
          await Permission.scheduleExactAlarm.status;
      final notificationStatus = await Permission.notification.status;

      if (scheduleExactAlarmStatus.isDenied || notificationStatus.isDenied) {
        // 必要な権限を個別にリクエスト
        PermissionStatus scheduleStatus =
            await Permission.scheduleExactAlarm.request();
        PermissionStatus notificationPermStatus =
            await Permission.notification.request();
        androidPermissionsGranted =
            scheduleStatus.isGranted && notificationPermStatus.isGranted;
      } else if (scheduleExactAlarmStatus.isPermanentlyDenied ||
          notificationStatus.isPermanentlyDenied) {
        // ユーザーが永続的に拒否した場合の処理（例：設定画面へ誘導）
        androidPermissionsGranted = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.notificationPermissionPermanentlyDenied,
              ),
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.openSettings,
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
      } else {
        androidPermissionsGranted =
            scheduleExactAlarmStatus.isGranted && notificationStatus.isGranted;
      }
      debugPrint(
        "Android Notification permission result: $androidPermissionsGranted",
      );
    }

    return (iosResult ?? false) || androidPermissionsGranted;
  }

  Future<void> _scheduleDailyNotification(TimeOfDay time) async {
    final bool permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.notificationPermissionRequired,
            ),
          ),
        );
      }
      return;
    }

    await flutterLocalNotificationsPlugin.cancel(0);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      AppLocalizations.of(context)!.learningTimeNotificationTitle,
      AppLocalizations.of(context)!.learningTimeNotificationBody,
      _nextInstanceOfTime(time),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel_id',
          AppLocalizations.of(context)!.dailyLearningReminderChannelName,
          channelDescription:
              AppLocalizations.of(
                context,
              )!.dailyLearningReminderChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder_${time.hour}_${time.minute}',
    );
    debugPrint("Scheduled daily notification at ${time.hour}:${time.minute}");
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Widget _buildTimeSelectionButton(
    BuildContext context,
    TimeOfDay time,
    String label,
  ) {
    final bool isSelected =
        _selectedTime?.hour == time.hour &&
        _selectedTime?.minute == time.minute;
    final neumorphicTheme = NeumorphicTheme.currentTheme(context);
    final double? embossDepth = NeumorphicTheme.embossDepth(context);
    final double defaultButtonDepth = neumorphicTheme.depth ?? 4.0;

    return Expanded(
      child: NeumorphicButton(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        onPressed: () {
          setState(() {
            _selectedTime = time;
          });
        },
        style: NeumorphicStyle(
          depth:
              isSelected
                  ? (embossDepth != null ? -embossDepth : -2.0)
                  : defaultButtonDepth,
          color:
              isSelected
                  ? NeumorphicTheme.accentColor(context).withOpacity(0.2)
                  : NeumorphicTheme.baseColor(context),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: NeumorphicTheme.defaultTextColor(context)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final neumorphicTheme = NeumorphicTheme.currentTheme(context);
    final double buttonDepth = neumorphicTheme.depth ?? 4.0;

    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(AppLocalizations.of(context)!.reminderSettingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.maximizeLearningEffectTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: NeumorphicTheme.defaultTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.maximizeLearningEffectBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: NeumorphicTheme.variantColor(context),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.whenToRemind,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: NeumorphicTheme.defaultTextColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeSelectionButton(
                  context,
                  const TimeOfDay(hour: 9, minute: 0),
                  '9:00',
                ),
                _buildTimeSelectionButton(
                  context,
                  const TimeOfDay(hour: 12, minute: 0),
                  '12:00',
                ),
                _buildTimeSelectionButton(
                  context,
                  const TimeOfDay(hour: 19, minute: 0),
                  '19:00',
                ),
              ],
            ),
            const SizedBox(height: 48),
            NeumorphicButton(
              onPressed:
                  _selectedTime == null
                      ? null
                      : () async {
                        await _scheduleDailyNotification(_selectedTime!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.reminderSetSuccess(
                                  _selectedTime!.format(context),
                                ),
                              ),
                            ),
                          );
                          context.go('/app_review');
                        }
                      },
              style: NeumorphicStyle(
                color:
                    _selectedTime == null
                        ? Colors.grey[500]
                        : NeumorphicTheme.accentColor(context),
                disableDepth: _selectedTime == null,
                depth: _selectedTime == null ? 0 : buttonDepth,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.setReminderButton,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        _selectedTime == null
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () {
                context.go('/app_review');
              },
              style: NeumorphicStyle(
                color: NeumorphicTheme.baseColor(context),
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.setReminderLaterButton,
                  style: TextStyle(
                    fontSize: 16,
                    color: NeumorphicTheme.defaultTextColor(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
