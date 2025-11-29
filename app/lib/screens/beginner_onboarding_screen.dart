import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/analytics_service.dart';
import '../l10n/strings_nl.dart' as strings;
import 'learning_path_screen.dart';

/// A screen that prompts first-time users or those who self-identify as beginners
/// to opt into the beginner learning mode.
class BeginnerOnboardingScreen extends StatelessWidget {
  /// Whether this screen is being shown as a modal/dialog or as a full screen
  final bool isModal;

  /// Callback when user decides to start learning path
  final VoidCallback? onStartLearningPath;

  /// Callback when user skips the beginner onboarding
  final VoidCallback? onSkip;

  const BeginnerOnboardingScreen({
    super.key,
    this.isModal = false,
    this.onStartLearningPath,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Icon with animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) =>
                            Transform.scale(scale: value, child: child),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        strings.AppStrings.beginnerOnboardingTitle,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        strings.AppStrings.beginnerOnboardingMessage,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Features list
                      _FeatureCard(
                        icon: Icons.menu_book_outlined,
                        title: 'Gestructureerde Lessen',
                        description: 'Leer stap voor stap over de Bijbel',
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 12),
                      _FeatureCard(
                        icon: Icons.quiz_outlined,
                        title: 'Oefen Quizzen',
                        description: 'Test je kennis na elke les',
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 12),
                      _FeatureCard(
                        icon: Icons.emoji_events_outlined,
                        title: 'Prestaties',
                        description: 'Verdien badges voor je voortgang',
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleStartLearningPath(context),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(strings.AppStrings.startLearningPath),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _handleSkip(context),
                    child: Text(
                      strings.AppStrings.skipForNow,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleStartLearningPath(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);

    // Track analytics
    analyticsService.capture(context, 'beginner_onboarding_accepted');
    analyticsService.trackFeatureStart(
        context, AnalyticsService.featureLearningPath);

    // Enable beginner mode and mark onboarding as seen
    await settings.setBeginnerModeEnabled(true);
    await settings.markBeginnerOnboardingAsSeen();

    if (!context.mounted) return;

    if (onStartLearningPath != null) {
      onStartLearningPath!();
    } else {
      // Navigate to learning path screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LearningPathScreen(),
        ),
      );
    }
  }

  Future<void> _handleSkip(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);

    // Track analytics
    analyticsService.capture(context, 'beginner_onboarding_skipped');

    // Mark onboarding as seen but don't enable beginner mode
    await settings.markBeginnerOnboardingAsSeen();

    if (!context.mounted) return;

    if (onSkip != null) {
      onSkip!();
    } else if (isModal) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the beginner onboarding as a dialog
Future<bool?> showBeginnerOnboardingDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: BeginnerOnboardingScreen(
          isModal: true,
          onStartLearningPath: () => Navigator.of(context).pop(true),
          onSkip: () => Navigator.of(context).pop(false),
        ),
      ),
    ),
  );
}
