import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';
import '../../models/user_model.dart';
import '../../services/translation_service.dart'; // 追加

class VideoSearchBox extends ConsumerStatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearchQueryChanged;
  final Function(String)
  onSearchSubmitted; // VoidCallback から Function(String) に変更
  final bool isLoading; // 親ウィジェットのisLoading状態
  final bool isSearching; // 検索中の状態
  final String? searchError;

  const VideoSearchBox({
    super.key,
    required this.searchController,
    required this.onSearchQueryChanged,
    required this.onSearchSubmitted,
    required this.isLoading,
    required this.isSearching,
    this.searchError,
  });

  @override
  ConsumerState<VideoSearchBox> createState() => _VideoSearchBoxState();
}

class _VideoSearchBoxState extends ConsumerState<VideoSearchBox> {
  bool _isTranslating = false;
  String? _translationError;
  bool _searchWithTranslation = true; // トグルスイッチの状態

  Future<void> _handleSearchSubmitted() async {
    final originalSearchText = widget.searchController.text;
    print(
      'VideoSearchBox: _handleSearchSubmitted START - originalSearchText: "$originalSearchText", _searchWithTranslation: $_searchWithTranslation',
    );

    if (originalSearchText.isEmpty) {
      print(
        'VideoSearchBox: _handleSearchSubmitted END - searchText is empty, not calling onSearchSubmitted.',
      );
      return;
    }

    if (!_searchWithTranslation) {
      // 翻訳せずに検索
      print(
        'VideoSearchBox: _handleSearchSubmitted - _searchWithTranslation is false. Calling onSearchSubmitted with originalSearchText: "$originalSearchText"',
      );
      widget.onSearchSubmitted(originalSearchText);
      print(
        'VideoSearchBox: _handleSearchSubmitted END - Called onSearchSubmitted with originalSearchText.',
      );
      return;
    }

    final user = ref.read(userDocumentProvider).value;
    if (user == null) {
      // ユーザー情報がない場合は翻訳せずに元のクエリで検索
      print(
        'VideoSearchBox: _handleSearchSubmitted - User is null. Calling onSearchSubmitted with originalSearchText: "$originalSearchText"',
      );
      widget.onSearchSubmitted(originalSearchText);
      print(
        'VideoSearchBox: _handleSearchSubmitted END - Called onSearchSubmitted with originalSearchText because user is null.',
      );
      return;
    }

    final nativeLanguage = user.nativeLanguageCode;
    final targetLanguage = user.targetLanguageCode;
    print(
      'VideoSearchBox: _handleSearchSubmitted - nativeLanguage: "$nativeLanguage", targetLanguage: "$targetLanguage"',
    );

    // ネイティブ言語とターゲット言語が同じ場合は翻訳不要
    if (nativeLanguage == targetLanguage) {
      print(
        'VideoSearchBox: _handleSearchSubmitted - Native and target languages are the same. Calling onSearchSubmitted with originalSearchText: "$originalSearchText"',
      );
      widget.onSearchSubmitted(originalSearchText);
      print(
        'VideoSearchBox: _handleSearchSubmitted END - Called onSearchSubmitted with originalSearchText because languages are the same.',
      );
      return;
    }

    setState(() {
      _isTranslating = true;
      _translationError = null;
    });
    print(
      'VideoSearchBox: _handleSearchSubmitted - Attempting translation for text: "$originalSearchText" from "$nativeLanguage" to "$targetLanguage"',
    );

    try {
      final translationService = ref.read(translationServiceProvider);
      final translatedText = await translationService.translate(
        originalSearchText,
        nativeLanguage,
        targetLanguage,
      );
      print(
        'VideoSearchBox: _handleSearchSubmitted - Translation SUCCESS - originalSearchText: "$originalSearchText", translatedText: "$translatedText"',
      );
      if (mounted) {
        print(
          'VideoSearchBox: _handleSearchSubmitted - Calling onSearchSubmitted with translatedText: "$translatedText"',
        );
        widget.onSearchSubmitted(translatedText);
        print(
          'VideoSearchBox: _handleSearchSubmitted END - Called onSearchSubmitted with translatedText.',
        );
      }
    } catch (e) {
      print(
        'VideoSearchBox: _handleSearchSubmitted - Translation ERROR - originalSearchText: "$originalSearchText", error: $e',
      );
      if (mounted) {
        setState(() {
          _translationError =
              AppLocalizations.of(context)!.translationFailed; // 新規キー
        });
        // 翻訳失敗時は元のテキストで検索する
        print(
          'VideoSearchBox: _handleSearchSubmitted - Translation failed. Calling onSearchSubmitted with originalSearchText: "$originalSearchText"',
        );
        widget.onSearchSubmitted(originalSearchText);
        print(
          'VideoSearchBox: _handleSearchSubmitted END - Called onSearchSubmitted with originalSearchText after translation failure.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
        print(
          'VideoSearchBox: _handleSearchSubmitted FINALLY - _isTranslating set to false',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userModel = ref.watch(userDocumentProvider).value;

    String hintText = l10n.searchVideosOnYouTube;
    String exampleQuery = l10n.exampleSearchQuery;

    if (userModel != null) {
      if (userModel.targetLanguageCode == 'ja') {
        hintText = l10n.searchVideosOnYouTubeWithJapaneseSubtitles;
        exampleQuery = l10n.exampleSearchQueryJapanese;
      }
    }

    final bool isOverallLoading =
        widget.isLoading || widget.isSearching || _isTranslating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Neumorphic(
          child: TextField(
            controller: widget.searchController,
            onChanged: widget.onSearchQueryChanged,
            enabled: !isOverallLoading,
            decoration: InputDecoration(
              hintText: exampleQuery,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: NeumorphicButton(
                padding: const EdgeInsets.all(10.0),
                style: const NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                ),
                onPressed:
                    isOverallLoading || widget.searchController.text.isEmpty
                        ? null
                        : _handleSearchSubmitted,
                child:
                    isOverallLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: NeumorphicProgressIndeterminate(
                            style: ProgressStyle(
                              depth: NeumorphicTheme.depth(context) ?? 0.0,
                            ),
                          ),
                        )
                        : const Icon(Icons.search, size: 20),
              ),
            ),
            onSubmitted:
                isOverallLoading || widget.searchController.text.isEmpty
                    ? null
                    : (_) => _handleSearchSubmitted(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.searchWithTranslation),
            NeumorphicSwitch(
              value: _searchWithTranslation,
              onChanged: (value) {
                setState(() {
                  _searchWithTranslation = value;
                });
              },
            ),
          ],
        ),
        if (widget.searchError != null && !widget.isSearching)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              widget.searchError!,
              style: TextStyle(
                color: Colors.redAccent[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (_translationError != null && !_isTranslating)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              _translationError!,
              style: TextStyle(
                color: Colors.orangeAccent[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
