import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/repository_providers.dart';
import 'package:swipelingo/models/watch_history_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;

// Video info cache provider
final videoInfoProvider = FutureProvider.family.autoDispose<yt_explode.Video?, String>((ref, videoId) async {
  final ytExplode = yt_explode.YoutubeExplode();
  try {
    final video = await ytExplode.videos.get(videoId);
    return video;
  } catch (e) {
    return null;
  } finally {
    ytExplode.close();
  }
});

class WatchHistoryScreen extends ConsumerStatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  ConsumerState<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends ConsumerState<WatchHistoryScreen>
    with TickerProviderStateMixin {
  
  // Single animation controller for better performance
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));
  }

  void _startAnimations() async {
    if (!mounted || _hasAnimated) return;
    _hasAnimated = true;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firebaseRepository = ref.watch(firebaseRepositoryProvider);
    final userId = firebaseRepository.getCurrentUserId();
    final theme = NeumorphicTheme.currentTheme(context);

    return Scaffold(
      backgroundColor: theme.baseColor,
      extendBodyBehindAppBar: true,
      appBar: NeumorphicAppBar(
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.indigo.shade500],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.watchHistoryScreenTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: NeumorphicTheme.defaultTextColor(context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        leading: NeumorphicButton(
          padding: const EdgeInsets.all(8.0),
          style: const NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          child: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.baseColor,
              theme.baseColor.withBlue(theme.baseColor.blue + 10),
            ],
          ),
        ),
        child: SafeArea(
          child: userId == null
              ? _buildUnauthenticatedState(context, l10n)
              : StreamBuilder<List<WatchHistory>>(
                  stream: firebaseRepository.getWatchHistoryStream(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    }
                    if (snapshot.hasError) {
                      return _buildErrorState(context, snapshot.error.toString(), l10n);
                    }

                    final watchHistory = snapshot.data ?? [];

                    if (watchHistory.isEmpty) {
                      return _buildEmptyState(context, l10n);
                    }

                    return _buildHistoryList(context, watchHistory, l10n);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context, AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade300, Colors.red.shade400],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.userNotAuthenticated,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: NeumorphicTheme.defaultTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '視聴履歴を読み込み中...',
            style: TextStyle(
              fontSize: 16,
              color: NeumorphicTheme.variantColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'エラーが発生しました',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: NeumorphicTheme.defaultTextColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: NeumorphicTheme.variantColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value.clamp(0.0, 1.0),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey.shade300, Colors.grey.shade400],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.history_toggle_off,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.noWatchHistoryFound,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: NeumorphicTheme.defaultTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '動画を見ると履歴がここに表示されます',
                    style: TextStyle(
                      fontSize: 16,
                      color: NeumorphicTheme.variantColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(BuildContext context, List<WatchHistory> watchHistory, AppLocalizations l10n) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // Header stats
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.withOpacity(0.1),
                        Colors.indigo.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade400, Colors.indigo.shade500],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.watchHistory,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.defaultTextColor(context),
                              ),
                            ),
                            Text(
                              '${watchHistory.length}本の動画',
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
          
          // History list - optimized for performance
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: watchHistory.length,
              cacheExtent: 500, // Improve scroll performance
              itemBuilder: (context, index) {
                final history = watchHistory[index];
                
                // Simple initial animation only - no scroll interference
                if (index < 5 && !_hasAnimated) {
                  // Only animate first 5 items on initial load
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final delay = index * 0.1;
                      final animationProgress = (_animationController.value - delay).clamp(0.0, 1.0);
                      
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - animationProgress)),
                        child: Opacity(
                          opacity: animationProgress.clamp(0.0, 1.0),
                          child: _buildWatchHistoryItem(context, history),
                        ),
                      );
                    },
                  );
                } else {
                  // No animation for other items or after initial animation
                  return _buildWatchHistoryItem(context, history);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchHistoryItem(BuildContext context, WatchHistory history) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: NeumorphicTheme.baseColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/video-viewer/${history.videoId}');
          },
          child: Consumer(
            builder: (context, ref, child) {
              final videoInfoAsync = ref.watch(videoInfoProvider(history.videoId));
              
              return videoInfoAsync.when(
                data: (video) {
                  final videoTitle = video?.title ?? 'Unknown Video';
                  final channelTitle = video?.author ?? 'Unknown Channel';
                  final thumbnailUrl = video?.thumbnails.mediumResUrl;

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Optimized thumbnail with cached network image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey.shade300, Colors.grey.shade400],
                              ),
                            ),
                            child: thumbnailUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: thumbnailUrl,
                                    width: 80,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.video_library,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  )
                                : const Icon(
                                    Icons.video_library,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                videoTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: NeumorphicTheme.defaultTextColor(context),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                channelTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: NeumorphicTheme.variantColor(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatDate(history.watchedAt.toDate()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purple.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Play button
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple.shade400, Colors.indigo.shade500],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => _buildLoadingHistoryItem(),
                error: (error, stack) => _buildLoadingHistoryItem(), // Use loading as fallback
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingHistoryItem() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}分前';
      }
      return '${difference.inHours}時間前';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}