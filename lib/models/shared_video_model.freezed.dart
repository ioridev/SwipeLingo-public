// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_video_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SharedVideoModel _$SharedVideoModelFromJson(Map<String, dynamic> json) {
  return _SharedVideoModel.fromJson(json);
}

/// @nodoc
mixin _$SharedVideoModel {
  String get id => throw _privateConstructorUsedError; // YouTube Video ID
  String get url => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get channelName => throw _privateConstructorUsedError;
  String get thumbnailUrl => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError; // 初回登録日時
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError; // 最終更新日時
// キー: 言語コード (例: 'en', 'ja')
// 値: 字幕セグメントのリスト Map{'text': String, 'start': double, 'end': double}
  Map<String, List<Map<String, dynamic>>> get captionsWithTimestamps =>
      throw _privateConstructorUsedError;
  String? get uploaderUid => throw _privateConstructorUsedError;

  /// Serializes this SharedVideoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SharedVideoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SharedVideoModelCopyWith<SharedVideoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedVideoModelCopyWith<$Res> {
  factory $SharedVideoModelCopyWith(
          SharedVideoModel value, $Res Function(SharedVideoModel) then) =
      _$SharedVideoModelCopyWithImpl<$Res, SharedVideoModel>;
  @useResult
  $Res call(
      {String id,
      String url,
      String title,
      String channelName,
      String thumbnailUrl,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      Map<String, List<Map<String, dynamic>>> captionsWithTimestamps,
      String? uploaderUid});
}

/// @nodoc
class _$SharedVideoModelCopyWithImpl<$Res, $Val extends SharedVideoModel>
    implements $SharedVideoModelCopyWith<$Res> {
  _$SharedVideoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SharedVideoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? title = null,
    Object? channelName = null,
    Object? thumbnailUrl = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? captionsWithTimestamps = null,
    Object? uploaderUid = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      channelName: null == channelName
          ? _value.channelName
          : channelName // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      captionsWithTimestamps: null == captionsWithTimestamps
          ? _value.captionsWithTimestamps
          : captionsWithTimestamps // ignore: cast_nullable_to_non_nullable
              as Map<String, List<Map<String, dynamic>>>,
      uploaderUid: freezed == uploaderUid
          ? _value.uploaderUid
          : uploaderUid // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SharedVideoModelImplCopyWith<$Res>
    implements $SharedVideoModelCopyWith<$Res> {
  factory _$$SharedVideoModelImplCopyWith(_$SharedVideoModelImpl value,
          $Res Function(_$SharedVideoModelImpl) then) =
      __$$SharedVideoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String url,
      String title,
      String channelName,
      String thumbnailUrl,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      Map<String, List<Map<String, dynamic>>> captionsWithTimestamps,
      String? uploaderUid});
}

/// @nodoc
class __$$SharedVideoModelImplCopyWithImpl<$Res>
    extends _$SharedVideoModelCopyWithImpl<$Res, _$SharedVideoModelImpl>
    implements _$$SharedVideoModelImplCopyWith<$Res> {
  __$$SharedVideoModelImplCopyWithImpl(_$SharedVideoModelImpl _value,
      $Res Function(_$SharedVideoModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SharedVideoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? title = null,
    Object? channelName = null,
    Object? thumbnailUrl = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? captionsWithTimestamps = null,
    Object? uploaderUid = freezed,
  }) {
    return _then(_$SharedVideoModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      channelName: null == channelName
          ? _value.channelName
          : channelName // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      captionsWithTimestamps: null == captionsWithTimestamps
          ? _value._captionsWithTimestamps
          : captionsWithTimestamps // ignore: cast_nullable_to_non_nullable
              as Map<String, List<Map<String, dynamic>>>,
      uploaderUid: freezed == uploaderUid
          ? _value.uploaderUid
          : uploaderUid // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SharedVideoModelImpl implements _SharedVideoModel {
  const _$SharedVideoModelImpl(
      {required this.id,
      required this.url,
      required this.title,
      required this.channelName,
      required this.thumbnailUrl,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt,
      final Map<String, List<Map<String, dynamic>>> captionsWithTimestamps =
          const {},
      this.uploaderUid})
      : _captionsWithTimestamps = captionsWithTimestamps;

  factory _$SharedVideoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharedVideoModelImplFromJson(json);

  @override
  final String id;
// YouTube Video ID
  @override
  final String url;
  @override
  final String title;
  @override
  final String channelName;
  @override
  final String thumbnailUrl;
  @override
  @TimestampConverter()
  final DateTime createdAt;
// 初回登録日時
  @override
  @TimestampConverter()
  final DateTime updatedAt;
// 最終更新日時
// キー: 言語コード (例: 'en', 'ja')
// 値: 字幕セグメントのリスト Map{'text': String, 'start': double, 'end': double}
  final Map<String, List<Map<String, dynamic>>> _captionsWithTimestamps;
// 最終更新日時
// キー: 言語コード (例: 'en', 'ja')
// 値: 字幕セグメントのリスト Map{'text': String, 'start': double, 'end': double}
  @override
  @JsonKey()
  Map<String, List<Map<String, dynamic>>> get captionsWithTimestamps {
    if (_captionsWithTimestamps is EqualUnmodifiableMapView)
      return _captionsWithTimestamps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_captionsWithTimestamps);
  }

  @override
  final String? uploaderUid;

  @override
  String toString() {
    return 'SharedVideoModel(id: $id, url: $url, title: $title, channelName: $channelName, thumbnailUrl: $thumbnailUrl, createdAt: $createdAt, updatedAt: $updatedAt, captionsWithTimestamps: $captionsWithTimestamps, uploaderUid: $uploaderUid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedVideoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.channelName, channelName) ||
                other.channelName == channelName) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
                other._captionsWithTimestamps, _captionsWithTimestamps) &&
            (identical(other.uploaderUid, uploaderUid) ||
                other.uploaderUid == uploaderUid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      url,
      title,
      channelName,
      thumbnailUrl,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_captionsWithTimestamps),
      uploaderUid);

  /// Create a copy of SharedVideoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedVideoModelImplCopyWith<_$SharedVideoModelImpl> get copyWith =>
      __$$SharedVideoModelImplCopyWithImpl<_$SharedVideoModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SharedVideoModelImplToJson(
      this,
    );
  }
}

abstract class _SharedVideoModel implements SharedVideoModel {
  const factory _SharedVideoModel(
      {required final String id,
      required final String url,
      required final String title,
      required final String channelName,
      required final String thumbnailUrl,
      @TimestampConverter() required final DateTime createdAt,
      @TimestampConverter() required final DateTime updatedAt,
      final Map<String, List<Map<String, dynamic>>> captionsWithTimestamps,
      final String? uploaderUid}) = _$SharedVideoModelImpl;

  factory _SharedVideoModel.fromJson(Map<String, dynamic> json) =
      _$SharedVideoModelImpl.fromJson;

  @override
  String get id; // YouTube Video ID
  @override
  String get url;
  @override
  String get title;
  @override
  String get channelName;
  @override
  String get thumbnailUrl;
  @override
  @TimestampConverter()
  DateTime get createdAt; // 初回登録日時
  @override
  @TimestampConverter()
  DateTime get updatedAt; // 最終更新日時
// キー: 言語コード (例: 'en', 'ja')
// 値: 字幕セグメントのリスト Map{'text': String, 'start': double, 'end': double}
  @override
  Map<String, List<Map<String, dynamic>>> get captionsWithTimestamps;
  @override
  String? get uploaderUid;

  /// Create a copy of SharedVideoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SharedVideoModelImplCopyWith<_$SharedVideoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
