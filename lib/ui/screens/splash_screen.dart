import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/repository_providers.dart'; // Adjust path as needed
import '../../models/user_model.dart'; // Adjust path as needed

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLanguageSettingsAndRedirect();
  }

  Future<void> _checkLanguageSettingsAndRedirect() async {
    // Ensure the widget is still mounted before attempting to access context or ref.
    // Add a small delay to ensure GoRouter is ready if called very early.
    await Future.delayed(const Duration(milliseconds: 50));

    if (!mounted) return;

    try {
      final userModel = await ref.read(userDocumentProvider.future);
      if (!mounted) return;

      if (userModel == null || !userModel.isLanguageSettingsCompleted) {
        context.go('/language_selection');
      } else {
        context.go('/');
      }
    } catch (e) {
      // Handle error, e.g., navigate to an error screen or home as a fallback
      debugPrint('Error fetching user document on splash: $e');
      if (mounted) {
        context.go('/'); // Fallback to home on error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
