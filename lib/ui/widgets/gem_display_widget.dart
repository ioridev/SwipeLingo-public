import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/models/user_model.dart'; // UserModelのパスを仮定
import 'package:swipelingo/providers/home_providers.dart'; // userProviderのパスを仮定

class GemDisplayWidget extends ConsumerWidget {
  final bool isSubscribed; // 課金ステータスを受け取る

  const GemDisplayWidget({super.key, required this.isSubscribed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return userAsyncValue.when(
      data: (UserModel? user) {
        final gemCount = user?.gemCount ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback:
                    (bounds) => const LinearGradient(
                      colors: [Color(0xFF40C4FF), Color(0xFF0091EA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                child: const Icon(Icons.diamond, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 6),
              if (isSubscribed)
                const Text(
                  '∞',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  gemCount.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      loading:
          () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      error: (error, stackTrace) {
        // エラーハンドリング: ログ出力やユーザーへの通知など
        debugPrint('Error fetching user gems: $error');
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 16, color: Colors.red),
              SizedBox(width: 4),
              Text(
                '--',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
