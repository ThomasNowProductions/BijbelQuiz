import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bijbelquiz/services/analytics_service.dart';
import 'package:bijbelquiz/services/connection_service.dart';
import 'package:bijbelquiz/providers/settings_provider.dart';
import 'package:bijbelquiz/providers/messages_provider.dart';
import 'package:bijbelquiz/providers/store_provider.dart';

import '../screens/lesson_select_screen.dart';
import '../screens/store_screen.dart';
import '../screens/social_screen.dart';
import '../settings_screen.dart';
import '../l10n/strings_nl.dart' as strings;

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late ConnectionService _connectionService;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _connectionService = ConnectionService();
    _connectionService.initialize();
    _connectionService
        .setConnectionStatusCallback((isConnected, connectionType) {
      if (mounted) {
        setState(() {
          _isOnline = isConnected;
        });
      }
    });
    _checkConnectionOnScreenLoad();
  }

  Future<void> _checkConnectionOnScreenLoad() async {
    await _connectionService.checkConnection();
  }

  List<Widget> _getScreens() {
    if (_isOnline) {
      return [
        const LessonSelectScreen(),
        const StoreScreen(),
        const SocialScreen(),
        const SettingsScreen(),
      ];
    } else {
      return [
        const LessonSelectScreen(),
        const SettingsScreen(),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;

      String screenName;
      String? featureName;

      if (_isOnline) {
        switch (index) {
          case 0:
            screenName = 'LessonSelectScreen';
            featureName = AnalyticsService.featureLessonSystem;
            break;
          case 1:
            screenName = 'StoreScreen';
            featureName = AnalyticsService.featureThemePurchases;
            break;
          case 2:
            screenName = 'SocialScreen';
            featureName = AnalyticsService.featureSocialFeatures;
            break;
          case 3:
            screenName = 'SettingsScreen';
            featureName = AnalyticsService.featureSettings;
            break;
          default:
            screenName = 'Unknown';
        }
      } else {
        switch (index) {
          case 0:
            screenName = 'LessonSelectScreen';
            featureName = AnalyticsService.featureLessonSystem;
            break;
          case 1:
            screenName = 'SettingsScreen';
            featureName = AnalyticsService.featureSettings;
            break;
          default:
            screenName = 'Unknown';
        }
      }

      final analyticsService =
          Provider.of<AnalyticsService>(context, listen: false);
      analyticsService.screen(context, screenName);
      if (featureName != null) {
        analyticsService.trackFeatureStart(context, featureName);
      }
    });
  }

  /// Builds the social destination with activity indicator for unread messages or login required
  NavigationDestination _buildSocialDestination() {
    final messagesProvider = Provider.of<MessagesProvider>(context);
    final hasUnreadMessages = messagesProvider.hasUnreadMessages;
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final showAlertDot = !isLoggedIn || hasUnreadMessages;

    return NavigationDestination(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Semantics(
            label: strings.AppStrings.social,
            button: true,
            child: const Icon(Icons.groups_outlined),
          ),
          if (showAlertDot)
            Positioned(
              right: -2,
              top: -2,
              child: Semantics(
                label: strings.AppStrings.newMessagesOrLoginRequired,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      selectedIcon: Stack(
        clipBehavior: Clip.none,
        children: [
          Semantics(
            label: 'Selected - ${strings.AppStrings.social}',
            button: true,
            child: const Icon(Icons.groups),
          ),
          if (showAlertDot)
            Positioned(
              right: -2,
              top: -2,
              child: Semantics(
                label: strings.AppStrings.newMessagesOrLoginRequired,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      label: strings.AppStrings.social,
    );
  }

  /// Builds the store destination with activity indicator for active discounts
  NavigationDestination _buildStoreDestination() {
    final storeProvider = Provider.of<StoreProvider>(context);
    final hasActiveDiscount = storeProvider.hasActiveDiscount;

    return NavigationDestination(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Semantics(
            label: strings.AppStrings.store,
            button: true,
            child: const Icon(Icons.store_outlined),
          ),
          if (hasActiveDiscount)
            Positioned(
              right: -2,
              top: -2,
              child: Semantics(
                label: strings.AppStrings.activeDiscountsAvailable,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      selectedIcon: Stack(
        clipBehavior: Clip.none,
        children: [
          Semantics(
            label: 'Selected - ${strings.AppStrings.store}',
            button: true,
            child: const Icon(Icons.store),
          ),
          if (hasActiveDiscount)
            Positioned(
              right: -2,
              top: -2,
              child: Semantics(
                label: strings.AppStrings.activeDiscountsAvailable,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      label: strings.AppStrings.store,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screens = _getScreens();
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        elevation: 10,
        height: settings.showNavigationLabels ? 80 : 60,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
        labelBehavior: settings.showNavigationLabels
            ? NavigationDestinationLabelBehavior.alwaysShow
            : NavigationDestinationLabelBehavior.alwaysHide,
        destinations: _buildDestinations(),
      ),
    );
  }

  List<NavigationDestination> _buildDestinations() {
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: Semantics(
          label: strings.AppStrings.lessons,
          button: true,
          child: const Icon(Icons.menu_book_outlined),
        ),
        selectedIcon: Semantics(
          label:
              '${strings.AppStrings.selected} - ${strings.AppStrings.lessons}',
          button: true,
          child: const Icon(Icons.menu_book),
        ),
        label: strings.AppStrings.lessons,
      ),
    ];

    if (_isOnline) {
      destinations.add(_buildStoreDestination());
      destinations.add(_buildSocialDestination());
    }

    destinations.add(
      NavigationDestination(
        icon: Semantics(
          label: strings.AppStrings.settings,
          button: true,
          child: const Icon(Icons.settings_outlined),
        ),
        selectedIcon: Semantics(
          label: 'Selected - ${strings.AppStrings.settings}',
          button: true,
          child: const Icon(Icons.settings),
        ),
        label: strings.AppStrings.settings,
      ),
    );

    return destinations;
  }
}
