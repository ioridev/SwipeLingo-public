import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// import 'package:hive/hive.dart'; // 不要
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpodをインポート

import '../models/firebase_card_model.dart'; // Firebase用カードモデル
import '../models/shared_video_model.dart'; // Firebase用動画モデル
import '../repositories/firebase_repository.dart'; // FirebaseRepository
import '../providers/repository_providers.dart'; // firebaseRepositoryProvider

/// Anki エクスポート関連の機能を提供するサービスクラス。
class AnkiExportService {
  final Dio _dio = Dio();
  final Ref _ref; // RiverpodのRefを追加

  AnkiExportService(this._ref); // コンストラクタでRefを受け取る

  Future<bool> exportCardsToAnki(List<FirebaseCardModel> cards) async {
    if (cards.isEmpty) {
      debugPrint('No cards to export.');
      return false;
    }

    Directory? tempDir;
    String? zipFilePath;
    final Map<String, String> mediaMap = {};
    int mediaCounter = 0;

    try {
      tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String csvFileName = 'deck.csv';
      // final String mediaJsonFileName = 'media'; // media.jsonはAnkiConnectでは不要な場合が多い

      final StringBuffer csvData = StringBuffer();
      csvData.writeln('Front;Back;Thumbnail'); // ヘッダー

      // FirebaseRepositoryを取得
      final firebaseRepository = _ref.read(firebaseRepositoryProvider);

      for (final card in cards) {
        final front = card.front.replaceAll('\n', '<br>');
        final back = card.back.replaceAll('\n', '<br>');
        String thumbnailField = '';

        // Firestoreから動画情報を取得
        final SharedVideoModel? video = await firebaseRepository.getSharedVideo(
          card.videoId,
        );

        if (video != null && video.thumbnailUrl.isNotEmpty) {
          final imageFileName = '${card.id}_thumbnail.jpg';
          final imageFilePath = '${tempDir.path}/$imageFileName';

          try {
            final response = await _dio.get<List<int>>(
              video.thumbnailUrl,
              options: Options(responseType: ResponseType.bytes),
            );
            if (response.statusCode == 200 && response.data != null) {
              final imageFile = File(imageFilePath);
              await imageFile.writeAsBytes(response.data!);
              mediaMap[mediaCounter.toString()] = imageFileName;
              thumbnailField = '<img src="$imageFileName">';
              mediaCounter++;
            } else {
              debugPrint(
                'Failed to download image: ${video.thumbnailUrl}, status: ${response.statusCode}',
              );
            }
          } catch (e) {
            debugPrint('Error downloading image ${video.thumbnailUrl}: $e');
          }
        }
        csvData.writeln('"$front";"$back";"$thumbnailField"');
      }

      final csvFile = File('${tempDir.path}/$csvFileName');
      await csvFile.writeAsString(csvData.toString());

      final encoder = ZipFileEncoder();
      zipFilePath = '${tempDir.path}/swipelingo_anki_export_$timestamp.zip';
      encoder.create(zipFilePath);
      encoder.addFile(csvFile, csvFileName);

      for (final entry in mediaMap.entries) {
        final imageFileNameInZip = entry.value;
        final imageFileToZip = File('${tempDir.path}/$imageFileNameInZip');
        if (await imageFileToZip.exists()) {
          encoder.addFile(imageFileToZip, imageFileNameInZip);
        }
      }
      encoder.close();

      final xfiles = <XFile>[];
      xfiles.add(XFile(zipFilePath, name: 'Swipelingo Anki Export.zip'));
      if (xfiles.isNotEmpty) {
        await Share.shareXFiles(
          xfiles,
          text: 'Anki deck exported from Swipelingo',
        );
        return true;
      } else {
        debugPrint('No file to share.');
        return false;
      }
    } catch (e, s) {
      debugPrint('Error during Anki export: $e');
      debugPrint(s.toString());
      return false;
    } finally {
      if (tempDir != null && await tempDir.exists()) {
        final csvFile = File('${tempDir.path}/deck.csv');
        if (await csvFile.exists()) await csvFile.delete();
        for (final entry in mediaMap.entries) {
          final imageFileToDelete = File('${tempDir.path}/${entry.value}');
          if (await imageFileToDelete.exists()) {
            await imageFileToDelete.delete();
          }
        }
        // zipファイルは共有後にOSが処理することを期待
      }
    }
  }
}

// AnkiExportServiceのProvider定義
final ankiExportServiceProvider = Provider<AnkiExportService>((ref) {
  return AnkiExportService(ref);
});
