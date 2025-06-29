import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:swipelingo/l10n/app_localizations.dart';
import 'package:swipelingo/providers/repository_providers.dart';
import 'package:swipelingo/models/user_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;
import 'package:cached_network_image/cached_network_image.dart';

class FavoriteChannelsScreen extends ConsumerStatefulWidget {
  const FavoriteChannelsScreen({super.key});

  @override
  ConsumerState<FavoriteChannelsScreen> createState() =>
      _FavoriteChannelsScreenState();
}

class _FavoriteChannelsScreenState
    extends ConsumerState<FavoriteChannelsScreen>
    with TickerProviderStateMixin {
  final yt_explode.YoutubeExplode _ytExplode = yt_explode.YoutubeExplode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ytExplode.close();
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
      appBar: NeumorphicAppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(l10n.favoriteChannelsScreenTitle),
          ],
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
        child: userId == null
            ? _buildNotAuthenticatedView(l10n)
            : StreamBuilder<UserModel?>(
                stream: firebaseRepository.getUserStream(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingView();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorView(l10n, snapshot.error.toString());
                  }
                  final user = snapshot.data;
                  if (user == null || user.favoriteChannelIds.isEmpty) {
                    return _buildEmptyView(l10n);
                  }

                  return _buildChannelsList(user.favoriteChannelIds);
                },
              ),
      ),
    );
  }

  Widget _buildNotAuthenticatedView(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_circle_outlined,
                    size: 64,
                    color: Colors.orange.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.userNotAuthenticated,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingView() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.loadingData, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n, String error) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.errorOccurred(error),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.1),
                        Colors.indigo.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.video_library_outlined,
                    size: 80,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.noFavoriteChannelsYet,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.addFavoriteChannelsMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: NeumorphicTheme.defaultTextColor(context).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChannelsList(List<String> favoriteChannels) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: favoriteChannels.length,
              itemBuilder: (context, index) {
                final channelId = favoriteChannels[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: _buildChannelCard(channelId, index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildChannelCard(String channelId, int index) {
    return FutureBuilder<yt_explode.Channel>(
      future: _ytExplode.channels.get(yt_explode.ChannelId(channelId)),
      builder: (context, channelSnapshot) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: channelSnapshot.hasData
                  ? () {
                      final channel = channelSnapshot.data!;
                      context.push(
                        '/channel/${channel.id.value}/videos',
                        extra: channel.title,
                      );
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NeumorphicTheme.baseColor(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
                child: _buildChannelCardContent(channelSnapshot),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChannelCardContent(AsyncSnapshot<yt_explode.Channel> snapshot) {
    final l10n = AppLocalizations.of(context)!;
    
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
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
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (snapshot.hasError) {
      return Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: Colors.red.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.errorOccurredWithMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.channelErrorMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: NeumorphicTheme.defaultTextColor(context).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final channel = snapshot.data;
    if (channel == null) {
      return Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.broken_image, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.channelNotFound(''),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: channel.logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: channel.logoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey.shade600,
                        size: 30,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                      size: 30,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.youtubeChannel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.red.shade600,
          ),
        ),
      ],
    );
  }
}
