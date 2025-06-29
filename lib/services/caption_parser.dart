import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml_parser;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;

/// YouTube XMLキャプションのパースを担当するクラス
class CaptionParser {
  /// YouTube自動翻訳XMLをClosedCaptionリストにパース
  Future<List<yt_explode.ClosedCaption>> parseAutoTranslatedXmlCaptions(
    String xmlString,
    String languageCodeForThisXml,
  ) async {
    debugPrint(
      '[CaptionParser] Called for lang "$languageCodeForThisXml" with XML string (length: ${xmlString.length})',
    );
    
    // XML内容の先頭部分をログに出力（長すぎる場合は省略）
    final previewLength = xmlString.length > 200 ? 200 : xmlString.length;
    debugPrint(
      '[CaptionParser] XML preview: ${xmlString.substring(0, previewLength)}',
    );

    final List<yt_explode.ClosedCaption> captions = [];
    
    if (xmlString.isEmpty || xmlString.trim().isEmpty) {
      // 空白のみの文字列もチェック
      debugPrint(
        '[CaptionParser] XML string is empty or whitespace only for lang "$languageCodeForThisXml", returning empty list.',
      );
      return captions;
    }
    
    try {
      final document = xml_parser.XmlDocument.parse(xmlString);
      final textElements = document.findAllElements('text');
      debugPrint(
        '[CaptionParser] Found ${textElements.length} <text> elements in XML.',
      );

      for (final element in textElements) {
        final startString = element.getAttribute('start');
        final durString = element.getAttribute('dur');
        final text = element.innerText;

        if (startString != null && durString != null && text.isNotEmpty) {
          final startSeconds = double.tryParse(startString);
          final durSeconds = double.tryParse(durString);

          if (startSeconds != null && durSeconds != null) {
            final offset = Duration(
              milliseconds: (startSeconds * 1000).round(),
            );
            final duration = Duration(
              milliseconds: (durSeconds * 1000).round(),
            );
            captions.add(
              yt_explode.ClosedCaption(
                text, // text
                offset, // offset
                duration, // duration
                const [], // parts (空の定数リスト)
              ),
            );
          } else {
            debugPrint(
              '[CaptionParser] Failed to parse start/dur seconds: start=$startString, dur=$durString for text: $text',
            );
          }
        } else {
          debugPrint(
            '[CaptionParser] Missing start/dur attribute or text is empty: start=$startString, dur=$durString, textIsEmpty=${text.isEmpty}',
          );
        }
      }
    } catch (e, s) {
      debugPrint(
        '[CaptionParser] Exception during XML parsing: $e',
      );
      debugPrint(
        '[CaptionParser] Stacktrace for XML parsing error: $s',
      );
    }
    
    debugPrint(
      '[CaptionParser] Parsed for lang "$languageCodeForThisXml". Returning ${captions.length} captions.',
    );
    return captions;
  }
}