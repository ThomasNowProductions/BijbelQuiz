import 'package:bijbelquiz/services/analytics_service.dart';
import 'package:bijbelquiz/services/auth_service.dart';
import 'package:bijbelquiz/services/feature_flags_service.dart';
import 'package:bijbelquiz/services/social_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings_nl.dart' as strings;
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'social_settings_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  bool _socialFeaturesEnabled = false;
  bool _showLogin = true;

  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

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
    final authService = Provider.of<AuthService>(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Responsive design
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final isTablet = size.width > 600 && size.width <= 800;

    if (!authService.isAuthenticated) {
      return _showLogin
          ? LoginScreen(
              onSwitchToSignup: () {
                setState(() {
                  _showLogin = false;
                });
              },
            )
          : SignupScreen(
              onSwitchToLogin: () {
                setState(() {
                  _showLogin = true;
                });
              },
            );
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SocialSettingsScreen(),
                ),
              );
            },
          ),
        ],
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
    final socialService = Provider.of<SocialService>(context, listen: false);

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search for users',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final results = await socialService.searchUsers(_searchController.text);
                setState(() {
                  _searchResults = results;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final user = _searchResults[index];
              return ListTile(
                title: Text(user),
                trailing: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement follow/unfollow logic
                  },
                  child: const Text('Follow'),
                ),
              );
            },
          ),
        ),
      ],
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