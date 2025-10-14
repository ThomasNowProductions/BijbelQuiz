import 'package:bijbelquiz/services/analytics_service.dart';
import 'package:bijbelquiz/services/feature_flags_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

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
    final strings = AppLocalizations.of(context)!.strings;

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
              strings.social,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.groups_rounded,
          size: isDesktop ? 120 : (isTablet ? 100 : 80),
          color: colorScheme.primary,
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        Text(
          'Social Features',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        Text(
          'Connect with other Bible Quiz users, share achievements, and compete on leaderboards!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        // Placeholder for actual social features
        Text(
          'Social features coming soon...',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withAlpha((0.5 * 255).round()),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildComingSoonContent(ColorScheme colorScheme, bool isDesktop, bool isTablet) {
    final strings = AppLocalizations.of(context)!.strings;
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
          strings.comingSoon,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        Text(
          strings.socialComingSoonMessage,
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
