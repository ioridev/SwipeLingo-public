import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import '../l10n/app_localizations.dart';

import '../main.dart'; // navigatorKey をインポート

class VersionCheckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore collection and document names
  static const String _appConfigsCollection = 'app_configs';
  static const String _versionInfoDocument = 'version_info';

  // Firestore field names
  static const String _iosMinRequiredBuildNumberKey =
      'iosMinRequiredBuildNumber';
  static const String _iosOptionalUpdateBuildNumberKey =
      'iosOptionalUpdateBuildNumber';
  static const String _androidMinRequiredBuildNumberKey =
      'androidMinRequiredBuildNumber';
  static const String _androidOptionalUpdateBuildNumberKey =
      'androidOptionalUpdateBuildNumber';

  // App Store URLs (Replace with your actual URLs)
  static const String appStoreUrlIOS = "https://apps.apple.com/app/6745492381";
  static const String playStoreUrlAndroid =
      "https://play.google.com/store/apps/details?id=dev.ioridev.swipelingo";

  String getStoreUrl() {
    if (Platform.isIOS) {
      return appStoreUrlIOS;
    } else if (Platform.isAndroid) {
      return playStoreUrlAndroid;
    }
    // プラットフォームが特定できない場合のフォールバックURL。
    // 必要に応じて適切なURLを設定してください。
    return "https://swipelingo.app/"; // 例: 公式ウェブサイト
  }

  Future<void> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      final versionInfoDoc =
          await _firestore
              .collection(_appConfigsCollection)
              .doc(_versionInfoDocument)
              .get();

      if (!versionInfoDoc.exists) {
        debugPrint('Version info document does not exist in Firestore.');
        return;
      }

      final data = versionInfoDoc.data();
      if (data == null) {
        debugPrint('Version info data is null.');
        return;
      }

      int forceUpdateBuildNumber = 0;
      int optionalUpdateBuildNumber = 0;

      if (Platform.isIOS) {
        forceUpdateBuildNumber =
            data[_iosMinRequiredBuildNumberKey] as int? ?? 0;
        optionalUpdateBuildNumber =
            data[_iosOptionalUpdateBuildNumberKey] as int? ?? 0;
      } else if (Platform.isAndroid) {
        forceUpdateBuildNumber =
            data[_androidMinRequiredBuildNumberKey] as int? ?? 0;
        optionalUpdateBuildNumber =
            data[_androidOptionalUpdateBuildNumberKey] as int? ?? 0;
      }

      debugPrint('forceUpdateBuildNumber: $forceUpdateBuildNumber');

      if (currentBuildNumber < forceUpdateBuildNumber &&
          forceUpdateBuildNumber > 0) {
        _showUpdateDialog(isForceUpdate: true);
      } else if (currentBuildNumber < optionalUpdateBuildNumber &&
          optionalUpdateBuildNumber > 0) {
        _showUpdateDialog(isForceUpdate: false);
      }
    } catch (e) {
      debugPrint('Error checking for update: $e');
    }
  }

  void _showUpdateDialog({required bool isForceUpdate}) {
    final BuildContext? currentContext = navigatorKey.currentContext;
    if (currentContext == null) {
      debugPrint('navigatorKey.currentContext is null, cannot show dialog.');
      return;
    }

    showGeneralDialog(
      context: currentContext,
      barrierDismissible: !isForceUpdate,
      barrierLabel: 'Update Dialog',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: animation,
            child: WillPopScope(
              onWillPop: () async => !isForceUpdate,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: ContentBox(
                  isForceUpdate: isForceUpdate,
                  onConfirm: () {
                    _launchStoreUrl();
                    if (!isForceUpdate) {
                      Navigator.of(context).pop();
                    }
                  },
                  onCancel:
                      isForceUpdate ? null : () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchStoreUrl() async {
    String urlString;
    if (Platform.isIOS) {
      urlString = appStoreUrlIOS;
    } else if (Platform.isAndroid) {
      urlString = playStoreUrlAndroid;
    } else {
      debugPrint('Unsupported platform for store URL');
      return;
    }

    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $urlString');
    }
  }
}

class ContentBox extends StatelessWidget {
  final bool isForceUpdate;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ContentBox({
    super.key,
    required this.isForceUpdate,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final title =
        isForceUpdate ? l10n.updateRequiredTitle : l10n.updateAvailableTitle;

    final message =
        isForceUpdate
            ? l10n.updateRequiredMessage
            : l10n.updateAvailableMessage;

    final confirmButtonText =
        isForceUpdate ? l10n.updateNowButton : l10n.updateButton;

    final cancelButtonText = isForceUpdate ? null : l10n.updateLaterButton;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(
                left: 24,
                top: 80,
                right: 24,
                bottom: 24,
              ),
              margin: const EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    NeumorphicTheme.baseColor(context),
                    NeumorphicTheme.baseColor(context).withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 20),

                  // タイトル
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, titleValue, child) {
                      return Opacity(
                        opacity: titleValue,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - titleValue)),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicTheme.defaultTextColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // メッセージ
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, messageValue, child) {
                      return Opacity(
                        opacity: messageValue,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - messageValue)),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isForceUpdate
                                        ? Colors.red.withOpacity(0.3)
                                        : Colors.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: NeumorphicTheme.defaultTextColor(
                                  context,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // 確認ボタン
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    builder: (context, buttonValue, child) {
                      return Transform.scale(
                        scale: buttonValue,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  isForceUpdate
                                      ? [
                                        const Color(0xFFEF4444),
                                        const Color(0xFFDC2626),
                                      ]
                                      : [
                                        const Color(0xFF3B82F6),
                                        const Color(0xFF2563EB),
                                      ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (isForceUpdate
                                        ? Colors.red
                                        : Colors.blue)
                                    .withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onConfirm,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isForceUpdate
                                          ? Icons.system_update
                                          : Icons.download_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      confirmButtonText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // キャンセルボタン（任意アップデートの場合のみ）
                  if (!isForceUpdate &&
                      cancelButtonText != null &&
                      onCancel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, cancelValue, child) {
                          return Opacity(
                            opacity: cancelValue,
                            child: TextButton(
                              onPressed: onCancel,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                cancelButtonText,
                                style: TextStyle(
                                  color: NeumorphicTheme.defaultTextColor(
                                    context,
                                  ).withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // トップアイコン（円の中に更新アイコン）
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.bounceOut,
                  builder: (context, iconValue, child) {
                    return Transform.scale(
                      scale: iconValue,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                isForceUpdate
                                    ? [
                                      const Color(0xFFEF4444),
                                      const Color(0xFFDC2626),
                                    ]
                                    : [
                                      const Color(0xFF3B82F6),
                                      const Color(0xFF2563EB),
                                    ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isForceUpdate ? Colors.red : Colors.blue)
                                  .withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          isForceUpdate
                              ? Icons.priority_high_rounded
                              : Icons.system_update_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
