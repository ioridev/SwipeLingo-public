import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/ui/widgets/gem_display_widget.dart';

class VideoViewerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? videoTitle;
  final bool isSubscribed;
  final VoidCallback? onClose; // オプション: 閉じるボタンのアクションを外部から指定する場合

  const VideoViewerAppBar({
    super.key,
    this.videoTitle,
    required this.isSubscribed,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NeumorphicAppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              videoTitle ?? l10n.videoPlayerTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: GemDisplayWidget(isSubscribed: isSubscribed)),
          ),
        ],
      ),
      leading: NeumorphicButton(
        padding: const EdgeInsets.all(8.0),
        style: const NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
        onPressed: onClose ?? () => context.pop(),
        child: const Icon(Icons.close, size: 20),
      ),
      actions: [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
