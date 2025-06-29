import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

part 'playlist_model.freezed.dart';
part 'playlist_model.g.dart';

@freezed
class PlaylistModel with _$PlaylistModel {
  const factory PlaylistModel({
    required String id,
    required String name,
    @Default('') String description,
    @Default([]) List<String> videoIds,
    @Default(PlaylistType.custom) PlaylistType type,
    @Default(0) int videoCount,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    String? thumbnailUrl,
  }) = _PlaylistModel;

  factory PlaylistModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistModelFromJson(json);
}

enum PlaylistType {
  @JsonValue('favorites')
  favorites,
  @JsonValue('watchLater')
  watchLater,
  @JsonValue('custom')
  custom,
}

@freezed
class PlaylistItemModel with _$PlaylistItemModel {
  const factory PlaylistItemModel({
    required String videoId,
    required int order,
    @TimestampConverter() required DateTime addedAt,
    String? note,
  }) = _PlaylistItemModel;

  factory PlaylistItemModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistItemModelFromJson(json);
}

