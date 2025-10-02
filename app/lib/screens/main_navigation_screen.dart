import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bijbelquiz/services/analytics_service.dart';
import 'package:bijbelquiz/models/bible_chat_conversation.dart';
import 'package:bijbelquiz/providers/bible_chat_provider.dart';

import '../screens/lesson_select_screen.dart';
import '../screens/store_screen.dart';
import '../screens/social_screen.dart';
import '../screens/bible_chat_screen.dart';
import '../settings_screen.dart';
import '../l10n/strings_nl.dart' as strings;

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  BibleChatConversation? _currentConversation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the active conversation from the provider
    final chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
    _currentConversation = chatProvider.activeConversation ?? _createInitialConversation();
  }

  List<Widget> _getScreens() {
    return [
      const LessonSelectScreen(),
      const StoreScreen(),
      const SocialScreen(),
      _buildBibleChatScreen(),
      const SettingsScreen(),
    ];
  }

  Widget _buildBibleChatScreen() {
    final conversation = _currentConversation ?? _createInitialConversation();

    return BibleChatScreen(
      conversation: conversation,
      onConversationUpdated: _onConversationUpdated,
    );
  }

  BibleChatConversation _createInitialConversation() {
    return BibleChatConversation(
      id: 'main_chat_${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime.now(),
      messageIds: [],
      title: 'Bible Chat',
    );
  }

  void _onConversationUpdated(BibleChatConversation conversation) {
    setState(() {
      _currentConversation = conversation;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      
      // Track screen view in analytics
      final screenNames = ['LessonSelectScreen', 'StoreScreen', 'SocialScreen', 'BibleChatScreen', 'SettingsScreen'];
      Provider.of<AnalyticsService>(context, listen: false)
          .screen(context, screenNames[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screens = _getScreens();

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        elevation: 10,
        height: 80,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: strings.AppStrings.lessons,
          ),
          NavigationDestination(
            icon: const Icon(Icons.store_outlined),
            selectedIcon: const Icon(Icons.store),
            label: strings.AppStrings.store,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: strings.AppStrings.social,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat),
            label: strings.AppStrings.bibleBot,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: strings.AppStrings.settings,
          ),
        ],
      ),
    );
  }
}