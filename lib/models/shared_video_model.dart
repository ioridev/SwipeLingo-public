import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart'; // TimestampConverterのため

part 'shared_video_model.freezed.dart';
part 'shared_video_model.g.dart';

@freezed
class SharedVideoModel with _$SharedVideoModel {
  const factory SharedVideoModel({
    required String id, // YouTube Video ID
    required String url,
    required String title,
    required String channelName,
    required String thumbnailUrl,
    @TimestampConverter() required DateTime createdAt, // 初回登録日時
    @TimestampConverter() required DateTime updatedAt, // 最終更新日時
    // キー: 言語コード (例: 'en', 'ja')
    // 値: 字幕セグメントのリスト Map{'text': String, 'start': double, 'end': double}
    @Default({}) Map<String, List<Map<String, dynamic>>> captionsWithTimestamps,
    String? uploaderUid, // 最初にこの動画情報を登録したユーザーのUID（参考情報として）
  }) = _SharedVideoModel;

  factory SharedVideoModel.fromJson(Map<String, dynamic> json) =>
      _$SharedVideoModelFromJson(json);
}
