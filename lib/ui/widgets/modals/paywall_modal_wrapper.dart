import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/ui/screens/paywall_screen.dart';
import 'package:swipelingo/providers/video_player_provider.dart';

class PaywallModalWrapper extends ConsumerWidget {
  // このウィジェット自体は特に引数を必要としないかもしれませんが、
  // 将来的な拡張性を考慮して videoUrl を受け取ることも可能です。
  // final String videoUrl;

  const PaywallModalWrapper({
    super.key,
    // required this.videoUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: NeumorphicTheme(
        themeMode: NeumorphicTheme.of(context)!.themeMode,
        child: const PaywallScreen(),
      ),
    );
  }
}

// Helper function to show the modal
Future<void> showPaywallModal(BuildContext context, String videoUrl) async {
  // videoUrl は videoPlayerNotifier を取得するために必要
  final videoPlayerNotifier = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(videoPlayerNotifierProvider(videoUrl).notifier);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext modalContext) {
      // Consumer 위젯으로 감싸서 Provider에 접근할 수 있도록 합니다.
      // ProviderScope.containerOf(context) を使ってNotifierを取得しているので、
      // ここで再度ProviderScopeで囲む必要はないかもしれません。
      // PaywallModalWrapperがConsumerWidgetなので、builder内でrefが使えます。
      return const PaywallModalWrapper();
    },
  ).then((_) {
    // モーダルが閉じた後に実行
    videoPlayerNotifier.resetShouldShowPaywall();
  });
}
