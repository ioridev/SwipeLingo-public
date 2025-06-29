import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class SessionLoadingIndicator extends StatefulWidget {
  const SessionLoadingIndicator({super.key});

  @override
  State<SessionLoadingIndicator> createState() =>
      _SessionLoadingIndicatorState();
}

class _SessionLoadingIndicatorState extends State<SessionLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeumorphicTheme.currentTheme(context);
    return Scaffold(
      backgroundColor: theme.baseColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RotationTransition(
              turns: _controller,
              child: Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 8,
                  intensity: 0.7,
                  color: theme.baseColor, // アイコン背景をテーマに合わせる
                ),
                padding: const EdgeInsets.all(20), // アイコン周りのパディング
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
            const SizedBox(height: 24),
            NeumorphicText(
              '集計中...',
              style: NeumorphicStyle(depth: 1, color: theme.defaultTextColor),
              textStyle: NeumorphicTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
