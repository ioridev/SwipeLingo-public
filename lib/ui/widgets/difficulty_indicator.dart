import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

// 難易度メーターウィジェット
class DifficultyIndicator extends StatelessWidget {
  final double difficulty; // 0.0 - 1.0

  const DifficultyIndicator({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('難易度: ', style: Theme.of(context).textTheme.bodySmall),
        Neumorphic(
          style: NeumorphicStyle(
            depth: -2, // くぼんだスタイル
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: CustomPaint(
            size: const Size(20, 12), // メーターのサイズ
            painter: _DifficultyPainter(
              difficulty,
              NeumorphicTheme.isUsingDark(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _DifficultyPainter extends CustomPainter {
  // final double difficulty; //重複していたため削除
  final bool isDarkMode;
  final double difficultyValue; // 新しい名前のフィールド

  _DifficultyPainter(this.difficultyValue, this.isDarkMode); // コンストラクタを修正

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final barWidth = size.width / 4; // 4本のバー
    final spacing = barWidth / 3; // バー間のスペース（おおよそ）

    for (int i = 0; i < 4; i++) {
      final barHeight = size.height * ((i + 1) / 4);
      final x = i * (barWidth + spacing);

      // 難易度に応じて色を決定
      final Color activeColor;
      if (difficultyValue < 0.33) {
        // difficulty を difficultyValue に変更
        activeColor =
            Color.lerp(
              Colors.green.shade400,
              Colors.yellow.shade600,
              difficultyValue / 0.33,
            )!;
      } else if (difficultyValue < 0.66) {
        // difficulty を difficultyValue に変更
        activeColor =
            Color.lerp(
              Colors.yellow.shade600,
              Colors.orange.shade600,
              (difficultyValue - 0.33) / 0.33,
            )!;
      } else {
        activeColor =
            Color.lerp(
              Colors.orange.shade600,
              Colors.red.shade600,
              (difficultyValue - 0.66) /
                  0.34, // difficulty を difficultyValue に変更
            )!;
      }

      bool isActive =
          (difficultyValue * 4).round() > i; // difficulty を difficultyValue に変更

      // ダークモードとライトモードで非アクティブなバーの色を調整
      final Color inactiveColor =
          isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
      paint.color = isActive ? activeColor : inactiveColor;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
          const Radius.circular(2), // 角丸
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DifficultyPainter oldDelegate) {
    return oldDelegate.difficultyValue !=
            difficultyValue || // difficulty を difficultyValue に変更
        oldDelegate.isDarkMode != isDarkMode;
  }
}
