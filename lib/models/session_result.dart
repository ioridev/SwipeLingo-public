// import 'card.dart' as models; // Hiveモデルは不要
import 'firebase_card_model.dart'; // Firebase用モデルをインポート

/// 1回の学習セッションの結果を保持するクラス
class SessionResult {
  /// レビュー対象となったカードのリスト (順番はレビュー順)
  final List<FirebaseCardModel> reviewedCards; // Firebaseモデルに変更
  /// 各カードの正誤結果 (Key: card.id, Value: correct (true/false))
  final Map<String, bool> results;

  SessionResult({required this.reviewedCards, required this.results});

  /// 正解数を計算するゲッター
  int get correctCount => results.values.where((correct) => correct).length;

  /// 不正解数を計算するゲッター
  int get incorrectCount => results.values.where((correct) => !correct).length;

  /// 正解率を計算するゲッター (0.0 ~ 1.0)
  double get accuracy {
    if (results.isEmpty) return 0.0;
    return correctCount / results.length;
  }
}
