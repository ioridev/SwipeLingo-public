import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/models/firebase_card_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CardDetailDialog extends ConsumerStatefulWidget {
  final FirebaseCardModel card;

  const CardDetailDialog({super.key, required this.card});

  @override
  ConsumerState<CardDetailDialog> createState() => _CardDetailDialogState();
}

class _CardDetailDialogState extends ConsumerState<CardDetailDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rippleController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentNeumorphicTheme = NeumorphicTheme.currentTheme(context);
    final dialogThemeMode =
        NeumorphicTheme.of(context)?.themeMode ?? ThemeMode.system;

    return NeumorphicTheme(
      themeMode: dialogThemeMode,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedBuilder(
          animation: Listenable.merge([_slideController, _fadeController, _scaleController]),
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      maxHeight: 600,
                    ),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          currentNeumorphicTheme.baseColor,
                          currentNeumorphicTheme.baseColor.withOpacity(0.95),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(-5, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header with icon and title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade300,
                                          Colors.indigo.shade400,
                                        ],
                                      ),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.cardDetailsTitle,
                                          style: currentNeumorphicTheme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: currentNeumorphicTheme.defaultTextColor,
                                          ),
                                        ),
                                        Text(
                                          'カード詳細を確認',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: currentNeumorphicTheme.variantColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: Icon(
                                      Icons.close,
                                      color: currentNeumorphicTheme.variantColor,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),

                              // Card content sections
                              _buildAnimatedCardInfo(
                                context,
                                l10n.cardFrontLabel,
                                widget.card.front,
                                currentNeumorphicTheme,
                                Colors.blue,
                                Icons.visibility,
                                0,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              _buildAnimatedCardInfo(
                                context,
                                l10n.cardBackLabel,
                                widget.card.back,
                                currentNeumorphicTheme,
                                Colors.green,
                                Icons.translate,
                                200,
                              ),

                              // Screenshot section
                              if (widget.card.screenshotUrl != null &&
                                  widget.card.screenshotUrl!.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.purple.withOpacity(0.1),
                                              Colors.pink.withOpacity(0.05),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: Colors.purple.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.photo_camera,
                                                  color: Colors.purple,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  l10n.cardScreenshotLabel,
                                                  style: currentNeumorphicTheme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                width: double.infinity,
                                                constraints: const BoxConstraints(
                                                  maxHeight: 200,
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: widget.card.screenshotUrl!,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Container(
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Center(
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => Container(
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(Icons.error, color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],

                              const SizedBox(height: 32),

                              // Action buttons
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1000),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.bounceOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 50 * (1 - value)),
                                    child: Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: Column(
                                        children: [
                                          // Watch video button
                                          _buildActionButton(
                                            context: context,
                                            onPressed: () {
                                              String videoUrl =
                                                  'https://www.youtube.com/watch?v=${widget.card.videoId}';
                                              if (widget.card.start != null) {
                                                videoUrl += '&t=${widget.card.start!.round()}s';
                                              }
                                              Navigator.of(context).pop();
                                              if (mounted) {
                                                context.push('/video-viewer/${widget.card.videoId}');
                                              }
                                            },
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.red.shade400,
                                                Colors.red.shade600,
                                              ],
                                            ),
                                            icon: Icons.play_arrow,
                                            label: l10n.watchVideoSegmentButton,
                                            primary: true,
                                          ),
                                          
                                          const SizedBox(height: 12),
                                          
                                          // Close button
                                          _buildActionButton(
                                            context: context,
                                            onPressed: () => Navigator.of(context).pop(),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.grey.shade400,
                                                Colors.grey.shade600,
                                              ],
                                            ),
                                            icon: Icons.close,
                                            label: l10n.closeButtonLabel,
                                            primary: false,
                                          ),
                                        ],
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedCardInfo(
    BuildContext context,
    String label,
    String value,
    NeumorphicThemeData neumorphicTheme,
    Color accentColor,
    IconData icon,
    int delay,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animValue)),
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.1),
                    accentColor.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: neumorphicTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: neumorphicTheme.baseColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      value,
                      style: neumorphicTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required LinearGradient gradient,
    required IconData icon,
    required String label,
    required bool primary,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
        boxShadow: primary
            ? [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
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
          onTap: () {
            if (mounted) {
              _rippleController.forward().then((_) {
                if (mounted) {
                  _rippleController.reset();
                  onPressed();
                }
              });
            }
          },
          child: AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 1.0 + (_rippleAnimation.value * 0.1),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Helper to show the dialog
Future<void> showCardDetailDialog(
  BuildContext context,
  FirebaseCardModel card,
) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
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