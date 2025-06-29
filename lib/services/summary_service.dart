import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart'; // firebase_ai をインポート (修正)
// FirebaseException のために firebase_core をインポートする必要があるか確認
import 'package:firebase_core/firebase_core.dart'; // FirebaseException のためにインポート

/// 字幕テキストからフラッシュカード候補を生成するサービスクラス (Firebase AI Vertex Gemini版)。
class SummaryService {
  // Vertex AI Gemini モデルを使用
  // チュートリアルに合わせてモデル名を 'gemini-2.0-flash' に変更
  static const String _modelName = 'gemini-2.0-flash';
  // static const String _wordExplanationModelName = 'gemma-3-27b-it';
  static const String _wordExplanationModelName = 'gemini-2.0-flash';

  final GenerativeModel _model;
  final GenerativeModel _wordExplanationModel;

  /// SummaryServiceを初期化します。
  SummaryService()
    : _model = FirebaseAI.vertexAI().generativeModel(
        // 初期化方法を修正
        model: _modelName,
        // 必要に応じて safetySettings や generationConfig を設定
        // safetySettings: [
        //   SafetySetting(
        //       harmCategory: HarmCategory.harassment,
        //       threshold: HarmBlockThreshold.mediumAndAbove),
        // ],
        // generationConfig: GenerationConfig(
        //   temperature: 0.7,
        //   maxOutputTokens: 8192, // 必要に応じて調整
        // ),
      ),
      _wordExplanationModel = FirebaseAI.vertexAI().generativeModel(
        model: _wordExplanationModelName,
      );

