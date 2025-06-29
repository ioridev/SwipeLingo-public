// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlaylistModel _$PlaylistModelFromJson(Map<String, dynamic> json) {
  return _PlaylistModel.fromJson(json);
}

/// @nodoc
mixin _$PlaylistModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get videoIds => throw _privateConstructorUsedError;
  PlaylistType get type => throw _privateConstructorUsedError;
  int get videoCount => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  /// Serializes this PlaylistModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaylistModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaylistModelCopyWith<PlaylistModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistModelCopyWith<$Res> {
  factory $PlaylistModelCopyWith(
          PlaylistModel value, $Res Function(PlaylistModel) then) =
      _$PlaylistModelCopyWithImpl<$Res, PlaylistModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<String> videoIds,
      PlaylistType type,
      int videoCount,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      String? thumbnailUrl});
}

/// @nodoc
class _$PlaylistModelCopyWithImpl<$Res, $Val extends PlaylistModel>
    implements $PlaylistModelCopyWith<$Res> {
  _$PlaylistModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaylistModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? videoIds = null,
    Object? type = null,
    Object? videoCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      videoIds: null == videoIds
          ? _value.videoIds
          : videoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlaylistType,
      videoCount: null == videoCount
          ? _value.videoCount
          : videoCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistModelImplCopyWith<$Res>
    implements $PlaylistModelCopyWith<$Res> {
  factory _$$PlaylistModelImplCopyWith(
          _$PlaylistModelImpl value, $Res Function(_$PlaylistModelImpl) then) =
      __$$PlaylistModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<String> videoIds,
      PlaylistType type,
      int videoCount,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      String? thumbnailUrl});
}

