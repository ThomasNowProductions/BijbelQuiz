import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings_nl.dart' as strings;
import '../providers/game_stats_provider.dart';
import '../services/analytics_service.dart';
import '../services/logger.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String userId;
  final String? initialUsername;
  final String? initialDisplayName;

  const ProfileDetailsScreen({
    super.key,
    required this.userId,
    this.initialUsername,
    this.initialDisplayName,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late AnalyticsService _analyticsService;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userProfile;
  bool _isFollowing = false;
  bool _isCurrentUser = false;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    _trackScreenAccess();
    _loadData();
  }

  void _trackScreenAccess() {
    _analyticsService.screen(context, 'ProfileDetailsScreen');
    _analyticsService.trackFeatureUsage(
        context, 'social_features', 'view_profile');
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final gameStatsProvider =
          Provider.of<GameStatsProvider>(context, listen: false);
      final syncService = gameStatsProvider.syncService;

      // Check if current user
      _isCurrentUser = syncService.currentUserId == widget.userId;


      // Load profile
      final profile = await syncService.getUserProfile(widget.userId);

      // Check follow status
      if (!_isCurrentUser) {
        final followingList = await syncService.getFollowingList();
        _isFollowing = followingList?.contains(widget.userId) ?? false;
      }

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading profile data', e);
      if (mounted) {
        setState(() {
          _error = strings.AppStrings.error; // Generic error or more specific
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_isFollowLoading) return;

    setState(() {
      _isFollowLoading = true;
    });

    try {
      final gameStatsProvider =
          Provider.of<GameStatsProvider>(context, listen: false);
      final syncService = gameStatsProvider.syncService;
      final username = _userProfile?['username'] ?? widget.initialUsername ?? '';

      _analyticsService.capture(
        context,
        _isFollowing ? 'unfollow_user' : 'follow_user',
        properties: {
          'target_user_id': widget.userId.substring(0, 8),
          'username': username,
          'source': 'profile_details',
        },
      );

      bool success;
      if (_isFollowing) {
        success = await syncService.unfollowUser(widget.userId);
      } else {
        success = await syncService.followUser(widget.userId);
      }

      if (mounted) {
        if (success) {
          setState(() {
            _isFollowing = !_isFollowing;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isFollowing
                  ? '${strings.AppStrings.follow} $username' // "Following username" would be better but using available strings
                  : '${strings.AppStrings.unfollow} $username'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.AppStrings.error),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error toggling follow status', e);
    } finally {
      if (mounted) {
        setState(() {
          _isFollowLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use initial data if available while loading
    final displayName = _userProfile?['display_name'] ?? 
                       widget.initialDisplayName ?? 
                       _userProfile?['username'] ?? 
                       widget.initialUsername ?? 
                       strings.AppStrings.unknownUser;
                       
    final username = _userProfile?['username'] ?? widget.initialUsername;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(displayName),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading && _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text(strings.AppStrings.tryAgain),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile Picture
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: colorScheme.primary,
                              child: Text(
                                displayName.isNotEmpty
                                    ? displayName.substring(0, 1).toUpperCase()
                                    : '?',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Profile Information
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display Name
                                  Text(
                                    displayName,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Username
                                  if (username != null)
                                    Text(
                                      '@$username',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bio Section
                      if (_userProfile?['bio'] != null && 
                          (_userProfile!['bio'] as String).isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bio',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _userProfile!['bio'],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Massive Follow Button
                      if (!_isCurrentUser)
                        SizedBox(
                          width: double.infinity,
                          height: 64, // Massive height
                          child: FilledButton.icon(
                            onPressed: _isFollowLoading ? null : _toggleFollow,
                            icon: _isFollowLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: _isFollowing
                                            ? colorScheme.primary
                                            : colorScheme.onPrimary))
                                : Icon(
                                    _isFollowing
                                        ? Icons.person_remove
                                        : Icons.person_add,
                                    size: 28),
                            label: Text(
                              _isFollowing
                                  ? strings.AppStrings.unfollow
                                  : strings.AppStrings.follow,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isFollowing
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onPrimary,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: _isFollowing
                                  ? colorScheme.surfaceContainerHighest
                                  : colorScheme.primary,
                              foregroundColor: _isFollowing
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: _isFollowing ? 0 : 4,
                            ),
                          ),
                        ),
                    ],
                    ),
                ),
    );
  }
}
