// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firebase_card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FirebaseCardModel _$FirebaseCardModelFromJson(Map<String, dynamic> json) {
  return _FirebaseCardModel.fromJson(json);
}

/// @nodoc
mixin _$FirebaseCardModel {
  String get id =>
      throw _privateConstructorUsedError; // videoId + serial (例: abc123-001) または Firestoreで自動生成ID
  String get videoId =>
      throw _privateConstructorUsedError; // どの動画から生成されたかを示す SharedVideoModel.id
  String get front => throw _privateConstructorUsedError;
  String get back => throw _privateConstructorUsedError;
  String get sourceLanguage =>
      throw _privateConstructorUsedError; // 元文の言語コード (例: 'en')
  String get targetLanguage =>
      throw _privateConstructorUsedError; // 翻訳文の言語コード (例: 'ja')
// SRS 関連
  @TimestampConverter()
  DateTime? get nextReview =>
      throw _privateConstructorUsedError; // 次回復習日時 (nullの場合は未学習)
  double get strength => throw _privateConstructorUsedError; // SRS強度
  @TimestampConverter()
  DateTime? get lastReviewedAt =>
      throw _privateConstructorUsedError; // 最終レビュー日時
// メタデータ
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError; // カード作成日時
  double? get start => throw _privateConstructorUsedError; // 字幕の開始時間 (秒)
  double? get end => throw _privateConstructorUsedError; // 字幕の終了時間 (秒)
  String? get note => throw _privateConstructorUsedError; // 任意メモ (LLM生成)
  double? get difficulty =>
      throw _privateConstructorUsedError; // 難易度 (0.0-1.0, LLM生成)
  @JsonKey(name: 'screenshot_url')
  String? get screenshotUrl => throw _privateConstructorUsedError;

  /// Serializes this FirebaseCardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseCardModelCopyWith<FirebaseCardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseCardModelCopyWith<$Res> {
  factory $FirebaseCardModelCopyWith(
          FirebaseCardModel value, $Res Function(FirebaseCardModel) then) =
      _$FirebaseCardModelCopyWithImpl<$Res, FirebaseCardModel>;
  @useResult
  $Res call(
      {String id,
      String videoId,
      String front,
      String back,
      String sourceLanguage,
      String targetLanguage,
      @TimestampConverter() DateTime? nextReview,
      double strength,
      @TimestampConverter() DateTime? lastReviewedAt,
      @TimestampConverter() DateTime createdAt,
      double? start,
      double? end,
      String? note,
      double? difficulty,
      @JsonKey(name: 'screenshot_url') String? screenshotUrl});
}

/// @nodoc
class _$FirebaseCardModelCopyWithImpl<$Res, $Val extends FirebaseCardModel>
    implements $FirebaseCardModelCopyWith<$Res> {
  _$FirebaseCardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoId = null,
    Object? front = null,
    Object? back = null,
    Object? sourceLanguage = null,
    Object? targetLanguage = null,
    Object? nextReview = freezed,
    Object? strength = null,
    Object? lastReviewedAt = freezed,
    Object? createdAt = null,
    Object? start = freezed,
    Object? end = freezed,
    Object? note = freezed,
    Object? difficulty = freezed,
    Object? screenshotUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _value.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
      sourceLanguage: null == sourceLanguage
          ? _value.sourceLanguage
          : sourceLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguage: null == targetLanguage
          ? _value.targetLanguage
          : targetLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      nextReview: freezed == nextReview
          ? _value.nextReview
          : nextReview // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as double,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      start: freezed == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as double?,
      end: freezed == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as double?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as double?,
      screenshotUrl: freezed == screenshotUrl
          ? _value.screenshotUrl
          : screenshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebaseCardModelImplCopyWith<$Res>
    implements $FirebaseCardModelCopyWith<$Res> {
  factory _$$FirebaseCardModelImplCopyWith(_$FirebaseCardModelImpl value,
          $Res Function(_$FirebaseCardModelImpl) then) =
      __$$FirebaseCardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String videoId,
      String front,
      String back,
      String sourceLanguage,
      String targetLanguage,
      @TimestampConverter() DateTime? nextReview,
      double strength,
      @TimestampConverter() DateTime? lastReviewedAt,
      @TimestampConverter() DateTime createdAt,
      double? start,
      double? end,
      String? note,
      double? difficulty,
      @JsonKey(name: 'screenshot_url') String? screenshotUrl});
}

