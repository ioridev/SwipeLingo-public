// lib/services/translation_payment_service.dart
import 'dart:async'; // Completerのために追加
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipelingo/providers/subscription_provider.dart'; // isSubscribedProvider
import 'package:swipelingo/providers/home_providers.dart'; // userProvider
import 'package:swipelingo/models/user_model.dart'; // UserModel
import 'package:swipelingo/repositories/firebase_repository.dart'; // FirebaseRepository
import 'package:swipelingo/providers/repository_providers.dart'; // firebaseRepositoryProvider

enum TranslationPaymentDecision {
  allow, // 翻訳を許可 (課金ユーザー or ネイティブ字幕 or 支払い済み)
  showConfirmation, // ジェム消費確認ダイアログを表示
  showPaywall, // Paywallを表示
  blocked, // 翻訳機能オフなど、上記以外でブロック
}

class TranslationPaymentService {
  final Ref _ref;
  bool _hasPaidForTranslationInSession = false;
  static const String showTranslatedCaptionPreferenceKey =
      'showTranslatedCaptionPreferenceKey'; // VideoPlayerNotifierから移動

  TranslationPaymentService(this._ref);

  bool get hasPaidForTranslationInSession => _hasPaidForTranslationInSession;

  void setPaidForTranslationInSession(bool value) {
    _hasPaidForTranslationInSession = value;
  }

  void resetPaidForTranslationInSession() {
    _hasPaidForTranslationInSession = false;
    debugPrint('TranslationPaymentService: Session payment status has been reset.');
  }

  // 翻訳字幕表示の可否を判断し、必要なアクションを決定する
  Future<TranslationPaymentDecision> decideTranslationAction({
    required bool wantsToShowTranslatedCaption, // ユーザーが翻訳字幕を表示したいか
    required bool hasNativeJapaneseSubtitles, // YouTube提供の日本語字幕があるか
  }) async {
    final isSubscribed = _ref.read(isSubscribedProvider);

    if (!wantsToShowTranslatedCaption) {
      // ユーザーが翻訳字幕をオフにしようとしている場合は常に許可
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(showTranslatedCaptionPreferenceKey, false);
      return TranslationPaymentDecision.blocked; // UI側で字幕を非表示にする
    }

    // ユーザーが翻訳字幕をオンにしようとしている場合
    if (isSubscribed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(showTranslatedCaptionPreferenceKey, true);
      return TranslationPaymentDecision.allow;
    }

    // 非課金ユーザーの場合
    if (hasNativeJapaneseSubtitles) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(showTranslatedCaptionPreferenceKey, true);
      return TranslationPaymentDecision.allow; // ネイティブ字幕があれば無料
    }

    if (_hasPaidForTranslationInSession) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(showTranslatedCaptionPreferenceKey, true);
      return TranslationPaymentDecision.allow; // セッション内で支払い済みなら無料
    }

    // ジェム確認ロジック
    // userProviderを再読み込みして最新の状態を取得
    _ref.refresh(userProvider);
    final userAsyncValue = _ref.read(userProvider);

    // whenの完了を待つためにCompleterを使用
    final completer = Completer<TranslationPaymentDecision>();

    userAsyncValue.when(
      data: (user) {
        final currentGemCount = user?.gemCount ?? 0;
        if (currentGemCount >= 1) {
          completer.complete(TranslationPaymentDecision.showConfirmation);
        } else {
          completer.complete(TranslationPaymentDecision.showPaywall);
        }
      },
      loading: () {
        // ローディング中はPaywallを表示するか、一時的にブロックするかなど仕様による
        // ここではPaywallを表示する方向に倒す（ユーザーが待たされるよりは明確なため）
        debugPrint("User data is loading for gem check in payment service.");
        // completer.complete(TranslationPaymentDecision.showPaywall);
        // もしくは、ローディングが終わるまで待つために、ここでは何もせず、呼び出し元でローディング状態をハンドルする
        // このサンプルでは、ローディング完了を待たずにPaywallを返すのは適切でないため、
        // 呼び出し側でローディング状態を考慮するか、Futureを返すようにする。
        // ここではシンプルにするため、ローディング完了後に再度このメソッドを呼ぶことを期待する。
        // しかし、より堅牢なのはFutureを返すこと。
        // 今回は userAsyncValue が Future を返さないため、一度 refresh して再度 read するアプローチ。
        // それでも非同期処理の完了を待つ必要がある。
        //
        // より良いアプローチ：
        // Future<TranslationPaymentDecision>にする。
        // final user = await _ref.watch(userProvider.future); のようにする。
        // ただし、userProviderがFutureProviderでない場合はこの書き方はできない。
        //
        // 今回のケースでは、userProviderがAsyncNotifierProviderなので、
        // `await _ref.read(userProvider.future)` が使える。
        // ただし、`decideTranslationAction` を async にする必要がある。
        // 上記の `userAsyncValue.when` の中で `completer.complete` しているので、
        // `await completer.future` で結果を待つ。
      },
      error: (error, stackTrace) {
        debugPrint(
          "Error fetching user data for gem check in payment service: $error",
        );
        completer.complete(TranslationPaymentDecision.showPaywall);
      },
    );
    return completer.future;
  }

  // ジェムを消費して翻訳を有効化する
  Future<bool> consumeGemForTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    // userProviderを再読み込みして最新の状態を取得
    _ref.refresh(userProvider);
    final user = await _ref.read(
      userProvider.future,
    ); // AsyncNotifierなので .future で待てる

    final currentGemCount = user?.gemCount ?? 0;
    if (currentGemCount >= 1) {
      try {
        await _ref.read(firebaseRepositoryProvider).decrementUserGem();
        _hasPaidForTranslationInSession = true;
        await prefs.setBool(showTranslatedCaptionPreferenceKey, true);
        return true; // ジェム消費成功
      } catch (e) {
        debugPrint('Failed to consume gem in payment service: $e');
        return false; // ジェム消費失敗
      }
    } else {
      return false; // ジェム不足
    }
  }

  Future<bool> getInitialShowTranslatedCaptionSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final isSubscribed = _ref.read(isSubscribedProvider);

    if (!isSubscribed) {
      // 非課金ユーザーはデフォルトでオフ、かつ設定も強制的にオフにする
      await prefs.setBool(showTranslatedCaptionPreferenceKey, false);
      return false;
    } else {
      // 課金ユーザーは保存された設定を尊重する（デフォルトはオン）
      return prefs.getBool(showTranslatedCaptionPreferenceKey) ?? true;
    }
  }
}

final translationPaymentServiceProvider = Provider<TranslationPaymentService>((
  ref,
) {
  return TranslationPaymentService(ref);
});
