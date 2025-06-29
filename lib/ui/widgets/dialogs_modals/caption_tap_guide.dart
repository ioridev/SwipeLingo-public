import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipelingo/l10n/app_localizations.dart';

const String _captionTapGuideShownKey = 'caption_tap_guide_shown';

Future<void> showCaptionTapGuideIfNeeded(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final bool guideShown = prefs.getBool(_captionTapGuideShownKey) ?? false;

  if (!guideShown && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.captionTapGuide),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          // kToolbarHeight を直接参照できないため、おおよその値を指定するか、
          // 呼び出し側で AppBar の高さを考慮した padding を渡すなどの工夫が必要になる場合がある。
          // ここでは元の実装に近い形で固定値を元に計算する。
          top:
              MediaQuery.of(context).padding.top +
              kToolbarHeight, // kToolbarHeight は flutter/material.dart で定義
          left: 10,
          right: 10,
          bottom: 10,
        ),
        dismissDirection: DismissDirection.up,
      ),
    );
    await prefs.setBool(_captionTapGuideShownKey, true);
  }
}
