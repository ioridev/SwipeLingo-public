import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // Purchases をインポート
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerStatefulWidget 用
import 'package:flutter/services.dart'; // PlatformException のために追加
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart'; // share_plus パッケージをインポート
import 'package:firebase_analytics/firebase_analytics.dart'; // Firebase Analytics をインポート
// import '../../models/card.dart' as models; // Hiveモデルは不要
import '../../models/firebase_card_model.dart'; // Firebase用カードモデルをインポート
import '../../models/invitation_code_response.dart'; // ApplyInvitationCodeResponse のため
import '../../services/anki_export.dart'; // AnkiExportServiceとそのProviderのため
import '../../providers/subscription_provider.dart'; // isSubscribedProvider のため
import 'package:url_launcher/url_launcher.dart'; // url_launcher のため
import 'package:in_app_review/in_app_review.dart'; // in_app_review のため
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth のため
import '../../repositories/firebase_repository.dart'; // FirebaseRepository のため
import '../../models/user_model.dart'; // UserModel のため
import '../../providers/repository_providers.dart'; // firebaseRepositoryProvider, userDocumentProviderのため
import '../../services/version_check_service.dart'; // VersionCheckService をインポート
// import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // FontAwesomeIcons のため FontAwesomeIcons が見つからないためコメントアウト

// Social Media URLs
const String xUrl = 'https://x.com/swipe_lingo';
const String discordUrl = 'https://discord.gg/r2dA8rbv66';

// StateProvider for the rating
final ratingProvider = StateProvider<int>((ref) => 0);

// Provider for current user data (firebaseRepositoryProviderはrepository_providers.dartから取得)
// userDocumentProvider を使用するため、この userProvider は不要になるか、userDocumentProvider を参照するように変更検討
// final userProvider = FutureProvider<UserModel?>((ref) async {
//   final firebaseRepository = ref.watch(firebaseRepositoryProvider);
//   final userId = FirebaseAuth.instance.currentUser?.uid;
//   if (userId == null) {
//     return null;
//   }
//   return firebaseRepository.getUser(userId);
// });

// StateProvider for invitation code TextField
final invitationCodeControllerProvider = Provider(
  (ref) => TextEditingController(),
);

