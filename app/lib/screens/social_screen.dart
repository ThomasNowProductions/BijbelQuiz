import 'package:bijbelquiz/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/strings_nl.dart' as strings;
import 'auth_screen.dart';
import 'sync_screen.dart';
import 'user_search_screen.dart';
import 'following_list_screen.dart';
import 'followers_list_screen.dart';
import 'messages_screen.dart';
import '../providers/game_stats_provider.dart';
import '../providers/messages_provider.dart';
import '../services/logger.dart';
import 'profile_details_screen.dart';
import 'main_navigation_screen.dart';
import '../utils/social_data_processor.dart';

/// Screen displaying social features of the app.
///
/// This screen provides social functionality including user search,
/// following/follower lists, messaging, and leaderboards.
class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  /// Whether social features are enabled in the app
  bool _socialFeaturesEnabled = false;

  /// Analytics service for tracking user interactions
  late AnalyticsService _analyticsService;

  /// Cache for user scores to avoid repeated API calls
  Map<String, Map<String, dynamic>>? _cachedUserScores;

  /// Current authenticated user
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    _checkAuthState();
    _trackScreenAccess();
    // Social features enabled since feature flags removed
    _socialFeaturesEnabled = true;

    // Set up sync callback to refresh leaderboard when game stats are synced
    _setupSyncCallbacks();

    // Navigate to sync screen immediately if not authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentUser == null) {
        _navigateToSyncScreen();
      }
    });
  }

  void _checkAuthState() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      AppLogger.error('Error checking auth state', e);
      setState(() {
        _currentUser = null;
      });
    }
  }

  /// Track screen access and feature usage.
  void _trackScreenAccess() {
    _analyticsService.screen(context, 'SocialScreen');
    _analyticsService.trackFeatureUsage(
        context, 'social_features', 'screen_accessed');
  }

  /// Helper method to track navigation events
  void _trackNavigation(String screenName) {
    _analyticsService.capture(context, '${screenName}_opened');
  }

  /// Sets up sync callbacks to refresh leaderboard when data is synced
  void _setupSyncCallbacks() {
    try {
      final gameStatsProvider =
          Provider.of<GameStatsProvider>(context, listen: false);
      final syncService = gameStatsProvider.syncService;

      // Set up callback for successful sync operations
      syncService.registerCallbacks(
        'game_stats',
        onSyncSuccess: (key) {
          if (key == 'game_stats' && mounted) {
            // Refresh leaderboard when game stats are synced
            setState(() {
              _analyticsService.trackFeatureUsage(
                  context, 'leaderboard', 'auto_refresh_on_sync');
            });
          }
        },
      );
    } catch (e) {
      AppLogger.error('Error setting up sync callbacks', e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check auth state when dependencies change
    _checkAuthState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // If not authenticated, show loading while navigating to sync screen
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme, textTheme),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive values based on available width
            final isLargeScreen = constraints.maxWidth > 600;
            final horizontalPadding = isLargeScreen ? 24.0 : 16.0;
            final maxContainerWidth =
                isLargeScreen ? 600.0 : constraints.maxWidth;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: maxContainerWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBqidManagementCard(colorScheme, textTheme),
                      const SizedBox(height: 24),
                      _buildSocialFeaturesContent(
                        colorScheme,
                        textTheme,
                        isLargeScreen,
                        _socialFeaturesEnabled,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Clears the cached user scores - call this when stats are updated
  void _clearCachedUserScores() {
    _cachedUserScores = null;
  }

  /// Builds the app bar with consistent styling.
  AppBar _buildAppBar(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBar(
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
              Icons.group_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            strings.AppStrings.social,
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
    );
  }


  /// Builds the BQID management card.
  Widget _buildBqidManagementCard(
      ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleBqidCardTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.AppStrings.manageYourBqid,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.AppStrings.manageYourBqidSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigates to the sync screen for authentication.
  void _navigateToSyncScreen() {
    _analyticsService.capture(context, 'open_sync_screen_from_social');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AuthScreen(
          requiredForSocial: true,
          onLoginSuccess: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen(initialIndex: 2)),
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  /// Handles tap on the BQID management card.
  void _handleBqidCardTap() {
    _analyticsService.capture(context, 'open_sync_screen');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SyncScreen(),
      ),
    );
  }

  /// Builds the social features content section.
  Widget _buildSocialFeaturesContent(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
    bool featuresEnabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSocialFeatureButtons(colorScheme, textTheme, isLargeScreen),
        const SizedBox(height: 24),
        _buildLeaderboardSection(colorScheme, textTheme, isLargeScreen),
        const SizedBox(height: 24),
        _buildFollowedUsersScores(colorScheme, textTheme, isLargeScreen),
      ],
    );
  }

  /// Builds responsive buttons for social features
  Widget _buildSocialFeatureButtons(
      ColorScheme colorScheme, TextTheme textTheme, bool isLargeScreen) {
    if (isLargeScreen) {
      // Arrange all buttons in a single row for large screens
      return Row(
        children: [
          Expanded(
            child: _buildFeatureButton(
              colorScheme: colorScheme,
              textTheme: textTheme,
              icon: Icons.search,
              label: strings.AppStrings.search,
              onPressed: _navigateToUserSearchScreen,
              isLargeScreen: isLargeScreen,
              isMessages: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeatureButton(
              colorScheme: colorScheme,
              textTheme: textTheme,
              icon: Icons.people_alt_rounded,
              label: strings.AppStrings.myFollowing,
              onPressed: _navigateToFollowingList,
              isLargeScreen: isLargeScreen,
              isMessages: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeatureButton(
              colorScheme: colorScheme,
              textTheme: textTheme,
              icon: Icons.person_add_rounded,
              label: strings.AppStrings.myFollowers,
              onPressed: _navigateToFollowersList,
              isLargeScreen: isLargeScreen,
              isMessages: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeatureButton(
              colorScheme: colorScheme,
              textTheme: textTheme,
              icon: Icons.message_rounded,
              label: strings.AppStrings.messages,
              onPressed: _navigateToMessagesScreen,
              isLargeScreen: isLargeScreen,
              isMessages: true,
            ),
          ),
        ],
      );
    } else {
      // Arrange buttons in 2x2 grid for mobile screens
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.1, // Makes buttons more compact
        children: [
          _buildFeatureButton(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.search,
            label: strings.AppStrings.search,
            onPressed: _navigateToUserSearchScreen,
            isLargeScreen: isLargeScreen,
            isMessages: false,
          ),
          _buildFeatureButton(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.people_alt_rounded,
            label: strings.AppStrings.myFollowing,
            onPressed: _navigateToFollowingList,
            isLargeScreen: isLargeScreen,
            isMessages: false,
          ),
          _buildFeatureButton(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.person_add_rounded,
            label: strings.AppStrings.myFollowers,
            onPressed: _navigateToFollowersList,
            isLargeScreen: isLargeScreen,
            isMessages: false,
          ),
          _buildFeatureButton(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.message_rounded,
            label: strings.AppStrings.messages,
            onPressed: _navigateToMessagesScreen,
            isLargeScreen: isLargeScreen,
            isMessages: true,
          ),
        ],
      );
    }
  }

  /// Builds the leaderboard section
  Widget _buildLeaderboardSection(
      ColorScheme colorScheme, TextTheme textTheme, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        strings.AppStrings.leaderboard,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        strings.AppStrings.beta,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {}); // Trigger a rebuild to refresh leaderboard
                },
              ),
            ],
          ),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getTopUsersForLeaderboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    strings.AppStrings.noLeaderboardData,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            }

            final topUsers = snapshot.data!;

            return Column(
              children: [
                ...topUsers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final user = entry.value;
                  return _buildLeaderboardUserCard(
                    user: user,
                    index: index,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Gets top users for leaderboard
  Future<List<Map<String, dynamic>>> _getTopUsersForLeaderboard() async {
    final gameStatsProvider =
        Provider.of<GameStatsProvider>(context, listen: false);
    final syncService = gameStatsProvider.syncService;

    return await SocialDataProcessor.getTopUsersForLeaderboard(syncService);
  }

  /// Builds the followed users scores section
  Widget _buildFollowedUsersScores(
      ColorScheme colorScheme, TextTheme textTheme, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        strings.AppStrings.followedUsersScores,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        strings.AppStrings.beta,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // Clear the cache to force a refresh
                  _clearCachedUserScores();
                  setState(() {}); // Trigger a rebuild
                },
              ),
            ],
          ),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getFollowedUsersScores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Container();
            }

            final followedUsers = snapshot.data!;

            return Column(
              children: [
                ...followedUsers.map((user) => _buildFollowedUserCard(
                      user: user,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    )),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Gets followed users and their scores
  Future<List<Map<String, dynamic>>> _getFollowedUsersScores() async {
    final gameStatsProvider =
        Provider.of<GameStatsProvider>(context, listen: false);
    final syncService = gameStatsProvider.syncService;

    final result = await SocialDataProcessor.getFollowedUsersScores(
      syncService,
      _cachedUserScores,
    );

    // Update cache with the latest fetched data
    _cachedUserScores = <String, Map<String, dynamic>>{};
    for (final user in result) {
      final userId = user['userId'] as String;
      final score = user['score'];
      _cachedUserScores![userId] = {'score': score};
    }

    return result;
  }


  /// Builds a single leaderboard user card
  Widget _buildLeaderboardUserCard({
    required Map<String, dynamic> user,
    required int index,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Card(
      color: colorScheme.surface,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfileDetailsScreen(
                userId: user['userId'],
                initialUsername: user['username'],
                initialDisplayName: user['displayName'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rank indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: index < 3
                      ? [colorScheme.primary, Colors.grey[600]!, Colors.amber][index]
                      : colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: index < 3
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['displayName'] ?? user['username'] ??
                          strings.AppStrings.unknownUser,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${strings.AppStrings.score}: ${user['score'] ?? 0}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user['score'] ?? 0}',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single followed user card
  Widget _buildFollowedUserCard({
    required Map<String, dynamic> user,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Card(
      color: colorScheme.surface,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfileDetailsScreen(
                userId: user['userId'],
                initialUsername: user['username'],
                initialDisplayName: user['displayName'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['displayName'] ?? user['username'] ??
                          strings.AppStrings.unknownUser,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${strings.AppStrings.lastScore} ${user['score'] ?? strings.AppStrings.notAvailable}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user['stars'] ?? 0}',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single feature button with responsive sizing
  Widget _buildFeatureButton({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isLargeScreen,
    bool isMessages = false,
  }) {
    final messagesProvider = Provider.of<MessagesProvider>(context);
    final unreadCount = messagesProvider.unreadCount;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(isLargeScreen ? 16.0 : 12.0),
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colorScheme.surface,
        fixedSize: Size.fromHeight(isLargeScreen ? 112.0 : 100.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: isLargeScreen ? 28.0 : 24.0,
                color: colorScheme.primary,
              ),
              if (isMessages && unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: TextStyle(
                          color: colorScheme.onError,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isMessages) // Don't show beta badge for messages
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                strings.AppStrings.beta,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Navigate to user search screen
  void _navigateToUserSearchScreen() {
    _trackNavigation('user_search_screen');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserSearchScreen(),
      ),
    );
  }

  /// Navigate to following list screen
  void _navigateToFollowingList() {
    _trackNavigation('following_list');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FollowingListScreen(),
      ),
    );
  }

  /// Navigate to followers list screen
  void _navigateToFollowersList() {
    _trackNavigation('followers_list');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FollowersListScreen(),
      ),
    );
  }

  /// Navigate to messages screen
  Future<void> _navigateToMessagesScreen() async {
    _trackNavigation('messages_screen');

    try {
      // Mark messages as viewed when navigating to messages screen
      final messagesProvider =
          Provider.of<MessagesProvider>(context, listen: false);
      await messagesProvider.markAllMessagesAsViewed();
    } catch (e) {
      AppLogger.error('Error marking messages as viewed', e);
      // Continue with navigation even if this fails
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MessagesScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Clean up sync callbacks to prevent memory leaks
    try {
      final gameStatsProvider =
          Provider.of<GameStatsProvider>(context, listen: false);
      final syncService = gameStatsProvider.syncService;

      // Remove callbacks to prevent memory leaks
      syncService.registerCallbacks(
        'game_stats',
        onSyncSuccess: null,
        onSyncError: null,
      );
    } catch (e) {
      // Silently handle any errors during cleanup
      AppLogger.debug('Error during social screen cleanup: $e');
    }

    super.dispose();
  }
}
