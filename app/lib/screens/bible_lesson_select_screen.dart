import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bible_lesson.dart';
import '../providers/settings_provider.dart';
import '../services/analytics_service.dart';
import '../services/bible_lesson_service.dart';
import '../screens/lesson_reading_screen.dart';
import '../l10n/strings_nl.dart' as strings;

/// Screen for selecting and browsing Bible learning lessons.
/// These are educational lessons designed for new users who want
/// to learn about the Bible before taking quizzes.
class BibleLessonSelectScreen extends StatefulWidget {
  const BibleLessonSelectScreen({super.key});

  @override
  State<BibleLessonSelectScreen> createState() =>
      _BibleLessonSelectScreenState();
}

class _BibleLessonSelectScreenState extends State<BibleLessonSelectScreen> {
  final BibleLessonService _lessonService = BibleLessonService();
  List<BibleLesson> _lessons = [];
  bool _isLoading = true;
  String? _error;
  Set<String> _completedLessons = {};

  static const String _completedLessonsKey = 'completed_bible_lessons_v1';

  @override
  void initState() {
    super.initState();
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.screen(context, 'BibleLessonSelectScreen');
    analyticsService.capture(context, 'bible_lessons_viewed');

    _loadLessons();
    _loadCompletedLessons();
  }

  Future<void> _loadLessons() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final lessons = await _lessonService.getBeginnerLessons(settings.language);

      if (!mounted) return;
      setState(() {
        _lessons = lessons;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = strings.AppStrings.couldNotLoadLessons;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCompletedLessons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedList = prefs.getStringList(_completedLessonsKey) ?? [];
      setState(() {
        _completedLessons = completedList.toSet();
      });
    } catch (e) {
      // Ignore errors loading completed lessons
    }
  }

  Future<void> _markLessonCompleted(String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _completedLessons.add(lessonId);
      await prefs.setStringList(_completedLessonsKey, _completedLessons.toList());
      if (mounted) setState(() {});
    } catch (e) {
      // Ignore errors saving completed lessons
    }
  }

  int _getNextUnlockedIndex() {
    // Find the first incomplete lesson
    for (int i = 0; i < _lessons.length; i++) {
      if (!_completedLessons.contains(_lessons[i].id)) {
        return i;
      }
    }
    // All completed, return last index
    return _lessons.length - 1;
  }

  bool _isLessonUnlocked(int index) {
    // First lesson is always unlocked
    if (index == 0) return true;
    // Lesson is unlocked if previous lesson is completed
    return _completedLessons.contains(_lessons[index - 1].id);
  }

  void _openLesson(BibleLesson lesson) {
    Provider.of<AnalyticsService>(context, listen: false).capture(
      context,
      'bible_lesson_opened',
      properties: {
        'lesson_id': lesson.id,
        'lesson_title': lesson.title,
      },
    );

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => LessonReadingScreen(lesson: lesson),
      ),
    )
        .then((_) {
      // Refresh to check for newly completed lessons
      _loadCompletedLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final settings = Provider.of<SettingsProvider>(context);

    final completedCount =
        _lessons.where((l) => _completedLessons.contains(l.id)).length;
    final totalCount = _lessons.length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                Icons.school,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              settings.language == 'en' ? 'Bible Basics' : 'Bijbel Basis',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
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
                        onPressed: _loadLessons,
                        child: Text(strings.AppStrings.tryAgain),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLessons,
                  child: CustomScrollView(
                    slivers: [
                      // Header with progress
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: colorScheme.primary,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        settings.language == 'en'
                                            ? 'Learn the basics of the Bible through reading and practice quizzes.'
                                            : 'Leer de basis van de Bijbel door te lezen en te oefenen met quizzen.',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Progress bar
                              if (totalCount > 0) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      settings.language == 'en'
                                          ? 'Progress'
                                          : 'Voortgang',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$completedCount / $totalCount',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: totalCount > 0
                                      ? completedCount / totalCount
                                      : 0,
                                  backgroundColor:
                                      colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  minHeight: 8,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Lesson list
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final lesson = _lessons[index];
                              final isCompleted =
                                  _completedLessons.contains(lesson.id);
                              final isUnlocked = _isLessonUnlocked(index);
                              final isNextUp =
                                  index == _getNextUnlockedIndex() &&
                                      !isCompleted;

                              return _BibleLessonCard(
                                lesson: lesson,
                                index: index,
                                isCompleted: isCompleted,
                                isUnlocked: isUnlocked,
                                isNextUp: isNextUp,
                                onTap: isUnlocked
                                    ? () => _openLesson(lesson)
                                    : null,
                              );
                            },
                            childCount: _lessons.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

/// Card widget for displaying a Bible lesson
class _BibleLessonCard extends StatelessWidget {
  final BibleLesson lesson;
  final int index;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isNextUp;
  final VoidCallback? onTap;

  const _BibleLessonCard({
    required this.lesson,
    required this.index,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isNextUp,
    this.onTap,
  });

  IconData _getIconFromHint(String? hint) {
    switch (hint) {
      case 'menu_book':
        return Icons.menu_book;
      case 'public':
        return Icons.public;
      case 'sailing':
        return Icons.sailing;
      case 'star':
        return Icons.star;
      case 'waves':
        return Icons.waves;
      case 'gavel':
        return Icons.gavel;
      case 'sports_martial_arts':
        return Icons.sports_martial_arts;
      case 'child_care':
        return Icons.child_care;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'brightness_7':
        return Icons.brightness_7;
      case 'school':
        return Icons.school;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final cardColor = !isUnlocked
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : isCompleted
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface;

    final borderColor = isNextUp
        ? colorScheme.primary
        : isCompleted
            ? colorScheme.primary.withValues(alpha: 0.3)
            : colorScheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isNextUp ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icon with lesson number
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: !isUnlocked
                        ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                        : isCompleted
                            ? colorScheme.primary.withValues(alpha: 0.15)
                            : colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        !isUnlocked
                            ? Icons.lock_outline
                            : _getIconFromHint(lesson.iconHint),
                        color: !isUnlocked
                            ? colorScheme.onSurface.withValues(alpha: 0.3)
                            : colorScheme.primary,
                        size: 28,
                      ),
                      if (isCompleted)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Lesson info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lesson.category,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        lesson.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: !isUnlocked
                              ? colorScheme.onSurface.withValues(alpha: 0.4)
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Description
                      Text(
                        lesson.description,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Meta info
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.estimatedReadingMinutes} min',
                            style: textTheme.labelSmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.article_outlined,
                            size: 14,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.sectionCount} sections',
                            style: textTheme.labelSmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.quiz_outlined,
                            size: 14,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.quizQuestionCount}Q',
                            style: textTheme.labelSmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow or status icon
                Icon(
                  !isUnlocked
                      ? Icons.lock_outline
                      : isCompleted
                          ? Icons.check_circle
                          : Icons.arrow_forward_ios,
                  color: !isUnlocked
                      ? colorScheme.onSurface.withValues(alpha: 0.3)
                      : isCompleted
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
