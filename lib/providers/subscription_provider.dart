import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:async'; // StreamController のために追加

/// RevenueCat の CustomerInfo の変更を監視する StreamProvider
///
/// ユーザーの購入情報（アクティブなサブスクリプション、権利など）が含まれます。
final customerInfoProvider = StreamProvider<CustomerInfo>((ref) {
  // Purchases.customerInfoStream がエラーになるため、
  // 代わりに addCustomerInfoUpdateListener を使用する
  // return Purchases.customerInfoStream;

  final controller = StreamController<CustomerInfo>();

  // Listener を設定 (非推奨だが代替として使用)
  // ignore: deprecated_member_use
  listener(CustomerInfo customerInfo) {
    if (!controller.isClosed) {
      controller.add(customerInfo);
    }
  }

  // ignore: deprecated_member_use
  Purchases.addCustomerInfoUpdateListener(listener);

  // Provider が破棄されるときに Listener と Controller をクリーンアップ
  ref.onDispose(() {
    // ignore: deprecated_member_use
    Purchases.removeCustomerInfoUpdateListener(listener);
    controller.close();
  });

  // 初期値を取得して Stream に流す
  Purchases.getCustomerInfo()
      .then((info) {
        debugPrint(
          '[DEBUG_Subscription] customerInfoProvider: Fetched initial CustomerInfo. Entitlements: ${info.entitlements.all}, Active Subscriptions: ${info.activeSubscriptions}, All Purchased Product Identifiers: ${info.allPurchasedProductIdentifiers}',
        );
        if (!controller.isClosed) {
          controller.add(info);
        }
      })
      .catchError((error) {
        if (!controller.isClosed) {
          controller.addError(error); // エラーも流す
        }
        debugPrint(
          '[DEBUG_Subscription] customerInfoProvider: Error fetching initial CustomerInfo: $error',
        );
      });

  return controller.stream;
});

/// 現在のユーザーがプレミアムサブスクリプションを持っているかどうかを示す Provider
///
/// customerInfoProvider を監視し、特定の権利（例: 'premium'）が
/// アクティブかどうかを判定します。
/// RevenueCat ダッシュボードで設定した権利の識別子に合わせて変更してください。
final isSubscribedProvider = Provider<bool>((ref) {
  // customerInfoProvider の状態を監視
  final customerInfoAsyncValue = ref.watch(customerInfoProvider);

  // データが利用可能で、エラーがない場合
  return customerInfoAsyncValue.maybeWhen(
    data: (customerInfo) {
      debugPrint(
        '[DEBUG_Subscription] isSubscribedProvider: Checking subscription status from CustomerInfo. Entitlements: ${customerInfo.entitlements.all}',
      );
      // 'premium' という権利がアクティブかどうかを確認
      // RevenueCat で設定した権利の識別子を使用してください
      final isActive =
          customerInfo.entitlements.all['Pro access']?.isActive ?? false;
      debugPrint(
        '[DEBUG_Subscription] isSubscribedProvider: Subscription active: $isActive (Premium Entitlement: ${customerInfo.entitlements.all['premium']})',
      );
      // debugPrint('Subscription active: $isActive'); // デバッグ用
      return isActive;
    },
    // データがない場合やエラーの場合は false とする
    orElse: () {
      debugPrint(
        '[DEBUG_Subscription] isSubscribedProvider: No data or error, returning false for subscription status.',
      );
      return false;
    },
  );
});

/// 利用可能な購入パッケージ（Offerings）を取得する FutureProvider
///
/// RevenueCat から現在利用可能なオファリング（サブスクリプションプランなど）を取得します。
/// Paywall 画面でこれらの情報を表示し、ユーザーが購入できるようにするために使用します。
final offeringsProvider = FutureProvider<Offerings>((ref) async {
  try {
    debugPrint(
      '[DEBUG_Subscription] offeringsProvider: Attempting to fetch offerings.',
    );
    final offerings = await Purchases.getOfferings();
    debugPrint(
      '[DEBUG_Subscription] offeringsProvider: Offerings fetched successfully. Current: ${offerings.current?.identifier}, All: ${offerings.all.map((key, value) => MapEntry(key, value.identifier))}',
    );
    debugPrint('[Debug] Offerings fetched successfully.');
    if (offerings.current != null) {
      debugPrint('[Debug] Current offering: ${offerings.current!.identifier}');
      offerings.current!.availablePackages.asMap().forEach((index, package) {
        debugPrint('[Debug]   Package ${index + 1}:');
        debugPrint('[Debug]     Identifier: ${package.identifier}');
        debugPrint(
          '[Debug]     Product Identifier: ${package.storeProduct.identifier}',
        );
        debugPrint('[Debug]     Product Title: ${package.storeProduct.title}');
        debugPrint('[Debug]     Price: ${package.storeProduct.priceString}');
      });
    } else {
      debugPrint('[Debug] No current offering available.');
    }
    return offerings;
  } catch (e, s) {
    // エラーとスタックトレースをキャッチ
    debugPrint('[Error] Error fetching offerings: $e');
    debugPrint('[Error] Stacktrace: $s'); // スタックトレースも出力
    // エラーを再スローして、UI 側でエラーハンドリングできるようにする
    rethrow;
  }
});
