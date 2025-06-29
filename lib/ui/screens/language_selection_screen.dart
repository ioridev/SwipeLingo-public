import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipelingo/l10n/app_localizations.dart';

import '../../providers/repository_providers.dart';
import '../../models/user_model.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  final Map<String, String> _supportedLanguages = {
    'en': 'English', // 今後ローカライズ対応する可能性あり
    'ja': '日本語', // 今後ローカライズ対応する可能性あり
  };

  String? _selectedNativeLanguage;
  String? _selectedTargetLanguage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // デバイスの言語を取得し、サポートされていれば初期値として設定
      if (mounted) {
        // contextが有効であることを確認
        final deviceLocale = Localizations.localeOf(context);
        final deviceLanguageCode = deviceLocale.languageCode;
        if (_supportedLanguages.containsKey(deviceLanguageCode)) {
          setState(() {
            _selectedNativeLanguage = deviceLanguageCode;
            // ネイティブ言語と異なるターゲット言語を初期設定
            if (_supportedLanguages.length > 1) {
              _selectedTargetLanguage = _supportedLanguages.keys.firstWhere(
                (lang) => lang != _selectedNativeLanguage,
                orElse: () => _supportedLanguages.keys.first,
              );
            }
          });
        }
      }
    });
  }

  Future<void> _saveLanguageSettings() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedNativeLanguage == null || _selectedTargetLanguage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectLanguages)));
      return;
    }
    if (_selectedNativeLanguage == _selectedTargetLanguage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nativeAndTargetMustBeDifferent)),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // エラー処理: ユーザーが認証されていない
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorMessageAnErrorOccurred),
        ), // 一般的なエラーメッセージ
      );
      return;
    }

    final updateData = {
      'nativeLanguageCode': _selectedNativeLanguage!,
      'targetLanguageCode': _selectedTargetLanguage!,
      'isLanguageSettingsCompleted': true,
    };

    try {
      await ref
          .read(firebaseRepositoryProvider)
          .updateUserDocument(uid, updateData);
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.errorMessageAnErrorOccurred}: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageSelectionScreenTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.selectYourNativeLanguage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            DropdownButtonFormField<String>(
              value: _selectedNativeLanguage,
              hint: Text(l10n.selectNativeLanguageHint),
              items:
                  _supportedLanguages.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                      ), // _supportedLanguagesの値は現状ローカライズしない
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedNativeLanguage = value;
                  // ネイティブ言語が変更された場合、ターゲット言語も変更する
                  // ただし、ネイティブ言語とターゲット言語が同じにならないようにする
                  if (_selectedNativeLanguage != null &&
                      _selectedNativeLanguage == _selectedTargetLanguage) {
                    // サポートされている言語が2つしかない前提で、もう一方の言語を選択
                    _selectedTargetLanguage = _supportedLanguages.keys
                        .firstWhere(
                          (lang) => lang != _selectedNativeLanguage,
                          orElse: () => _supportedLanguages.keys.first,
                        );
                  }
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.selectLanguageToLearn,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            DropdownButtonFormField<String>(
              value: _selectedTargetLanguage,
              hint: Text(l10n.selectLanguageToLearnHint),
              items:
                  _supportedLanguages.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                      ), // _supportedLanguagesの値は現状ローカライズしない
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTargetLanguage = value;
                  // ターゲット言語が変更された場合、ネイティブ言語と同じにならないようにする
                  if (_selectedTargetLanguage != null &&
                      _selectedTargetLanguage == _selectedNativeLanguage) {
                    // サポートされている言語が2つしかない前提で、もう一方の言語を選択
                    // このロジックは必須ではないかもしれないが、念のため入れておく
                    // _selectedNativeLanguage = _supportedLanguages.keys
                    //     .firstWhere((lang) => lang != _selectedTargetLanguage, orElse: () => null);
                  }
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveLanguageSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(l10n.confirmAndStartButton),
            ),
          ],
        ),
      ),
    );
  }
}
