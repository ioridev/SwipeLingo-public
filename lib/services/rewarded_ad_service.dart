import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:swipelingo/providers/subscription_provider.dart'; // 追加
import 'ad_manager.dart';

final rewardedAdServiceProvider =
    StateNotifierProvider<RewardedAdNotifier, RewardedAdState>((ref) {
      return RewardedAdNotifier(ref);
    });

class RewardedAdState {
  final bool isAdLoaded;
  final bool isLoading;

  RewardedAdState({this.isAdLoaded = false, this.isLoading = false});

  RewardedAdState copyWith({bool? isAdLoaded, bool? isLoading}) {
    return RewardedAdState(
      isAdLoaded: isAdLoaded ?? this.isAdLoaded,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RewardedAdNotifier extends StateNotifier<RewardedAdState> {
  final Ref _ref;
  RewardedAd? _rewardedAd;
  Completer<bool>? _adCompleter;

  RewardedAdNotifier(this._ref) : super(RewardedAdState());

  String get _rewardedAdUnitId => AdManager.rewardedAdUnitId;

  Future<void> loadAd() async {
    if (state.isAdLoaded || state.isLoading) {
      debugPrint(
        '[RewardedAdNotifier] Ad already loaded or loading in progress.',
      );
      return;
    }
    state = state.copyWith(isLoading: true);
    debugPrint('[RewardedAdNotifier] Loading rewarded ad...');
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('[RewardedAdNotifier] Rewarded ad loaded.');
          _rewardedAd = ad;
          state = state.copyWith(isAdLoaded: true, isLoading: false);
          _setFullScreenContentCallback();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('[RewardedAdNotifier] RewardedAd failed to load: $error');
          _rewardedAd = null;
          state = state.copyWith(isAdLoaded: false, isLoading: false);
        },
      ),
    );
  }

  void _setFullScreenContentCallback() {
    if (_rewardedAd == null) return;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent:
          (RewardedAd ad) => debugPrint(
            '[RewardedAdNotifier] $ad onAdShowedFullScreenContent.',
          ),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('[RewardedAdNotifier] $ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _rewardedAd = null;
        state = state.copyWith(isAdLoaded: false);
        _adCompleter?.complete(false); // 報酬を得ずに閉じた場合
        loadAd(); // 次の広告をロード
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint(
          '[RewardedAdNotifier] $ad onAdFailedToShowFullScreenContent: $error',
        );
        ad.dispose();
        _rewardedAd = null;
        state = state.copyWith(isAdLoaded: false);
        _adCompleter?.complete(false); // 表示失敗
        loadAd(); // 次の広告をロード
      },
    );
  }

  Future<bool> showAd() async {
    final isSubscribed = _ref.read(isSubscribedProvider); // 課金状態を確認

    if (isSubscribed) {
      debugPrint('[RewardedAdNotifier] User is subscribed. Skipping ad.');
      return true;
    }

    if (_rewardedAd != null && state.isAdLoaded) {
      _adCompleter = Completer<bool>();
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint(
            '[RewardedAdNotifier] User earned reward: ${reward.amount} ${reward.type}',
          );
          _adCompleter?.complete(true); // 報酬獲得
        },
      );
      return _adCompleter!.future;
    } else {
      debugPrint(
        '[RewardedAdNotifier] Attempted to show rewarded ad, but it was not loaded yet.',
      );
      await loadAd();
      return false;
    }
  }

  void disposeAd() {
    // Renamed from dispose to avoid conflict with StateNotifier's dispose
    _rewardedAd?.dispose();
    _rewardedAd = null;
    state = state.copyWith(isAdLoaded: false);
  }
}