/// @nodoc
class __$$FirebaseCardModelImplCopyWithImpl<$Res>
    extends _$FirebaseCardModelCopyWithImpl<$Res, _$FirebaseCardModelImpl>
    implements _$$FirebaseCardModelImplCopyWith<$Res> {
  __$$FirebaseCardModelImplCopyWithImpl(_$FirebaseCardModelImpl _value,
      $Res Function(_$FirebaseCardModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebaseCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoId = null,
    Object? front = null,
    Object? back = null,
    Object? sourceLanguage = null,
    Object? targetLanguage = null,
    Object? nextReview = freezed,
    Object? strength = null,
    Object? lastReviewedAt = freezed,
    Object? createdAt = null,
    Object? start = freezed,
    Object? end = freezed,
    Object? note = freezed,
    Object? difficulty = freezed,
    Object? screenshotUrl = freezed,
  }) {
    return _then(_$FirebaseCardModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _value.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
      sourceLanguage: null == sourceLanguage
          ? _value.sourceLanguage
          : sourceLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguage: null == targetLanguage
          ? _value.targetLanguage
          : targetLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      nextReview: freezed == nextReview
          ? _value.nextReview
          : nextReview // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as double,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      start: freezed == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as double?,
      end: freezed == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as double?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as double?,
      screenshotUrl: freezed == screenshotUrl
          ? _value.screenshotUrl
          : screenshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseCardModelImpl implements _FirebaseCardModel {
  const _$FirebaseCardModelImpl(
      {required this.id,
      required this.videoId,
      required this.front,
      required this.back,
      required this.sourceLanguage,
      required this.targetLanguage,
      @TimestampConverter() this.nextReview,
      this.strength = 1.0,
      @TimestampConverter() this.lastReviewedAt,
      @TimestampConverter() required this.createdAt,
      this.start,
      this.end,
      this.note,
      this.difficulty,
      @JsonKey(name: 'screenshot_url') this.screenshotUrl});

  factory _$FirebaseCardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseCardModelImplFromJson(json);

  @override
  final String id;
// videoId + serial (例: abc123-001) または Firestoreで自動生成ID
  @override
  final String videoId;
// どの動画から生成されたかを示す SharedVideoModel.id
  @override
  final String front;
  @override
  final String back;
  @override
  final String sourceLanguage;
// 元文の言語コード (例: 'en')
  @override
  final String targetLanguage;
// 翻訳文の言語コード (例: 'ja')
// SRS 関連
  @override
  @TimestampConverter()
  final DateTime? nextReview;
// 次回復習日時 (nullの場合は未学習)
  @override
  @JsonKey()
  final double strength;
// SRS強度
  @override
  @TimestampConverter()
  final DateTime? lastReviewedAt;
// 最終レビュー日時
// メタデータ
  @override
  @TimestampConverter()
  final DateTime createdAt;
// カード作成日時
  @override
  final double? start;
// 字幕の開始時間 (秒)
  @override
  final double? end;
// 字幕の終了時間 (秒)
  @override
  final String? note;
// 任意メモ (LLM生成)
  @override
  final double? difficulty;
// 難易度 (0.0-1.0, LLM生成)
  @override
  @JsonKey(name: 'screenshot_url')
  final String? screenshotUrl;

  @override
  String toString() {
    return 'FirebaseCardModel(id: $id, videoId: $videoId, front: $front, back: $back, sourceLanguage: $sourceLanguage, targetLanguage: $targetLanguage, nextReview: $nextReview, strength: $strength, lastReviewedAt: $lastReviewedAt, createdAt: $createdAt, start: $start, end: $end, note: $note, difficulty: $difficulty, screenshotUrl: $screenshotUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseCardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.back, back) || other.back == back) &&
            (identical(other.sourceLanguage, sourceLanguage) ||
                other.sourceLanguage == sourceLanguage) &&
            (identical(other.targetLanguage, targetLanguage) ||
                other.targetLanguage == targetLanguage) &&
            (identical(other.nextReview, nextReview) ||
                other.nextReview == nextReview) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            (identical(other.lastReviewedAt, lastReviewedAt) ||
                other.lastReviewedAt == lastReviewedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.screenshotUrl, screenshotUrl) ||
                other.screenshotUrl == screenshotUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      videoId,
      front,
      back,
      sourceLanguage,
      targetLanguage,
      nextReview,
      strength,
      lastReviewedAt,
      createdAt,
      start,
      end,
      note,
      difficulty,
      screenshotUrl);

  /// Create a copy of FirebaseCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseCardModelImplCopyWith<_$FirebaseCardModelImpl> get copyWith =>
      __$$FirebaseCardModelImplCopyWithImpl<_$FirebaseCardModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseCardModelImplToJson(
      this,
    );
  }
}

abstract class _FirebaseCardModel implements FirebaseCardModel {
  const factory _FirebaseCardModel(
          {required final String id,
          required final String videoId,
          required final String front,
          required final String back,
          required final String sourceLanguage,
          required final String targetLanguage,
          @TimestampConverter() final DateTime? nextReview,
          final double strength,
          @TimestampConverter() final DateTime? lastReviewedAt,
          @TimestampConverter() required final DateTime createdAt,
          final double? start,
          final double? end,
          final String? note,
          final double? difficulty,
          @JsonKey(name: 'screenshot_url') final String? screenshotUrl}) =
      _$FirebaseCardModelImpl;

  factory _FirebaseCardModel.fromJson(Map<String, dynamic> json) =
      _$FirebaseCardModelImpl.fromJson;

  @override
  String get id; // videoId + serial (例: abc123-001) または Firestoreで自動生成ID
  @override
  String get videoId; // どの動画から生成されたかを示す SharedVideoModel.id
  @override
  String get front;
  @override
  String get back;
  @override
  String get sourceLanguage; // 元文の言語コード (例: 'en')
  @override
  String get targetLanguage; // 翻訳文の言語コード (例: 'ja')
// SRS 関連
  @override
  @TimestampConverter()
  DateTime? get nextReview; // 次回復習日時 (nullの場合は未学習)
  @override
  double get strength; // SRS強度
  @override
  @TimestampConverter()
  DateTime? get lastReviewedAt; // 最終レビュー日時
// メタデータ
  @override
  @TimestampConverter()
  DateTime get createdAt; // カード作成日時
  @override
  double? get start; // 字幕の開始時間 (秒)
  @override
  double? get end; // 字幕の終了時間 (秒)
  @override
  String? get note; // 任意メモ (LLM生成)
  @override
  double? get difficulty; // 難易度 (0.0-1.0, LLM生成)
  @override
  @JsonKey(name: 'screenshot_url')
  String? get screenshotUrl;

  /// Create a copy of FirebaseCardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseCardModelImplCopyWith<_$FirebaseCardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
