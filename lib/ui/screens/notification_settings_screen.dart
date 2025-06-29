import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../services/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  late NotificationService _notificationService;
  bool _notificationEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = true;
  
  // 通知タイプの設定
  bool _dailyReminder = true;
  bool _reviewReminder = true;
  // TODO: 将来実装予定の通知タイプ
  // bool _milestoneNotification = true;
  // bool _newContentNotification = true;

  @override
  void initState() {
    super.initState();
    _notificationService = ref.read(notificationServiceProvider);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Firebaseからユーザー設定を読み込む
    final userId = ref.read(firebaseRepositoryProvider).getCurrentUserId();
    if (userId != null) {
      final user = await ref.read(firebaseRepositoryProvider).getUser(userId);
      if (user != null) {
        final settings = user.settings;
        final notificationTypes = settings?.notificationTypes;
        
        setState(() {
          _notificationEnabled = settings?.notificationEnabled ?? true;
          if (settings?.preferredNotificationTime != null) {
            final parts = settings!.preferredNotificationTime.split(':');
            if (parts.length == 2) {
              _notificationTime = TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            }
          }
          _dailyReminder = notificationTypes?.daily ?? true;
          _reviewReminder = notificationTypes?.review ?? true;
          _isLoading = false;
        });
        return;
      }
    }
    
    // Fallbackとしてデフォルト値を使用
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateNotificationEnabled(bool value) async {
    if (value) {
      // 通知権限をリクエスト
      final granted = await _notificationService.requestNotificationPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.notificationPermissionDenied),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }
    
    setState(() {
      _notificationEnabled = value;
    });
    
    await _notificationService.setNotificationEnabled(value);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
      await _notificationService.setNotificationTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      appBar: NeumorphicAppBar(
        title: Text(
          l10n.notificationSettings,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // メイン通知設定
          Neumorphic(
            style: NeumorphicStyle(
              depth: 5,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.enableNotifications,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      NeumorphicSwitch(
                        value: _notificationEnabled,
                        onChanged: _updateNotificationEnabled,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.notificationDescription,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 通知時間設定
          AnimatedOpacity(
            opacity: _notificationEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_notificationEnabled,
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: 5,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                ),
                child: ListTile(
                  title: Text(
                    l10n.notificationTime,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _notificationTime.format(context),
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: _selectTime,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 通知タイプ設定
          AnimatedOpacity(
            opacity: _notificationEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_notificationEnabled,
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: 5,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notificationTypes,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // デイリーリマインダー
                    _buildNotificationTypeRow(
                      title: l10n.dailyReminder,
                      subtitle: l10n.dailyReminderDescription,
                      value: _dailyReminder,
                      onChanged: (value) async {
                        setState(() {
                          _dailyReminder = value;
                        });
                        await _updateNotificationTypesInFirebase();
                      },
                    ),
                    
                    const Divider(height: 24),
                    
                    // 復習リマインダー
                    _buildNotificationTypeRow(
                      title: l10n.reviewReminder,
                      subtitle: l10n.reviewReminderDescription,
                      value: _reviewReminder,
                      onChanged: (value) async {
                        setState(() {
                          _reviewReminder = value;
                        });
                        await _updateNotificationTypesInFirebase();
                      },
                    ),
                    
                    // TODO: 以下の通知タイプは将来実装予定
                    // const Divider(height: 24),
                    
                    // // マイルストーン通知
                    // _buildNotificationTypeRow(
                    //   title: l10n.milestoneNotification,
                    //   subtitle: l10n.milestoneDescription,
                    //   value: true, // _milestoneNotification,
                    //   onChanged: (value) async {
                    //     setState(() {
                    //       // _milestoneNotification = value;
                    //     });
                    //     // Firebase\u306e\u307f\u306b\u4fdd\u5b58
                    //     await _updateNotificationTypesInFirebase();
                    //   },
                    // ),
                    
                    // const Divider(height: 24),
                    
                    // // 新着コンテンツ通知
                    // _buildNotificationTypeRow(
                    //   title: l10n.newContentNotification,
                    //   subtitle: l10n.newContentDescription,
                    //   value: true, // _newContentNotification,
                    //   onChanged: (value) async {
                    //     setState(() {
                    //       // _newContentNotification = value;
                    //     });
                    //     // Firebase\u306e\u307f\u306b\u4fdd\u5b58
                    //     await _updateNotificationTypesInFirebase();
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
  
  Widget _buildNotificationTypeRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        NeumorphicSwitch(
          value: value,
          onChanged: onChanged,
          style: NeumorphicSwitchStyle(
            activeTrackColor: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
  
  Future<void> _updateNotificationTypesInFirebase() async {
    final userId = ref.read(firebaseRepositoryProvider).getCurrentUserId();
    if (userId != null) {
      try {
        await ref.read(firebaseRepositoryProvider).updateUserDocument(userId, {
          'settings.notificationTypes.daily': _dailyReminder,
          'settings.notificationTypes.review': _reviewReminder,
          // TODO: 将来実装予定の通知タイプ
          // 'settings.notificationTypes.milestone': true,
          // 'settings.notificationTypes.newContent': true,
        });
      } catch (e) {
        debugPrint('Failed to update notification types in Firebase: $e');
      }
    }
  }
}