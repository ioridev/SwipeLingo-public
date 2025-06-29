import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:swipelingo/l10n/app_localizations.dart';

import '../../providers/mining_providers.dart';
import '../../providers/video_list_providers.dart';
import '../widgets/video_url_input_field.dart';
import '../widgets/recommended_videos_list.dart';
import '../widgets/video_search_box.dart';

class VideoWatchingScreen extends ConsumerStatefulWidget {
  const VideoWatchingScreen({super.key});

  @override
  ConsumerState<VideoWatchingScreen> createState() =>
      _VideoWatchingScreenState();
}

class _VideoWatchingScreenState extends ConsumerState<VideoWatchingScreen>
    with TickerProviderStateMixin {
  late TextEditingController _urlController;
  late TextEditingController _searchController;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _urlController = TextEditingController(
      text: ref.read(miningNotifierProvider).url,
    );
    _searchController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }
  
  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startAnimations() async {
    if (!mounted) return;
    
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (!mounted) return;
    _slideController.forward();
    
    if (mounted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final text = clipboardData.text!;
      _urlController.text = text;
      ref.read(miningNotifierProvider.notifier).setUrl(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(miningNotifierProvider);
    final notifier = ref.read(miningNotifierProvider.notifier);
    final recommendedVideosAsyncValue = ref.watch(recommendedVideosProvider);

    // MiningScreen の ref.listen にあった画面遷移ロジックはここでは不要
    // VideoSearchResultsScreen への遷移は検索ボタン押下時に直接行う
    ref.listen<MiningState>(miningNotifierProvider, (previous, next) {
      // 検索が完了し、結果がある場合、新しい検索結果画面に遷移
      if (previous != null &&
          previous.isSearching &&
          !next.isSearching &&
          next.searchError == null &&
          next.searchQuery.isNotEmpty) {
        // searchQueryが空でないことも確認
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            // MiningScreen と同じパスで検索結果画面へ
            context.push('/mining/search_results', extra: next.searchQuery);
          }
        });
      }
      // URLがセットされたら動画視聴画面へ遷移するロジックはここでは不要
    });

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NeumorphicTheme.baseColor(context),
              NeumorphicTheme.baseColor(context).withBlue(
                NeumorphicTheme.baseColor(context).blue + 10,
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Welcome header with animation
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.red.withOpacity(0.1),
                                Colors.pink.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red.shade400, Colors.pink.shade400],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.videoLearning,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: NeumorphicTheme.defaultTextColor(context),
                                      ),
                                    ),
                                    Text(
                                      l10n.videoLearningSubtitle,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: NeumorphicTheme.variantColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Quick actions with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildQuickActionsCard(context, l10n),
                  ),

                  const SizedBox(height: 24),

                  // URL Input section with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildUrlInputSection(context, l10n, state, notifier),
                  ),

                  const SizedBox(height: 24),

                  // Video search section with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildSearchSection(context, l10n, state, notifier),
                  ),

                  const SizedBox(height: 24),

                  // Recommended videos with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildRecommendedSection(context, l10n, recommendedVideosAsyncValue),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, AppLocalizations l10n) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: NeumorphicTheme.baseColor(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade400, Colors.indigo.shade500],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l10n.quickActions,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: NeumorphicTheme.defaultTextColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context: context,
                        icon: Icons.favorite,
                        label: l10n.favoriteChannels,
                        colors: [Colors.pink.shade400, Colors.red.shade500],
                        onTap: () => context.push('/favorite-channels'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        context: context,
                        icon: Icons.folder,
                        label: l10n.cardList,
                        colors: [Colors.amber.shade400, Colors.orange.shade500],
                        onTap: () => context.push('/manage-cards'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context: context,
                        icon: Icons.history,
                        label: l10n.watchHistoryShort,
                        colors: [Colors.blue.shade400, Colors.indigo.shade500],
                        onTap: () => context.push('/watch-history'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        context: context,
                        icon: Icons.playlist_play,
                        label: 'Playlists',
                        colors: [Colors.green.shade400, Colors.teal.shade500],
                        onTap: () => context.push('/playlists'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.first.withOpacity(0.1),
                colors.last.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.first.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.first,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrlInputSection(BuildContext context, AppLocalizations l10n, MiningState state, MiningNotifier notifier) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: NeumorphicTheme.baseColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade600],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.link, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.youtubeUrlInput,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  VideoUrlInputField(
                    urlController: _urlController,
                    onUrlChanged: notifier.setUrl,
                    onPaste: _pasteFromClipboard,
                    isLoading: state.isLoading,
                    errorMessage: state.errorMessage,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: state.url.isNotEmpty ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: state.url.isEmpty
                                  ? [Colors.grey.shade300, Colors.grey.shade400]
                                  : [Colors.red.shade400, Colors.red.shade600],
                            ),
                            boxShadow: state.url.isNotEmpty
                                ? [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: state.isLoading || state.url.isEmpty
                                  ? null
                                  : () {
                                      if (state.url.isNotEmpty) {
                                        final videoIdOrUrl = state.url;
                                        String pathParam;
                                        if (videoIdOrUrl.contains('youtube.com') ||
                                            videoIdOrUrl.contains('youtu.be')) {
                                          Uri uri = Uri.parse(videoIdOrUrl);
                                          if (uri.host.contains('youtu.be')) {
                                            pathParam = uri.pathSegments.isNotEmpty
                                                ? uri.pathSegments.first
                                                : videoIdOrUrl;
                                          } else if (uri.queryParameters.containsKey('v')) {
                                            pathParam = uri.queryParameters['v']!;
                                          } else {
                                            pathParam = videoIdOrUrl;
                                          }
                                        } else {
                                          pathParam = videoIdOrUrl;
                                        }
                                        context.push('/video-viewer/$pathParam');
                                      }
                                    },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      l10n.watchVideo,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(BuildContext context, AppLocalizations l10n, MiningState state, MiningNotifier notifier) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: NeumorphicTheme.baseColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.indigo.shade500],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.search, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.videoSearch,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  VideoSearchBox(
                    searchController: _searchController,
                    onSearchQueryChanged: notifier.setSearchQuery,
                    onSearchSubmitted: (query) {
                      notifier.setSearchQuery(query);
                      notifier.searchVideos();
                    },
                    isLoading: state.isLoading,
                    isSearching: state.isSearching,
                    searchError: state.searchError,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendedSection(BuildContext context, AppLocalizations l10n, AsyncValue recommendedVideosAsyncValue) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: NeumorphicTheme.baseColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade400, Colors.red.shade500],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.recommend, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.recommendedVideos,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  recommendedVideosAsyncValue.when(
                    data: (videos) => RecommendedVideosList(
                      videos: videos,
                      isLoading: false,
                      onVideoTap: (videoId) {
                        context.push('/video-viewer/$videoId');
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => RecommendedVideosList(
                      videos: [],
                      isLoading: false,
                      errorMessage: l10n.failedToLoadRelatedVideos,
                      onVideoTap: (videoId) {
                        context.push('/video-viewer/$videoId');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
