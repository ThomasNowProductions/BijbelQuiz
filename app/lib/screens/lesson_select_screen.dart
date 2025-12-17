import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bijbelquiz/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson.dart';
import '../providers/lesson_progress_provider.dart';
import '../providers/settings_provider.dart';
import '../services/lesson_service.dart';
import '../screens/quiz_screen.dart';
import '../screens/guide_screen.dart';
import '../screens/multiplayer_game_setup_screen.dart';
import '../screens/social_screen.dart';
import '../widgets/top_snackbar.dart';
import '../l10n/strings_nl.dart' as strings;
import '../constants/urls.dart';
import '../widgets/progress_header.dart';
import '../widgets/lesson_tile.dart';
import '../widgets/lesson_skeleton.dart';
import '../widgets/promo_card.dart';
import '../utils/streak_calculator.dart' as streak_utils;

class LessonSelectScreen extends StatefulWidget {
  const LessonSelectScreen({super.key});

  @override
  State<LessonSelectScreen> createState() => _LessonSelectScreenState();
}

class _LessonSelectScreenState extends State<LessonSelectScreen> {
  final LessonService _lessonService = LessonService();
  final ScrollController _scrollController = ScrollController();

  /// Whether lessons are currently loading for the first time
  bool _isInitialLoading = true;

  /// Whether lessons are currently loading
  bool _isLoading = false;

  /// Whether more lessons are currently loading
  bool _isLoadingMore = false;

  /// Whether to show skeleton loaders while loading
  bool _showSkeletons = true;

  /// Error message if loading failed
  String? _error;

  /// List of loaded lessons
  List<Lesson> _lessons = const [];

  /// Flag to prevent multiple guide checks
  bool _guideCheckCompleted = false;

  /// Whether to show the promotional card
  bool _showPromoCard = false;

  /// Which type of promo to show
  bool _isDonationPromo = true; // true for donation, false for follow
  bool _isSatisfactionPromo = false; // true for satisfaction survey
  bool _isDifficultyPromo = false; // true for difficulty feedback
  bool _isAccountCreationPromo = false; // true for account creation
  String? _socialMediaType; // for individual social media popups
  // Search and filters removed for simplified UI

  // Daily usage streak tracking (persisted locally)
  static const String _activeDaysKey = 'daily_active_days_v1';
  Set<String> _activeDays = {};
  int _streakDays = 0;

  // Cached lessons
  static const String _cachedLessonsKey = 'cached_lessons_v1';

  @override
  void initState() {
    super.initState();
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);

    // Track screen view
    analyticsService.screen(context, 'LessonSelectScreen');

    // Track lesson system access
    analyticsService.trackFeatureStart(
        context, AnalyticsService.featureLessonSystem);

    _loadLessons(maxLessons: 20);
    _loadStreakData();
    _loadCachedLessons();
    _scrollController.addListener(_onScroll);

