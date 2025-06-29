// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get uid => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get gemCount => throw _privateConstructorUsedError;
  String get invitationCode => throw _privateConstructorUsedError;
  bool get hasUsedInvitationCode => throw _privateConstructorUsedError;
  String? get invitedBy => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastLearningDate => throw _privateConstructorUsedError;
  bool get isHiveDataMigrated => throw _privateConstructorUsedError;
  String get nativeLanguageCode => throw _privateConstructorUsedError;
  String get targetLanguageCode => throw _privateConstructorUsedError;
  bool get isLanguageSettingsCompleted => throw _privateConstructorUsedError;
  List<String> get favoriteChannelIds => throw _privateConstructorUsedError;
  bool get hasRequestedReview => throw _privateConstructorUsedError;
  String? get fcmToken => throw _privateConstructorUsedError;
  UserSettings? get settings => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String uid,
      @TimestampConverter() DateTime createdAt,
      int gemCount,
      String invitationCode,
      bool hasUsedInvitationCode,
      String? invitedBy,
      int currentStreak,
      int longestStreak,
      @TimestampConverter() DateTime? lastLearningDate,
      bool isHiveDataMigrated,
      String nativeLanguageCode,
      String targetLanguageCode,
      bool isLanguageSettingsCompleted,
      List<String> favoriteChannelIds,
      bool hasRequestedReview,
      String? fcmToken,
      UserSettings? settings});

  $UserSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? createdAt = null,
    Object? gemCount = null,
    Object? invitationCode = null,
    Object? hasUsedInvitationCode = null,
    Object? invitedBy = freezed,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastLearningDate = freezed,
    Object? isHiveDataMigrated = null,
    Object? nativeLanguageCode = null,
    Object? targetLanguageCode = null,
    Object? isLanguageSettingsCompleted = null,
    Object? favoriteChannelIds = null,
    Object? hasRequestedReview = null,
    Object? fcmToken = freezed,
    Object? settings = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gemCount: null == gemCount
          ? _value.gemCount
          : gemCount // ignore: cast_nullable_to_non_nullable
              as int,
      invitationCode: null == invitationCode
          ? _value.invitationCode
          : invitationCode // ignore: cast_nullable_to_non_nullable
              as String,
      hasUsedInvitationCode: null == hasUsedInvitationCode
          ? _value.hasUsedInvitationCode
          : hasUsedInvitationCode // ignore: cast_nullable_to_non_nullable
              as bool,
      invitedBy: freezed == invitedBy
          ? _value.invitedBy
          : invitedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastLearningDate: freezed == lastLearningDate
          ? _value.lastLearningDate
          : lastLearningDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isHiveDataMigrated: null == isHiveDataMigrated
          ? _value.isHiveDataMigrated
          : isHiveDataMigrated // ignore: cast_nullable_to_non_nullable
              as bool,
      nativeLanguageCode: null == nativeLanguageCode
          ? _value.nativeLanguageCode
          : nativeLanguageCode // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguageCode: null == targetLanguageCode
          ? _value.targetLanguageCode
          : targetLanguageCode // ignore: cast_nullable_to_non_nullable
              as String,
      isLanguageSettingsCompleted: null == isLanguageSettingsCompleted
          ? _value.isLanguageSettingsCompleted
          : isLanguageSettingsCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      favoriteChannelIds: null == favoriteChannelIds
          ? _value.favoriteChannelIds
          : favoriteChannelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasRequestedReview: null == hasRequestedReview
          ? _value.hasRequestedReview
          : hasRequestedReview // ignore: cast_nullable_to_non_nullable
              as bool,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      settings: freezed == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as UserSettings?,
    ) as $Val);
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSettingsCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $UserSettingsCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      @TimestampConverter() DateTime createdAt,
      int gemCount,
      String invitationCode,
      bool hasUsedInvitationCode,
      String? invitedBy,
      int currentStreak,
      int longestStreak,
      @TimestampConverter() DateTime? lastLearningDate,
      bool isHiveDataMigrated,
      String nativeLanguageCode,
      String targetLanguageCode,
      bool isLanguageSettingsCompleted,
      List<String> favoriteChannelIds,
      bool hasRequestedReview,
      String? fcmToken,
      UserSettings? settings});

  @override
  $UserSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? createdAt = null,
    Object? gemCount = null,
    Object? invitationCode = null,
    Object? hasUsedInvitationCode = null,
    Object? invitedBy = freezed,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastLearningDate = freezed,
    Object? isHiveDataMigrated = null,
    Object? nativeLanguageCode = null,
    Object? targetLanguageCode = null,
    Object? isLanguageSettingsCompleted = null,
    Object? favoriteChannelIds = null,
    Object? hasRequestedReview = null,
    Object? fcmToken = freezed,
    Object? settings = freezed,
  }) {
    return _then(_$UserModelImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gemCount: null == gemCount
          ? _value.gemCount
          : gemCount // ignore: cast_nullable_to_non_nullable
              as int,
      invitationCode: null == invitationCode
          ? _value.invitationCode
          : invitationCode // ignore: cast_nullable_to_non_nullable
              as String,
      hasUsedInvitationCode: null == hasUsedInvitationCode
          ? _value.hasUsedInvitationCode
          : hasUsedInvitationCode // ignore: cast_nullable_to_non_nullable
              as bool,
      invitedBy: freezed == invitedBy
          ? _value.invitedBy
          : invitedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastLearningDate: freezed == lastLearningDate
          ? _value.lastLearningDate
          : lastLearningDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isHiveDataMigrated: null == isHiveDataMigrated
          ? _value.isHiveDataMigrated
          : isHiveDataMigrated // ignore: cast_nullable_to_non_nullable
              as bool,
      nativeLanguageCode: null == nativeLanguageCode
          ? _value.nativeLanguageCode
          : nativeLanguageCode // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguageCode: null == targetLanguageCode
          ? _value.targetLanguageCode
          : targetLanguageCode // ignore: cast_nullable_to_non_nullable
              as String,
      isLanguageSettingsCompleted: null == isLanguageSettingsCompleted
          ? _value.isLanguageSettingsCompleted
          : isLanguageSettingsCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      favoriteChannelIds: null == favoriteChannelIds
          ? _value._favoriteChannelIds
          : favoriteChannelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasRequestedReview: null == hasRequestedReview
          ? _value.hasRequestedReview
          : hasRequestedReview // ignore: cast_nullable_to_non_nullable
              as bool,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      settings: freezed == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as UserSettings?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {required this.uid,
      @TimestampConverter() required this.createdAt,
      this.gemCount = 3,
      required this.invitationCode,
      this.hasUsedInvitationCode = false,
      this.invitedBy,
      this.currentStreak = 0,
      this.longestStreak = 0,
      @TimestampConverter() this.lastLearningDate,
      this.isHiveDataMigrated = false,
      this.nativeLanguageCode = 'ja',
      this.targetLanguageCode = 'en',
      this.isLanguageSettingsCompleted = false,
      final List<String> favoriteChannelIds = const [],
      this.hasRequestedReview = false,
      this.fcmToken,
      this.settings})
      : _favoriteChannelIds = favoriteChannelIds;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String uid;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @JsonKey()
  final int gemCount;
  @override
  final String invitationCode;
  @override
  @JsonKey()
  final bool hasUsedInvitationCode;
  @override
  final String? invitedBy;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  @TimestampConverter()
  final DateTime? lastLearningDate;
  @override
  @JsonKey()
  final bool isHiveDataMigrated;
  @override
  @JsonKey()
  final String nativeLanguageCode;
  @override
  @JsonKey()
  final String targetLanguageCode;
  @override
  @JsonKey()
  final bool isLanguageSettingsCompleted;
  final List<String> _favoriteChannelIds;
  @override
  @JsonKey()
  List<String> get favoriteChannelIds {
    if (_favoriteChannelIds is EqualUnmodifiableListView)
      return _favoriteChannelIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteChannelIds);
  }

  @override
  @JsonKey()
  final bool hasRequestedReview;
  @override
  final String? fcmToken;
  @override
  final UserSettings? settings;

  @override
  String toString() {
    return 'UserModel(uid: $uid, createdAt: $createdAt, gemCount: $gemCount, invitationCode: $invitationCode, hasUsedInvitationCode: $hasUsedInvitationCode, invitedBy: $invitedBy, currentStreak: $currentStreak, longestStreak: $longestStreak, lastLearningDate: $lastLearningDate, isHiveDataMigrated: $isHiveDataMigrated, nativeLanguageCode: $nativeLanguageCode, targetLanguageCode: $targetLanguageCode, isLanguageSettingsCompleted: $isLanguageSettingsCompleted, favoriteChannelIds: $favoriteChannelIds, hasRequestedReview: $hasRequestedReview, fcmToken: $fcmToken, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.gemCount, gemCount) ||
                other.gemCount == gemCount) &&
            (identical(other.invitationCode, invitationCode) ||
                other.invitationCode == invitationCode) &&
            (identical(other.hasUsedInvitationCode, hasUsedInvitationCode) ||
                other.hasUsedInvitationCode == hasUsedInvitationCode) &&
            (identical(other.invitedBy, invitedBy) ||
                other.invitedBy == invitedBy) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.lastLearningDate, lastLearningDate) ||
                other.lastLearningDate == lastLearningDate) &&
            (identical(other.isHiveDataMigrated, isHiveDataMigrated) ||
                other.isHiveDataMigrated == isHiveDataMigrated) &&
            (identical(other.nativeLanguageCode, nativeLanguageCode) ||
                other.nativeLanguageCode == nativeLanguageCode) &&
            (identical(other.targetLanguageCode, targetLanguageCode) ||
                other.targetLanguageCode == targetLanguageCode) &&
            (identical(other.isLanguageSettingsCompleted,
                    isLanguageSettingsCompleted) ||
                other.isLanguageSettingsCompleted ==
                    isLanguageSettingsCompleted) &&
            const DeepCollectionEquality()
                .equals(other._favoriteChannelIds, _favoriteChannelIds) &&
            (identical(other.hasRequestedReview, hasRequestedReview) ||
                other.hasRequestedReview == hasRequestedReview) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.settings, settings) ||
                other.settings == settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      createdAt,
      gemCount,
      invitationCode,
      hasUsedInvitationCode,
      invitedBy,
      currentStreak,
      longestStreak,
      lastLearningDate,
      isHiveDataMigrated,
      nativeLanguageCode,
      targetLanguageCode,
      isLanguageSettingsCompleted,
      const DeepCollectionEquality().hash(_favoriteChannelIds),
      hasRequestedReview,
      fcmToken,
      settings);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
      {required final String uid,
      @TimestampConverter() required final DateTime createdAt,
      final int gemCount,
      required final String invitationCode,
      final bool hasUsedInvitationCode,
      final String? invitedBy,
      final int currentStreak,
      final int longestStreak,
      @TimestampConverter() final DateTime? lastLearningDate,
      final bool isHiveDataMigrated,
      final String nativeLanguageCode,
      final String targetLanguageCode,
      final bool isLanguageSettingsCompleted,
      final List<String> favoriteChannelIds,
      final bool hasRequestedReview,
      final String? fcmToken,
      final UserSettings? settings}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get uid;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  int get gemCount;
  @override
  String get invitationCode;
  @override
  bool get hasUsedInvitationCode;
  @override
  String? get invitedBy;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  @TimestampConverter()
  DateTime? get lastLearningDate;
  @override
  bool get isHiveDataMigrated;
  @override
  String get nativeLanguageCode;
  @override
  String get targetLanguageCode;
  @override
  bool get isLanguageSettingsCompleted;
  @override
  List<String> get favoriteChannelIds;
  @override
  bool get hasRequestedReview;
  @override
  String? get fcmToken;
  @override
  UserSettings? get settings;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) {
  return _UserSettings.fromJson(json);
}

