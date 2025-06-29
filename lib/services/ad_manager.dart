import 'package:flutter/foundation.dart'; // kDebugMode, defaultTargetPlatform のために必要

class AdManager {
  static String get rewardedAdUnitId {
    if (kDebugMode) {
      // デバッグモードの場合
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'ca-app-pub-3940256099942544/5224354917'; // Android Test ID
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return ''; // iOS Test ID
      }
    } else {
      // リリースモードの場合
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'ca-app-pub-5489683693708544/3787453725'; // Android 本番リワードID (訂正後)
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // TODO: iOS用の本番リワード広告ユニットIDが提供されたらここに設定
        return '';
      }
    }
    // サポートされていないプラットフォームの場合はエラーを投げる
    throw UnsupportedError('Unsupported platform for ads');
  }

  // 今後、他の広告タイプ（バナー、インタースティシャルなど）のIDもここに追加できます
  // static String get bannerAdUnitId { ... }
  // static String get interstitialAdUnitId { ... }
}
