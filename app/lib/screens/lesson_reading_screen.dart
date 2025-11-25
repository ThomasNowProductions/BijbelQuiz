import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bible_lesson.dart';
import '../models/lesson.dart';
import '../providers/settings_provider.dart';
import '../services/analytics_service.dart';
import '../screens/quiz_screen.dart';
import '../l10n/strings_nl.dart' as strings;

/// Screen that displays the reading content of a Bible lesson.
/// Users read through the educational sections before taking the quiz.
class LessonReadingScreen extends StatefulWidget {
  final BibleLesson lesson;

  const LessonReadingScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonReadingScreen> createState() => _LessonReadingScreenState();
}

class _LessonReadingScreenState extends State<LessonReadingScreen> {
  final PageController _pageController = PageController();
  int _currentSection = 0;

  @override
  void initState() {
    super.initState();
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.screen(context, 'LessonReadingScreen');
    analyticsService.capture(context, 'bible_lesson_started', properties: {
      'lesson_id': widget.lesson.id,
      'lesson_title': widget.lesson.title,
      'section_count': widget.lesson.sectionCount,
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextSection() {
    if (_currentSection < widget.lesson.sectionCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // All sections read, start the quiz
      _startQuiz();
    }
  }

  void _goToPreviousSection() {
    if (_currentSection > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startQuiz() {
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.capture(context, 'bible_lesson_reading_completed',
        properties: {
          'lesson_id': widget.lesson.id,
          'lesson_title': widget.lesson.title,
        });

    // Convert BibleLesson to Lesson for the quiz screen
    final quizLesson = Lesson(
      id: widget.lesson.id,
      title: widget.lesson.title,
      category: widget.lesson.questionCategory,
      maxQuestions: widget.lesson.quizQuestionCount,
      index: widget.lesson.index,
      description: widget.lesson.description,
      iconHint: widget.lesson.iconHint,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          lesson: quizLesson,
          sessionLimit: widget.lesson.quizQuestionCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final settings = Provider.of<SettingsProvider>(context);
    final isLastSection = _currentSection == widget.lesson.sectionCount - 1;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: strings.AppStrings.close,
        ),
        title: Text(
          widget.lesson.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Reading time estimate
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.lesson.estimatedReadingMinutes} min',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      settings.language == 'en'
                          ? 'Section ${_currentSection + 1} of ${widget.lesson.sectionCount}'
                          : 'Sectie ${_currentSection + 1} van ${widget.lesson.sectionCount}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '${((_currentSection + 1) / widget.lesson.sectionCount * 100).round()}%',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentSection + 1) / widget.lesson.sectionCount,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          // Section content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentSection = index;
                });
                // Track section view
                Provider.of<AnalyticsService>(context, listen: false).capture(
                    context, 'bible_lesson_section_viewed',
                    properties: {
                      'lesson_id': widget.lesson.id,
                      'section_index': index,
                      'section_heading': widget.lesson.sections[index].heading,
                    });
              },
              itemCount: widget.lesson.sectionCount,
              itemBuilder: (context, index) {
                final section = widget.lesson.sections[index];
                return _SectionContent(section: section);
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Previous button
                  if (_currentSection > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _goToPreviousSection,
                        icon: const Icon(Icons.arrow_back),
                        label: Text(strings.AppStrings.previous),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                  const SizedBox(width: 12),
                  // Next / Start Quiz button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _goToNextSection,
                      icon: Icon(isLastSection
                          ? Icons.quiz_outlined
                          : Icons.arrow_forward),
                      label: Text(
                        isLastSection
                            ? strings.AppStrings.startQuiz
                            : strings.AppStrings.next,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display a single section's content
class _SectionContent extends StatelessWidget {
  final LessonSection section;

  const _SectionContent({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              section.heading,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),

          // Bible reference badge (if available)
          if (section.bibleReference != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    section.bibleReference!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Main content
          Text(
            section.content,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.87),
              height: 1.6,
              letterSpacing: 0.15,
            ),
          ),

          // Image (if available)
          if (section.imagePath != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                section.imagePath!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