  /// 与えられたタイムスタンプ付き字幕全体から、複数のフラッシュカード候補を生成します (Firebase AI Vertex Gemini版)。
  ///
  /// [captionsWithTimestamps] タイムスタンプ付き字幕データのリスト Map{'text': String, 'start': double, 'end': double}
  /// [videoId] 動画ID (JSONスキーマで使用)
  /// [userNativeLanguageCode] ユーザーの母語の言語コード (例: 'en')。
  /// [userTargetLanguageCode] ユーザーの学習対象言語の言語コード (例: 'ja')。
  ///
  /// 成功した場合は複数のカード情報を含むJSON文字列を返します。
  /// 失敗した場合は例外をスローします。
  Future<String> generateMultipleFlashcards(
    List<Map<String, dynamic>> captionsWithTimestamps,
    String videoId,
    String userNativeLanguageCode,
    String userTargetLanguageCode,
  ) async {
    // ユーザープロンプト用に字幕データを整形
    final formattedTranscript = captionsWithTimestamps
        .map((caption) {
          final start = caption['start']?.toStringAsFixed(1) ?? '0.0';
          final end = caption['end']?.toStringAsFixed(1) ?? '0.0';
          final text = caption['text'] ?? '';
          return '$start - $end - $text';
        })
        .join('\n');

    // プロンプトの組み立て (システムプロンプトとユーザープロンプトを結合)
    // Gemini APIでは、通常プロンプトは List<Content> で渡されるが、
    // ここでは従来のシステムプロンプト + ユーザプロンプトの形式を維持し、
    // 1つのテキストプロンプトとして渡す。
    // 必要に応じて、Content.system() や Content.user() を使用する形式に変更も可能。
    final fullPrompt = """
あなたはプロの言語教育アシスタントです。
タスク:
以下のYouTube字幕から、フレーズ学習用のフラッシュカードに適したサイズの1文ペアを作成してください。
・カードの表（front）は学習対象言語 (${userTargetLanguageCode.toUpperCase()}) で、裏（back）はユーザーの母語 (${userNativeLanguageCode.toUpperCase()}) で生成してください。
・不完全または無意味な断片（例：「ええと」、「はい」など）はスキップしてください。
・長すぎないように1行にしてください。文が長すぎる場合は、適切に分割してください。多少文を変化させても構いません。
・できるだけ多くのペアを作成してください。
・元の文の語彙と文法の複雑さに基づいて、難易度をスコアリングしてください（0.0=易～1.0=難）。
・関連する場合、用法、ニュアンス、文法に関する簡単なメモ（note）を任意で追加してください。
・以下のJSONスキーマに厳密に従った有効なJSONのみを返してください。

JSONスキーマ:
{
  "videoId": "$videoId",
  "language": "${userTargetLanguageCode.toUpperCase()}",
  "card": [
    {
      "id": "$videoId-XXX",               // videoId + 3桁連番 (001, 002, ...)
      "front": "学習対象言語 (${userTargetLanguageCode.toUpperCase()}) の文", // 出題文（LLM 整形済み）
      "back": "ユーザーの母語 (${userNativeLanguageCode.toUpperCase()}) への自然な翻訳/言い換え", // 対訳（LLM 翻訳）
      "start": 12.3,                    // 秒 (元字幕の開始時間)
      "end": 14.1,                      // 秒 (元字幕の終了時間)
      "note": "用法/ニュアンスに関する任意メモ", // 任意メモ
      "difficulty": 0.35               // 0.0=易～1.0=難
    }
  ]
}

**注意: JSON オブジェクトのみを返し、他のテキスト (例: "```json", "```", "はい、承知いたしました。") は一切含めないでください。**

---
videoId: $videoId
targetLanguage: ${userTargetLanguageCode.toUpperCase()}
nativeLanguage: ${userNativeLanguageCode.toUpperCase()}
transcript (startSec - endSec - text):
$formattedTranscript
""";

    debugPrint("--- [SummaryService] Attempting model: $_modelName ---");
    try {
      final cardsJson = await _callVertexAiApi(prompt: fullPrompt);
      debugPrint(
        "--- [SummaryService] Successfully generated cards with model: $_modelName ---",
      );
      return cardsJson;
    } on FirebaseException catch (e) {
      // Firebase関連のエラー (APIエラー、権限エラーなど)
      debugPrint(
        "!!! [SummaryService] Failed with FirebaseException with $_modelName: ${e.message} (Code: ${e.code}) !!!",
      );
      throw Exception(
        'Failed to generate flashcard with $_modelName: ${e.message} (Code: ${e.code})',
      );
    } catch (e) {
      // その他の予期せぬエラー
      debugPrint(
        "!!! [SummaryService] Unexpected error during flashcard generation with $_modelName: $e",
      );
      throw Exception(
        'An unexpected error occurred during flashcard generation with $_modelName: $e',
      );
    }
  }

  /// Vertex AI Gemini APIを呼び出す内部メソッド。

