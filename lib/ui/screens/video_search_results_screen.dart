import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart'; // context.pop() のために追加
import 'package:swipelingo/l10n/app_localizations.dart';
import '../../providers/mining_providers.dart'; // MiningProvider をインポート
import '../../models/shared_video_model.dart'; // SharedVideoModel をインポート
import 'package:cached_network_image/cached_network_image.dart';

class VideoSearchResultsScreen extends ConsumerStatefulWidget {
  // ConsumerStatefulWidget に変更
  final String searchQuery;

  const VideoSearchResultsScreen({super.key, required this.searchQuery});

  @override
  ConsumerState<VideoSearchResultsScreen> createState() => // createState を実装
      _VideoSearchResultsScreenState();
}

class _VideoSearchResultsScreenState
    extends ConsumerState<VideoSearchResultsScreen> {
  // Stateクラスを作成
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint(
      "[VideoSearchResultsScreen initState] START - searchQuery: ${widget.searchQuery}",
    );
    _scrollController.addListener(_onScroll);
    debugPrint("[VideoSearchResultsScreen initState] END");
  }

  void _onScroll() {
    // isLoadingMore, canLoadMore, nextPageToken の状態を Provider から取得
    final miningState = ref.read(miningNotifierProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !miningState.isLoadingMore &&
        miningState.canLoadMore &&
        miningState.nextPageToken != null) {
      ref.read(miningNotifierProvider.notifier).searchMoreVideos();
    }
  }

  @override
  void dispose() {
    debugPrint("[VideoSearchResultsScreen dispose] START");
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
    debugPrint("[VideoSearchResultsScreen dispose] END");
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "[VideoSearchResultsScreen build] START - searchQuery: ${widget.searchQuery}",
    );
    // WidgetRef は build メソッドの引数から削除 (ConsumerStatefulWidget の場合は ref でアクセス)
    final miningState = ref.watch(miningNotifierProvider);
    final miningNotifier = ref.read(miningNotifierProvider.notifier);

    final result = Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(
          AppLocalizations.of(
            context,
          )!.searchResultsTitle(widget.searchQuery), // widget.searchQuery を使用
        ),
        leading: NeumorphicButton(
          padding: const EdgeInsets.all(8.0),
          style: const NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
          onPressed: () {
            debugPrint(
              "[VideoSearchResultsScreen AppBar onPressed] context.pop() called",
            );
            context.pop(); // go_router の pop を使用
          },
          child: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: _buildBody(
        context,
        miningState,
        miningNotifier,
      ), // notifier は渡す必要がなくなるかも
    );
    debugPrint("[VideoSearchResultsScreen build] END");
    return result;
  }

  Widget _buildBody(
    BuildContext context,
    MiningState state,
    MiningNotifier notifier, // notifier は ref.read で取得できるので引数から削除しても良い
  ) {
    if (state.isSearching && state.searchResults.isEmpty) {
      // 初回検索中のみフルスクリーンローディング
      return const Center(child: NeumorphicProgressIndeterminate());
    }

    if (state.searchError != null && state.searchResults.isEmpty) {
      // 結果がなくエラーがある場合のみ表示
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.errorPrefix(state.searchError!),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              NeumorphicButton(
                onPressed: () {
                  // notifier.searchVideos(); // 再検索のロジックはMiningScreen側にある想定
                },
                child: Text(
                  AppLocalizations.of(context)!.retryButton,
                ), // TODO: 再検索ロジックを検討
              ),
            ],
          ),
        ),
      );
    }

    if (state.searchResults.isEmpty &&
        !state.isSearching &&
        !state.isLoadingMore) {
      // 結果がなく、検索中でも追加読み込み中でもない場合
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            AppLocalizations.of(context)!.noVideosFoundMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 追加読み込み時のエラー表示
    if (state.searchMoreError != null) {
      // スナックバーなどで表示することも検討
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorPrefix(state.searchMoreError!),
            ),
            backgroundColor: Colors.red,
          ),
        );
        // エラー表示後はクリアする（Provider側でクリアする方が良いかもしれない）
        ref.read(miningNotifierProvider.notifier).state = state.copyWith(
          searchMoreError: null,
          clearSearchMoreError: true,
        );
      });
    }

    return ListView.builder(
      controller: _scrollController, // ScrollController を ListView に設定
      itemCount:
          state.searchResults.length +
          (state.isLoadingMore ? 1 : 0), // 追加読み込み中は末尾にローディング表示用のアイテムを追加
      itemBuilder: (context, index) {
        if (index == state.searchResults.length && state.isLoadingMore) {
          // 最後のアイテムで、かつ追加読み込み中の場合はローディングインジケーターを表示
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: NeumorphicProgressIndeterminate(height: 40),
            ),
          );
        }

        final video = state.searchResults[index];
        return Neumorphic(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading:
                video.thumbnailUrl.isNotEmpty
                    ? SizedBox(
                      width: 100, // サムネイルの幅を調整
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: video.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorWidget:
                              (ctx, err, st) =>
                                  const Icon(Icons.ondemand_video, size: 40),
                        ),
                      ),
                    )
                    : const Icon(Icons.ondemand_video, size: 40),
            title: Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              video.channelName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: NeumorphicButton(
              padding: const EdgeInsets.all(8.0),
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                color: Colors.red.withOpacity(0.4),
              ),
              tooltip: AppLocalizations.of(context)!.playVideoInAppTooltip,
              onPressed: () {
                debugPrint(
                  "[VideoSearchResultsScreen] Play button tapped for URL: ${video.url}",
                );
                debugPrint(
                  "[VideoSearchResultsScreen Play button] context.push('/video-viewer/${video.id}') called",
                );
                context.push('/video-viewer/${video.id}');
              },
              child: const Icon(Icons.play_circle_outline, size: 24),
            ),
            onTap: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text(
                      AppLocalizations.of(context)!.confirmDialogTitle,
                    ),
                    content: Text(
                      AppLocalizations.of(
                        context,
                      )!.confirmGenerateFlashcardsMessage(video.title),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.cancelButton),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context)!.generateButtonLabel,
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                debugPrint(
                  "[VideoSearchResultsScreen onTap confirmed] ListTile tapped for URL: ${video.url}, Title: ${video.title}",
                );
                // notifier は ref.read で取得
                ref.read(miningNotifierProvider.notifier).setUrl(video.url);
                // 検索関連の状態クリアは MiningScreen 側で行うか、より適切なタイミングを検討
                // ここでは一旦クリアしないでおく
                // ref.read(miningNotifierProvider.notifier).state = state.copyWith(
                //   searchResults: [],
                //   searchError: null,
                //   clearSearchError: true,
                //   nextPageToken: null,
                //   canLoadMore: false,
                // );
                if (context.mounted) {
                  debugPrint(
                    "[VideoSearchResultsScreen ListTile onTap] context.pop() called",
                  );
                  context.pop(); // MiningScreen に戻る
                }
              } else {
                debugPrint("[VideoSearchResultsScreen onTap] Canceled.");
              }
            },
          ),
        );
      },
    );
  }
}
