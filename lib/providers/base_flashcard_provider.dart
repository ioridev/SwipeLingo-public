import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../models/card.dart' as models; // Hiveモデルは不要
import '../../models/firebase_card_model.dart'; // Firebase用モデルをインポート
import '../../models/session_result.dart';
import 'flashcard_providers.dart' show CardFace;

// 共通の状態を定義する Mixin または抽象クラス
// ここでは Mixin を使用
mixin BaseFlashcardState {
  List<FirebaseCardModel> get cards; // Firebaseモデルに変更
  int get currentIndex;
  CardFace get currentFace;
  bool get isLoading;
  String? get errorMessage;
  bool get isSessionComplete;
  SessionResult? get sessionResult;
  String? get currentVideoThumbnailUrl;

  FirebaseCardModel? get currentCard => // Firebaseモデルに変更
      cards.isNotEmpty && currentIndex < cards.length
          ? cards[currentIndex]
          : null;

  // copyWith は各 State クラスで実装する必要がある
  // BaseFlashcardState copyWith({ ... });
}

// 共通のメソッドシグネチャを定義する抽象クラス
abstract class BaseFlashcardNotifier<T extends BaseFlashcardState>
    extends StateNotifier<T> {
  final Ref ref; // 共通で Ref を持つ

  BaseFlashcardNotifier(this.ref, T initialState) : super(initialState);

  // 共通メソッドのシグネチャ
  void flipCard();
  Future<void> handleSwipe(bool correct);
  Future<void> speakCurrentCard();
  Future<void> deleteCurrentCard();
  void refresh(); // カードリスト再読み込み

  // 共通で使う可能性のある内部メソッド (必要に応じて)
  // void _goToNextCard();
  // Future<void> _updateStats(bool correct);
}