  // 新しいヘルパーメソッド
  Map<String, dynamic>? _tryParseJsonLeniently(String jsonString) {
    String trimmedJson = jsonString.trim();

    // 試行する修正パターンのリスト
    List<String Function(String)> fixAttempts = [
      (s) => s, // オリジナル
      (s) => s.endsWith(']') || s.endsWith('}') ? s : '$s]', // 配列の閉じ括弧がない場合
      (s) => s.endsWith(']') || s.endsWith('}') ? s : '$s}', // オブジェクトの閉じ括弧がない場合
      (s) =>
          s.endsWith('}]') || s.endsWith('}}')
              ? s
              : '$s}]', // card配列の要素のオブジェクトが閉じていない場合
      (s) => s.endsWith('}]}') ? s : '$s}]}', // card配列とルートオブジェクトが閉じていない場合
      // "card": [ まで来て途切れた場合など、より複雑なケースを想定
      (s) {
        // "card": [ { "key": "value" // ここで途切れたケース
        if (s.contains('"card": [') && !s.endsWith('}')) {
          if (s.split('{').length > s.split('}').length) {
            // オブジェクトが閉じていない
            return '$s}]}'; // オブジェクト、配列、ルートを閉じる
          }
        }
        return s; // 上記に当てはまらない場合は元のまま
      },
      (s) {
        // "card": [ // ここで途切れたケース
        if (s.endsWith('"card": [')) {
          return '$s{}]}'; // ダミーの要素と配列、ルートを閉じる（空のカードリストとして扱う試み）
        }
        if (s.endsWith('"card": [ ') || s.endsWith('"card": [\n')) {
          return '${s.trimRight()}{}]}';
        }
        return s;
      },
    ];

    for (var fixAttempt in fixAttempts) {
      String potentialJson = fixAttempt(trimmedJson);
      try {
        final decoded = jsonDecode(potentialJson);
        if (decoded is Map<String, dynamic>) {
          // 基本的な構造チェック（'card'キーの存在など）
          if (decoded.containsKey('card') && decoded['card'] is List) {
            debugPrint(
              "--- [_tryParseJsonLeniently] Successfully parsed with fix: ${potentialJson == trimmedJson ? 'original' : potentialJson} ---",
            );
            return decoded;
          } else if (!decoded.containsKey('card') &&
              potentialJson.contains('"card": []')) {
            // "card": [] が含まれるように修正されたが、デコード結果にcardがない場合(例: ルートが配列だった場合など)
            // このケースは現状のスキーマではありえないが、念のため
            return null; // or throw
          }
        }
      } catch (e) {
        // パース失敗、次の試行へ
        debugPrint(
          "--- [_tryParseJsonLeniently] Attempt failed for: $potentialJson --- Error: $e",
        );
      }
    }
    debugPrint(
      "!!! [_tryParseJsonLeniently] All lenient parse attempts failed for: $jsonString !!!",
    );
    return null; // すべての試行で失敗
  }

