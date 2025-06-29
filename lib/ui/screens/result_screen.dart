import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import '../../models/session_result.dart';
import '../widgets/dialogs_modals/card_detail_dialog.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final SessionResult sessionResult;

  const ResultScreen({super.key, required this.sessionResult});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
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
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.bounceOut,
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() async {
    if (!mounted) return;
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _fadeInController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _slideController.forward();
    
    if (widget.sessionResult.accuracy >= 0.8) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      _confettiController.forward();
    }
    
    if (mounted) {
      _pulseController.repeat(reverse: true);
    }
  }
  
  @override
  void dispose() {
    _fadeInController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeumorphicTheme.currentTheme(context);
    final accuracyPercentage = (widget.sessionResult.accuracy * 100).toStringAsFixed(1);
    final isHighScore = widget.sessionResult.accuracy >= 0.8;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.baseColor,
      extendBodyBehindAppBar: true,
      appBar: NeumorphicAppBar(
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
              child: Text(
                AppLocalizations.of(context)!.sessionResults,
                style: TextStyle(
                  color: NeumorphicTheme.defaultTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isHighScore
                    ? [
                        Colors.amber.withOpacity(0.1),
                        theme.baseColor,
                        Colors.green.withOpacity(0.05),
                      ]
                    : [
                        Colors.blue.withOpacity(0.05),
                        theme.baseColor,
                        Colors.indigo.withOpacity(0.05),
                      ],
              ),
            ),
          ),
          
          // Confetti animation for high scores
          if (isHighScore)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return _confettiController.value > 0
                      ? Lottie.asset(
                          'assets/animations/confetti_update.json',
                          controller: _confettiController,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox.shrink();
                },
              ),
            ),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero result card
                  SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(top: 20, bottom: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isHighScore
                                ? [
                                    Colors.amber.withOpacity(0.2),
                                    Colors.orange.withOpacity(0.1),
                                  ]
                                : [
                                    Colors.blue.withOpacity(0.1),
                                    Colors.indigo.withOpacity(0.05),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isHighScore
                                  ? Colors.amber.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Score circle with animation
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: isHighScore
                                            ? [
                                                Colors.amber,
                                                Colors.orange.shade300,
                                              ]
                                            : [
                                                Colors.blue.shade300,
                                                Colors.indigo.shade400,
                                              ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isHighScore
                                              ? Colors.amber.withOpacity(0.4)
                                              : Colors.blue.withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$accuracyPercentage%',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Icon(
                                            isHighScore
                                                ? Icons.star
                                                : Icons.trending_up,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Title with animation
                            AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                                  child: Text(
                                    isHighScore
                                        ? '🎉 素晴らしい結果です！'
                                        : 'お疲れ様でした！',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: NeumorphicTheme.defaultTextColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            // Stats row
                            AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildStatChip(
                                        icon: Icons.check_circle,
                                        label: '正解',
                                        value: '${widget.sessionResult.correctCount}',
                                        color: Colors.green,
                                      ),
                                      _buildStatChip(
                                        icon: Icons.cancel,
                                        label: '不正解',
                                        value: '${widget.sessionResult.incorrectCount}',
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Section header with animation
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.list_alt,
                                color: NeumorphicTheme.defaultTextColor(context),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.reviewedCards,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: NeumorphicTheme.defaultTextColor(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Animated cards list
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: widget.sessionResult.reviewedCards.length,
                          itemBuilder: (context, index) {
                            final card = widget.sessionResult.reviewedCards[index];
                            final correct = widget.sessionResult.results[card.id] ?? false;
                            
                            // Staggered animation delay
                            final delay = index * 100;
                            
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 600 + delay),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value.clamp(0.0, 1.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        _showEnhancedCardDetailDialog(context, card);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: correct
                                                ? [
                                                    Colors.green.withOpacity(0.1),
                                                    Colors.green.withOpacity(0.05),
                                                  ]
                                                : [
                                                    Colors.red.withOpacity(0.1),
                                                    Colors.pink.withOpacity(0.05),
                                                  ],
                                          ),
                                          border: Border.all(
                                            color: correct
                                                ? Colors.green.withOpacity(0.3)
                                                : Colors.red.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (correct ? Colors.green : Colors.red)
                                                  .withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // Status indicator
                                              Container(
                                                width: 4,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: correct ? Colors.green : Colors.red,
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              
                                              // Card content
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      card.front,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: NeumorphicTheme.defaultTextColor(context),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      card.back,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: NeumorphicTheme.variantColor(context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Result icon with animation
                                              TweenAnimationBuilder<double>(
                                                duration: Duration(milliseconds: 800 + delay),
                                                tween: Tween(begin: 0.0, end: 1.0),
                                                curve: Curves.bounceOut,
                                                builder: (context, iconValue, child) {
                                                  return Transform.scale(
                                                    scale: iconValue.clamp(0.0, 1.0),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: (correct ? Colors.green : Colors.red)
                                                            .withOpacity(0.1),
                                                      ),
                                                      child: Icon(
                                                        correct
                                                            ? Icons.check_circle
                                                            : Icons.cancel,
                                                        color: correct ? Colors.green : Colors.red,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating action button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
              )),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isHighScore
                        ? [
                            Colors.amber.shade400,
                            Colors.orange.shade500,
                          ]
                        : [
                            Colors.blue.shade400,
                            Colors.indigo.shade500,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isHighScore ? Colors.amber : Colors.blue)
                          .withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final bool isFirstSessionCompleted =
                          prefs.getBool('isFirstSessionCompleted') ?? false;

                      if (mounted) {
                        if (!isFirstSessionCompleted) {
                          await prefs.setBool('isFirstSessionCompleted', true);
                          if (mounted) {
                            context.go('/reminder-settings');
                          }
                        } else {
                          if (mounted) {
                            context.go('/');
                          }
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.backToHome,
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
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showEnhancedCardDetailDialog(BuildContext context, card) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.elasticOut,
            )),
            child: CardDetailDialog(card: card),
          ),
        );
      },
    );
  }
}