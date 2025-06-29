import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart'; // TimestampConverterのため

part 'firebase_daily_stat_model.freezed.dart';
part 'firebase_daily_stat_model.g.dart';

@freezed
class FirebaseDailyStatModel with _$FirebaseDailyStatModel {
  const factory FirebaseDailyStatModel({
    required String dateString, // YYYY-MM-DD 形式のドキュメントIDとしても使用
    @Default(0) int reviewedCount, // その日にレビューしたカード数
    @Default(0) int correctCount, // その日に正解したカード数
    @TimestampConverter() required DateTime learnedDate, // 学習日 (その日の0時0分など)
  }) = _FirebaseDailyStatModel;

  factory FirebaseDailyStatModel.fromJson(Map<String, dynamic> json) =>
      _$FirebaseDailyStatModelFromJson(json);
}
