import 'package:bijbelquiz/services/analytics_service.dart';
import 'package:bijbelquiz/services/feature_flags_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings_nl.dart' as strings;
import '../providers/user_provider.dart';
import 'auth_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  bool _socialFeaturesEnabled = false;

  @override
  void initState() {
    super.initState();
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);

    analyticsService.screen(context, 'SocialScreen');

    // Track social screen access and feature availability
    analyticsService.trackFeatureUsage(context, 'social_features', 'screen_accessed');

    _checkSocialFeaturesEnabled();
  }

  Future<void> _checkSocialFeaturesEnabled() async {
    FeatureFlagsService? featureFlags;
    try {
      featureFlags = Provider.of<FeatureFlagsService>(context, listen: false);
    } catch (e) {
      // Feature flags service not available in provider yet, create new instance
      featureFlags = FeatureFlagsService();
    }
    final enabled = await featureFlags.areSocialFeaturesEnabled();
    setState(() {
      _socialFeaturesEnabled = enabled;
    });

    // Track social features availability
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.trackFeatureUsage(context, 'social_features', enabled ? 'available' : 'unavailable');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Responsive design
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final isTablet = size.width > 600 && size.width <= 800;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.group_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strings.AppStrings.social,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 800 : (isTablet ? 600 : double.infinity),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
                vertical: 24,
              ),
              child: _socialFeaturesEnabled
                ? _buildSocialFeaturesContent(colorScheme, isDesktop, isTablet)
                : _buildComingSoonContent(colorScheme, isDesktop, isTablet),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialFeaturesContent(ColorScheme colorScheme, bool isDesktop, bool isTablet) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isAuthenticated) {
          return _buildAuthenticationPrompt(colorScheme, isDesktop, isTablet);
        }

        return _buildAuthenticatedContent(colorScheme, isDesktop, isTablet, userProvider);
      },
    );
  }

  Widget _buildAuthenticationPrompt(ColorScheme colorScheme, bool isDesktop, bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_add_rounded,
          size: isDesktop ? 120 : (isTablet ? 100 : 80),
          color: colorScheme.primary,
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        Text(
          'Join the Community',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        Text(
          'Create an account to sync your progress, follow other players, and compete on leaderboards!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AuthScreen(),
              ),
            );
          },
          icon: const Icon(Icons.login_rounded),
          label: const Text('Sign In / Sign Up'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatedContent(ColorScheme colorScheme, bool isDesktop, bool isTablet, UserProvider userProvider) {
    return Column(
      children: [
        // User profile section
        _buildUserProfileSection(colorScheme, isDesktop, isTablet, userProvider),
        SizedBox(height: isDesktop ? 32 : 24),
        
        // Social features grid
        _buildSocialFeaturesGrid(colorScheme, isDesktop, isTablet, userProvider),
        
        SizedBox(height: isDesktop ? 32 : 24),
        
        // Feed section
        _buildFeedSection(colorScheme, isDesktop, isTablet, userProvider),
      ],
    );
  }

  Widget _buildUserProfileSection(ColorScheme colorScheme, bool isDesktop, bool isTablet, UserProvider userProvider) {
    final user = userProvider.user!;
    final stats = userProvider.userStats;
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withAlpha((0.3 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withAlpha((0.2 * 255).round()),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: isDesktop ? 40 : 32,
            backgroundColor: colorScheme.primary.withAlpha((0.1 * 255).round()),
            child: user.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.avatarUrl!,
                      width: isDesktop ? 80 : 64,
                      height: isDesktop ? 80 : 64,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    size: isDesktop ? 40 : 32,
                    color: colorScheme.primary,
                  ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            user.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            '@${user.username}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            ),
          ),
          if (stats != null) ...[
            SizedBox(height: isDesktop ? 16 : 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Score', stats.score.toString(), colorScheme),
                _buildStatItem('Level', stats.level.toString(), colorScheme),
                _buildStatItem('Streak', stats.longestStreak.toString(), colorScheme),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialFeaturesGrid(ColorScheme colorScheme, bool isDesktop, bool isTablet, UserProvider userProvider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.2 : 1.0,
      children: [
        _buildFeatureCard(
          'Leaderboard',
          Icons.leaderboard_rounded,
          'View top players',
          colorScheme,
          () => _showLeaderboard(),
        ),
        _buildFeatureCard(
          'Find Friends',
          Icons.search_rounded,
          'Search for players',
          colorScheme,
          () => _showUserSearch(),
        ),
        _buildFeatureCard(
          'Following',
          Icons.people_rounded,
          '${userProvider.following.length} following',
          colorScheme,
          () => _showFollowing(),
        ),
        _buildFeatureCard(
          'Followers',
          Icons.group_rounded,
          '${userProvider.followers.length} followers',
          colorScheme,
          () => _showFollowers(),
        ),
        _buildFeatureCard(
          'Store',
          Icons.store_rounded,
          'Buy powerups & themes',
          colorScheme,
          () => _showStore(),
        ),
        _buildFeatureCard(
          'Settings',
          Icons.settings_rounded,
          'Account settings',
          colorScheme,
          () => _showAccountSettings(),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    String subtitle,
    ColorScheme colorScheme,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedSection(ColorScheme colorScheme, bool isDesktop, bool isTablet, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Feed',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (userProvider.feed.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.timeline_rounded,
                  size: 48,
                  color: colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                ),
                const SizedBox(height: 12),
                Text(
                  'No activity yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Follow other players to see their activity here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userProvider.feed.length,
            itemBuilder: (context, index) {
              final item = userProvider.feed[index];
              return _buildFeedItem(item, colorScheme);
            },
          ),
      ],
    );
  }

  Widget _buildFeedItem(dynamic item, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withAlpha((0.1 * 255).round()),
          child: Text(
            item.user.displayName[0].toUpperCase(),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(item.user.displayName),
        subtitle: Text('@${item.user.username}'),
        trailing: Text(
          _formatTimeAgo(item.timestamp),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showLeaderboard() {
    // TODO: Implement leaderboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leaderboard coming soon!')),
    );
  }

  void _showUserSearch() {
    // TODO: Implement user search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User search coming soon!')),
    );
  }

  void _showFollowing() {
    // TODO: Implement following list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Following list coming soon!')),
    );
  }

  void _showFollowers() {
    // TODO: Implement followers list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Followers list coming soon!')),
    );
  }

  void _showStore() {
    // TODO: Implement store
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store coming soon!')),
    );
  }

  void _showAccountSettings() {
    // TODO: Implement account settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account settings coming soon!')),
    );
  }

  Widget _buildComingSoonContent(ColorScheme colorScheme, bool isDesktop, bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.groups_rounded,
          size: isDesktop ? 120 : (isTablet ? 100 : 80),
          color: colorScheme.primary.withAlpha((0.5 * 255).round()),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        Text(
          strings.AppStrings.comingSoon,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        Text(
          strings.AppStrings.socialComingSoonMessage,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface.withAlpha((0.5 * 255).round()),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}