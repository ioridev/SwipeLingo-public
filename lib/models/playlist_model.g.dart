// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaylistModelImpl _$$PlaylistModelImplFromJson(Map<String, dynamic> json) =>
    _$PlaylistModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      videoIds: (json['videoIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      type: $enumDecodeNullable(_$PlaylistTypeEnumMap, json['type']) ??
          PlaylistType.custom,
      videoCount: (json['videoCount'] as num?)?.toInt() ?? 0,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      updatedAt:
          const TimestampConverter().fromJson(json['updatedAt'] as Timestamp),
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );

Map<String, dynamic> _$$PlaylistModelImplToJson(_$PlaylistModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'videoIds': instance.videoIds,
      'type': _$PlaylistTypeEnumMap[instance.type]!,
      'videoCount': instance.videoCount,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'thumbnailUrl': instance.thumbnailUrl,
    };

const _$PlaylistTypeEnumMap = {
  PlaylistType.favorites: 'favorites',
  PlaylistType.watchLater: 'watchLater',
  PlaylistType.custom: 'custom',
};

_$PlaylistItemModelImpl _$$PlaylistItemModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PlaylistItemModelImpl(
      videoId: json['videoId'] as String,
      order: (json['order'] as num).toInt(),
      addedAt:
          const TimestampConverter().fromJson(json['addedAt'] as Timestamp),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$PlaylistItemModelImplToJson(
        _$PlaylistItemModelImpl instance) =>
    <String, dynamic>{
      'videoId': instance.videoId,
      'order': instance.order,
      'addedAt': const TimestampConverter().toJson(instance.addedAt),
      'note': instance.note,
    };
