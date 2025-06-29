// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firebase_daily_stat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FirebaseDailyStatModel _$FirebaseDailyStatModelFromJson(
    Map<String, dynamic> json) {
  return _FirebaseDailyStatModel.fromJson(json);
}

/// @nodoc
mixin _$FirebaseDailyStatModel {
  String get dateString =>
      throw _privateConstructorUsedError; // YYYY-MM-DD 形式のドキュメントIDとしても使用
  int get reviewedCount => throw _privateConstructorUsedError; // その日にレビューしたカード数
  int get correctCount => throw _privateConstructorUsedError; // その日に正解したカード数
  @TimestampConverter()
  DateTime get learnedDate => throw _privateConstructorUsedError;

  /// Serializes this FirebaseDailyStatModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseDailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseDailyStatModelCopyWith<FirebaseDailyStatModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseDailyStatModelCopyWith<$Res> {
  factory $FirebaseDailyStatModelCopyWith(FirebaseDailyStatModel value,
          $Res Function(FirebaseDailyStatModel) then) =
      _$FirebaseDailyStatModelCopyWithImpl<$Res, FirebaseDailyStatModel>;
  @useResult
  $Res call(
      {String dateString,
      int reviewedCount,
      int correctCount,
      @TimestampConverter() DateTime learnedDate});
}

/// @nodoc
class _$FirebaseDailyStatModelCopyWithImpl<$Res,
        $Val extends FirebaseDailyStatModel>
    implements $FirebaseDailyStatModelCopyWith<$Res> {
  _$FirebaseDailyStatModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseDailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateString = null,
    Object? reviewedCount = null,
    Object? correctCount = null,
    Object? learnedDate = null,
  }) {
    return _then(_value.copyWith(
      dateString: null == dateString
          ? _value.dateString
          : dateString // ignore: cast_nullable_to_non_nullable
              as String,
      reviewedCount: null == reviewedCount
          ? _value.reviewedCount
          : reviewedCount // ignore: cast_nullable_to_non_nullable
              as int,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      learnedDate: null == learnedDate
          ? _value.learnedDate
          : learnedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebaseDailyStatModelImplCopyWith<$Res>
    implements $FirebaseDailyStatModelCopyWith<$Res> {
  factory _$$FirebaseDailyStatModelImplCopyWith(
          _$FirebaseDailyStatModelImpl value,
          $Res Function(_$FirebaseDailyStatModelImpl) then) =
      __$$FirebaseDailyStatModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String dateString,
      int reviewedCount,
      int correctCount,
      @TimestampConverter() DateTime learnedDate});
}

/// @nodoc
class __$$FirebaseDailyStatModelImplCopyWithImpl<$Res>
    extends _$FirebaseDailyStatModelCopyWithImpl<$Res,
        _$FirebaseDailyStatModelImpl>
    implements _$$FirebaseDailyStatModelImplCopyWith<$Res> {
  __$$FirebaseDailyStatModelImplCopyWithImpl(
      _$FirebaseDailyStatModelImpl _value,
      $Res Function(_$FirebaseDailyStatModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebaseDailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateString = null,
    Object? reviewedCount = null,
    Object? correctCount = null,
    Object? learnedDate = null,
  }) {
    return _then(_$FirebaseDailyStatModelImpl(
      dateString: null == dateString
          ? _value.dateString
          : dateString // ignore: cast_nullable_to_non_nullable
              as String,
      reviewedCount: null == reviewedCount
          ? _value.reviewedCount
          : reviewedCount // ignore: cast_nullable_to_non_nullable
              as int,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      learnedDate: null == learnedDate
          ? _value.learnedDate
          : learnedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseDailyStatModelImpl implements _FirebaseDailyStatModel {
  const _$FirebaseDailyStatModelImpl(
      {required this.dateString,
      this.reviewedCount = 0,
      this.correctCount = 0,
      @TimestampConverter() required this.learnedDate});

  factory _$FirebaseDailyStatModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseDailyStatModelImplFromJson(json);

  @override
  final String dateString;
// YYYY-MM-DD 形式のドキュメントIDとしても使用
  @override
  @JsonKey()
  final int reviewedCount;
// その日にレビューしたカード数
  @override
  @JsonKey()
  final int correctCount;
// その日に正解したカード数
  @override
  @TimestampConverter()
  final DateTime learnedDate;

  @override
  String toString() {
    return 'FirebaseDailyStatModel(dateString: $dateString, reviewedCount: $reviewedCount, correctCount: $correctCount, learnedDate: $learnedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseDailyStatModelImpl &&
            (identical(other.dateString, dateString) ||
                other.dateString == dateString) &&
            (identical(other.reviewedCount, reviewedCount) ||
                other.reviewedCount == reviewedCount) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.learnedDate, learnedDate) ||
                other.learnedDate == learnedDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, dateString, reviewedCount, correctCount, learnedDate);

  /// Create a copy of FirebaseDailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseDailyStatModelImplCopyWith<_$FirebaseDailyStatModelImpl>
      get copyWith => __$$FirebaseDailyStatModelImplCopyWithImpl<
          _$FirebaseDailyStatModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseDailyStatModelImplToJson(
      this,
    );
  }
}

abstract class _FirebaseDailyStatModel implements FirebaseDailyStatModel {
  const factory _FirebaseDailyStatModel(
          {required final String dateString,
          final int reviewedCount,
          final int correctCount,
          @TimestampConverter() required final DateTime learnedDate}) =
      _$FirebaseDailyStatModelImpl;

  factory _FirebaseDailyStatModel.fromJson(Map<String, dynamic> json) =
      _$FirebaseDailyStatModelImpl.fromJson;

  @override
  String get dateString; // YYYY-MM-DD 形式のドキュメントIDとしても使用
  @override
  int get reviewedCount; // その日にレビューしたカード数
  @override
  int get correctCount; // その日に正解したカード数
  @override
  @TimestampConverter()
  DateTime get learnedDate;

  /// Create a copy of FirebaseDailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseDailyStatModelImplCopyWith<_$FirebaseDailyStatModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
