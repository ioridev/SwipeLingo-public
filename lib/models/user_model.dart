import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestampのために必要

part 'user_model.freezed.dart';
part 'user_model.g.dart';

// FirestoreのTimestampをDateTimeに変換するためのコンバータ
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    @TimestampConverter() required DateTime createdAt,
    @Default(3) int gemCount,
    required String invitationCode,
    @Default(false) bool hasUsedInvitationCode,
    String? invitedBy,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @TimestampConverter() DateTime? lastLearningDate,
    @Default(false) bool isHiveDataMigrated,
    @Default('ja') String nativeLanguageCode,
    @Default('en') String targetLanguageCode,
    @Default(false) bool isLanguageSettingsCompleted,
    @Default([]) List<String> favoriteChannelIds,
    @Default(false) bool hasRequestedReview,
    String? fcmToken,
    UserSettings? settings,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(true) bool notificationEnabled,
    @Default('20:00') String preferredNotificationTime,
    @TimestampConverter() DateTime? lastNotificationTime,
    @TimestampConverter() DateTime? lastPatternAnalysis,
    @Default('ja') String language,
    NotificationTypes? notificationTypes,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

@freezed
class NotificationTypes with _$NotificationTypes {
  const factory NotificationTypes({
    @Default(true) bool daily,
    @Default(true) bool review,
    @Default(true) bool milestone,
    @Default(true) bool newContent,
  }) = _NotificationTypes;

  factory NotificationTypes.fromJson(Map<String, dynamic> json) =>
      _$NotificationTypesFromJson(json);
}
