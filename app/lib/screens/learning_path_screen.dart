import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/learning_module.dart';
import '../providers/settings_provider.dart';
import '../providers/learning_progress_provider.dart';
import '../services/beginner_learning_service.dart';
import '../services/analytics_service.dart';
import '../l10n/strings_nl.dart' as strings;
import 'learning_module_screen.dart';

/// Screen displaying the beginner learning path with all available modules.
class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  final LearningService _learningService = LearningService();
  List<LearningModule> _modules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadModules();

    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analyticsService =
          Provider.of<AnalyticsService>(context, listen: false);
      analyticsService.screen(context, 'LearningPathScreen');
    });
  }

  Future<void> _loadModules() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final modules = await _learningService.getModules();

      if (!mounted) return;
      setState(() {
        _modules = modules;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Kon modules niet laden';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final progress = Provider.of<LearningProgressProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.school_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strings.AppStrings.learningPath,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadModules,
                        child: const Text('Opnieuw proberen'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadModules,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Progress header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: _ProgressHeader(
                            completedCount: progress.completedModuleCount,
                            totalCount: _modules.length,
                            streak: progress.learningStreak,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                        ),
                      ),

                      // Module list
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final module = _modules[index];
                              final isCompleted =
                                  progress.isModuleCompleted(module.id);
                              final isLocked = index > 0 &&
                                  !progress.isModuleCompleted(
                                      _modules[index - 1].id);
                              final quizScore =
                                  progress.getModuleQuizScore(module.id);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ModuleCard(
                                  module: module,
                                  isCompleted: isCompleted,
                                  isLocked: isLocked,
                                  quizScore: quizScore,
                                  colorScheme: colorScheme,
                                  textTheme: textTheme,
                                  onTap: isLocked
                                      ? null
                                      : () => _navigateToModule(module),
                                ),
                              );
                            },
                            childCount: _modules.length,
                          ),
                        ),
                      ),

                      // Recommendation for regular quizzes
                      if (progress.completedModuleCount >= 3)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _RegularQuizzesCard(
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                          ),
                        ),

                      const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                    ],
                  ),
                ),
    );
  }

  void _navigateToModule(LearningModule module) {
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.capture(context, 'open_learning_module', properties: {
      'module_id': module.id,
      'module_title': module.title,
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearningModuleScreen(module: module),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final int streak;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ProgressHeader({
    required this.completedCount,
    required this.totalCount,
    required this.streak,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent =
        totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.8),
            colorScheme.primaryContainer.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.AppStrings.modulesCompleted,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount / $totalCount',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              if (streak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: colorScheme.onPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final LearningModule module;
  final bool isCompleted;
  final bool isLocked;
  final int? quizScore;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  const _ModuleCard({
    required this.module,
    required this.isCompleted,
    required this.isLocked,
    required this.quizScore,
    required this.colorScheme,
    required this.textTheme,
    this.onTap,
  });

  IconData _getIconData() {
    switch (module.iconHint) {
      case 'menu_book':
        return Icons.menu_book_outlined;
      case 'history_edu':
        return Icons.history_edu_outlined;
      case 'auto_stories':
        return Icons.auto_stories_outlined;
      case 'public':
        return Icons.public_outlined;
      case 'church':
        return Icons.church_outlined;
      default:
        return Icons.school_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isLocked
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : isCompleted
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surface;

    final contentOpacity = isLocked ? 0.5 : 1.0;

    return Card(
      elevation: isLocked ? 0 : 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Opacity(
            opacity: contentOpacity,
            child: Row(
              children: [
                // Module icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isLocked
                      ? Icon(
                          Icons.lock_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 24,
                        )
                      : Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : _getIconData(),
                          color: isCompleted
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 16),
                // Module info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.description,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${module.estimatedMinutes} ${strings.AppStrings.minutesShort}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          if (quizScore != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.quiz_outlined,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$quizScore%',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow or status indicator
                if (!isLocked)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegularQuizzesCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _RegularQuizzesCard({
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.tertiaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: colorScheme.tertiary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.AppStrings.readyForRegularQuizzes,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            strings.AppStrings.readyForRegularQuizzesMessage,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Return to lesson select
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.tertiary,
                foregroundColor: colorScheme.onTertiary,
              ),
              child: Text(strings.AppStrings.tryRegularQuizzes),
            ),
          ),
        ],
      ),
    );
  }
}
