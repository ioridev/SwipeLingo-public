import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiny_segmenter_dart/tiny_segmenter_dart.dart'; // ローカルパッケージをインポート

// Provider名は budouxProvider のままにしておくか、tinySegmenterProvider に変更するか検討。
// 既存の参照箇所への影響を考えると、一旦このままにしておくのが無難かもしれないが、
// 実態と合わなくなるため、tinySegmenterProvider に変更するのが望ましい。
// ここでは tinySegmenterProvider に変更する。
final tinySegmenterProvider = Provider<TinySegmenter>((ref) {
  return TinySegmenter();
});
