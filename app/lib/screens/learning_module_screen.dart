import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/learning_module.dart';
import '../providers/learning_progress_provider.dart';
import '../services/analytics_service.dart';
import '../l10n/strings_nl.dart' as strings;

/// Screen displaying the content of a single learning module.
class LearningModuleScreen extends StatefulWidget {
  final LearningModule module;

  const LearningModuleScreen({
    super.key,
    required this.module,
  });

  @override
  State<LearningModuleScreen> createState() => _LearningModuleScreenState();
}

class _LearningModuleScreenState extends State<LearningModuleScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analyticsService =
          Provider.of<AnalyticsService>(context, listen: false);
      analyticsService.screen(context, 'LearningModuleScreen');
      analyticsService.capture(context, 'start_learning_module', properties: {
        'module_id': widget.module.id,
        'module_title': widget.module.title,
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _totalPages => widget.module.sections.length + 1; // sections + summary

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.module.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _totalPages,
                minHeight: 4,
                backgroundColor: colorScheme.outlineVariant,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                if (index < widget.module.sections.length) {
                  return _SectionPage(
                    section: widget.module.sections[index],
                    sectionIndex: index,
                    totalSections: widget.module.sections.length,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  );
                } else {
                  return _SummaryPage(
                    module: widget.module,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onComplete: _handleModuleComplete,
                  );
                }
              },
            ),
          ),
          // Navigation buttons
          _NavigationBar(
            currentPage: _currentPage,
            totalPages: _totalPages,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onPrevious: _currentPage > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            onNext: _currentPage < _totalPages - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _handleModuleComplete() async {
    final progress =
        Provider.of<LearningProgressProvider>(context, listen: false);
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);

    // Track completion
    analyticsService.capture(context, 'complete_learning_module', properties: {
      'module_id': widget.module.id,
      'module_title': widget.module.title,
    });

    // Mark module as completed
    await progress.markModuleCompleted(module: widget.module);

    if (!mounted) return;

    // Show completion dialog
    await _showCompletionDialog();

    if (!mounted) return;

    // Navigate back to the learning path
    Navigator.of(context).pop();
  }

  Future<bool?> _showCompletionDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.celebration_outlined,
                color: colorScheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.AppStrings.moduleComplete,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Je hebt "${widget.module.title}" voltooid!',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(strings.AppStrings.backToModules),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionPage extends StatelessWidget {
  final LearningSection section;
  final int sectionIndex;
  final int totalSections;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SectionPage({
    required this.section,
    required this.sectionIndex,
    required this.totalSections,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Deel ${sectionIndex + 1} van $totalSections',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Section title
          Text(
            section.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Text(
            section.content,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          // Key points
          if (section.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        strings.AppStrings.keyPoints,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...section.keyPoints.map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                point,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SummaryPage extends StatelessWidget {
  final LearningModule module;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onComplete;

  const _SummaryPage({
    required this.module,
    required this.colorScheme,
    required this.textTheme,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fun facts section
          if (module.funFacts.isNotEmpty) ...[
            Container(
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
                border:
                    Border.all(color: colorScheme.tertiary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: colorScheme.tertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        strings.AppStrings.funFact,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...module.funFacts.map((fact) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                fact,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Completion card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: colorScheme.primary,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Klaar om af te ronden!',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Je hebt alle onderdelen van deze module bekeken. '
                  'Druk op de knop hieronder om de module af te ronden.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Module Afronden'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
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

class _NavigationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _NavigationBar({
    required this.currentPage,
    required this.totalPages,
    required this.colorScheme,
    required this.textTheme,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: onPrevious,
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(strings.AppStrings.previous),
              style: TextButton.styleFrom(
                foregroundColor: onPrevious != null
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            // Page indicator dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                totalPages,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage == index
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onNext,
              icon: Text(strings.AppStrings.next),
              label: const Icon(Icons.arrow_forward_rounded),
              style: TextButton.styleFrom(
                foregroundColor: onNext != null
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
