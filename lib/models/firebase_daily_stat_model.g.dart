// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_daily_stat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FirebaseDailyStatModelImpl _$$FirebaseDailyStatModelImplFromJson(
        Map<String, dynamic> json) =>
    _$FirebaseDailyStatModelImpl(
      dateString: json['dateString'] as String,
      reviewedCount: (json['reviewedCount'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      learnedDate:
          const TimestampConverter().fromJson(json['learnedDate'] as Timestamp),
    );

Map<String, dynamic> _$$FirebaseDailyStatModelImplToJson(
        _$FirebaseDailyStatModelImpl instance) =>
    <String, dynamic>{
      'dateString': instance.dateString,
      'reviewedCount': instance.reviewedCount,
      'correctCount': instance.correctCount,
      'learnedDate': const TimestampConverter().toJson(instance.learnedDate),
    };
