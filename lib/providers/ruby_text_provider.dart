// lib/providers/ruby_text_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ルビ表示設定の永続化プロバイダー
final rubyTextSettingProvider = AsyncNotifierProvider<RubyTextSettingNotifier, bool>(() {
  return RubyTextSettingNotifier();
});

class RubyTextSettingNotifier extends AsyncNotifier<bool> {
  static const _prefKey = 'showRubyText';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSetting = prefs.getBool(_prefKey);
    // デフォルトはtrue（ルビ表示オン）
    return savedSetting ?? true;
  }

  Future<void> updateSetting(bool showRubyText) async {
    state = AsyncValue.data(showRubyText);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, showRubyText);
    debugPrint('[RubyTextSetting] Ruby text setting saved: $showRubyText');
  }

  Future<void> toggle() async {
    final currentValue = state.value ?? true;
    await updateSetting(!currentValue);
  }
}