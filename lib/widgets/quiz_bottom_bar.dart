import 'package:flutter/material.dart';
import '../providers/game_stats_provider.dart';
import '../providers/settings_provider.dart';
import '../models/quiz_state.dart';
import '../l10n/strings_nl.dart' as strings;

/// Bottom navigation bar for quiz screen with action buttons
/// (skip question, unlock biblical reference) and cost display.
class QuizBottomBar extends StatelessWidget {
  final QuizState quizState;
  final GameStatsProvider gameStats;
  final SettingsProvider settings;
  final VoidCallback onSkipPressed;
  final VoidCallback onUnlockPressed;
  final bool isDesktop;

  const QuizBottomBar({
    super.key,
    required this.quizState,
    required this.gameStats,
    required this.settings,
    required this.onSkipPressed,
    required this.onUnlockPressed,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canSkip = gameStats.score >= 35 && !quizState.isAnswering && !quizState.isTransitioning;
    final hasBiblicalReference = quizState.question.biblicalReference != null &&
                                quizState.question.biblicalReference!.isNotEmpty;
    final canUnlock = gameStats.score >= 10 &&
                      !quizState.isAnswering &&
                      !quizState.isTransitioning &&
                      hasBiblicalReference;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha((0.1 * 255).round()),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Skip button
            _buildActionButton(
              context: context,
              icon: Icons.skip_next_rounded,
              label: settings.language == 'en' ? strings.AppStrings.skip : strings.AppStrings.overslaan,
              cost: 35,
              canUse: canSkip,
              onPressed: onSkipPressed,
              isDesktop: isDesktop,
            ),

            // Unlock biblical reference button
            if (hasBiblicalReference)
              _buildActionButton(
                context: context,
                icon: Icons.book_rounded,
                label: strings.AppStrings.unlockBiblicalReference,
                cost: 10,
                canUse: canUnlock,
                onPressed: onUnlockPressed,
                isDesktop: isDesktop,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int cost,
    required bool canUse,
    required VoidCallback onPressed,
    required bool isDesktop,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = canUse ? colorScheme.primary : Colors.grey;

    return Container(
      constraints: BoxConstraints(
        minWidth: isDesktop ? 140 : 100,
        maxWidth: isDesktop ? 220 : 140,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canUse ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isDesktop ? 20 : 18,
                  color: textColor,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.star_rounded,
                  size: isDesktop ? 16 : 14,
                  color: textColor,
                ),
                const SizedBox(width: 2),
                Text(
                  cost.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: isDesktop ? 14 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}