/// @nodoc
class __$$PlaylistModelImplCopyWithImpl<$Res>
    extends _$PlaylistModelCopyWithImpl<$Res, _$PlaylistModelImpl>
    implements _$$PlaylistModelImplCopyWith<$Res> {
  __$$PlaylistModelImplCopyWithImpl(
      _$PlaylistModelImpl _value, $Res Function(_$PlaylistModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaylistModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? videoIds = null,
    Object? type = null,
    Object? videoCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(_$PlaylistModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      videoIds: null == videoIds
          ? _value._videoIds
          : videoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlaylistType,
      videoCount: null == videoCount
          ? _value.videoCount
          : videoCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistModelImpl implements _PlaylistModel {
  const _$PlaylistModelImpl(
      {required this.id,
      required this.name,
      this.description = '',
      final List<String> videoIds = const [],
      this.type = PlaylistType.custom,
      this.videoCount = 0,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt,
      this.thumbnailUrl})
      : _videoIds = videoIds;

  factory _$PlaylistModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  final List<String> _videoIds;
  @override
  @JsonKey()
  List<String> get videoIds {
    if (_videoIds is EqualUnmodifiableListView) return _videoIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_videoIds);
  }

  @override
  @JsonKey()
  final PlaylistType type;
  @override
  @JsonKey()
  final int videoCount;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  final String? thumbnailUrl;

  @override
  String toString() {
    return 'PlaylistModel(id: $id, name: $name, description: $description, videoIds: $videoIds, type: $type, videoCount: $videoCount, createdAt: $createdAt, updatedAt: $updatedAt, thumbnailUrl: $thumbnailUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._videoIds, _videoIds) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.videoCount, videoCount) ||
                other.videoCount == videoCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      const DeepCollectionEquality().hash(_videoIds),
      type,
      videoCount,
      createdAt,
      updatedAt,
      thumbnailUrl);

  /// Create a copy of PlaylistModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistModelImplCopyWith<_$PlaylistModelImpl> get copyWith =>
      __$$PlaylistModelImplCopyWithImpl<_$PlaylistModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistModelImplToJson(
      this,
    );
  }
}

abstract class _PlaylistModel implements PlaylistModel {
  const factory _PlaylistModel(
      {required final String id,
      required final String name,
      final String description,
      final List<String> videoIds,
      final PlaylistType type,
      final int videoCount,
      @TimestampConverter() required final DateTime createdAt,
      @TimestampConverter() required final DateTime updatedAt,
      final String? thumbnailUrl}) = _$PlaylistModelImpl;

  factory _PlaylistModel.fromJson(Map<String, dynamic> json) =
      _$PlaylistModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  List<String> get videoIds;
  @override
  PlaylistType get type;
  @override
  int get videoCount;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  String? get thumbnailUrl;

  /// Create a copy of PlaylistModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaylistModelImplCopyWith<_$PlaylistModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlaylistItemModel _$PlaylistItemModelFromJson(Map<String, dynamic> json) {
  return _PlaylistItemModel.fromJson(json);
}

/// @nodoc
mixin _$PlaylistItemModel {
  String get videoId => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get addedAt => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this PlaylistItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaylistItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaylistItemModelCopyWith<PlaylistItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistItemModelCopyWith<$Res> {
  factory $PlaylistItemModelCopyWith(
          PlaylistItemModel value, $Res Function(PlaylistItemModel) then) =
      _$PlaylistItemModelCopyWithImpl<$Res, PlaylistItemModel>;
  @useResult
  $Res call(
      {String videoId,
      int order,
      @TimestampConverter() DateTime addedAt,
      String? note});
}

/// @nodoc
class _$PlaylistItemModelCopyWithImpl<$Res, $Val extends PlaylistItemModel>
    implements $PlaylistItemModelCopyWith<$Res> {
  _$PlaylistItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaylistItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? order = null,
    Object? addedAt = null,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistItemModelImplCopyWith<$Res>
    implements $PlaylistItemModelCopyWith<$Res> {
  factory _$$PlaylistItemModelImplCopyWith(_$PlaylistItemModelImpl value,
          $Res Function(_$PlaylistItemModelImpl) then) =
      __$$PlaylistItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String videoId,
      int order,
      @TimestampConverter() DateTime addedAt,
      String? note});
}

/// @nodoc
class __$$PlaylistItemModelImplCopyWithImpl<$Res>
    extends _$PlaylistItemModelCopyWithImpl<$Res, _$PlaylistItemModelImpl>
    implements _$$PlaylistItemModelImplCopyWith<$Res> {
  __$$PlaylistItemModelImplCopyWithImpl(_$PlaylistItemModelImpl _value,
      $Res Function(_$PlaylistItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaylistItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? order = null,
    Object? addedAt = null,
    Object? note = freezed,
  }) {
    return _then(_$PlaylistItemModelImpl(
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistItemModelImpl implements _PlaylistItemModel {
  const _$PlaylistItemModelImpl(
      {required this.videoId,
      required this.order,
      @TimestampConverter() required this.addedAt,
      this.note});

  factory _$PlaylistItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistItemModelImplFromJson(json);

  @override
  final String videoId;
  @override
  final int order;
  @override
  @TimestampConverter()
  final DateTime addedAt;
  @override
  final String? note;

  @override
  String toString() {
    return 'PlaylistItemModel(videoId: $videoId, order: $order, addedAt: $addedAt, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistItemModelImpl &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, videoId, order, addedAt, note);

  /// Create a copy of PlaylistItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistItemModelImplCopyWith<_$PlaylistItemModelImpl> get copyWith =>
      __$$PlaylistItemModelImplCopyWithImpl<_$PlaylistItemModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistItemModelImplToJson(
      this,
    );
  }
}

abstract class _PlaylistItemModel implements PlaylistItemModel {
  const factory _PlaylistItemModel(
      {required final String videoId,
      required final int order,
      @TimestampConverter() required final DateTime addedAt,
      final String? note}) = _$PlaylistItemModelImpl;

  factory _PlaylistItemModel.fromJson(Map<String, dynamic> json) =
      _$PlaylistItemModelImpl.fromJson;

  @override
  String get videoId;
  @override
  int get order;
  @override
  @TimestampConverter()
  DateTime get addedAt;
  @override
  String? get note;

  /// Create a copy of PlaylistItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaylistItemModelImplCopyWith<_$PlaylistItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