    // Check if we need to show the guide screen (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowGuide();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500 &&
        !_isLoadingMore &&
        !_isLoading) {
      _loadMoreLessons();
    }
  }

  void _checkAndShowGuide() {
    if (!mounted || _guideCheckCompleted) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // If settings are still loading, retry shortly after load completes
    if (settings.isLoading) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _checkAndShowGuide();
      });
      return;
    }

    // Only show the guide if the user hasn't seen it yet
    if (!settings.hasSeenGuide) {
      // Prevent multiple navigations
      _guideCheckCompleted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const GuideScreen(),
          ),
        );
      });
      return;
    }

    // No need to show the guide; mark check as completed
    _guideCheckCompleted = true;
  }

  /// Helper method to track lesson selection analytics
  void _trackLessonSelection(Lesson lesson, bool unlocked) {
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);

    // Track lesson system usage
    analyticsService.trackFeatureSuccess(
        context, AnalyticsService.featureLessonSystem,
        additionalProperties: {
          'lesson_id': lesson.id,
          'lesson_category': lesson.category,
          'lesson_unlocked': unlocked,
        });

    // Track streak feature if this contributes to streak
    if (_streakDays > 0) {
      analyticsService.trackFeatureUsage(
          context,
          AnalyticsService.featureStreakTracking,
          AnalyticsService.actionUsed,
          additionalProperties: {
            'current_streak': _streakDays,
          });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only check for guide if we haven't already completed the check
    if (mounted && !_guideCheckCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowGuide();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_activeDaysKey) ?? <String>[];
      _activeDays = list.toSet();

      // Calculate streak using the utility class
      _streakDays = streak_utils.StreakCalculator.calculateCurrentStreak(_activeDays);
    } catch (e) {
      // Log error but continue gracefully
      debugPrint('Error loading streak data: $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _refreshStreakData() async {
    await _loadStreakData();
  }

  Future<void> _loadCachedLessons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cachedLessonsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final cachedLessons = jsonList.map((e) => Lesson.fromJson(e)).toList();

        // If we have cached lessons, show them while we load fresh data
        if (cachedLessons.isNotEmpty) {
          if (mounted) {
            setState(() {
              _lessons = cachedLessons;
              _showSkeletons = false;
              _isInitialLoading = false;
            });
          }
        }
      }
    } catch (e) {
      // Log error but continue gracefully
      debugPrint('Error loading cached lessons: $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveCachedLessons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_lessons.map((l) => l.toJson()).toList());
      await prefs.setString(_cachedLessonsKey, jsonString);
    } catch (e) {
      // Log error but continue gracefully
      debugPrint('Error saving cached lessons: $e');
    }
  }

  List<DayIndicator> _getFiveDayWindow() {
    final streakDayIndicators = streak_utils.StreakCalculator.getFiveDayWindow(_activeDays);
    // Convert from streak_utils.DayIndicator to progress_header.DayIndicator
    return streakDayIndicators.map((streakDayIndicator) {
      DayState state;
      switch (streakDayIndicator.state) {
        case streak_utils.DayState.success:
          state = DayState.success;
        case streak_utils.DayState.fail:
          state = DayState.fail;
        case streak_utils.DayState.freeze:
          state = DayState.freeze;
        case streak_utils.DayState.future:
          state = DayState.future;
      }
      return DayIndicator(date: streakDayIndicator.date, state: state);
    }).toList();
  }

  Future<void> _loadLessons({int? maxLessons, bool append = false}) async {
    Provider.of<AnalyticsService>(context, listen: false)
        .capture(context, 'load_lessons');
    final progress =
        Provider.of<LessonProgressProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    try {
      if (!append) {
        setState(() {
          _isLoading = true;
          _error = null;

          // Show skeletons during loading if we don't have cached lessons yet
          if (_lessons.isEmpty) {
            _showSkeletons = true;
          }
        });
      }

      // Read current progress to size the visible track dynamically.
      // Always show at least (unlockedCount + buffer) lessons, with a floor.
      const int buffer = 12;
      const int minVisible = 36;
      final int desired = append
          ? (maxLessons ?? _lessons.length + 20)
          : (progress.unlockedCount + buffer);
      final int visibleCount = desired < minVisible ? minVisible : desired;

      final lessons = await _lessonService.generateLessons(
        settings.language,
        maxLessons: visibleCount,
        maxQuestionsPerLesson: 10,
      );

      if (!mounted) return;
      setState(() {
        if (append) {
          _lessons.addAll(lessons.sublist(_lessons.length));
        } else {
          _lessons = lessons;
        }

        // Stop showing skeletons once we have lessons
        _showSkeletons = false;
        _isInitialLoading = false;
      });

      // Save cached lessons
      await _saveCachedLessons();

      // Ensure at least the first lesson is unlocked for new users.
      if (!append) {
        await progress.ensureUnlockedCountAtLeast(1);
      }
    } catch (e) {
      if (!mounted) return;
      Provider.of<AnalyticsService>(context, listen: false).capture(
          context, 'load_lessons_error',
          properties: {'error': e.toString()});
      setState(() {
        _error = strings.AppStrings.couldNotLoadLessons;
        _showSkeletons = false;
        _isInitialLoading = false;
      });
    } finally {
      if (mounted && !append) {
        setState(() {
          _isLoading = false;
          // Show promo card with new logic for different popup types
          _showPromoCard = _shouldShowPromoCard(settings);
          if (_showPromoCard) {
            // Check if user is not logged in - always show account creation promo
            final isLoggedIn =
                Supabase.instance.client.auth.currentUser != null;
            if (!isLoggedIn) {
              _isDonationPromo = false;
              _isSatisfactionPromo = false;
              _isDifficultyPromo = false;
              _isAccountCreationPromo = true;
              _socialMediaType = null;
            } else {
              // For logged-in users, determine which type of promo to show
              final rand = Random().nextDouble();
              if (rand < 0.125) {
                _isDonationPromo = true;
                _isSatisfactionPromo = false;
                _isDifficultyPromo = false;
                _isAccountCreationPromo = false;
                _socialMediaType = null;
              } else if (rand < 0.25) {
                _isDonationPromo = false;
                _isSatisfactionPromo = false;
                _isDifficultyPromo = true;
                _isAccountCreationPromo = false;
                _socialMediaType = null;
              } else if (rand < 0.375) {
                _isDonationPromo = false;
                _isSatisfactionPromo = true;
                _isDifficultyPromo = false;
                _isAccountCreationPromo = false;
                _socialMediaType = null;
              } else {
                _isDonationPromo = false;
                _isSatisfactionPromo = false;
                _isDifficultyPromo = false;
                _isAccountCreationPromo = false;
                _socialMediaType = 'follow';
              }
            }
            Provider.of<AnalyticsService>(context, listen: false)
                .capture(context, 'show_promo_card', properties: {
              'is_donation': _isDonationPromo,
              'is_satisfaction': _isSatisfactionPromo,
              'is_difficulty': _isDifficultyPromo,
              'is_account_creation': _isAccountCreationPromo,
              'social_media_type': _socialMediaType ?? '',
            });
          }
        });
      }
    }
  }

  Future<void> _loadMoreLessons() async {
    if (_isLoadingMore || _isLoading) return;
    setState(() => _isLoadingMore = true);
    try {
      await _loadLessons(maxLessons: _lessons.length + 20, append: true);
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  /// Determines whether to show a promo card based on probability and user interaction history
  bool _shouldShowPromoCard(SettingsProvider settings) {
    // Check if user has enabled hiding promo cards
    if (settings.hidePromoCard) {
      return false;
    }

    // Check if user is not logged in - if so, always show account creation promo
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    if (!isLoggedIn) {
      return true;
    }

    // 10% chance to show a popup (only for logged-in users)
    if (Random().nextInt(10) != 0) {
      return false;
    }

    // For donation popup
    if (_shouldHidePromo(settings.lastDonationPopup, settings.hasClickedDonationLink)) {
      return false;
    }

    // For follow popup
    if (_shouldHidePromo(settings.lastFollowPopup, settings.hasClickedFollowLink)) {
      return false;
    }

    // For satisfaction popup
    if (_shouldHidePromo(settings.lastSatisfactionPopup, settings.hasClickedSatisfactionLink)) {
      return false;
    }

    // For difficulty feedback popup
    if (_shouldHidePromo(settings.lastDifficultyPopup, settings.hasClickedDifficultyLink)) {
      return false;
    }

    // If we get here, we can show a popup
    return true;
  }

  /// Checks if a specific promo should be hidden based on last popup date and click status
  bool _shouldHidePromo(DateTime? lastPopup, bool hasClickedLink) {
    if (!hasClickedLink || lastPopup == null) {
      return false; // Don't hide if not clicked or no previous popup date
    }

    final now = DateTime.now();
    final nextAllowed = DateTime(lastPopup.year, lastPopup.month + 1, 1); // First of next month
    return now.isBefore(nextAllowed);
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        debugPrint('Could not launch URL: $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Future<void> _openDonationPage() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.markDonationLinkAsClicked();
    _launchUrl(AppUrls.donateUrl);
  }

  /// Adjusts the difficulty level based on user feedback
  /// The ProgressiveQuestionSelector dynamically adjusts difficulty based on performance
  /// so we'll store the user's preference to potentially influence future difficulty
  Future<void> _adjustDifficulty(String feedback) async {
    // Get analytics service before any async operations to avoid context issues
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Capture analytics before async operation to avoid context issues
    analyticsService.capture(context, 'difficulty_adjusted',
        properties: {'feedback': feedback});

    // Store the user's difficulty preference
    await settings.setDifficultyPreference(feedback);
  }

  /// Helper method to handle analytics for locked lesson taps
  void _handleLockedLessonTap(String lessonId) {
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.capture(context, 'tap_locked_lesson',
        properties: {'lesson_id': lessonId});
    showTopSnackBar(
        context, strings.AppStrings.lessonLocked,
        style: TopSnackBarStyle.warning);
  }

  /// Helper method to handle navigation to quiz screen
  Future<void> _navigateToQuiz(Lesson lesson) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
            lesson: lesson,
            sessionLimit: lesson.maxQuestions),
      ),
    );

    // After returning from the quiz, refresh streak data and reload lessons if needed.
    if (!mounted) return;
    await _refreshStreakData();
    await _loadLessons();
  }

  /// Builds the lesson layout based on the selected layout type
  Widget _buildLessonLayout(
      String layoutType,
      List<int> filteredIndices,
      LessonProgressProvider progress,
      int totalLessons,
      int continueIdx,
      double tileMaxExtent,
      double gridAspect) {
    // Create a common lesson tile with unified tap handler
    Widget createLessonTile(int index) {
      final realIndex = filteredIndices[index];
      final lesson = _lessons[realIndex];
      final unlocked = progress.isLessonUnlocked(realIndex);
      final stars = progress.bestStarsFor(lesson.id);
      final recommended = totalLessons > 0 && realIndex == continueIdx;
      final playable = unlocked;

      return LessonTile(
        lesson: lesson,
        index: realIndex,
        unlocked: unlocked,
        playable: playable,
        stars: stars,
        recommended: unlocked && recommended,
        onTap: () async {
          if (!unlocked) {
            _handleLockedLessonTap(lesson.id);
            return;
          }

          // Track lesson selection
          _trackLessonSelection(lesson, unlocked);

          // Capture tap event
          Provider.of<AnalyticsService>(context, listen: false)
              .capture(context, 'tap_lesson',
                  properties: {'lesson_id': lesson.id});

          // Navigate to quiz
          await _navigateToQuiz(lesson);
        },
      );
    }

    // Create a skeleton tile for loading states
    Widget createSkeletonTile(int index) {
      return LessonTileSkeleton(
        layoutType: layoutType,
        isDesktop: MediaQuery.of(context).size.width > 1200,
        isTablet: MediaQuery.of(context).size.width > 600 &&
                 MediaQuery.of(context).size.width <= 1200,
        isSmallPhone: MediaQuery.of(context).size.width < 400,
      );
    }

    if (_showSkeletons) {
      switch (layoutType) {
        case SettingsProvider.layoutList:
          // List view layout with skeletons
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Container(
                    height: 120, // Fixed height for list items
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: RepaintBoundary(
                      child: createSkeletonTile(index),
                    ),
                  );
                },
                childCount: 10, // Show 10 skeleton items
                addAutomaticKeepAlives: false,
                addSemanticIndexes: false,
                addRepaintBoundaries: true,
              ),
            ),
          );
        case SettingsProvider.layoutCompactGrid:
          // Compact grid layout with skeletons
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: tileMaxExtent * 0.8, // 80% of normal size
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: gridAspect * 0.9, // Slightly more square
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return RepaintBoundary(
                    child: createSkeletonTile(index),
                  );
                },
                childCount: 12, // Show 12 skeleton items for compact grid
                addAutomaticKeepAlives: false,
                addSemanticIndexes: false,
                addRepaintBoundaries: true,
              ),
            ),
          );
        case SettingsProvider.layoutGrid:
        default:
          // Original grid layout with skeletons
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: tileMaxExtent,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: gridAspect,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return RepaintBoundary(
                    child: createSkeletonTile(index),
                  );
                },
                childCount: 12, // Show 12 skeleton items for grid
                addAutomaticKeepAlives: false,
                addSemanticIndexes: false,
                addRepaintBoundaries: true,
              ),
            ),
          );
      }
    }

    switch (layoutType) {
      case SettingsProvider.layoutList:
        // List view layout
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  height: 120, // Fixed height for list items
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: RepaintBoundary(
                    child: createLessonTile(index),
                  ),
                );
              },
              childCount: filteredIndices.length,
              // Performance: disable keep-alives and semantic indexes for list items.
              addAutomaticKeepAlives: false,
              addSemanticIndexes: false,
              addRepaintBoundaries: true,
            ),
          ),
        );
      case SettingsProvider.layoutCompactGrid:
        // Compact grid layout with smaller tiles
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: tileMaxExtent * 0.8, // 80% of normal size
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: gridAspect * 0.9, // Slightly more square
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return RepaintBoundary(
                  child: createLessonTile(index),
                );
              },
              childCount: filteredIndices.length,
              // Performance: disable keep-alives and semantic indexes for grid items.
              // The grid lazily builds children and does not need to keep offscreen items alive.
              addAutomaticKeepAlives: false,
              addSemanticIndexes: false,
              addRepaintBoundaries: true,
            ),
          ),
        );
      case SettingsProvider.layoutGrid:
      default:
        // Original grid layout - Optimized to avoid SliverLayoutBuilder where not needed
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: tileMaxExtent,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: gridAspect,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return RepaintBoundary(
                  child: createLessonTile(index),
                );
              },
              childCount: filteredIndices.length,
              // Performance: disable keep-alives and semantic indexes for grid items.
              // The grid lazily builds children and does not need to keep offscreen items alive.
              addAutomaticKeepAlives: false,
              addSemanticIndexes: false,
              addRepaintBoundaries: true,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final progress = Provider.of<LessonProgressProvider>(context);

    // Responsive: adapt grid by max tile width instead of fixed column count
    final screenWidth = MediaQuery.sizeOf(context).width;
    final double tileMaxExtent = screenWidth >= 1400
        ? 260
        : screenWidth >= 1200
            ? 240
            : screenWidth >= 1000
                ? 220
                : screenWidth >= 840
                    ? 210
                    : screenWidth >= 600
                        ? 200
                        : screenWidth >= 400
                            ? 170
                            : 160;
    final double gridAspect = screenWidth >= 1000
        ? 1.12
        : screenWidth >= 600
            ? 1.05
            : screenWidth >= 360
                ? 0.98
                : 0.92;

    // Get the selected layout type from settings
    final settings = Provider.of<SettingsProvider>(context);
    final layoutType = settings.layoutType;

    // Simplified: show all lessons without search/filters
    final filteredIndices = List.generate(_lessons.length, (i) => i);

    // Determine the "continue" target to incentivize starting a game:
    // We pick the last unlocked lesson (index unlockedCount-1), capped to list length.
    final totalLessons = _lessons.length;
    final continueIdx = totalLessons == 0
        ? 0
        : (progress.unlockedCount.clamp(1, totalLessons) - 1);
    final Lesson? continueLesson =
        totalLessons > 0 ? _lessons[continueIdx] : null;

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
                Icons.menu_book,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strings.AppStrings.lessons,
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
      body: _isInitialLoading && _showSkeletons
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: textTheme.bodyLarge
                              ?.copyWith(color: colorScheme.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadLessons,
                        child: Text(strings.AppStrings.tryAgain),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    // Guard against transient zero-sized viewport during lifecycle changes.
                    if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
                      return const SizedBox.shrink();
                    }
                    return RefreshIndicator(
                      onRefresh: () => _loadLessons(maxLessons: 20),
                      child: CustomScrollView(
                        controller: _scrollController,
                        // Increase cache extent to prebuild upcoming sliver children
                        // for smoother, jank-free scrolling at the cost of some memory.
                        cacheExtent: 800,
                        physics:
                            const BouncingScrollPhysics(), // Add bouncing physics for snappy feel
                        slivers: [
                          // Promo card (if shown)
                          if (_showPromoCard)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: RepaintBoundary(
                                  child: PromoCard(
                                    isDonation: _isDonationPromo,
                                    isSatisfaction: _isSatisfactionPromo,
                                    isDifficulty: _isDifficultyPromo,
                                    isAccountCreation: _isAccountCreationPromo,
                                    socialMediaType: _socialMediaType,
                                    onDismiss: () {
                                      final analyticsService =
                                          Provider.of<AnalyticsService>(context,
                                              listen: false);
                                      analyticsService.capture(
                                          context, 'dismiss_promo_card');
                                      analyticsService.trackFeatureDismissal(
                                          context,
                                          AnalyticsService.featurePromoCards,
                                          additionalProperties: {
                                            'promo_type': _isDonationPromo
                                                ? 'donation'
                                                : (_isSatisfactionPromo
                                                    ? 'satisfaction'
                                                    : (_isDifficultyPromo
                                                        ? 'difficulty'
                                                        : (_isAccountCreationPromo
                                                            ? 'account_creation'
                                                            : (_socialMediaType ??
                                                                'follow')))),
                                          });
                                      setState(() {
                                        _showPromoCard = false;
                                      });
                                    },
                                    onView: () {
                                      // Track promo card view
                                      final analyticsService =
                                          Provider.of<AnalyticsService>(context,
                                              listen: false);
                                      analyticsService.trackFeatureUsage(
                                          context,
                                          AnalyticsService.featurePromoCards,
                                          AnalyticsService.actionAccessed,
                                          additionalProperties: {
                                            'promo_type': _isDonationPromo
                                                ? 'donation'
                                                : (_isSatisfactionPromo
                                                    ? 'satisfaction'
                                                    : (_isDifficultyPromo
                                                        ? 'difficulty'
                                                        : (_isAccountCreationPromo
                                                            ? 'account_creation'
                                                            : (_socialMediaType ??
                                                                'follow')))),
                                          });
                                    },
                                    onAction: (url) async {
                                      final settings =
                                          Provider.of<SettingsProvider>(context,
                                              listen: false);

                                      if (_isDonationPromo) {
                                        final analyticsService =
                                            Provider.of<AnalyticsService>(
                                                context,
                                                listen: false);
                                        analyticsService.capture(
                                            context, 'tap_donation_promo');
                                        analyticsService.trackFeatureSuccess(
                                            context,
                                            AnalyticsService
                                                .featureDonationSystem);
                                        await settings
                                            .markDonationLinkAsClicked();
                                        await settings
                                            .updateLastDonationPopup();
                                        _openDonationPage();
                                      } else if (_isSatisfactionPromo) {
                                        final analyticsService =
                                            Provider.of<AnalyticsService>(
                                                context,
                                                listen: false);
                                        analyticsService.capture(
                                            context, 'tap_satisfaction_promo');
                                        analyticsService.trackFeatureSuccess(
                                            context,
                                            AnalyticsService
                                                .featureSatisfactionSurveys);
                                        await settings
                                            .markSatisfactionLinkAsClicked();
                                        await settings
                                            .updateLastSatisfactionPopup();
                                        _launchUrl(
                                            AppUrls.satisfactionSurveyUrl);
                                      } else if (_isDifficultyPromo) {
                                        // Handle difficulty feedback
                                        final analyticsService =
                                            Provider.of<AnalyticsService>(
                                                context,
                                                listen: false);
                                        analyticsService.capture(
                                            context, 'tap_difficulty_feedback',
                                            properties: {'feedback': url});
                                        analyticsService.trackFeatureSuccess(
                                            context,
                                            AnalyticsService
                                                .featureDifficultyFeedback,
                                            additionalProperties: {
                                              'feedback_type': url
                                            });
                                        await settings
                                            .markDifficultyLinkAsClicked();
                                        await settings
                                            .updateLastDifficultyPopup();

                                        // Handle the different feedback options
                                        if (url == 'too_hard') {
                                          // User feels questions are too hard
                                          await _adjustDifficulty('too_hard');
                                        } else if (url == 'too_easy') {
                                          // User feels questions are too easy
                                          await _adjustDifficulty('too_easy');
                                        } else if (url == 'good') {
                                          // User feels questions are just right
                                          await _adjustDifficulty('good');
                                        }

                                        // Hide the promo after action
                                        setState(() {
                                          _showPromoCard = false;
                                        });
                                      } else if (_isAccountCreationPromo) {
                                        final analyticsService =
                                            Provider.of<AnalyticsService>(
                                                context,
                                                listen: false);
                                        analyticsService.capture(context,
                                            'tap_create_account_promo');
                                        // Navigate to social screen which will handle auth
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SocialScreen(),
                                          ),
                                        );
                                      } else {
                                        Provider.of<AnalyticsService>(context,
                                                listen: false)
                                            .capture(
                                                context, 'tap_follow_promo',
                                                properties: {'url': url});
                                        await settings
                                            .markFollowLinkAsClicked();
                                        await settings.updateLastFollowPopup();
                                        _launchUrl(url);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),

                          // Hero progress + CTA section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RepaintBoundary(
                                    child: ProgressHeader(
                                      lessons: _lessons,
                                      continueLesson: continueLesson,
                                      streakDays: _streakDays,
                                      dayWindow: _getFiveDayWindow(),
                                      onAfterQuizReturn: _refreshStreakData,
                                      onMultiplayerPressed: () {
                                        final analyticsService =
                                            Provider.of<AnalyticsService>(
                                                context,
                                                listen: false);
                                        analyticsService.capture(context,
                                            'multiplayer_button_tapped');
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const MultiplayerGameSetupScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),

                          if (filteredIndices.isNotEmpty)
                            _buildLessonLayout(
                                layoutType,
                                filteredIndices,
                                progress,
                                totalLessons,
                                continueIdx,
                                tileMaxExtent,
                                gridAspect),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
