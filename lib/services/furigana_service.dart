// lib/services/furigana_service.dart
import 'package:jp_transliterate/jp_transliterate.dart';

class FuriganaService {
  /// 日本語テキストを自動的にふりがな付きのデータに変換する
  /// jp_transliterateパッケージを使用して漢字のふりがなを自動生成
  static Future<TransliterationData> generateTransliterationData(String text) async {
    try {
      // jp_transliterateで漢字を変換
      final transliterationData = await JpTransliterate.transliterate(kanji: text);
      return transliterationData;
    } catch (e) {
      // エラーが発生した場合は、元のテキストで空のデータを返す
      throw Exception('Failed to transliterate text: $e');
    }
  }

  /// テキスト内に漢字が含まれているかチェック
  static bool containsKanji(String text) {
    return text.runes.any((rune) {
      final char = String.fromCharCode(rune);
      return _isKanji(char);
    });
  }

  /// 文字が漢字かどうかをチェック
  static bool _isKanji(String char) {
    final code = char.codeUnitAt(0);
    // 基本的な漢字の範囲をチェック
    return (code >= 0x4E00 && code <= 0x9FAF) || // CJK統合漢字
           (code >= 0x3400 && code <= 0x4DBF) || // CJK拡張A
           (code >= 0x20000 && code <= 0x2A6DF); // CJK拡張B
  }
}