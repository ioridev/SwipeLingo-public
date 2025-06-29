import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ボトムナビゲーションの選択状態を管理するProvider
final bottomNavigationProvider =
    StateNotifierProvider<BottomNavigationNotifier, int>((ref) {
      return BottomNavigationNotifier();
    });

class BottomNavigationNotifier extends StateNotifier<int> {
  static const String _selectedTabKey = 'selected_tab_index';
  
  BottomNavigationNotifier() : super(0) {
    _loadSelectedTab();
  }

  // 保存されているタブを読み込む
  Future<void> _loadSelectedTab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_selectedTabKey) ?? 0;
      // 有効なインデックス範囲内であることを確認（0-1の範囲）
      if (savedIndex >= 0 && savedIndex <= 1) {
        state = savedIndex;
      }
    } catch (e) {
      // エラーが発生した場合はデフォルト値のまま
      state = 0;
    }
  }

  void selectTab(int index) {
    state = index;
    _saveSelectedTab(index);
  }

  // 選択されたタブを保存する
  Future<void> _saveSelectedTab(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_selectedTabKey, index);
    } catch (e) {
      // 保存に失敗してもアプリの動作に影響しないように
      // エラーハンドリングは特に行わない
    }
  }
}
