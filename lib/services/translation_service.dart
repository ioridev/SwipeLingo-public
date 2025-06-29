import 'package:translator/translator.dart';

abstract class TranslationService {
  Future<String> translate(
    String text,
    String sourceLanguage,
    String targetLanguage,
  );
}

class GoogleTranslationService implements TranslationService {
  final _translator = GoogleTranslator();

  @override
  Future<String> translate(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    print(
      'TranslationService: translate START - text: "$text", sourceLanguage: "$sourceLanguage", targetLanguage: "$targetLanguage"',
    );
    if (text.isEmpty) {
      print('TranslationService: translate END - text is empty, returning ""');
      return "";
    }
    try {
      final translation = await _translator.translate(
        text,
        from: sourceLanguage,
        to: targetLanguage,
      );
      print(
        'TranslationService: translate SUCCESS - originalText: "$text", translatedText: "${translation.text}", sourceLanguage: "$sourceLanguage", targetLanguage: "$targetLanguage"',
      );
      return translation.text;
    } catch (e) {
      print(
        'TranslationService: translate ERROR - text: "$text", sourceLanguage: "$sourceLanguage", targetLanguage: "$targetLanguage", error: $e',
      );
      // TODO: より詳細なエラーハンドリングとロギングを検討する
      print('Translation Error: $e');
      // 翻訳に失敗した場合は、例外を再スローして呼び出し元にエラーを伝える
      rethrow;
    }
  }
}