  Future<String> _callVertexAiApi({required String prompt}) async {
    final startTime = DateTime.now();
    debugPrint(
      "--- [_callVertexAiApi] Calling Vertex AI Gemini API ($_modelName) at $startTime ---",
    );
    // debugPrint("--- [_callVertexAiApi] Prompt: $prompt ---"); // 必要ならコメント解除

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint(
        "--- [_callVertexAiApi] API call successful ($_modelName). Duration: ${duration.inMilliseconds}ms ---",
      );

      if (response.text == null) {
        debugPrint(
          "!!! [_callVertexAiApi] API response text is null. Candidates: ${response.candidates}",
        );
        // 候補の中にエラーがないか確認 (例: Safety ratings)
        if (response.candidates.isNotEmpty) {
          final candidate = response.candidates.first;
          if (candidate.finishReason != FinishReason.safety &&
              candidate.finishReason != FinishReason.recitation &&
              candidate.finishReason != FinishReason.other) {
            // 正常終了だがテキストがない場合
            debugPrint(
              "!!! [_callVertexAiApi] API response text is null but finishReason is ${candidate.finishReason}. Content: ${candidate.content.parts.map((p) => p.toString()).join(',')}",
            );
          }

          // SafetyRating のチェックを修正
          // HarmProbability enum が存在すると仮定 (例: HarmProbability.MEDIUM, HarmProbability.HIGH)
          // 実際のenum名はfirebase_aiのドキュメントで確認が必要
          // ここでは rating.probability が特定の閾値以上かで判断する例
          // TODO: HarmProbability の正しい enum 値を確認し、適切な条件に修正してください。
          // HarmProbability.MEDIUM に相当する値が不明なため、一旦具体的なチェックはコメントアウトします。
          // if (candidate.safetyRatings?.any((rating) =>
          //         (rating.probability != null &&
          //             rating.probability!.index >= /* HarmProbability.MEDIUM に相当する値 */ 3)) ??
          //     false) {
          //   debugPrint(
          //     "!!! [_callVertexAiApi] Content blocked due to safety ratings: ${candidate.safetyRatings}",
          //   );
          //   throw Exception(
          //     'Content generation blocked due to safety concerns. Please revise your input.',
          //   );
          // }
          // 代わりに、safetyRatings が存在し、何らかのレーティングがある場合に警告を出すようにします。
          // より詳細なエラーハンドリングは、HarmProbability の仕様確認後に行ってください。
          if (candidate.safetyRatings != null &&
              candidate.safetyRatings!.isNotEmpty) {
            bool isBlocked = false;
            for (var rating in candidate.safetyRatings!) {
              // HarmProbability の enum の実際の値に基づいて条件を調整してください。
              // 例: rating.probability == HarmProbability.HIGH など
              if (rating.probability.index >= 3) {
                // 仮に index 3 (MEDIUM相当) 以上をブロック
                isBlocked = true;
                break;
              }
            }
            if (isBlocked) {
              debugPrint(
                "!!! [_callVertexAiApi] Content blocked due to safety ratings: ${candidate.safetyRatings}",
              );
              throw Exception(
                'Content generation blocked due to safety concerns. Please revise your input.',
              );
            }
          }
        }
        throw Exception(
          'Failed to generate content: API response text is null.',
        );
      }

      final rawContent = response.text!;
      debugPrint(
        "--- [_callVertexAiApi] Raw content received from $_modelName: ---",
      );
      debugPrint(rawContent);
      debugPrint("--- End of raw content ---");

      String? jsonString;
      // ```json ... ``` ブロックを探す
      final regex = RegExp(r"```json\s*(\{.*?\})\s*```", dotAll: true);
      final match = regex.firstMatch(rawContent);

      if (match != null && match.groupCount >= 1) {
        jsonString = match.group(1);
        debugPrint("--- Extracted JSON from Markdown block ---");
      } else {
        // ```json ブロックがない場合、単純に最初と最後の {} を探す (フォールバック)
        final jsonStartIndex = rawContent.indexOf('{');
        final jsonEndIndex = rawContent.lastIndexOf('}');
        if (jsonStartIndex != -1 &&
            jsonEndIndex != -1 &&
            jsonStartIndex < jsonEndIndex) {
          jsonString = rawContent.substring(jsonStartIndex, jsonEndIndex + 1);
          debugPrint("--- Extracted JSON using fallback ({} search) ---");
        }
      }

      if (jsonString != null) {
        debugPrint(
          "--- [_callVertexAiApi] Extracted potential JSON string: ---",
        );
        debugPrint(jsonString);
        debugPrint("--- End of potential JSON string ---");
        try {
          debugPrint(
            "--- [_callVertexAiApi] Attempting jsonDecode with the string above. ---",
          );
          final decodedJson = jsonDecode(jsonString); // まず通常パース
          debugPrint(
            "--- [_callVertexAiApi] jsonDecode seemingly successful. Type: ${decodedJson.runtimeType} ---",
          );

          if (decodedJson is Map<String, dynamic> &&
              decodedJson.containsKey('card') &&
              decodedJson['card'] is List) {
            debugPrint(
              "--- [_callVertexAiApi] Decoded JSON structure is valid (contains 'card' list). ---",
            );
            return jsonString; // 成功したのでそのまま返す
          } else {
            debugPrint(
              "!!! [_callVertexAiApi] Decoded JSON structure is invalid or incomplete after initial parse. Attempting lenient parse. !!!",
            );
            // 通常パースで構造が不正だった場合も寛容なパースを試みる
            final lenientlyParsedJson = _tryParseJsonLeniently(jsonString);
            if (lenientlyParsedJson != null) {
              debugPrint(
                "--- [_callVertexAiApi] Lenient JSON parsing successful. ---",
              );
              // 寛容なパースで成功した場合、それを文字列に戻して返す
              // (元のjsonStringではなく、修正されたものが返る可能性があるため、再エンコードする)
              return jsonEncode(lenientlyParsedJson);
            }
            debugPrint(
              "!!! [_callVertexAiApi] Lenient JSON parsing also failed. Treating as parse error. !!!",
            );
            throw FormatException(
              "Decoded JSON structure is invalid even after lenient parsing.",
            );
          }
        } on FormatException catch (e) {
          debugPrint(
            "!!! Warning: Initial JSON parsing failed ($e), attempting lenient parse... !!!",
          );
          final lenientlyParsedJson = _tryParseJsonLeniently(jsonString);
          if (lenientlyParsedJson != null) {
            debugPrint(
              "--- [_callVertexAiApi] Lenient JSON parsing successful after FormatException. ---",
            );
            return jsonEncode(lenientlyParsedJson); // 寛容なパース結果を返す
          } else {
            debugPrint(
              "!!! [_callVertexAiApi] Lenient JSON parsing failed after FormatException. Throwing original error. !!!",
            );
            throw Exception(
              // より具体的なエラー情報を含める
              'Invalid or incomplete JSON format from LLM, and lenient parsing failed: $e. Raw content: $rawContent. Extracted JSON: $jsonString',
            );
          }
        } catch (e) {
          debugPrint("!!! Error during JSON decode (non-format): $e");
          throw Exception('Unexpected error during JSON processing: $e');
        }
      } else {
        debugPrint("!!! Error: Could not find JSON block in LLM response.");
        throw Exception(
          'Could not extract JSON from LLM response. Raw content: $rawContent',
        );
      }
    } on FirebaseException catch (e) {
      // API呼び出し中のFirebaseエラー
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint(
        "!!! [_callVertexAiApi] Firebase API call failed ($_modelName). Duration: ${duration.inMilliseconds}ms, Error: ${e.message} (Code: ${e.code}) !!!",
      );
      rethrow; // FirebaseException はそのまま上位に投げる
    } catch (e) {
      // その他の予期せぬエラー
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint(
        "!!! [_callVertexAiApi] Unexpected API call error ($_modelName). Duration: ${duration.inMilliseconds}ms, Error: $e !!!",
      );
      throw Exception('Unexpected error during Vertex AI API call: $e');
    }
  }

  /// 指定された単語のAIによる解説を取得します。
  ///
  /// [word] 解説する単語。
  /// [wordLanguageCode] 単語の言語コード (例: 'en', 'ja')。
  /// [userNativeLanguageCode] ユーザーの母語の言語コード (例: 'ja', 'en')。
  ///
  /// 成功した場合は解説文 (String) を返します。
  /// 失敗した場合は例外をスローします。
  Future<String> getWordExplanation(
    String word,
    String contextSentence, // contextSentence (現在の字幕 + 前の字幕の可能性あり)
    String wordLanguageCode, // タップされた単語の言語 (通常 targetLanguageCode)
    String userNativeLanguageCode, // 解説文の言語
  ) async {
    // contextSentence には前の字幕と現在の字幕が含まれる可能性がある。
    // 前の字幕の言語が wordLanguageCode と異なる場合も考慮が必要だが、
    // 現状の実装では、前の字幕も targetLanguageCode であることを期待している。
    // プロンプトで、文脈が複数の文から成る可能性をAIに伝える。
    final fullPrompt = """
あなたはプロの言語教育アシスタントです。
タスク:
以下の単語について、それが使われている文脈を踏まえて、学習者（母語：${userNativeLanguageCode.toUpperCase()}）が理解しやすいように解説してください。
解説は${userNativeLanguageCode.toUpperCase()}で行い、プレーンテキストで回答してください。

- 説明する: この文で単語の使用を説明してください。  
- 例: $word この文で使用されている単語の例をさらに挙げてください。
- 文法: この文で単語の文法を説明してください

単語: "$word"
文脈:
$contextSentence

説明セクション、例セクション、文法セクションはそれぞれ1つのセクションにまとめてください。

解説文のみを返してください。他の余計なテキストは含めないでください。

""";

    debugPrint(
      "--- [SummaryService] Attempting AI explanation for word: '$word' with context: '$contextSentence' using model: $_wordExplanationModelName ---",
    );
    try {
      final explanationText = await _callVertexAiApiForPlainText(
        prompt: fullPrompt,
      );
      debugPrint(
        "--- [SummaryService] Successfully generated explanation for '$word' using model: $_wordExplanationModelName ---",
      );
      return explanationText;
    } on FirebaseException catch (e) {
      debugPrint(
        "!!! [SummaryService] FirebaseException during word explanation for '$word': ${e.message} (Code: ${e.code}) !!!",
      );
      throw Exception(
        'Failed to get AI explanation for "$word": ${e.message} (Code: ${e.code})',
      );
    } catch (e) {
      debugPrint(
        "!!! [SummaryService] Unexpected error during word explanation for '$word': $e !!!",
      );
      throw Exception(
        'An unexpected error occurred while getting AI explanation for "$word": $e',
      );
    }
  }

  /// プレーンテキスト用のVertex AI API呼び出しメソッド。
  /// JSONパースを行わず、生成されたテキストをそのまま返します。
  Future<String> _callVertexAiApiForPlainText({required String prompt}) async {
    final startTime = DateTime.now();
    debugPrint(
      "--- [_callVertexAiApiForPlainText] Calling Vertex AI API ($_wordExplanationModelName) at $startTime ---",
    );

    try {
      final content = [Content.text(prompt)];
      final response = await _wordExplanationModel.generateContent(content);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint(
        "--- [_callVertexAiApiForPlainText] API call successful ($_wordExplanationModelName). Duration: ${duration.inMilliseconds}ms ---",
      );

      if (response.text == null) {
        debugPrint(
          "!!! [_callVertexAiApiForPlainText] API response text is null. Candidates: ${response.candidates}",
        );
        // 候補の中にエラーがないか確認 (例: Safety ratings)
        if (response.candidates.isNotEmpty) {
          final candidate = response.candidates.first;
          if (candidate.finishReason != FinishReason.safety &&
              candidate.finishReason != FinishReason.recitation &&
              candidate.finishReason != FinishReason.other) {
            // 正常終了だがテキストがない場合
            debugPrint(
              "!!! [_callVertexAiApiForPlainText] API response text is null but finishReason is ${candidate.finishReason}. Content: ${candidate.content.parts.map((p) => p.toString()).join(',')}",
            );
          }

          if (candidate.safetyRatings != null &&
              candidate.safetyRatings!.isNotEmpty) {
            bool isBlocked = false;
            for (var rating in candidate.safetyRatings!) {
              if (rating.probability.index >= 3) {
                // MEDIUM以上をブロックと仮定
                isBlocked = true;
                break;
              }
            }
            if (isBlocked) {
              debugPrint(
                "!!! [_callVertexAiApiForPlainText] Content blocked due to safety ratings: ${candidate.safetyRatings}",
              );
              throw Exception(
                'Content generation blocked due to safety concerns. Please revise your input.',
              );
            }
          }
        }
        throw Exception(
          'Failed to generate content: API response text is null.',
        );
      }

      final rawContent = response.text!;
      debugPrint(
        "--- [_callVertexAiApiForPlainText] Raw content received from $_wordExplanationModelName: ---",
      );
      debugPrint(rawContent);
      debugPrint("--- End of raw content ---");

      return rawContent;
    } on FirebaseException catch (e) {
      // API呼び出し中のFirebaseエラー
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint(
        "!!! [_callVertexAiApiForPlainText] Firebase API call failed ($_wordExplanationModelName). Duration: ${duration.inMilliseconds}ms, Error: ${e.message} (Code: ${e.code}) !!!",
      );
      rethrow; // FirebaseException はそのまま上位に投げる
    } catch (e) {
      // その他の予期せぬエラー
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint(
        "!!! [_callVertexAiApiForPlainText] Unexpected API call error ($_wordExplanationModelName). Duration: ${duration.inMilliseconds}ms, Error: $e !!!",
      );
      throw Exception('Unexpected error during Vertex AI API call: $e');
    }
  }

  // disposeメソッドはdioに依存していたため不要
  // void dispose() {
  //   _dio.close();
  // }
}