/// @nodoc
mixin _$UserSettings {
  bool get notificationEnabled => throw _privateConstructorUsedError;
  String get preferredNotificationTime => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastNotificationTime => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastPatternAnalysis => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  NotificationTypes? get notificationTypes =>
      throw _privateConstructorUsedError;

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSettingsCopyWith<UserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsCopyWith<$Res> {
  factory $UserSettingsCopyWith(
          UserSettings value, $Res Function(UserSettings) then) =
      _$UserSettingsCopyWithImpl<$Res, UserSettings>;
  @useResult
  $Res call(
      {bool notificationEnabled,
      String preferredNotificationTime,
      @TimestampConverter() DateTime? lastNotificationTime,
      @TimestampConverter() DateTime? lastPatternAnalysis,
      String language,
      NotificationTypes? notificationTypes});

  $NotificationTypesCopyWith<$Res>? get notificationTypes;
}

/// @nodoc
class _$UserSettingsCopyWithImpl<$Res, $Val extends UserSettings>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationEnabled = null,
    Object? preferredNotificationTime = null,
    Object? lastNotificationTime = freezed,
    Object? lastPatternAnalysis = freezed,
    Object? language = null,
    Object? notificationTypes = freezed,
  }) {
    return _then(_value.copyWith(
      notificationEnabled: null == notificationEnabled
          ? _value.notificationEnabled
          : notificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredNotificationTime: null == preferredNotificationTime
          ? _value.preferredNotificationTime
          : preferredNotificationTime // ignore: cast_nullable_to_non_nullable
              as String,
      lastNotificationTime: freezed == lastNotificationTime
          ? _value.lastNotificationTime
          : lastNotificationTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPatternAnalysis: freezed == lastPatternAnalysis
          ? _value.lastPatternAnalysis
          : lastPatternAnalysis // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      notificationTypes: freezed == notificationTypes
          ? _value.notificationTypes
          : notificationTypes // ignore: cast_nullable_to_non_nullable
              as NotificationTypes?,
    ) as $Val);
  }

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationTypesCopyWith<$Res>? get notificationTypes {
    if (_value.notificationTypes == null) {
      return null;
    }

    return $NotificationTypesCopyWith<$Res>(_value.notificationTypes!, (value) {
      return _then(_value.copyWith(notificationTypes: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserSettingsImplCopyWith<$Res>
    implements $UserSettingsCopyWith<$Res> {
  factory _$$UserSettingsImplCopyWith(
          _$UserSettingsImpl value, $Res Function(_$UserSettingsImpl) then) =
      __$$UserSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool notificationEnabled,
      String preferredNotificationTime,
      @TimestampConverter() DateTime? lastNotificationTime,
      @TimestampConverter() DateTime? lastPatternAnalysis,
      String language,
      NotificationTypes? notificationTypes});

  @override
  $NotificationTypesCopyWith<$Res>? get notificationTypes;
}

/// @nodoc
class __$$UserSettingsImplCopyWithImpl<$Res>
    extends _$UserSettingsCopyWithImpl<$Res, _$UserSettingsImpl>
    implements _$$UserSettingsImplCopyWith<$Res> {
  __$$UserSettingsImplCopyWithImpl(
      _$UserSettingsImpl _value, $Res Function(_$UserSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationEnabled = null,
    Object? preferredNotificationTime = null,
    Object? lastNotificationTime = freezed,
    Object? lastPatternAnalysis = freezed,
    Object? language = null,
    Object? notificationTypes = freezed,
  }) {
    return _then(_$UserSettingsImpl(
      notificationEnabled: null == notificationEnabled
          ? _value.notificationEnabled
          : notificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredNotificationTime: null == preferredNotificationTime
          ? _value.preferredNotificationTime
          : preferredNotificationTime // ignore: cast_nullable_to_non_nullable
              as String,
      lastNotificationTime: freezed == lastNotificationTime
          ? _value.lastNotificationTime
          : lastNotificationTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPatternAnalysis: freezed == lastPatternAnalysis
          ? _value.lastPatternAnalysis
          : lastPatternAnalysis // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      notificationTypes: freezed == notificationTypes
          ? _value.notificationTypes
          : notificationTypes // ignore: cast_nullable_to_non_nullable
              as NotificationTypes?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsImpl implements _UserSettings {
  const _$UserSettingsImpl(
      {this.notificationEnabled = true,
      this.preferredNotificationTime = '20:00',
      @TimestampConverter() this.lastNotificationTime,
      @TimestampConverter() this.lastPatternAnalysis,
      this.language = 'ja',
      this.notificationTypes});

  factory _$UserSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool notificationEnabled;
  @override
  @JsonKey()
  final String preferredNotificationTime;
  @override
  @TimestampConverter()
  final DateTime? lastNotificationTime;
  @override
  @TimestampConverter()
  final DateTime? lastPatternAnalysis;
  @override
  @JsonKey()
  final String language;
  @override
  final NotificationTypes? notificationTypes;

  @override
  String toString() {
    return 'UserSettings(notificationEnabled: $notificationEnabled, preferredNotificationTime: $preferredNotificationTime, lastNotificationTime: $lastNotificationTime, lastPatternAnalysis: $lastPatternAnalysis, language: $language, notificationTypes: $notificationTypes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsImpl &&
            (identical(other.notificationEnabled, notificationEnabled) ||
                other.notificationEnabled == notificationEnabled) &&
            (identical(other.preferredNotificationTime,
                    preferredNotificationTime) ||
                other.preferredNotificationTime == preferredNotificationTime) &&
            (identical(other.lastNotificationTime, lastNotificationTime) ||
                other.lastNotificationTime == lastNotificationTime) &&
            (identical(other.lastPatternAnalysis, lastPatternAnalysis) ||
                other.lastPatternAnalysis == lastPatternAnalysis) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.notificationTypes, notificationTypes) ||
                other.notificationTypes == notificationTypes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      notificationEnabled,
      preferredNotificationTime,
      lastNotificationTime,
      lastPatternAnalysis,
      language,
      notificationTypes);

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      __$$UserSettingsImplCopyWithImpl<_$UserSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsImplToJson(
      this,
    );
  }
}

abstract class _UserSettings implements UserSettings {
  const factory _UserSettings(
      {final bool notificationEnabled,
      final String preferredNotificationTime,
      @TimestampConverter() final DateTime? lastNotificationTime,
      @TimestampConverter() final DateTime? lastPatternAnalysis,
      final String language,
      final NotificationTypes? notificationTypes}) = _$UserSettingsImpl;

  factory _UserSettings.fromJson(Map<String, dynamic> json) =
      _$UserSettingsImpl.fromJson;

  @override
  bool get notificationEnabled;
  @override
  String get preferredNotificationTime;
  @override
  @TimestampConverter()
  DateTime? get lastNotificationTime;
  @override
  @TimestampConverter()
  DateTime? get lastPatternAnalysis;
  @override
  String get language;
  @override
  NotificationTypes? get notificationTypes;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationTypes _$NotificationTypesFromJson(Map<String, dynamic> json) {
  return _NotificationTypes.fromJson(json);
}

/// @nodoc
mixin _$NotificationTypes {
  bool get daily => throw _privateConstructorUsedError;
  bool get review => throw _privateConstructorUsedError;
  bool get milestone => throw _privateConstructorUsedError;
  bool get newContent => throw _privateConstructorUsedError;

  /// Serializes this NotificationTypes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationTypes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationTypesCopyWith<NotificationTypes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationTypesCopyWith<$Res> {
  factory $NotificationTypesCopyWith(
          NotificationTypes value, $Res Function(NotificationTypes) then) =
      _$NotificationTypesCopyWithImpl<$Res, NotificationTypes>;
  @useResult
  $Res call({bool daily, bool review, bool milestone, bool newContent});
}

/// @nodoc
class _$NotificationTypesCopyWithImpl<$Res, $Val extends NotificationTypes>
    implements $NotificationTypesCopyWith<$Res> {
  _$NotificationTypesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationTypes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? daily = null,
    Object? review = null,
    Object? milestone = null,
    Object? newContent = null,
  }) {
    return _then(_value.copyWith(
      daily: null == daily
          ? _value.daily
          : daily // ignore: cast_nullable_to_non_nullable
              as bool,
      review: null == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as bool,
      milestone: null == milestone
          ? _value.milestone
          : milestone // ignore: cast_nullable_to_non_nullable
              as bool,
      newContent: null == newContent
          ? _value.newContent
          : newContent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationTypesImplCopyWith<$Res>
    implements $NotificationTypesCopyWith<$Res> {
  factory _$$NotificationTypesImplCopyWith(_$NotificationTypesImpl value,
          $Res Function(_$NotificationTypesImpl) then) =
      __$$NotificationTypesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool daily, bool review, bool milestone, bool newContent});
}

/// @nodoc
class __$$NotificationTypesImplCopyWithImpl<$Res>
    extends _$NotificationTypesCopyWithImpl<$Res, _$NotificationTypesImpl>
    implements _$$NotificationTypesImplCopyWith<$Res> {
  __$$NotificationTypesImplCopyWithImpl(_$NotificationTypesImpl _value,
      $Res Function(_$NotificationTypesImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationTypes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? daily = null,
    Object? review = null,
    Object? milestone = null,
    Object? newContent = null,
  }) {
    return _then(_$NotificationTypesImpl(
      daily: null == daily
          ? _value.daily
          : daily // ignore: cast_nullable_to_non_nullable
              as bool,
      review: null == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as bool,
      milestone: null == milestone
          ? _value.milestone
          : milestone // ignore: cast_nullable_to_non_nullable
              as bool,
      newContent: null == newContent
          ? _value.newContent
          : newContent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationTypesImpl implements _NotificationTypes {
  const _$NotificationTypesImpl(
      {this.daily = true,
      this.review = true,
      this.milestone = true,
      this.newContent = true});

  factory _$NotificationTypesImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationTypesImplFromJson(json);

  @override
  @JsonKey()
  final bool daily;
  @override
  @JsonKey()
  final bool review;
  @override
  @JsonKey()
  final bool milestone;
  @override
  @JsonKey()
  final bool newContent;

  @override
  String toString() {
    return 'NotificationTypes(daily: $daily, review: $review, milestone: $milestone, newContent: $newContent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationTypesImpl &&
            (identical(other.daily, daily) || other.daily == daily) &&
            (identical(other.review, review) || other.review == review) &&
            (identical(other.milestone, milestone) ||
                other.milestone == milestone) &&
            (identical(other.newContent, newContent) ||
                other.newContent == newContent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, daily, review, milestone, newContent);

  /// Create a copy of NotificationTypes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationTypesImplCopyWith<_$NotificationTypesImpl> get copyWith =>
      __$$NotificationTypesImplCopyWithImpl<_$NotificationTypesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationTypesImplToJson(
      this,
    );
  }
}

abstract class _NotificationTypes implements NotificationTypes {
  const factory _NotificationTypes(
      {final bool daily,
      final bool review,
      final bool milestone,
      final bool newContent}) = _$NotificationTypesImpl;

  factory _NotificationTypes.fromJson(Map<String, dynamic> json) =
      _$NotificationTypesImpl.fromJson;

  @override
  bool get daily;
  @override
  bool get review;
  @override
  bool get milestone;
  @override
  bool get newContent;

  /// Create a copy of NotificationTypes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationTypesImplCopyWith<_$NotificationTypesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
