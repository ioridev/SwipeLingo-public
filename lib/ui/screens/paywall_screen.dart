import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart'; // 画面遷移用
import 'package:flutter/services.dart'; // PlatformException のために追加
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart'; // URL起動用

import '../../providers/subscription_provider.dart'; // Provider をインポート

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  // URLを開くヘルパーメソッド
  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.couldNotLaunchUrl(urlString),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsyncValue = ref.watch(offeringsProvider);
    final theme = NeumorphicTheme.currentTheme(context);
    final textStyle = TextStyle(
      color: NeumorphicTheme.defaultTextColor(context),
      fontSize: 12,
    );
    final linkStyle = TextStyle(
      color: theme.accentColor,
      fontSize: 12,
      decoration: TextDecoration.underline,
    );

    const privacyPolicyUrl =
        'https://gist.githubusercontent.com/ioridev/dbe15b714f558fda77e1bf140e75af1c/raw/9f6496a4f7b3797898faebff2ac0236be7255654/gistfile1.txt';
    const termsOfUseUrl =
        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

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
        title: Text(AppLocalizations.of(context)!.swipelingoPro),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NeumorphicTheme.baseColor(context),
              NeumorphicTheme.baseColor(
                context,
              ).withBlue(NeumorphicTheme.baseColor(context).blue + 15),
            ],
          ),
        ),
        child: offeringsAsyncValue.when(
          data: (offerings) {
            debugPrint(
              '[DEBUG_Paywall] PaywallScreen: Received offerings data. Current offering: ${offerings.current?.identifier}, Available packages: ${offerings.current?.availablePackages.length ?? 0}',
            );
            if (offerings.all.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context)!.noOfferingsAvailable,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final currentOffering = offerings.current;
            if (currentOffering == null ||
                currentOffering.availablePackages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context)!.noPackagesAvailableInOffering(
                      offerings.current?.identifier ?? 'N/A',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // パッケージの並べ替え（Weekly, Monthly, Annual の順）
            final sortedPackages = [...currentOffering.availablePackages];
            sortedPackages.sort((a, b) {
              final order = {
                PackageType.weekly: 0,
                PackageType.monthly: 1,
                PackageType.annual: 2,
              };
              return (order[a.packageType] ?? 99).compareTo(
                order[b.packageType] ?? 99,
              );
            });

            // 月額プランの価格を見つける（年額プランの割引率計算用）
            double? monthlyPrice;
            for (final package in sortedPackages) {
              if (package.packageType == PackageType.monthly) {
                monthlyPrice =
                    double.tryParse(package.storeProduct.price.toString()) ??
                    0.0;
                break;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // プレミアム特典リスト
                  Neumorphic(
                    style: NeumorphicStyle(
                      depth: 3,
                      intensity: 0.5,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(16),
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 24.0),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.premiumFeatures,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.defaultTextColor(
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(context)!.unlimitedGems,
                          AppLocalizations.of(
                            context,
                          )!.unlimitedTranslationSubtitles,
                          Icons.diamond,
                        ),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(context)!.adsFree,
                          AppLocalizations.of(context)!.concentrateOnLearning,
                          Icons.block,
                        ),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(context)!.unlimitedCardCreation,
                          AppLocalizations.of(
                            context,
                          )!.learnAsMuchAsYouWantDaily,
                          Icons.flash_on,
                        ),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(context)!.premiumSupport,
                          AppLocalizations.of(context)!.prioritySupport,
                          Icons.support_agent,
                        ),
                      ],
                    ),
                  ),

                  // プラン選択
                  Neumorphic(
                    style: NeumorphicStyle(
                      depth: 3,
                      intensity: 0.5,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(16),
                      ),
                      color: NeumorphicTheme.baseColor(context),
                    ),
                    margin: const EdgeInsets.only(bottom: 24.0),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selectBestPlanForYou,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.defaultTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...sortedPackages.map((package) {
                          return _buildEnhancedPackageCard(
                            context,
                            ref,
                            package,
                            theme,
                            monthlyPrice,
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: textStyle,
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              AppLocalizations.of(
                                context,
                              )!.purchaseTermsDescription,
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.termsOfUseEULA,
                          style: linkStyle,
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap =
                                    () => _launchUrl(context, termsOfUseUrl),
                        ),
                        const TextSpan(text: ' | '),
                        TextSpan(
                          text: AppLocalizations.of(context)!.privacyPolicy,
                          style: linkStyle,
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap =
                                    () => _launchUrl(context, privacyPolicyUrl),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  NeumorphicButton(
                    minDistance: -4,
                    style: NeumorphicStyle(
                      depth: -2,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(8),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    onPressed: () async {
                      try {
                        debugPrint(
                          '[DEBUG_Paywall] Restore Purchases: Attempting to restore purchases.',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.restoringPurchases,
                            ),
                          ),
                        );
                        await Purchases.restorePurchases();
                        final restoredCustomerInfo =
                            await Purchases.getCustomerInfo();
                        debugPrint(
                          '[DEBUG_Paywall] Restore Purchases: Restore successful. Restored CustomerInfo: Entitlements: ${restoredCustomerInfo.entitlements.all}, Active Subscriptions: ${restoredCustomerInfo.activeSubscriptions}',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.purchasesRestored,
                            ),
                          ),
                        );
                      } catch (e) {
                        debugPrint(
                          '[DEBUG_Paywall] Restore Purchases: Error restoring purchases: $e',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.restorePurchasesFailed(e.toString()),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.restorePurchasesButton,
                      style: TextStyle(
                        color: NeumorphicTheme.defaultTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading:
              () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.loadingPlans),
                  ],
                ),
              ),
          error: (error, stackTrace) {
            debugPrint(
              '[DEBUG_Paywall] PaywallScreen: Error loading offerings. Error: $error, StackTrace: $stackTrace',
            );
            String errorMessage =
                AppLocalizations.of(context)!.failedToLoadPlans;
            if (error is PlatformException) {
              final errorCodeValue = PurchasesErrorHelper.getErrorCode(error);
              errorMessage +=
                  '\n${AppLocalizations.of(context)!.errorCode(errorCodeValue.toString())}';
              errorMessage +=
                  '\n${AppLocalizations.of(context)!.details(error.message ?? '')}';
            } else {
              errorMessage +=
                  '\n${AppLocalizations.of(context)!.details(error.toString())}';
            }
            debugPrint('[Error] PaywallScreen error: $error');
            debugPrint('[Error] PaywallScreen stacktrace: $stackTrace');

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    NeumorphicButton(
                      onPressed: () => ref.invalidate(offeringsProvider),
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: NeumorphicTheme.accentColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: NeumorphicTheme.accentColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NeumorphicTheme.defaultTextColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: NeumorphicTheme.defaultTextColor(
                      context,
                    ).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPackageCard(
    BuildContext context,
    WidgetRef ref,
    Package package,
    NeumorphicThemeData theme,
    double? monthlyPrice,
  ) {
    final product = package.storeProduct;
    String packageTitle;
    String packageFeature = '';
    bool isRecommended = false;
    double? discount;

    // 価格の取得
    double price = double.tryParse(product.price.toString()) ?? 0.0;

    // プランタイプごとの表示設定
    switch (package.packageType) {
      case PackageType.weekly:
        packageTitle = AppLocalizations.of(context)!.weeklyPlan;
        packageFeature = AppLocalizations.of(context)!.daysFreeTrial;
        break;
      case PackageType.monthly:
        packageTitle = AppLocalizations.of(context)!.monthlyPlan;
        isRecommended = true;
        break;
      case PackageType.annual:
        packageTitle = AppLocalizations.of(context)!.annualPlan;
        if (monthlyPrice != null && monthlyPrice > 0) {
          // 年間での月額に換算した価格
          double monthlyEquivalent = price / 12;
          // 割引率の計算（小数点以下切り上げ）
          discount =
              ((monthlyPrice - monthlyEquivalent) / monthlyPrice * 100)
                  .ceilToDouble();
          packageFeature = AppLocalizations.of(
            context,
          )!.discountFromMonthly(discount.toInt().toString());
        }
        break;
      default:
        packageTitle = product.title;
    }

    // プランカードのスタイルを条件によって変更
    NeumorphicStyle getCardStyle() {
      if (isRecommended) {
        return NeumorphicStyle(
          depth: 4,
          intensity: 0.6,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          color: NeumorphicTheme.accentColor(context).withOpacity(0.1),
          border: const NeumorphicBorder(color: Colors.blue, width: 2),
        );
      } else {
        return NeumorphicStyle(
          depth: 4,
          intensity: 0.6,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Neumorphic(
        style: getCardStyle(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            packageTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicTheme.defaultTextColor(context),
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: NeumorphicTheme.accentColor(context),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.recommended,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (packageFeature.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          packageFeature,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                package.packageType == PackageType.annual
                                    ? Colors.green
                                    : NeumorphicTheme.accentColor(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.priceString,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                    ),
                    if (package.packageType == PackageType.weekly ||
                        package.packageType == PackageType.monthly)
                      Text(
                        package.packageType == PackageType.weekly
                            ? AppLocalizations.of(context)!.perWeek
                            : AppLocalizations.of(context)!.perMonth,
                        style: TextStyle(
                          fontSize: 12,
                          color: NeumorphicTheme.variantColor(context),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            NeumorphicButton(
              style: NeumorphicStyle(
                depth: 3,
                intensity: 0.7,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(8),
                ),
                color: isRecommended ? theme.accentColor : null,
              ),
              onPressed: () async {
                await _purchasePackage(context, ref, package);
              },
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Center(
                child: Text(
                  isRecommended
                      ? AppLocalizations.of(context)!.startNow
                      : AppLocalizations.of(context)!.selectButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isRecommended
                            ? Colors.white
                            : NeumorphicTheme.defaultTextColor(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchasePackage(
    BuildContext context,
    WidgetRef ref,
    Package package,
  ) async {
    try {
      debugPrint(
        '[DEBUG_Paywall] _purchasePackage: Attempting to purchase package. Package ID: ${package.identifier}, Product ID: ${package.storeProduct.identifier}, Product Title: ${package.storeProduct.title}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.startingPurchaseProcess),
        ),
      );

      final customerInfo = await Purchases.purchasePackage(package);
      debugPrint(
        '[DEBUG_Paywall] _purchasePackage: Purchase successful. CustomerInfo received. Entitlements: ${customerInfo.entitlements.all}, Active Subscriptions: ${customerInfo.activeSubscriptions}, Transaction ID (latest): ${customerInfo.latestExpirationDate}',
      );

      final isPremium =
          customerInfo.entitlements.all['premium']?.isActive ?? false;
      if (isPremium) {
        if (context.mounted) {
          // context の有効性を確認
          debugPrint(
            '[DEBUG_Paywall] _purchasePackage: Checked premium status after purchase. isPremium: $isPremium. Entitlement "premium": ${customerInfo.entitlements.all['premium']}',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.purchaseCompletedThankYou,
              ),
            ),
          );
          if (context.canPop()) {
            context.pop();
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.purchaseCompletedPlanNotActive,
              ),
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      String message;
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        message = AppLocalizations.of(context)!.purchaseCancelled;
        debugPrint(
          '[DEBUG_Paywall] _purchasePackage: PlatformException during purchase. ErrorCode: $errorCode, Message: ${e.message}, Details: ${e.details}',
        );
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        message = AppLocalizations.of(context)!.purchasePending;
      } else {
        message = AppLocalizations.of(
          context,
        )!.purchaseFailed(e.message ?? "不明なエラー");
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      debugPrint(
        '[DEBUG_Paywall] _purchasePackage: Generic error during purchase: $e',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.unexpectedErrorOccurred(e.toString()),
            ),
          ),
        );
      }
    }
  }
}
