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

enum PromoType { donation, satisfaction, difficulty, accountCreation, follow }

extension PromoTypeExtension on PromoType {
  String get analyticsName {
    switch (this) {
      case PromoType.donation:
        return 'donation';
      case PromoType.satisfaction:
        return 'satisfaction';
      case PromoType.difficulty:
        return 'difficulty';
      case PromoType.accountCreation:
        return 'account_creation';
      case PromoType.follow:
        return 'follow';
    }
  }
}

class LessonSelectScreen extends StatefulWidget {
  const LessonSelectScreen({super.key});

  @override
  State<LessonSelectScreen> createState() => _LessonSelectScreenState();
}

class _LessonSelectScreenState extends State<LessonSelectScreen>
    with SingleTickerProviderStateMixin {
  final LessonService _lessonService = LessonService();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

  /// Current promo type to display
  PromoType? _currentPromoType;

  // Daily usage streak tracking (persisted locally)
  static const String _activeDaysKey = 'daily_active_days_v1';
  Set<String> _activeDays = {};
  int _streakDays = 0;

  // Cached lessons
  static const String _cachedLessonsKey = 'cached_lessons_v1';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );
    _fadeController.forward();

    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);

    analyticsService.screen(context, 'LessonSelectScreen');
    analyticsService.trackFeatureStart(
        context, AnalyticsService.featureLessonSystem);

    _loadLessons(maxLessons: 20);
    _loadStreakData();
    _loadCachedLessons();
    _scrollController.addListener(_onScroll);

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
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);

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
      analyticsService.trackFeatureUsage(context,
          AnalyticsService.featureStreakTracking, AnalyticsService.actionUsed,
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
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_activeDaysKey) ?? <String>[];
      _activeDays = list.toSet();

      // Calculate streak using the utility class
      _streakDays =
          streak_utils.StreakCalculator.calculateCurrentStreak(_activeDays);
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
    final streakDayIndicators =
        streak_utils.StreakCalculator.getFiveDayWindow(_activeDays);
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
          _showPromoCard = _shouldShowPromoCard(settings);
          if (_showPromoCard) {
            _currentPromoType = _determinePromoType();
            _trackPromoCardShown();
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
    if (_shouldHidePromo(
        settings.lastDonationPopup, settings.hasClickedDonationLink)) {
      return false;
    }

    // For follow popup
    if (_shouldHidePromo(
        settings.lastFollowPopup, settings.hasClickedFollowLink)) {
      return false;
    }

    // For satisfaction popup
    if (_shouldHidePromo(
        settings.lastSatisfactionPopup, settings.hasClickedSatisfactionLink)) {
      return false;
    }

    // For difficulty feedback popup
    if (_shouldHidePromo(
        settings.lastDifficultyPopup, settings.hasClickedDifficultyLink)) {
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
    final nextAllowed =
        DateTime(lastPopup.year, lastPopup.month + 1, 1); // First of next month
    return now.isBefore(nextAllowed);
  }

  PromoType _determinePromoType() {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    if (!isLoggedIn) {
      return PromoType.accountCreation;
    }

    final rand = Random().nextDouble();
    if (rand < 0.125) return PromoType.donation;
    if (rand < 0.25) return PromoType.difficulty;
    if (rand < 0.375) return PromoType.satisfaction;
    return PromoType.follow;
  }

  void _trackPromoCardShown() {
    Provider.of<AnalyticsService>(context, listen: false)
        .capture(context, 'show_promo_card', properties: {
      'promo_type': _currentPromoType?.analyticsName ?? '',
    });
  }

  void _onPromoDismissed() {
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.capture(context, 'dismiss_promo_card');
    analyticsService.trackFeatureDismissal(
        context, AnalyticsService.featurePromoCards,
        additionalProperties: {
          'promo_type': _currentPromoType?.analyticsName ?? '',
        });
    setState(() {
      _showPromoCard = false;
    });
  }

  void _onPromoViewed() {
    Provider.of<AnalyticsService>(context, listen: false).trackFeatureUsage(
        context,
        AnalyticsService.featurePromoCards,
        AnalyticsService.actionAccessed,
        additionalProperties: {
          'promo_type': _currentPromoType?.analyticsName ?? '',
        });
  }

  Future<void> _onPromoAction(String action) async {
    switch (_currentPromoType) {
      case PromoType.donation:
        await _handleDonationAction();
        break;
      case PromoType.satisfaction:
        await _handleSatisfactionAction();
        break;
      case PromoType.difficulty:
        await _handleDifficultyAction(action);
        break;
      case PromoType.accountCreation:
        await _handleAccountCreationAction();
        break;
      case PromoType.follow:
        await _handleFollowAction(action);
        break;
      case null:
        break;
    }
  }

  Future<void> _handleDonationAction() async {
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.capture(context, 'tap_donation_promo');
    analyticsService.trackFeatureSuccess(
        context, AnalyticsService.featureDonationSystem);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.markDonationLinkAsClicked();
    await settings.updateLastDonationPopup();
    _openDonationPage();
  }

  Future<void> _handleSatisfactionAction() async {
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.capture(context, 'tap_satisfaction_promo');
    analyticsService.trackFeatureSuccess(
        context, AnalyticsService.featureSatisfactionSurveys);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.markSatisfactionLinkAsClicked();
    await settings.updateLastSatisfactionPopup();
    _launchUrl(AppUrls.satisfactionSurveyUrl);
  }

  Future<void> _handleDifficultyAction(String feedback) async {
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.capture(context, 'tap_difficulty_feedback',
        properties: {'feedback': feedback});
    analyticsService.trackFeatureSuccess(
        context, AnalyticsService.featureDifficultyFeedback,
        additionalProperties: {'feedback_type': feedback});
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.markDifficultyLinkAsClicked();
    await settings.updateLastDifficultyPopup();

    if (feedback == 'too_hard' ||
        feedback == 'too_easy' ||
        feedback == 'good') {
      await _adjustDifficulty(feedback);
    }

    setState(() {
      _showPromoCard = false;
    });
  }

  Future<void> _handleAccountCreationAction() async {
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.capture(context, 'tap_create_account_promo');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SocialScreen(),
      ),
    );
  }

  Future<void> _handleFollowAction(String url) async {
    Provider.of<AnalyticsService>(context, listen: false)
        .capture(context, 'tap_follow_promo', properties: {'url': url});
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.markFollowLinkAsClicked();
    await settings.updateLastFollowPopup();
    _launchUrl(url);
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
    final analyticsService =
        Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.capture(context, 'tap_locked_lesson',
        properties: {'lesson_id': lessonId});
    showTopSnackBar(context, strings.AppStrings.lessonLocked,
        style: TopSnackBarStyle.warning);
  }

  /// Helper method to handle navigation to quiz screen
  Future<void> _navigateToQuiz(Lesson lesson) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            QuizScreen(lesson: lesson, sessionLimit: lesson.maxQuestions),
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
          Provider.of<AnalyticsService>(context, listen: false).capture(
              context, 'tap_lesson',
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

    final isList = layoutType == SettingsProvider.layoutList;
    final isCompactGrid = layoutType == SettingsProvider.layoutCompactGrid;
    final childCount =
        _showSkeletons ? (isList ? 10 : 12) : filteredIndices.length;
    final maxExtent = isCompactGrid ? tileMaxExtent * 0.8 : tileMaxExtent;
    final spacing = isCompactGrid ? 10.0 : 14.0;
    final aspect = isCompactGrid ? gridAspect * 0.9 : gridAspect;

    final delegate = SliverChildBuilderDelegate(
      (context, index) {
        final child = _showSkeletons
            ? createSkeletonTile(index)
            : RepaintBoundary(child: createLessonTile(index));
        if (isList) {
          return Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 8.0),
            child: child,
          );
        }
        return child;
      },
      childCount: childCount,
      addAutomaticKeepAlives: false,
      addSemanticIndexes: false,
      addRepaintBoundaries: true,
    );

    if (isList) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        sliver: SliverList(delegate: delegate),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxExtent,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: aspect,
        ),
        delegate: delegate,
      ),
    );
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.15),
                    colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 22,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              strings.AppStrings.lessons,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        surfaceTintColor: colorScheme.surface,
      ),
      body: _isInitialLoading && _showSkeletons
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.AppStrings.loading,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.errorContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            strings.AppStrings.couldNotLoadLessons,
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadLessons,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onError,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(strings.AppStrings.tryAgain),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
                        return const SizedBox.shrink();
                      }
                      return RefreshIndicator(
                        onRefresh: () => _loadLessons(maxLessons: 20),
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        child: CustomScrollView(
                          controller: _scrollController,
                          cacheExtent: 1000,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            if (_showPromoCard)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: RepaintBoundary(
                                    child: PromoCard(
                                      isDonation: _currentPromoType ==
                                          PromoType.donation,
                                      isSatisfaction: _currentPromoType ==
                                          PromoType.satisfaction,
                                      isDifficulty: _currentPromoType ==
                                          PromoType.difficulty,
                                      isAccountCreation: _currentPromoType ==
                                          PromoType.accountCreation,
                                      socialMediaType:
                                          _currentPromoType == PromoType.follow
                                              ? 'follow'
                                              : null,
                                      onDismiss: _onPromoDismissed,
                                      onView: _onPromoViewed,
                                      onAction: _onPromoAction,
                                    ),
                                  ),
                                ),
                              ),

                            // Hero progress + CTA section
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                ),
    );
  }
}
