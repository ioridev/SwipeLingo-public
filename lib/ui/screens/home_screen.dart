import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'package:swipelingo/l10n/app_localizations.dart';

import '../../providers/repository_providers.dart';
import '../../providers/home_providers.dart';
import '../../providers/flashcard_providers.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/bottom_navigation_provider.dart';
import 'package:in_app_review/in_app_review.dart';
import '../widgets/heatmap_chart.dart';
import '../widgets/gem_display_widget.dart';
import '../../utils/youtube_utils.dart';
import '../../services/rewarded_ad_service.dart';
import './video_watching_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<List<SharedMediaFile>>? _sharedMediaSubscription;

  // Animation controllers
  late AnimationController _welcomeController;
  late AnimationController _cardsController;
  late AnimationController _fabController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _welcomeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initDeepLinks();
    _initSharedIntent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowReviewRequest();
      _startAnimations();
    });
  }

  void _initAnimations() {
    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _welcomeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.bounceOut));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    if (!mounted) return;

    _welcomeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    _cardsController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    _fabController.forward();

    if (mounted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    _cardsController.dispose();
    _fabController.dispose();
    _pulseController.dispose();
    _linkSubscription?.cancel();
    _sharedMediaSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleLink(initialUri);
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  void _handleLink(Uri uri) {
    developer.log('Received link: $uri', name: 'HomeScreen._handleLink');
    final videoId = extractVideoId(uri.toString());
    if (videoId != null) {
      developer.log(
        'Navigating to video: $videoId',
        name: 'HomeScreen._handleLink',
      );
      context.push('/video-viewer/$videoId');
    } else {
      developer.log(
        'Not a valid YouTube video link: $uri',
        name: 'HomeScreen._handleLink',
      );
    }
  }

  Future<void> _initSharedIntent() async {
    final List<SharedMediaFile> initialMedia =
        await ReceiveSharingIntent.instance.getInitialMedia();
    if (initialMedia.isNotEmpty) {
      _handleSharedMedia(initialMedia);
    }

    _sharedMediaSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedMediaFile> media) {
            _handleSharedMedia(media);
          },
          onError: (err) {
            developer.log(
              'Error receiving shared media: $err',
              name: 'HomeScreen._initSharedIntent',
            );
          },
        );
  }

  void _handleSharedMedia(List<SharedMediaFile> mediaList) {
    if (mediaList.isNotEmpty) {
      final sharedPath = mediaList.first.path;
      developer.log(
        'Received shared media path: $sharedPath',
        name: 'HomeScreen._handleSharedMedia',
      );
      final videoId = extractVideoId(sharedPath);
      if (videoId != null) {
        developer.log(
          'Navigating to video from shared media: $videoId',
          name: 'HomeScreen._handleSharedMedia',
        );
        context.push('/video-viewer/$videoId');
      } else {
        developer.log(
          'Not a valid YouTube video link from shared media: $sharedPath',
          name: 'HomeScreen._handleSharedMedia',
        );
      }
    } else {
      developer.log(
        'Received empty shared media list.',
        name: 'HomeScreen._handleSharedMedia',
      );
    }
  }

  Future<void> _checkAndShowReviewRequest() async {
    developer.log('_checkAndShowReviewRequest called', name: 'HomeScreen');
    try {
      final shouldShow = await ref.read(shouldShowReviewRequestProvider.future);
      developer.log(
        'shouldShow: $shouldShow, mounted: $mounted',
        name: 'HomeScreen._checkAndShowReviewRequest',
      );
      if (shouldShow && mounted) {
        developer.log(
          'Showing review request dialog',
          name: 'HomeScreen._checkAndShowReviewRequest',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showReviewRequestDialog();
        });
      }
    } catch (error) {
      developer.log(
        'Error checking review request: $error',
        name: 'HomeScreen._checkAndShowReviewRequest',
      );
    }
  }

  Future<void> _showReviewRequestDialog() async {
    final l10n = AppLocalizations.of(context)!;

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Review Request',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 10,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      NeumorphicTheme.baseColor(context),
                      NeumorphicTheme.baseColor(
                        context,
                      ).withBlue(NeumorphicTheme.baseColor(context).blue + 20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.bounceOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Text(
                              l10n.reviewRequestTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Text(
                              l10n.reviewRequestMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color: NeumorphicTheme.defaultTextColor(
                                  context,
                                ).withOpacity(0.8),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value.clamp(0.0, 1.0),
                              child: _buildReviewButton(
                                context: context,
                                text: l10n.rateNow,
                                icon: Icons.star_rate,
                                isPrimary: true,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD54F),
                                    Color(0xFFFFB300),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _rateApp();
                                  _markReviewRequested();
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value.clamp(0.0, 1.0),
                              child: _buildReviewButton(
                                context: context,
                                text: l10n.remindLater,
                                icon: Icons.access_time,
                                isPrimary: false,
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _markReviewRequested();
                                },
                                child: Text(
                                  l10n.noThanks,
                                  style: TextStyle(
                                    color: NeumorphicTheme.defaultTextColor(
                                      context,
                                    ).withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required bool isPrimary,
    LinearGradient? gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: isPrimary ? Colors.amber.withOpacity(0.3) : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            gradient: isPrimary ? gradient : null,
            color: isPrimary ? null : NeumorphicTheme.baseColor(context),
            borderRadius: BorderRadius.circular(16),
            border:
                isPrimary
                    ? null
                    : Border.all(
                      color: NeumorphicTheme.defaultTextColor(
                        context,
                      ).withOpacity(0.2),
                      width: 1,
                    ),
            boxShadow:
                isPrimary
                    ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    isPrimary
                        ? Colors.white
                        : NeumorphicTheme.defaultTextColor(context),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      isPrimary
                          ? Colors.white
                          : NeumorphicTheme.defaultTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing();
    }
  }

  void _markReviewRequested() {
    final firebaseRepository = ref.read(firebaseRepositoryProvider);
    final userId = firebaseRepository.getCurrentUserId();
    if (userId != null) {
      firebaseRepository.markReviewRequested(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeumorphicTheme.currentTheme(context);
    final isSubscribed = ref.watch(isSubscribedProvider);
    final rewardedAdState = ref.watch(rewardedAdServiceProvider);
    final selectedIndex = ref.watch(bottomNavigationProvider);

    final List<Widget> screens = [
      _LearningTabContent(
        welcomeAnimation: _welcomeAnimation,
        slideAnimation: _slideAnimation,
        pulseAnimation: _pulseAnimation,
      ),
      const VideoWatchingScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.baseColor,
      extendBodyBehindAppBar: true,
      appBar: NeumorphicAppBar(
        title: AnimatedBuilder(
          animation: _welcomeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _welcomeAnimation.value.clamp(0.0, 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 0.8 + (_welcomeAnimation.value * 0.2),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    isSubscribed
                                        ? [
                                          Colors.amber.shade400,
                                          Colors.orange.shade500,
                                        ]
                                        : [
                                          Colors.blue.shade400,
                                          Colors.indigo.shade500,
                                        ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isSubscribed
                                          ? Colors.amber
                                          : Colors.blue)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.translate,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            isSubscribed ? 'Swipelingo Pro' : 'Swipelingo',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: NeumorphicTheme.defaultTextColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Transform.translate(
                        offset: Offset(50 * (1 - _welcomeAnimation.value), 0),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GemDisplayWidget(isSubscribed: isSubscribed),
                        ),
                      ),
                      if (rewardedAdState.isAdLoaded && !isSubscribed)
                        Transform.scale(
                          scale: _welcomeAnimation.value,
                          child: _buildAnimatedAdButton(context),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          AnimatedBuilder(
            animation: _welcomeAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: (1 - _welcomeAnimation.value) * 0.5,
                child: IconButton(
                  icon: const Icon(Icons.menu, size: 20),
                  onPressed: () => context.push('/settings'),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.baseColor,
              theme.baseColor.withBlue(theme.baseColor.blue + 15),
            ],
          ),
        ),
        child: IndexedStack(index: selectedIndex, children: screens),
      ),
      bottomNavigationBar: _buildAnimatedBottomNavBar(context, selectedIndex),
      floatingActionButton: _buildAnimatedFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAnimatedAdButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final adShownSuccessfully =
              await ref.read(rewardedAdServiceProvider.notifier).showAd();
          if (adShownSuccessfully) {
            try {
              await ref.read(firebaseRepositoryProvider).incrementUserGem();
              debugPrint('[HomeScreen] Gem incremented successfully after ad.');
            } catch (e) {
              debugPrint('[HomeScreen] Error incrementing gem: $e');
            }
          } else {
            debugPrint('[HomeScreen] Ad not shown successfully or skipped.');
          }
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.amber.withOpacity(0.3),
        highlightColor: Colors.amber.withOpacity(0.1),
        child: Container(
          margin: const EdgeInsets.only(right: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.getMore,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0.5, 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBottomNavBar(BuildContext context, int selectedIndex) {
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _cardsController,
              curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: NeumorphicTheme.baseColor(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 5,
                  offset: const Offset(0, -10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSimpleNavItem(
                      context: context,
                      index: 0,
                      selectedIndex: selectedIndex,
                      icon: Icons.school_outlined,
                      selectedIcon: Icons.school,
                      label: AppLocalizations.of(context)!.learningTab,
                      color: const Color(0xFF10B981),
                      onTap:
                          () => ref
                              .read(bottomNavigationProvider.notifier)
                              .selectTab(0),
                    ),
                    const SizedBox(width: 60), // Space for FAB
                    _buildSimpleNavItem(
                      context: context,
                      index: 1,
                      selectedIndex: selectedIndex,
                      icon: Icons.smart_display_outlined,
                      selectedIcon: Icons.smart_display,
                      label: AppLocalizations.of(context)!.videoTab,
                      color: const Color(0xFFEF4444),
                      onTap:
                          () => ref
                              .read(bottomNavigationProvider.notifier)
                              .selectTab(1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleNavItem({
    required BuildContext context,
    required int index,
    required int selectedIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isSelected = index == selectedIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    size: 22,
                    color: isSelected ? color : color.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? color : color.withOpacity(0.6),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFAB(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fabController, _pulseController]),
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFA855F7),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(35),
                  onTap: () {
                    // Quick action menu or primary action
                    _showQuickActionMenu(context);
                  },
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _QuickActionMenu(),
    );
  }

  Widget _buildProSubscriptionCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/paywall'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 3,
            intensity: 0.5,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
            color: NeumorphicTheme.accentColor(context).withOpacity(0.1),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.amber, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.upgradeToSwipelingoPro,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.unlimitedGemsNoAdsAccessAllFeatures,
                      style: TextStyle(
                        fontSize: 14,
                        color: NeumorphicTheme.defaultTextColor(
                          context,
                        ).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool hasBadge,
    VoidCallback onTap,
  ) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        depth: 2,
        intensity: 0.7,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      padding: const EdgeInsets.all(16.0),
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasBadge) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.review,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: NeumorphicTheme.defaultTextColor(
                      context,
                    ).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: NeumorphicTheme.defaultTextColor(context).withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

class _LearningTabContent extends ConsumerWidget {
  final Animation<double> welcomeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> pulseAnimation;

  const _LearningTabContent({
    required this.welcomeAnimation,
    required this.slideAnimation,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueCardCountAsync = ref.watch(dueCardCountProvider);
    final streakAsync = ref.watch(streakProvider);
    final totalCardCountAsync = ref.watch(totalCardCountProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20), // Space for transparent app bar
              // Welcome message with animation
              AnimatedBuilder(
                animation: welcomeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: welcomeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.3),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: welcomeAnimation,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.withOpacity(0.1),
                              Colors.indigo.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.indigo.shade500,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.waving_hand,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.welcomeBack,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              NeumorphicTheme.defaultTextColor(
                                                context,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.letsLearnTogether,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: NeumorphicTheme.variantColor(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Promotion card with animation
              if (!isSubscribed)
                SlideTransition(
                  position: slideAnimation,
                  child: _buildEnhancedProCard(context, ref),
                ),

              // Learning features card with staggered animation
              SlideTransition(
                position: slideAnimation,
                child: _buildEnhancedLearningCard(
                  context,
                  ref,
                  dueCardCountAsync,
                ),
              ),

              // Statistics card with animation
              SlideTransition(
                position: slideAnimation,
                child: _buildEnhancedStatsCard(
                  context,
                  ref,
                  streakAsync,
                  totalCardCountAsync,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedProCard(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value.clamp(0.0, 1.0),
          child: GestureDetector(
            onTap: () => context.push('/paywall'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.withOpacity(0.2),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.orange.shade400],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.diamond,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.upgradeToSwipelingoPro,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.unlimitedGemsNoAdsAccessAllFeatures,
                          style: TextStyle(
                            fontSize: 14,
                            color: NeumorphicTheme.defaultTextColor(
                              context,
                            ).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.white,
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

  Widget _buildEnhancedLearningCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue dueCardCountAsync,
  ) {
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
              margin: const EdgeInsets.only(bottom: 20),
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
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        AppLocalizations.of(context)!.learningMenu,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Learning buttons with staggered animation
                  ...List.generate(3, (index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 600 + (index * 200)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, buttonValue, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - buttonValue)),
                          child: Opacity(
                            opacity: buttonValue.clamp(0.0, 1.0),
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: index < 2 ? 16 : 0,
                              ),
                              child: _getEnhancedFeatureButton(
                                context,
                                ref,
                                index,
                                dueCardCountAsync,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getEnhancedFeatureButton(
    BuildContext context,
    WidgetRef ref,
    int index,
    AsyncValue dueCardCountAsync,
  ) {
    switch (index) {
      case 0:
        return dueCardCountAsync.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          data: (dueCardCount) {
            return _buildEnhancedFeatureButton(
              context,
              AppLocalizations.of(context)!.startLearning,
              AppLocalizations.of(
                context,
              )!.dueCardsWaitingForReview(dueCardCount),
              Icons.play_arrow_rounded,
              [Colors.green.shade400, Colors.green.shade600],
              dueCardCount > 0,
              () {
                ref.read(flashcardNotifierProvider.notifier).refresh();
                context.push('/learn');
                if (dueCardCount == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.noScheduledCardsRandomMode,
                      ),
                    ),
                  );
                }
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stackTrace) => Center(
                child: Text(
                  AppLocalizations.of(context)!.countRetrievalError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
        );
      case 1:
        return _buildEnhancedFeatureButton(
          context,
          AppLocalizations.of(context)!.createCardsFromVideo,
          AppLocalizations.of(context)!.learnNewWordsFromYouTube,
          Icons.movie_creation_outlined,
          [Colors.red.shade400, Colors.red.shade600],
          false,
          () => context.push('/mining'),
        );
      case 2:
        return _buildEnhancedFeatureButton(
          context,
          AppLocalizations.of(context)!.cardDeckList,
          AppLocalizations.of(context)!.checkSavedVideoCards,
          Icons.folder_outlined,
          [Colors.amber.shade400, Colors.orange.shade500],
          false,
          () => context.push('/videos'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEnhancedFeatureButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    bool hasBadge,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: gradientColors.first.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                gradientColors.first.withOpacity(0.1),
                gradientColors.last.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gradientColors.first.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasBadge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.review,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: NeumorphicTheme.defaultTextColor(
                          context,
                        ).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gradientColors.first.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: gradientColors.first,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedStatsCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue streakAsync,
    AsyncValue totalCardCountAsync,
  ) {
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
              margin: const EdgeInsets.only(bottom: 20),
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
                            colors: [
                              Colors.purple.shade400,
                              Colors.indigo.shade500,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.insights,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        AppLocalizations.of(context)!.learningStats,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Streak display with animation
                  streakAsync.when(
                    data: (streakValue) {
                      if (streakValue > 0) {
                        return TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.bounceOut,
                          builder: (context, streakAnimation, child) {
                            return Transform.scale(
                              scale: streakAnimation.clamp(0.0, 1.0),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.withOpacity(0.2),
                                      Colors.red.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange,
                                            Colors.red.shade400,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.learningStreakDays(streakValue),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          Text(
                                            '連続学習記録',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.emoji_events_outlined,
                                      color: Colors.orange,
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading:
                        () => const SizedBox(
                          height: 60,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  ),

                  Text(
                    AppLocalizations.of(context)!.activityLast105Days,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: NeumorphicTheme.variantColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Heatmap with animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeInOut,
                    builder: (context, heatmapValue, child) {
                      return Opacity(
                        opacity: heatmapValue.clamp(0.0, 1.0),
                        child: ref
                            .watch(contributionDataProvider)
                            .when(
                              data: (contributionDataValue) {
                                return HeatmapChart(
                                  data:
                                      contributionDataValue.isEmpty
                                          ? const {}
                                          : contributionDataValue,
                                );
                              },
                              loading:
                                  () => const SizedBox(
                                    height: 100,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              error:
                                  (error, stackTrace) => Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.activityRetrievalError,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                            ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Total cards with animation
                  totalCardCountAsync.when(
                    data:
                        (count) => TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, cardValue, child) {
                            return Transform.scale(
                              scale: cardValue.clamp(0.0, 1.0),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.withOpacity(0.15),
                                      Colors.indigo.withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade400,
                                            Colors.indigo.shade500,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.credit_card,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.totalCardsLearned(count),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          Text(
                                            '学習済みカード数',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue.withOpacity(
                                                0.8,
                                              ),
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
                    loading:
                        () => const SizedBox(
                          height: 60,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    error:
                        (err, stack) => Text(
                          AppLocalizations.of(context)!.cardCountRetrievalError,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
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

class _QuickActionMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NeumorphicTheme.baseColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'クイックアクション',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: NeumorphicTheme.defaultTextColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionItem(
                  context,
                  Icons.play_arrow,
                  '学習開始',
                  [Colors.green.shade400, Colors.green.shade600],
                  () {
                    Navigator.pop(context);
                    context.push('/learn');
                  },
                ),
                _buildQuickActionItem(
                  context,
                  Icons.movie_creation,
                  'カード作成',
                  [Colors.red.shade400, Colors.red.shade600],
                  () {
                    Navigator.pop(context);
                    context.push('/mining');
                  },
                ),
                _buildQuickActionItem(
                  context,
                  Icons.folder,
                  'カード一覧',
                  [Colors.amber.shade400, Colors.orange.shade500],
                  () {
                    Navigator.pop(context);
                    context.push('/manage-cards');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context,
    IconData icon,
    String label,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: NeumorphicTheme.defaultTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
