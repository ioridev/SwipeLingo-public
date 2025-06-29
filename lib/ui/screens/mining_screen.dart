import 'package:flutter/foundation.dart'; // defaultTargetPlatform のために追加
// import 'package:flutter/material.dart'; // unnecessary_import: 削除
import 'package:flutter/services.dart'; // クリップボードのために追加
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart'
    as cs; // カルーセルスライダーのインポート（プレフィックス付き）
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMobのインポート // この行は新しいサービスで不要になる可能性
import 'package:swipelingo/l10n/app_localizations.dart';
import '../../providers/mining_providers.dart';
import '../../providers/subscription_provider.dart'; // 課金状態プロバイダーをインポート
// import '../../services/ad_manager.dart'; // AdManager は RewardedAdService 経由で利用
import '../../services/rewarded_ad_service.dart'; // 新しいリワード広告サービス
// import '../../data/recommended_videos.dart'; // recommendedVideosProvider を使うため不要に
import '../../providers/video_list_providers.dart'; // recommendedVideosProvider のため
import '../widgets/video_url_input_field.dart'; // 共通ウィジェット
import '../widgets/recommended_videos_carousel.dart'; // 共通ウィジェット
import '../widgets/video_search_box.dart'; // 共通ウィジェット
import 'package:cached_network_image/cached_network_image.dart';

// TextEditingController を使うために StatefulWidget に変更
class MiningScreen extends ConsumerStatefulWidget {
  const MiningScreen({super.key});

