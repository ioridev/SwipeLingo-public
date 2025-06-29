import 'dart:math';

/// Ebbinghaus 忘却曲線に基づく次回復習日時を計算します。
///
/// [lastReviewed] 前回のレビュー日時。初回の場合は現在日時など。
/// [strength] 現在の記憶強度 (例: 1.0 から始まり、正解で増加、不正解で減少)。
/// [targetRecallProbability] 目標想起確率 (例: 0.8 は 80% の確率で思い出せることを目標とする)。
/// [baseInterval] 記憶強度が 1.0 のときの基本復習間隔（日数）。
///
/// 計算式参考: https://supermemo.guru/wiki/Forgetting_curve
/// R = e^(-t/S)  =>  t = -S * ln(R)
/// ここで R は想起確率、t は時間、S は記憶強度 (Strength)。
/// 次回復習間隔 (日数) = -strength * ln(targetRecallProbability) * baseInterval
DateTime calcNextReview(
  DateTime lastReviewed,
  double strength, {
  double targetRecallProbability = 0.8,
  double baseInterval = 1.0, // 強度1.0の時に1日後に復習
}) {
  // 不正解などで強度が初期値(1.0)未満になった場合
  if (strength < 1.0) {
    // 強度が低い場合は、ほぼ即時復習
    // これにより、次のセッションで取得される可能性が高まる
    return lastReviewed.add(Duration.zero);
  }

  // 次回復習までの日数 (負の対数なので正の値になる) - 強度が1.0以上の場合
  final double daysUntilNextReview =
      -strength * log(targetRecallProbability) * baseInterval;

  // 日数を秒に変換して Duration を作成 (最小・最大制限なし)
  // 計算結果が負にならないように最低0秒を保証
  final intervalInSeconds = (daysUntilNextReview * 24 * 60 * 60).round();
  final intervalDuration = Duration(seconds: max(0, intervalInSeconds));

  final DateTime nextReviewDate = lastReviewed.add(intervalDuration);

  // 簡単のため、時刻は固定 (例: 翌日の午前6時) にするなどの調整も可能
  // return DateTime(nextReviewDate.year, nextReviewDate.month, nextReviewDate.day, 6);

  return nextReviewDate;
}

/// レビュー結果に基づいて記憶強度を更新します。
///
/// [currentStrength] 現在の記憶強度。
/// [correct] レビューが正解だったかどうか。
/// [correctMultiplier] 正解時の強度増加係数。
/// [incorrectMultiplier] 不正解時の強度減少係数。
/// [minStrength] 強度の下限値。
/// [maxStrength] 強度の上限値。
double updateStrength(
  double currentStrength,
  bool correct, {
  double correctMultiplier = 1.7, // 仕様書の値
  double incorrectMultiplier = 0.6, // 仕様書の値
  double minStrength = 0.1, // 0にならないように下限を設定
  double maxStrength = 100.0, // 上限も設定しておくと安全
}) {
  double newStrength;
  if (correct) {
    newStrength = currentStrength * correctMultiplier;
  } else {
    newStrength = currentStrength * incorrectMultiplier;
  }

  // 上限と下限の範囲内に収める
  return newStrength.clamp(minStrength, maxStrength);
}