// StateProvider for loading state during invitation code application
final isLoadingInvitationProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _selectedNativeLanguage;
  String? _selectedTargetLanguage;
  bool _isLoadingLanguages = true;

  final Map<String, String> _languageOptions = {'en': 'English', 'ja': '日本語'};

  @override
  void initState() {
    super.initState();
    _loadUserLanguages();
  }

  Future<void> _loadUserLanguages() async {
    // didChangeDependencies の代わりに initState で一度だけ watch するか、
    // もしくは build メソッド内で watch して、変更があった場合に setState する。
    // ここでは、初回ロード時に取得し、その後はローカル状態で管理する方針とする。
    // userDocumentProvider が StreamProvider の場合、listen するのが適切。
    // FutureProvider の場合は、FutureBuilder や .when を使う。
    // 指示では ref.watch(userDocumentProvider) とあるため、buildメソッドでの使用が想定されているかもしれないが、
    // initState で初期値を設定する。
    // userDocumentProvider が null を返す可能性も考慮。
    final userDoc = await ref.read(userDocumentProvider.future);
    if (mounted) {
      setState(() {
        _selectedNativeLanguage = userDoc?.nativeLanguageCode;
        _selectedTargetLanguage = userDoc?.targetLanguageCode;
        _isLoadingLanguages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userDocumentAsyncValue = ref.watch(userDocumentProvider);

    return Scaffold(
      appBar: NeumorphicAppBar(
        leading: NeumorphicButton(
          padding: const EdgeInsets.all(8.0),
          style: const NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          child: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          // --- 自分の招待コード表示 ---
          Consumer(
            builder: (context, ref, child) {
              // userDocumentProvider を使用するように変更
              final userAsyncValue = ref.watch(userDocumentProvider);
              return userAsyncValue.when(
                data: (user) {
                  if (user == null || user.invitationCode.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Neumorphic(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.yourInvitationCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Neumorphic(
                                style: NeumorphicStyle(
                                  depth: -1,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: Text(
                                  user.invitationCode,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            NeumorphicButton(
                              tooltip: l10n.copyButton,
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: user.invitationCode),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.invitationCodeCopied),
                                  ),
                                );
                              },
                              child: const Icon(Icons.copy, size: 20),
                            ),
                            const SizedBox(width: 8),
                            NeumorphicButton(
                              tooltip: l10n.shareButton, // ローカライズキー
                              onPressed: () {
                                final invitationCode = user.invitationCode;
                                final versionCheckService =
                                    VersionCheckService();
                                final storeUrl =
                                    versionCheckService.getStoreUrl();
                                final downloadPrompt = l10n.downloadAppPrompt;
                                // ローカライズされた共有メッセージを作成
                                final shareText = l10n.shareInvitationMessage(
                                  invitationCode,
                                  downloadPrompt,
                                  storeUrl,
                                );
                                Share.share(shareText);
                                
                                // Firebase Analytics イベントを送信
                                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                                final analyticsParams = <String, Object>{
                                  'invitation_code': invitationCode,
                                };
                                // user_idが取得できた場合のみパラメータに追加
                                if (currentUserId != null) {
                                  analyticsParams['user_id'] = currentUserId;
                                }
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'share_invitation_code',
                                  parameters: analyticsParams,
                                );
                              },
                              child: const Icon(Icons.share, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                loading:
                    () => const SizedBox.shrink(), // Or a loading indicator
                error:
                    (err, stack) =>
                        const SizedBox.shrink(), // Or an error message
              );
            },
          ),
          // --- 招待コード入力 ---
          Consumer(
            builder: (context, ref, child) {
              final userAsyncValue = ref.watch(
                userDocumentProvider,
              ); // userDocumentProvider を使用
              final isLoading = ref.watch(isLoadingInvitationProvider);

              return userAsyncValue.when(
                data: (user) {
                  if (user == null) {
                    return const SizedBox.shrink();
                  }
                  if (user.hasUsedInvitationCode) {
                    return Neumorphic(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text(l10n.invitationCodeAlreadyUsed),
                      ),
                    );
                  }
                  return Neumorphic(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.enterInvitationCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Neumorphic(
                          child: TextField(
                            controller: ref.watch(
                              invitationCodeControllerProvider,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.invitationCodeHint,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: NeumorphicButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      await _applyInvitationCode(context, ref);
                                    },
                            child:
                                isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(l10n.applyButton),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, stack) => Center(
                      child: Text(l10n.errorDialogMessage(err.toString())),
                    ),
              );
            },
          ),
          // --- Social Media Links ---
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.followUs,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    NeumorphicButton(
                      tooltip: 'X (Twitter)',
                      onPressed: () async {
                        final Uri url = Uri.parse(xUrl);
                        if (!await launchUrl(url)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.couldNotLaunchUrl(url.toString()),
                              ),
                            ),
                          );
                        }
                      },
                      style: const NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.circle(),
                        depth: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      // child: const FaIcon(FontAwesomeIcons.twitter, size: 24), // FontAwesomeIcons が見つからないためコメントアウト
                      child: const Icon(FontAwesomeIcons.x, size: 24), // 代替アイコン
                    ),
                    NeumorphicButton(
                      tooltip: 'Discord',
                      onPressed: () async {
                        final Uri url = Uri.parse(discordUrl);
                        if (!await launchUrl(url)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.couldNotLaunchUrl(url.toString()),
                              ),
                            ),
                          );
                        }
                      },
                      style: const NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.circle(),
                        depth: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      // child: const FaIcon(FontAwesomeIcons.discord, size: 24), // FontAwesomeIcons が見つからないためコメントアウト
                      child: const Icon(Icons.discord, size: 24), // 代替アイコン
                    ),
                  ],
                ),
              ],
            ),
          ),
          // --- アプリを評価 ---
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.star),
              title: Text(l10n.rateTheApp),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                ref.read(ratingProvider.notifier).state = 0;
                await _showRatingDialog(context, ref);
              },
            ),
          ),
          // --- 不具合報告 ---
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(l10n.reportBugsOrRequests),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final Uri url = Uri.parse(
                  'https://forms.gle/r87uafjeVSU2xj4d7',
                );
                if (!await launchUrl(url)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.couldNotLaunchUrl(url.toString())),
                    ),
                  );
                }
              },
            ),
          ),
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text(l10n.manageCards),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/manage-cards');
              },
            ),
          ),
          // --- プレミアムプランへの登録 ---
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: Text(l10n.premiumPlan),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/paywall');
              },
            ),
          ),

          // --- Ankiエクスポート ---
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(l10n.ankiExportCsv),
              onTap: () async {
                await _exportToAnki(context, ref);
              },
            ),
          ),
          // --- お気に入りチャンネル一覧画面への導線 ---
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.favorite),
              title: Text(
                l10n.favoriteChannelsScreenTitle,
              ), // l10n.favoriteChannelsScreenTitle を使用
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/favorite-channels'); // TODO: GoRouterにルートを追加
              },
            ),
          ),
          // --- 視聴履歴 ---
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(
                l10n.watchHistoryScreenTitle,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/watch-history');
              },
            ),
          ),
          // --- リマインダー設定 ---
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.notifications_active),
              title: Text(l10n.settingsReminderSettings), // ローカライズされたテキスト
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/reminder-settings');
              },
            ),
          ),
          // --- スマート通知設定 ---
          Neumorphic(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(l10n.notificationSettings), // スマート通知設定
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/notification-settings');
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLanguageSettings() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedNativeLanguage == null || _selectedTargetLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectBothLanguages), // 新しいローカライズキー候補
        ),
      );
      return;
    }

    if (_selectedNativeLanguage == _selectedTargetLanguage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.nativeAndTargetMustBeDifferent), // 新しいローカライズキー
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.userAuthenticationRequired)));
      return;
    }

    try {
      final firebaseRepository = ref.read(firebaseRepositoryProvider);
      await firebaseRepository.updateUserDocument(userId, {
        'nativeLanguageCode': _selectedNativeLanguage,
        'targetLanguageCode': _selectedTargetLanguage,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsSavedSuccessfully), // 新しいローカライズキー
        ),
      );
      // 必要であれば userDocumentProvider を invalidate して再読み込み
      ref.invalidate(userDocumentProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.errorSavingSettings(e.toString()),
          ), // 新しいローカライズキー候補
        ),
      );
    }
  }

  Future<void> _showRatingDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context, dialogRef, child) {
            final rating = dialogRef.watch(ratingProvider);
            return AlertDialog(
              title: Text(l10n.pleaseRateTheApp),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(index < rating ? Icons.star : Icons.star_border),
                    color: Colors.amber,
                    onPressed: () {
                      dialogRef.read(ratingProvider.notifier).state = index + 1;
                    },
                  );
                }),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(l10n.cancelButton),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: Text(l10n.submitButton),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    final actualRating = dialogRef.read(ratingProvider);

                    if (actualRating <= 3 && actualRating > 0) {
                      final Uri url = Uri.parse(
                        'https://forms.gle/r87uafjeVSU2xj4d7',
                      );
                      if (!await launchUrl(url)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.couldNotLaunchUrl(url.toString()),
                            ),
                          ),
                        );
                      }
                    } else if (actualRating > 3) {
                      final InAppReview inAppReview = InAppReview.instance;
                      if (await inAppReview.isAvailable()) {
                        inAppReview.requestReview();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.reviewFeatureNotAvailable),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportToAnki(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final isProUser = ref.watch(isSubscribedProvider);

    if (!isProUser) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.premiumFeatureOnly)));
      context.push('/paywall');
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.startingAnkiExport)));

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.loginRequiredForExport)));
        return;
      }

      final firebaseRepository = ref.read(firebaseRepositoryProvider);
      // Firestoreから全カードデータを取得 (Streamの最初の値を取得)
      final List<FirebaseCardModel> allCards =
          await firebaseRepository.getUserCardsStream(userId).first;

      if (allCards.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noCardsToExport)));
        return;
      }

      final ankiExportService = ref.read(
        ankiExportServiceProvider,
      ); // Provider経由で取得
      final success = await ankiExportService.exportCardsToAnki(allCards);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ankiExportRequested)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ankiExportFailed)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorDuringAnkiExport(e.toString()))),
      );
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.restoringPurchases)));
      await Purchases.restorePurchases();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.purchasesRestored)));
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      String message;
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        message = l10n.restoreCancelled;
      } else if (errorCode == PurchasesErrorCode.networkError) {
        message = l10n.networkErrorPleaseCheckConnection;
      } else if (errorCode == PurchasesErrorCode.storeProblemError) {
        message = l10n.storeCommunicationError;
      } else {
        message = l10n.restorePurchasesFailed(e.message ?? '');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unexpectedErrorOccurred(e.toString()))),
      );
    }
  }

  Future<void> _applyInvitationCode(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final firebaseRepository = ref.read(firebaseRepositoryProvider);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final invitationCode =
        ref.read(invitationCodeControllerProvider).text.trim();

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.userAuthenticationRequired)));
      return;
    }

    if (invitationCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterInvitationCode)));
      return;
    }

    ref.read(isLoadingInvitationProvider.notifier).state = true;

    try {
      final response = await firebaseRepository.applyInvitationCode(
        userId,
        invitationCode,
      );
      
      // Firebase Analytics イベントを送信
      FirebaseAnalytics.instance.logEvent(
        name: 'apply_invitation_code',
        parameters: {
          'invitation_code': invitationCode,
          'user_id': userId,
          'success': response.isSuccess,
        },
      );
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.displayMessage)));
      
      if (response.isSuccess) {
        ref.invalidate(
          userDocumentProvider,
        ); // userDocumentProvider を invalidate
        ref.read(invitationCodeControllerProvider).clear();
      }
    } catch (e) {
      // エラー時のAnalyticsイベントを送信
      FirebaseAnalytics.instance.logEvent(
        name: 'apply_invitation_code_error',
        parameters: {
          'invitation_code': invitationCode,
          'user_id': userId,
          'error': e.toString(),
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorDialogMessage(e.toString()))),
      );
    } finally {
      ref.read(isLoadingInvitationProvider.notifier).state = false;
    }
  }
}
