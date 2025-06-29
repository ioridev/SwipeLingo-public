import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart'; // TimestampConverterのため

part 'firebase_card_model.freezed.dart';
part 'firebase_card_model.g.dart';

@freezed
class FirebaseCardModel with _$FirebaseCardModel {
  const factory FirebaseCardModel({
    required String id, // videoId + serial (例: abc123-001) または Firestoreで自動生成ID
    required String videoId, // どの動画から生成されたかを示す SharedVideoModel.id
    required String front,
    required String back,
    required String sourceLanguage, // 元文の言語コード (例: 'en')
    required String targetLanguage, // 翻訳文の言語コード (例: 'ja')
    // SRS 関連
    @TimestampConverter() DateTime? nextReview, // 次回復習日時 (nullの場合は未学習)
    @Default(1.0) double strength, // SRS強度
    @TimestampConverter() DateTime? lastReviewedAt, // 最終レビュー日時
    // メタデータ
    @TimestampConverter() required DateTime createdAt, // カード作成日時
    double? start, // 字幕の開始時間 (秒)
    double? end, // 字幕の終了時間 (秒)
    String? note, // 任意メモ (LLM生成)
    double? difficulty, // 難易度 (0.0-1.0, LLM生成)
    @JsonKey(name: 'screenshot_url') String? screenshotUrl, // スクリーンショット画像のURL
  }) = _FirebaseCardModel;

  factory FirebaseCardModel.fromJson(Map<String, dynamic> json) =>
      _$FirebaseCardModelFromJson(json);
}
