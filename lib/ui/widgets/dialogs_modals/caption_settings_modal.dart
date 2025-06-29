import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/video_player_provider.dart';
import 'package:swipelingo/providers/ruby_text_provider.dart';
import 'package:swipelingo/services/caption_service.dart';
import 'package:swipelingo/services/caption_cache.dart';

void showCaptionSettingsModal(
  BuildContext context,
  WidgetRef ref,
  String videoUrl,
) {
  final l10n = AppLocalizations.of(context)!;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final captionFetchingStrategy = ref.watch(
            captionFetchingStrategyProvider,
          );

          final videoPlayerState = ref.watch(videoPlayerNotifierProvider(videoUrl));
          final rubyTextSetting = ref.watch(rubyTextSettingProvider);
          final rubyTextNotifier = ref.read(rubyTextSettingProvider.notifier);

          return Container(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: <Widget>[
                Text(
                  l10n.playerSettings, // "プレイヤー設定"
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: Text(
                    l10n.forceTranslatedCaptionsTitle,
                  ), // "強制的な翻訳字幕を表示する"
                  value: captionFetchingStrategy.when(
                    data:
                        (strategy) =>
                            strategy ==
                            CaptionFetchingStrategy.individualTranslation,
                    loading: () => false,
                    error: (err, stack) => false,
                  ),
                  onChanged: (bool value) {
                    final newStrategy =
                        value
                            ? CaptionFetchingStrategy.individualTranslation
                            : CaptionFetchingStrategy.xml;
                    ref
                        .read(captionFetchingStrategyProvider.notifier)
                        .updateStrategy(newStrategy);
                    // 動画プレイヤーの字幕をリフレッシュ
                    ref
                        .read(videoPlayerNotifierProvider(videoUrl).notifier)
                        .refreshCaptions();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    l10n.forceTranslatedCaptionsDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                // ルビ表示設定 (日本語字幕の場合のみ表示)
                if (videoPlayerState.targetLanguageCode == 'ja') ...[
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: Text(l10n.showRubyText),
                    subtitle: Text(l10n.showRubyTextDescription),
                    value: rubyTextSetting.value ?? true,
                    onChanged: (bool value) {
                      rubyTextNotifier.updateSetting(value);
                    },
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}
