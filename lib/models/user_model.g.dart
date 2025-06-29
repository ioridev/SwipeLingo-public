// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      gemCount: (json['gemCount'] as num?)?.toInt() ?? 3,
      invitationCode: json['invitationCode'] as String,
      hasUsedInvitationCode: json['hasUsedInvitationCode'] as bool? ?? false,
      invitedBy: json['invitedBy'] as String?,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastLearningDate: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['lastLearningDate'], const TimestampConverter().fromJson),
      isHiveDataMigrated: json['isHiveDataMigrated'] as bool? ?? false,
      nativeLanguageCode: json['nativeLanguageCode'] as String? ?? 'ja',
      targetLanguageCode: json['targetLanguageCode'] as String? ?? 'en',
      isLanguageSettingsCompleted:
          json['isLanguageSettingsCompleted'] as bool? ?? false,
      favoriteChannelIds: (json['favoriteChannelIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hasRequestedReview: json['hasRequestedReview'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
      settings: json['settings'] == null
          ? null
          : UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'gemCount': instance.gemCount,
      'invitationCode': instance.invitationCode,
      'hasUsedInvitationCode': instance.hasUsedInvitationCode,
      'invitedBy': instance.invitedBy,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastLearningDate': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.lastLearningDate, const TimestampConverter().toJson),
      'isHiveDataMigrated': instance.isHiveDataMigrated,
      'nativeLanguageCode': instance.nativeLanguageCode,
      'targetLanguageCode': instance.targetLanguageCode,
      'isLanguageSettingsCompleted': instance.isLanguageSettingsCompleted,
      'favoriteChannelIds': instance.favoriteChannelIds,
      'hasRequestedReview': instance.hasRequestedReview,
      'fcmToken': instance.fcmToken,
      'settings': instance.settings,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      preferredNotificationTime:
          json['preferredNotificationTime'] as String? ?? '20:00',
      lastNotificationTime: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['lastNotificationTime'], const TimestampConverter().fromJson),
      lastPatternAnalysis: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['lastPatternAnalysis'], const TimestampConverter().fromJson),
      language: json['language'] as String? ?? 'ja',
      notificationTypes: json['notificationTypes'] == null
          ? null
          : NotificationTypes.fromJson(
              json['notificationTypes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'notificationEnabled': instance.notificationEnabled,
      'preferredNotificationTime': instance.preferredNotificationTime,
      'lastNotificationTime': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.lastNotificationTime, const TimestampConverter().toJson),
      'lastPatternAnalysis': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.lastPatternAnalysis, const TimestampConverter().toJson),
      'language': instance.language,
      'notificationTypes': instance.notificationTypes,
    };

_$NotificationTypesImpl _$$NotificationTypesImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationTypesImpl(
      daily: json['daily'] as bool? ?? true,
      review: json['review'] as bool? ?? true,
      milestone: json['milestone'] as bool? ?? true,
      newContent: json['newContent'] as bool? ?? true,
    );

Map<String, dynamic> _$$NotificationTypesImplToJson(
        _$NotificationTypesImpl instance) =>
    <String, dynamic>{
      'daily': instance.daily,
      'review': instance.review,
      'milestone': instance.milestone,
      'newContent': instance.newContent,
    };
