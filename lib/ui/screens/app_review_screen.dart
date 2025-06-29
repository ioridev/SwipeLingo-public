import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:swipelingo/l10n/app_localizations.dart';

class AppReviewScreen extends StatelessWidget {
  AppReviewScreen({super.key});

  final InAppReview _inAppReview = InAppReview.instance;

  Future<void> _requestReview() async {
    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: NeumorphicAppBar(title: Text(l10n.rateAppTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // パディングを追加
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // ボタンを横幅いっぱいに
          children: [
            Text(
              l10n.thankYouForUsingSwipelingo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: NeumorphicTheme.defaultTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pleaseRateOurApp,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: NeumorphicTheme.variantColor(context),
              ),
            ),
            const SizedBox(height: 32), // スペース調整
            Text(
              l10n.howIsYourExperience,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: NeumorphicTheme.defaultTextColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            NeumorphicButton(
              onPressed: () async {
                await _requestReview();
                // レビューダイアログ表示後、少し待ってから遷移する方が自然かもしれない
                // Future.delayed(const Duration(seconds: 1), () {
                //   context.go('/'); // ホーム画面へ
                // });
                // 現状は即時遷移
                context.go('/'); // ホーム画面へ
              },
              style: NeumorphicStyle(
                // スタイルを追加
                color: NeumorphicTheme.accentColor(context),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16), // パディング調整
              child: Center(
                child: Text(
                  l10n.writeReviewButton,
                  style: TextStyle(
                    // テキストスタイル調整
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // スペース調整
            NeumorphicButton(
              onPressed: () {
                context.go('/'); // ホーム画面へ
              },
              style: NeumorphicStyle(
                color: NeumorphicTheme.baseColor(context),
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14), // パディング調整
              child: Center(
                child: Text(
                  l10n.laterButton,
                  style: TextStyle(
                    fontSize: 16,
                    color: NeumorphicTheme.defaultTextColor(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
