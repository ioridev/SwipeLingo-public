// lib/services/dictionary_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Providerのために追加

class DictionaryService {
  Map<String, String> _englishJapaneseDictionary = {};
  Map<String, Map<String, dynamic>> _japaneseEnglishDictionary = {};
  bool _isInitialized = false;

  DictionaryService();

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadDictionaries();
    _isInitialized = true;
  }

  Future<void> _loadDictionaries() async {
    // Load English-Japanese dictionary
    try {
      final String ejData = await rootBundle.loadString('assets/ejdict.json');
      final Map<String, dynamic> ejJsonMap =
          json.decode(ejData) as Map<String, dynamic>;
      _englishJapaneseDictionary = ejJsonMap.map(
        (key, value) => MapEntry(key.toLowerCase(), value.toString()),
      );
      debugPrint('English-Japanese dictionary loaded: ${_englishJapaneseDictionary.length} words');
    } catch (e) {
      debugPrint('Error loading English-Japanese dictionary: $e');
    }

    // Load Japanese-English dictionary
    try {
      final String jeData = await rootBundle.loadString('assets/edictjp.json');
      final Map<String, dynamic> jeJsonMap =
          json.decode(jeData) as Map<String, dynamic>;
      _japaneseEnglishDictionary = jeJsonMap.cast<String, Map<String, dynamic>>();
      debugPrint('Japanese-English dictionary loaded: ${_japaneseEnglishDictionary.length} entries');
    } catch (e) {
      debugPrint('Error loading Japanese-English dictionary: $e');
    }
  }

  String? searchWord(String word, {String targetLanguageCode = 'en'}) {
    if (!_isInitialized) {
      debugPrint("Dictionary not initialized yet. Call initialize() first.");
      return "辞書初期化中...";
    }

    if (targetLanguageCode == 'ja') {
      // Use Japanese-English dictionary for Japanese target language
      return _searchInJapaneseEnglishDictionary(word);
    } else {
      // Use English-Japanese dictionary for other languages (default English)
      return _searchInEnglishJapaneseDictionary(word);
    }
  }

  String? _searchInEnglishJapaneseDictionary(String word) {
    final lowerCaseWord = word.toLowerCase().replaceAll(
      RegExp(r'[^\w\s-]'),
      '',
    ); // ハイフンを許容
    if (_englishJapaneseDictionary.containsKey(lowerCaseWord)) {
      return _englishJapaneseDictionary[lowerCaseWord];
    }

    // ハイフンやスペースで区切られた複合語の検索
    final parts = lowerCaseWord.split(RegExp(r'[- ]'));
    if (parts.length > 1) {
      for (final part in parts) {
        if (_englishJapaneseDictionary.containsKey(part)) {
          return _englishJapaneseDictionary[part]; // 最初に見つかった部分語の意味を返す
        }
      }
    }
    return null; // 見つからなかった場合
  }

  String? _searchInJapaneseEnglishDictionary(String word) {
    final searchWord = word.trim();
    
    // Search through all entries in the Japanese-English dictionary
    for (final entry in _japaneseEnglishDictionary.values) {
      // Check kanji elements (k_ele)
      final kEle = entry['k_ele'] as List<dynamic>?;
      if (kEle != null) {
        for (final kanjiElement in kEle) {
          if (kanjiElement.toString().contains(searchWord)) {
            final senses = entry['sense'] as List<dynamic>?;
            if (senses != null && senses.isNotEmpty) {
              return senses.first.toString();
            }
          }
        }
      }

      // Check reading elements (r_ele)
      final rEle = entry['r_ele'] as List<dynamic>?;
      if (rEle != null) {
        for (final readingElement in rEle) {
          if (readingElement.toString().contains(searchWord)) {
            final senses = entry['sense'] as List<dynamic>?;
            if (senses != null && senses.isNotEmpty) {
              return senses.first.toString();
            }
          }
        }
      }
    }
    return null; // 見つからなかった場合
  }
}

final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  // DictionaryServiceは初期化が必要なので、使用直前に initialize() を呼ぶか、
  // アプリケーション起動時に初期化しておくなどの対応が必要。
  // ここではインスタンスを返すだけ。
  return DictionaryService();
});
