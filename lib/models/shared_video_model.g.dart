// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharedVideoModelImpl _$$SharedVideoModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SharedVideoModelImpl(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      channelName: json['channelName'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      updatedAt:
          const TimestampConverter().fromJson(json['updatedAt'] as Timestamp),
      captionsWithTimestamps:
          (json['captionsWithTimestamps'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    (e as List<dynamic>)
                        .map((e) => e as Map<String, dynamic>)
                        .toList()),
              ) ??
              const {},
      uploaderUid: json['uploaderUid'] as String?,
    );

Map<String, dynamic> _$$SharedVideoModelImplToJson(
        _$SharedVideoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'channelName': instance.channelName,
      'thumbnailUrl': instance.thumbnailUrl,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'captionsWithTimestamps': instance.captionsWithTimestamps,
      'uploaderUid': instance.uploaderUid,
    };
