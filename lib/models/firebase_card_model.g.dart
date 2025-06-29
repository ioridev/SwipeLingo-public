// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FirebaseCardModelImpl _$$FirebaseCardModelImplFromJson(
        Map<String, dynamic> json) =>
    _$FirebaseCardModelImpl(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      nextReview: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['nextReview'], const TimestampConverter().fromJson),
      strength: (json['strength'] as num?)?.toDouble() ?? 1.0,
      lastReviewedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['lastReviewedAt'], const TimestampConverter().fromJson),
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      start: (json['start'] as num?)?.toDouble(),
      end: (json['end'] as num?)?.toDouble(),
      note: json['note'] as String?,
      difficulty: (json['difficulty'] as num?)?.toDouble(),
      screenshotUrl: json['screenshot_url'] as String?,
    );

Map<String, dynamic> _$$FirebaseCardModelImplToJson(
        _$FirebaseCardModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'front': instance.front,
      'back': instance.back,
      'sourceLanguage': instance.sourceLanguage,
      'targetLanguage': instance.targetLanguage,
      'nextReview': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.nextReview, const TimestampConverter().toJson),
      'strength': instance.strength,
      'lastReviewedAt': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.lastReviewedAt, const TimestampConverter().toJson),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'start': instance.start,
      'end': instance.end,
      'note': instance.note,
      'difficulty': instance.difficulty,
      'screenshot_url': instance.screenshotUrl,
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