  @override
  ConsumerState<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends ConsumerState<MiningScreen>
    with SingleTickerProviderStateMixin {
  // SingleTickerProviderStateMixin を追加
  late TextEditingController _urlController;
  late TextEditingController _searchController; // 検索用Controllerを追加
  late AnimationController _animationController; // AnimationController を追加

  // RewardedAd? _rewardedAd; // RewardedAdService に移動
  // bool _isRewardedAdLoaded = false; // RewardedAdService に移動

  // TODO: Replace with your actual Ad Unit ID
  // final String _rewardedAdUnitId = AdManager.rewardedAdUnitId; // RewardedAdService に移動

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: ref.read(miningNotifierProvider).url,
    );
    _searchController = TextEditingController(); // 検索用Controllerを初期化
    _animationController = AnimationController(
      // AnimationController を初期化
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    // _loadRewardedAd(); // 初期ロードは RewardedAdService で管理されるか、必要に応じて呼び出す
    // アプリ起動時や画面表示時に一度ロードしておくのが一般的
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rewardedAdServiceProvider.notifier).loadAd();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _searchController.dispose(); // 検索用Controllerを破棄
    _animationController.dispose(); // AnimationController を破棄
    // _rewardedAd?.dispose(); // RewardedAdService で管理
    super.dispose();
  }

  // --- ペースト処理を追加 ---
  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final text = clipboardData.text!;
      _urlController.text = text; // Controller を更新
      ref.read(miningNotifierProvider.notifier).setUrl(text); // Provider を更新
    }
  }
  // --- ここまで追加 ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 国際化のために追加
    // ref は ConsumerState からアクセス可能
    final state = ref.watch(miningNotifierProvider);
    final notifier = ref.read(miningNotifierProvider.notifier);
    // final availableLanguages = ref.watch(availableLanguagesProvider); // 削除
    // final theme = NeumorphicTheme.currentTheme(context); // unused_local_variable: 削除

    // Listen for completion to navigate
    ref.listen<MiningState>(miningNotifierProvider, (previous, next) {
      // --- デバッグ出力追加 ---
      debugPrint("+++ Mining State Changed +++");
      debugPrint(
        "Previous isSearching: ${previous?.isSearching}, Next isSearching: ${next.isSearching}",
      );
      debugPrint(
        "Previous searchError: ${previous?.searchError}, Next searchError: ${next.searchError}",
      );
      debugPrint(
        "Previous searchResults count: ${previous?.searchResults.length}, Next searchResults count: ${next.searchResults.length}",
      );
      debugPrint("Previous isLoading: ${previous?.isLoading}");
      debugPrint("Next isLoading: ${next.isLoading}");
      debugPrint("Next errorMessage: ${next.errorMessage}");
      debugPrint("Next generatedCards count: ${next.generatedCards.length}");
      debugPrint(
        "Next searchResults count: ${next.searchResults.length}",
      ); // 検索結果のデバッグ出力追加
      debugPrint("++++++++++++++++++++++++++++");

      // カード生成完了時のナビゲーション
      final shouldNavigateToCards =
          previous?.isLoading == true &&
          next.isLoading == false &&
          next.errorMessage == 'Processing complete!' &&
          next.generatedCards.isNotEmpty;

      debugPrint("Should navigate to /cards: $shouldNavigateToCards");

      if (shouldNavigateToCards) {
        debugPrint("Navigating to /cards...");
        context.push('/cards', extra: next.generatedCards);
      }
      // カード生成エラー時のSnackBar表示
      else if (previous?.isLoading == true &&
          next.isLoading == false &&
          next.errorMessage != null &&
          next.errorMessage != '処理完了！') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }

      // ローディング開始時にリワード広告表示を試みる (他の条件より先に評価)
      if (previous != null &&
          previous.isLoading == false &&
          next.isLoading == true) {
        // final isSubscribed = ref.watch(isSubscribedProvider); // 課金状態のチェックはRewardedAdServiceに移動
        debugPrint(
          "[MiningScreen listen] isLoading changed to true. Attempting to show rewarded ad via RewardedAdService.",
        );
        // if (!isSubscribed) { // 課金状態のチェックはRewardedAdServiceに移動
        // 非課金ユーザーの場合のみ広告表示
        ref.read(rewardedAdServiceProvider.notifier).showAd().then((
          rewardEarned,
        ) {
          if (rewardEarned) {
            debugPrint(
              "[MiningScreen listen] Rewarded ad process completed successfully (either shown or skipped by service).",
            );
            // 広告視聴成功時の追加処理があればここに記述
          } else {
            debugPrint(
              "[MiningScreen listen] Rewarded ad process failed or was not completed.",
            );
            // 広告視聴失敗時の処理（例：エラーメッセージ表示、機能制限など）
            // ただし、カード生成自体は広告表示とは独立して進む想定
          }
        });
        // } else { // 課金状態のチェックはRewardedAdServiceに移動
        //   debugPrint(
        //     "[MiningScreen listen] User is subscribed, skipping rewarded ad.",
        //   );
        // }
      }

      // 検索が完了し、結果がある場合、新しい検索結果画面に遷移
      if (previous != null && // previous が null でないことを確認
          previous.isSearching && // 前の状態が検索中であり
          !next.isSearching && // 現在の状態が検索中でなく
          next.searchError ==
              null // エラーがない場合
      // next.searchResults.isNotEmpty は遷移先でハンドリングするため、ここでは必須としない
      ) {
        debugPrint(
          "Search completed. Navigating to search results screen with query: ${next.searchQuery}",
        );
        // WidgetsBinding.instance.addPostFrameCallback((_) { // ビルド完了後に実行
        //   if (context.mounted) {
        //     // TODO: go_router の設定に /search-results を追加し、searchQuery を渡す
        //     // context.push('/search-results', extra: next.searchQuery);
        //     // 仮で直接 VideoSearchResultsScreen を表示 (go_router設定後修正)
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) => VideoSearchResultsScreen(searchQuery: next.searchQuery),
        //       ),
        //     );
        //   }
        // });
        // go_router を使った画面遷移 (パスは後で main.dart に定義)
        // 検索クエリをパスパラメータとして渡すか、extraとして渡すか検討。
        // ここでは extra を使用する例
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            debugPrint(
              "[MiningScreen listen] Navigating to /mining/search_results with query: ${next.searchQuery}",
            );
            context.push('/mining/search_results', extra: next.searchQuery);
          }
        });
      }

      // VideoSearchResultsScreen から戻ってきて URL がセットされた場合にマイニングを開始
      // if (previous != null &&
      //     next.url.isNotEmpty && // URLが空でない
      //     previous.url != next.url && // URLが変更された
      //     !next.isLoading && // ローディング中でない
      //     !next.isSearching && // 検索中でもない (念のため)
      //     next
      //         .generatedCards
      //         .isEmpty // まだカードが生成されていない (再生成を防ぐ意図)
      // // この条件は、検索結果画面から戻ってきたことをより確実に示すために調整が必要な場合がある
      // // 例えば、特定のフラグを立てるなど
      // ) {
      //   debugPrint(
      //     "[MiningScreen listen] URL changed, attempting to start mining. New URL: ${next.url}, Old URL: ${previous.url}",
      //   );
      //   _urlController.text = next.url; // テキストボックスの表示も更新
      //   debugPrint(
      //     "[MiningScreen listen] _urlController.text updated to: ${next.url}",
      //   );
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     if (context.mounted && !ref.read(miningNotifierProvider).isLoading) {
      //       // isLoadingでないことも確認
      //       debugPrint(
      //         "[MiningScreen listen postFrame] Calling notifier.startMining() for URL: ${next.url}",
      //       );
      //       notifier.startMining(next.url); // next.url を引数として渡す
      //     } else {
      //       debugPrint(
      //         "[MiningScreen listen postFrame] notifier.startMining() NOT called. context.mounted=${context.mounted}, isLoading=${ref.read(miningNotifierProvider).isLoading}",
      //       );
      //     }
      //   });
      // }
    });

    return Scaffold(
      appBar: NeumorphicAppBar(
        leading: NeumorphicButton(
          // Neumorphic デザインの戻るボタン
          padding: const EdgeInsets.all(8.0), // パディング調整
          style: const NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(), // 円形にする
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop(); // 戻れる場合は pop
            } else {
              context.go('/'); // 戻れない場合はホームへ
            }
          },
          child: const Icon(
            Icons.arrow_back_ios_new, // iOS スタイルの戻るアイコン
            size: 20, // アイコンサイズ調整
          ),
        ),
        title: Text(l10n.selectVideo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Allow scrolling if content overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- URL Input & Paste Button (共通ウィジェットを使用) ---
              VideoUrlInputField(
                urlController: _urlController,
                onUrlChanged: notifier.setUrl,
                onPaste: _pasteFromClipboard,
                isLoading: state.isLoading,
                errorMessage: state.errorMessage,
              ),
              const SizedBox(height: 16),

              // --- 動画検索ボックス (共通ウィジェットを使用) ---
              VideoSearchBox(
                searchController: _searchController,
                onSearchQueryChanged: notifier.setSearchQuery,
                onSearchSubmitted: (query) {
                  debugPrint(
                    '[MiningScreen VideoSearchBox.onSearchSubmitted] Received query: "$query". Current time: ${DateTime.now()}',
                  );
                  // notifier.setSearchQuery(query); // notifier.searchVideos() の中で searchQuery は state から読まれるので、ここでは不要かもしれない。ただし、UIの即時反映のためには必要。
                  // 一旦コメントアウトして、searchVideos 呼び出し前のログで確認
                  debugPrint(
                    '[MiningScreen VideoSearchBox.onSearchSubmitted] Calling notifier.setSearchQuery("$query"). Current time: ${DateTime.now()}',
                  );
                  notifier.setSearchQuery(query);
                  debugPrint(
                    '[MiningScreen VideoSearchBox.onSearchSubmitted] Calling notifier.searchVideos(). Current time: ${DateTime.now()}',
                  );
                  notifier.searchVideos();
                  debugPrint(
                    '[MiningScreen VideoSearchBox.onSearchSubmitted] Called notifier.searchVideos(). Current time: ${DateTime.now()}',
                  );
                },
                isLoading: state.isLoading,
                isSearching: state.isSearching,
                searchError: state.searchError,
              ),
              const SizedBox(height: 16),

              // --- Start Button ---
              NeumorphicButton(
                onPressed:
                    state.isLoading || state.url.isEmpty
                        ? null
                        : () => notifier.startMining(
                          state.url,
                        ), // state.url を引数として渡す
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    state.isLoading ? l10n.generating : l10n.generateFlashcards,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          state.isLoading
                              ? NeumorphicTheme.disabledColor(context)
                              : NeumorphicTheme.defaultTextColor(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // ボタン間のスペースを調整
              // --- Watch Video Button ---
              NeumorphicButton(
                onPressed:
                    state.isLoading || state.url.isEmpty
                        ? null
                        : () {
                          if (state.url.isNotEmpty) {
                            context.push('/video-viewer', extra: state.url);
                          }
                        },
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    l10n.watchVideo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          state.isLoading || state.url.isEmpty
                              ? NeumorphicTheme.disabledColor(context)
                              : NeumorphicTheme.defaultTextColor(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Progress Indicator ---
              if (state.isLoading) ...[
                RotationTransition(
                  turns: _animationController,
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.circle(),
                      depth: 8,
                      intensity: 0.7,
                      color: NeumorphicTheme.currentTheme(context).baseColor,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/icon/icon.png', // アプリアイコン
                      width: 60, // 少し小さめに
                      height: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getLoadingMessage(
                    context,
                    state.errorMessage,
                    l10n,
                  ), // 進捗メッセージ
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: NeumorphicTheme.variantColor(context),
                  ),
                ),
                const SizedBox(height: 12),
                NeumorphicProgress(
                  percent: state.progress,
                  height: 12, // 少し太く
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.processingCardCount(state.generatedCardCount), // テキストを調整
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: NeumorphicTheme.variantColor(context),
                  ),
                ),
                const SizedBox(height: 24), // 下に余白を追加

                const SizedBox(height: 24),
              ],
              // --- 動画カルーセル (共通ウィジェットを使用) ---
              Consumer(
                builder: (context, ref, child) {
                  final recommendedVideosAsyncValue = ref.watch(
                    recommendedVideosProvider,
                  );
                  return recommendedVideosAsyncValue.when(
                    data:
                        (videos) => RecommendedVideosCarousel(
                          videos: videos,
                          isLoading: false, // Providerからロード状態が来るのでfalse固定
                          onVideoTap: (videoId) {
                            context.push('/video-viewer/$videoId');
                          },
                        ),
                    loading:
                        () => RecommendedVideosCarousel(
                          videos: [], // ローディング中は空リスト
                          isLoading: true,
                          onVideoTap: (videoId) {
                            // ローディング中はタップできない想定だが念のため
                            context.push('/video-viewer/$videoId');
                          },
                        ),
                    error:
                        (error, stackTrace) =>
                            Center(child: Text('おすすめ動画の読み込みに失敗しました: $error')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildVideoCarousel, _buildSearchBox は共通ウィジェット化したため削除

  // --- 検索結果表示モーダル ---
  Future<void> _showSearchResultsModal(
    BuildContext context,
    WidgetRef ref,
    MiningState state,
    MiningNotifier notifier,
    AppLocalizations l10n,
  ) async {
    debugPrint(
      "_showSearchResultsModal called. isSearching: ${state.isSearching}, searchResults.length: ${state.searchResults.length}, searchError: ${state.searchError}",
    );
    // isSearching が false で searchResults が空でない場合のみ表示
    // searchError がある場合は、モーダル表示前にSnackBarで通知済みか、あるいはモーダル内で表示する
    if (state.searchResults.isEmpty) {
      debugPrint("_showSearchResultsModal: No results to display, returning.");
      return;
    }
    // isSearching が true の場合も表示しない (ref.listen側で制御しているが念のため)
    if (state.isSearching) {
      debugPrint("_showSearchResultsModal: Still searching, returning.");
      return;
    }
    // searchError があり、結果がない場合はモーダルを表示しない (エラーはSnackBar等で表示想定)
    if (state.searchError != null && state.searchResults.isEmpty) {
      debugPrint(
        "_showSearchResultsModal: Search error and no results, not showing modal.",
      );
      // 必要であればここで再度SnackBar表示
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(state.searchError!),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 高さをコンテンツに合わせる
      builder: (BuildContext modalContext) {
        // modalContext を使用
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5, // 初期表示の高さ（画面の50%）
          minChildSize: 0.3, // 最小の高さ
          maxChildSize: 0.8, // 最大の高さ
          builder: (_, scrollController) {
            return NeumorphicTheme(
              // themeMode の指定を削除
              child: NeumorphicBackground(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        l10n.searchResultsCount(state.searchResults.length),
                        style:
                            NeumorphicTheme.currentTheme(
                              modalContext,
                            ).textTheme.titleLarge,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: state.searchResults.length,
                        itemBuilder: (context, index) {
                          final video = state.searchResults[index];
                          return ListTile(
                            leading:
                                video.thumbnailUrl.isNotEmpty
                                    ? SizedBox(
                                      width: 80,
                                      height: 60,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          4.0,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: video.thumbnailUrl,
                                          fit: BoxFit.cover,
                                          errorWidget:
                                              (ctx, err, st) => const Icon(
                                                Icons.ondemand_video,
                                              ),
                                        ),
                                      ),
                                    )
                                    : const Icon(
                                      Icons.ondemand_video,
                                      size: 40,
                                    ),
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
                            onTap: () {
                              _urlController.text = video.url;
                              notifier.setUrl(video.url);
                              Navigator.of(modalContext).pop(); // モーダルを閉じる
                              // URLセット後、isLoading中でなければマイニング開始
                              final isLoading =
                                  ref.read(miningNotifierProvider).isLoading;
                              debugPrint(
                                "[Modal onTap] isLoading before startMining: $isLoading",
                              );
                              if (!isLoading) {
                                debugPrint(
                                  "[Modal onTap] Calling notifier.startMining()... with URL: ${video.url}",
                                );
                                notifier.startMining(
                                  video.url,
                                ); // video.url を引数として渡す
                              } else {
                                debugPrint(
                                  "[Modal onTap] notifier.startMining() NOT called because isLoading is true.",
                                );
                              }
                              // 検索結果とエラーをクリア
                              notifier.state = state.copyWith(
                                searchResults: [],
                                searchError: null,
                                clearSearchError: true,
                                searchQuery: '', // 検索クエリもクリアする
                              );
                              _searchController.clear(); // 検索ボックスのテキストもクリア
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    // モーダルが閉じた後に検索結果をクリアする (もしモーダル外タップで閉じられた場合など)
    // ただし、モーダル内で選択された場合は既にクリアされている
    if (ref.read(miningNotifierProvider).searchResults.isNotEmpty) {
      notifier.state = state.copyWith(
        searchResults: [],
        searchError: null,
        clearSearchError: true,
        // searchQuery: '', // ここでクリアすると、モーダル再表示時に問題が起きる可能性があるので注意
      );
    }
  }

  // --- ローディングメッセージ取得ヘルパー ---
  String _getLoadingMessage(
    BuildContext context,
    String? currentMessage,
    AppLocalizations l10n,
  ) {
    if (currentMessage == 'Fetching video info & English captions...') {
      return l10n.fetchingVideoInfoCaptions;
    } else if (currentMessage ==
        'Requesting card generation (JA) from LLM...') {
      return l10n.requestingCardGenerationJa;
    } else if (currentMessage == 'Processing generated cards...') {
      return l10n.processingGeneratedCards;
    }
    return currentMessage ?? l10n.generatingCards;
  }

  // void _loadRewardedAd() { // RewardedAdService に移動
  //   // ...
  // }

  // void _setFullScreenContentCallback() { // RewardedAdService に移動
  //   // ...
  // }

  // void _showRewardedAd() { // RewardedAdService に移動
  //   // ...
  // }
}
