import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import 'logger.dart';

/// Data class for offline sync queue items
class _OfflineSyncItem {
  final String key;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? userId;

  _OfflineSyncItem({
    required this.key,
    required this.data,
    required this.timestamp,
    this.userId,
  });

  /// Creates an OfflineSyncItem from JSON
  factory _OfflineSyncItem.fromJson(Map<String, dynamic> json) {
    return _OfflineSyncItem(
      key: json['key'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
    );
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }
}

class SyncService {
  static const String _tableName = 'user_sync_data';
  static const String _offlineQueueKey = 'sync_offline_queue';
  late final SupabaseClient _client;
  String? _currentUserId;
  RealtimeChannel? _channel;
  final Map<String, Function(Map<String, dynamic>)> _listeners = {};
  SharedPreferences? _prefs;
  Timer? _retryTimer;

  // Rate limiting and debouncing
  final Map<String, DateTime> _lastSyncTimes = {};
  final Map<String, Timer> _debounceTimers = {};
  static const Duration _minSyncInterval = Duration(seconds: 5); // Minimum 5 seconds between syncs for same key
  static const Duration _debounceDelay = Duration(seconds: 2); // Wait 2 seconds after last change before syncing

  // Concurrency protection
  final Map<String, bool> _syncInProgress = {}; // Track ongoing sync operations per key
  bool _isApplyingRealtimeUpdate = false; // Prevent conflicts during real-time updates

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 2);
  static const double _retryBackoffMultiplier = 1.5;

  // Error handling callbacks
  Function(String, String)? _onSyncError;
  Function(String)? _onSyncSuccess;

  SyncService() {
    _client = SupabaseConfig.client;
  }

  /// Initializes the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _setupAuthListener();
    _startOfflineRetryTimer();
  }

  /// Sets error and success callbacks for user notifications
  void setCallbacks({
    Function(String, String)? onSyncError,
    Function(String)? onSyncSuccess,
  }) {
    _onSyncError = onSyncError;
    _onSyncSuccess = onSyncSuccess;
  }

  /// Performs immediate sync without debouncing (for manual sync operations)
  Future<void> syncDataImmediate(String key, Map<String, dynamic> data) async {
    // Cancel any pending debounced sync for this key
    _debounceTimers[key]?.cancel();
    _debounceTimers.remove(key);

    await _performSync(key, data);
  }

  /// Sets up auth state listener to handle user login/logout
  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final user = event.session?.user;
      if (user != null) {
        _currentUserId = user.id;
        _startListening();
        AppLogger.info('User logged in, starting sync for user: ${user.id}');
      } else {
        // User logged out - perform complete session cleanup
        _performSessionCleanup();
        AppLogger.info('User logged out, complete session cleanup performed');
      }
    });
  }

  /// Performs complete cleanup of user session data
  void _performSessionCleanup() {
    // Stop all sync operations
    _currentUserId = null;
    _stopListening();

    // Cancel all pending debounced sync operations
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    // Reset sync state
    _syncInProgress.clear();
    _lastSyncTimes.clear();
    _isApplyingRealtimeUpdate = false;

    // Clear all listeners to prevent cross-user contamination
    _listeners.clear();

    // Clear offline queue for the previous user
    if (_prefs != null) {
      _prefs!.remove(_offlineQueueKey);
    }

    AppLogger.info('Complete session cleanup performed - all user data cleared');
  }

  /// Syncs data to the current user's data with rate limiting, debouncing, and improved retry logic
  Future<void> syncData(String key, Map<String, dynamic> data) async {
    if (_currentUserId == null) {
      AppLogger.warning('Cannot sync data: no user logged in');
      return;
    }

    // Rate limiting: check if we're syncing this key too frequently
    final lastSync = _lastSyncTimes[key];
    if (lastSync != null && DateTime.now().difference(lastSync) < _minSyncInterval) {
      AppLogger.debug('Rate limiting: skipping sync for key $key, too soon since last sync');
      // Schedule a debounced sync instead
      _scheduleDebouncedSync(key, data);
      return;
    }

    // Use debounced sync for better performance
    _scheduleDebouncedSync(key, data);
  }

  /// Schedules a debounced sync operation
  void _scheduleDebouncedSync(String key, Map<String, dynamic> data) {
    // Cancel any existing timer for this key
    _debounceTimers[key]?.cancel();

    // Schedule new debounced sync
    _debounceTimers[key] = Timer(_debounceDelay, () async {
      _debounceTimers.remove(key);
      await _performSync(key, data);
    });
  }

  /// Performs the actual sync operation with retry logic and error handling
  Future<void> _performSync(String key, Map<String, dynamic> data) async {
    if (_currentUserId == null) {
      AppLogger.warning('Cannot sync data: no user logged in');
      return;
    }

    // Concurrency protection: prevent multiple syncs for the same key
    if (_syncInProgress[key] == true) {
      AppLogger.debug('Sync already in progress for key: $key, skipping');
      return;
    }

    // Prevent real-time updates during sync operations
    _isApplyingRealtimeUpdate = true;
    _syncInProgress[key] = true;

    try {
      // Validate data integrity
      if (!_isValidSyncedData(key, data)) {
        AppLogger.error('Invalid $key data, skipping sync');
        _onSyncError?.call(key, 'Invalid $key data');
        return;
      }

      AppLogger.info('Starting sync for key: $key, user: $_currentUserId, data keys: ${data.keys.toList()}');

      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        try {
          // Calculate retry delay with exponential backoff
          final retryDelay = attempt > 1
              ? _baseRetryDelay * (_retryBackoffMultiplier * (attempt - 1))
              : Duration.zero;

          if (retryDelay > Duration.zero) {
            AppLogger.info('Retrying sync in ${retryDelay.inSeconds} seconds...');
            await Future.delayed(retryDelay);
          }

          // Get current user data or create new record
          final userDataResponse = await _client
              .from(_tableName)
              .select('data')
              .eq('user_id', _currentUserId!)
              .maybeSingle();

          final currentData = Map<String, dynamic>.from(
              userDataResponse?['data'] as Map<String, dynamic>? ?? {});

          AppLogger.debug('Current sync data keys before update: ${currentData.keys.toList()}');

          // Check for potential conflicts
          final existingEntry = currentData[key] as Map<String, dynamic>?;
          if (existingEntry != null) {
            final existingTimestamp = DateTime.parse(existingEntry['timestamp'] as String);
            final now = DateTime.now();
            AppLogger.info('Potential conflict for key $key: existing timestamp $existingTimestamp, new timestamp $now');

            // Implement conflict resolution based on data type
            if (key == 'game_stats') {
              final existingValue = existingEntry['value'] as Map<String, dynamic>;
              final mergedData = _mergeGameStats(existingValue, data);
              currentData[key] = {
                'value': mergedData,
                'timestamp': DateTime.now().toIso8601String(),
              };
              AppLogger.info('Merged game stats due to conflict');
            } else if (key == 'settings') {
              final existingValue = existingEntry['value'] as Map<String, dynamic>;
              final mergedData = _mergeSettings(existingValue, data);
              currentData[key] = {
                'value': mergedData,
                'timestamp': DateTime.now().toIso8601String(),
              };
              AppLogger.info('Merged settings due to conflict');
            } else if (key == 'lesson_progress') {
              final existingValue = existingEntry['value'] as Map<String, dynamic>;
              final mergedData = _mergeLessonProgress(existingValue, data);
              currentData[key] = {
                'value': mergedData,
                'timestamp': DateTime.now().toIso8601String(),
              };
              AppLogger.info('Merged lesson progress due to conflict');
            } else {
              // For other keys, last write wins
              currentData[key] = {
                'value': data,
                'timestamp': DateTime.now().toIso8601String(),
              };
            }
          } else {
            // No existing data, just set it
            currentData[key] = {
              'value': data,
              'timestamp': DateTime.now().toIso8601String(),
            };
          }

          // Upsert the user data
          await _client.from(_tableName).upsert({
            'user_id': _currentUserId,
            'data': currentData,
            'updated_at': DateTime.now().toIso8601String(),
          });

          // Update rate limiting timestamp
          _lastSyncTimes[key] = DateTime.now();

          AppLogger.info('Successfully synced data for key: $key for user: $_currentUserId on attempt $attempt');
          _onSyncSuccess?.call(key);
          return; // Success, exit retry loop
        } catch (e) {
          AppLogger.error('Failed to sync data for key: $key on attempt $attempt/$_maxRetries', e);
          if (attempt == _maxRetries) {
            AppLogger.error('All retry attempts failed for key: $key, queuing for offline sync');
            await _queueOfflineSync(key, data);
            _onSyncError?.call(key, 'Sync failed after $_maxRetries attempts: ${e.toString()}');
          }
        }
      }
    } finally {
      // Reset concurrency flags
      _syncInProgress[key] = false;
      _isApplyingRealtimeUpdate = false;
    }
  }

  /// Adds a listener for data changes
  void addListener(String key, Function(Map<String, dynamic>) callback) {
    _listeners[key] = callback;
  }

  /// Removes a listener
  void removeListener(String key) {
    _listeners.remove(key);
  }

  /// Starts listening for real-time updates for the current user
  void _startListening() {
    if (_currentUserId == null) return;

    // Unsubscribe from any existing channel
    _stopListening();

    AppLogger.info('Starting real-time sync listening for user: $_currentUserId');

    _channel = _client
        .channel('user_sync_$_currentUserId')
        .onPostgresChanges(
           event: PostgresChangeEvent.update,
           schema: 'public',
           table: _tableName,
           filter: PostgresChangeFilter(
             type: PostgresChangeFilterType.eq,
             column: 'user_id',
             value: _currentUserId,
           ),
           callback: (payload) {
             AppLogger.info('Received real-time sync update for user: $_currentUserId');
             final newRecord = payload.newRecord as Map<String, dynamic>? ?? {};
             final newData = newRecord['data'] as Map<String, dynamic>? ?? {};
             AppLogger.debug('Real-time update data keys: ${newData.keys.toList()}');
             _notifyListeners(newData);
           },
         )
         .subscribe((status, error) {
           if (status == RealtimeSubscribeStatus.subscribed) {
             AppLogger.info('Real-time sync channel subscribed successfully for user: $_currentUserId');
           } else if (status == RealtimeSubscribeStatus.closed) {
             AppLogger.warning('Real-time sync channel closed for user: $_currentUserId');
           } else if (status == RealtimeSubscribeStatus.timedOut) {
             AppLogger.error('Real-time sync channel timed out for user: $_currentUserId');
           } else if (status == RealtimeSubscribeStatus.channelError) {
             AppLogger.error('Real-time sync channel error for user: $_currentUserId: $error');
           }
         });
  }

  /// Stops listening for updates
  void _stopListening() {
    if (_channel != null) {
      _channel!.unsubscribe();
      _channel = null;
    }
  }

  /// Notifies all listeners of data changes
  void _notifyListeners(Map<String, dynamic> data) {
    // Prevent real-time updates during sync operations to avoid conflicts
    if (_isApplyingRealtimeUpdate) {
      AppLogger.debug('Skipping real-time listener notifications during sync operation');
      return;
    }

    AppLogger.debug('Notifying listeners for ${data.length} data keys');
    data.forEach((key, value) {
      final listener = _listeners[key];
      if (listener != null && value is Map<String, dynamic>) {
        AppLogger.info('Notifying listener for key: $key');
        listener(value['value'] as Map<String, dynamic>);
      } else if (listener == null) {
        AppLogger.warning('No listener registered for key: $key');
      }
    });
  }

  /// Gets the current user's data
  Future<Map<String, dynamic>?> getUserData() async {
    if (_currentUserId == null) return null;

    try {
      final response = await _client
          .from(_tableName)
          .select('data')
          .eq('user_id', _currentUserId!)
          .single();
      return response['data'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      AppLogger.error('Failed to get user data', e);
      return null;
    }
  }

  /// Checks if user is authenticated
  bool get isAuthenticated => _currentUserId != null;

  /// Gets the current user ID
  String? get currentUserId => _currentUserId;

  /// Merges game stats by taking the maximum values (prevents accumulation bugs)
  Map<String, dynamic> _mergeGameStats(Map<String, dynamic> existing, Map<String, dynamic> incoming) {
    // Validate input data
    if (!_isValidGameStatsData(existing) || !_isValidGameStatsData(incoming)) {
      AppLogger.warning('Invalid game stats data in merge, using incoming data as fallback');
      return incoming;
    }

    return {
      'score': (existing['score'] as int? ?? 0) > (incoming['score'] as int? ?? 0)
          ? existing['score']
          : incoming['score'],
      'currentStreak': (existing['currentStreak'] as int? ?? 0) > (incoming['currentStreak'] as int? ?? 0)
          ? existing['currentStreak']
          : incoming['currentStreak'],
      'longestStreak': (existing['longestStreak'] as int? ?? 0) > (incoming['longestStreak'] as int? ?? 0)
          ? existing['longestStreak']
          : incoming['longestStreak'],
      // Take maximum incorrect answers instead of summing to prevent accumulation
      'incorrectAnswers': (existing['incorrectAnswers'] as int? ?? 0) > (incoming['incorrectAnswers'] as int? ?? 0)
          ? existing['incorrectAnswers']
          : incoming['incorrectAnswers'],
    };
  }

  /// Merges settings by taking the latest values (last write wins for most settings)
  Map<String, dynamic> _mergeSettings(Map<String, dynamic> existing, Map<String, dynamic> incoming) {
    // For settings, we generally want the latest values, but merge AI themes by combining
    final merged = Map<String, dynamic>.from(incoming);

    // For AI themes, merge by combining all themes
    if (existing.containsKey('aiThemes') && incoming.containsKey('aiThemes')) {
      final existingThemes = Map<String, dynamic>.from(existing['aiThemes'] ?? {});
      final incomingThemes = Map<String, dynamic>.from(incoming['aiThemes'] ?? {});
      final mergedThemes = Map<String, dynamic>.from(existingThemes);
      mergedThemes.addAll(incomingThemes); // Incoming themes override existing
      merged['aiThemes'] = mergedThemes;
    }

    return merged;
  }

  /// Merges lesson progress by taking maximum values
  Map<String, dynamic> _mergeLessonProgress(Map<String, dynamic> existing, Map<String, dynamic> incoming) {
    final merged = Map<String, dynamic>.from(incoming);

    // Take the maximum unlocked count
    final existingUnlocked = existing['unlockedCount'] as int? ?? 1;
    final incomingUnlocked = incoming['unlockedCount'] as int? ?? 1;
    merged['unlockedCount'] = existingUnlocked > incomingUnlocked ? existingUnlocked : incomingUnlocked;

    // Merge best stars by taking maximum for each lesson
    final existingStars = Map<String, int>.from(existing['bestStarsByLesson'] ?? {});
    final incomingStars = Map<String, int>.from(incoming['bestStarsByLesson'] ?? {});
    final mergedStars = Map<String, int>.from(existingStars);

    incomingStars.forEach((lessonId, stars) {
      final currentStars = mergedStars[lessonId] ?? 0;
      if (stars > currentStars) {
        mergedStars[lessonId] = stars;
      }
    });

    merged['bestStarsByLesson'] = mergedStars;
    return merged;
  }

  /// Queues failed sync data for later retry with proper JSON serialization
  Future<void> _queueOfflineSync(String key, Map<String, dynamic> data) async {
    if (_prefs == null) return;

    final queueJson = _prefs!.getString(_offlineQueueKey) ?? '[]';
    final queue = List<Map<String, dynamic>>.from(json.decode(queueJson) as List);

    final queueItem = _OfflineSyncItem(
      key: key,
      data: data,
      timestamp: DateTime.now(),
      userId: _currentUserId,
    );

    queue.add(queueItem.toJson());
    await _prefs!.setString(_offlineQueueKey, json.encode(queue));
    AppLogger.info('Queued offline sync for key: $key (${queue.length} items in queue)');
  }

  /// Processes the offline sync queue with conflict resolution
  Future<void> _processOfflineQueue() async {
    if (_prefs == null || _currentUserId == null) return;

    final queueJson = _prefs!.getString(_offlineQueueKey);
    if (queueJson == null || queueJson.isEmpty) return;

    final queue = List<Map<String, dynamic>>.from(json.decode(queueJson) as List);
    if (queue.isEmpty) return;

    AppLogger.info('Processing ${queue.length} offline sync items');

    // Group items by key to handle conflicts
    final groupedItems = <String, List<_OfflineSyncItem>>{};
    final remainingQueue = <Map<String, dynamic>>[];

    for (final itemJson in queue) {
      try {
        final item = _OfflineSyncItem.fromJson(itemJson);
        if (item.userId == _currentUserId) { // Only process items for current user
          groupedItems.putIfAbsent(item.key, () => []).add(item);
        } else {
          remainingQueue.add(itemJson); // Keep items for other users
        }
      } catch (e) {
        AppLogger.error('Failed to parse offline sync item', e);
        remainingQueue.add(itemJson); // Keep malformed items
      }
    }

    // Process each group, merging conflicts
    for (final entry in groupedItems.entries) {
      final key = entry.key;
      final items = entry.value;

      if (items.isEmpty) continue;

      // Sort by timestamp (oldest first)
      items.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Merge all items for this key using conflict resolution
      Map<String, dynamic> mergedData = items.first.data;
      for (int i = 1; i < items.length; i++) {
        mergedData = _mergeDataByKey(key, mergedData, items[i].data);
      }

      try {
        // Try to sync the merged data
        await syncData(key, mergedData);
        AppLogger.info('Successfully processed offline sync for key: $key');
      } catch (e) {
        AppLogger.error('Failed to sync merged offline data for key: $key', e);
        // Re-queue the merged item
        final mergedItem = _OfflineSyncItem(
          key: key,
          data: mergedData,
          timestamp: DateTime.now(),
          userId: _currentUserId,
        );
        remainingQueue.add(mergedItem.toJson());
      }
    }

    // Save remaining queue
    await _prefs!.setString(_offlineQueueKey, json.encode(remainingQueue));

    if (remainingQueue.isNotEmpty) {
      AppLogger.info('${remainingQueue.length} offline sync items remaining');
    }
  }

  /// Merges data based on the key type (same logic as real-time sync)
  Map<String, dynamic> _mergeDataByKey(String key, Map<String, dynamic> existing, Map<String, dynamic> incoming) {
    switch (key) {
      case 'game_stats':
        return _mergeGameStats(existing, incoming);
      case 'settings':
        return _mergeSettings(existing, incoming);
      case 'lesson_progress':
        return _mergeLessonProgress(existing, incoming);
      default:
        return incoming; // Last write wins for unknown keys
    }
  }

  /// Starts the offline retry timer
  void _startOfflineRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_currentUserId != null) {
        _processOfflineQueue();
      }
    });
  }

  /// Stops the offline retry timer
  void _stopOfflineRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Validates data integrity
  bool _isValidGameStatsData(Map<String, dynamic> data) {
    return data.containsKey('score') &&
           data.containsKey('currentStreak') &&
           data.containsKey('longestStreak') &&
           data.containsKey('incorrectAnswers') &&
           data['score'] is int &&
           data['currentStreak'] is int &&
           data['longestStreak'] is int &&
           data['incorrectAnswers'] is int &&
           (data['score'] as int) >= 0 &&
           (data['currentStreak'] as int) >= 0 &&
           (data['longestStreak'] as int) >= 0 &&
           (data['incorrectAnswers'] as int) >= 0;
  }

  /// Validates lesson progress data
  bool _isValidLessonProgressData(Map<String, dynamic> data) {
    if (!data.containsKey('unlockedCount') || !(data['unlockedCount'] is int)) return false;
    if ((data['unlockedCount'] as int) < 1) return false;

    if (data.containsKey('bestStarsByLesson')) {
      final starsMap = data['bestStarsByLesson'];
      if (starsMap is! Map<String, dynamic>) return false;

      for (final value in starsMap.values) {
        if (value is! int || value < 0 || value > 3) return false;
      }
    }

    return true;
  }

  /// Validates settings data
  bool _isValidSettingsData(Map<String, dynamic> data) {
    // Basic structure validation - could be expanded
    return data is Map<String, dynamic>;
  }

  /// Validates synced data before applying
  bool _isValidSyncedData(String key, Map<String, dynamic> data) {
    switch (key) {
      case 'game_stats':
        return _isValidGameStatsData(data);
      case 'lesson_progress':
        return _isValidLessonProgressData(data);
      case 'settings':
        return _isValidSettingsData(data);
      default:
        return true; // Allow unknown keys for forward compatibility
    }
  }

  /// Disposes the service
  void dispose() {
    _stopListening();
    _stopOfflineRetryTimer();

    // Cancel all debounce timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// Gets the current user's profile, creating it if it doesn't exist
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (_currentUserId == null) return null;

    try {
      // First try to get existing profile
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (response != null) {
        return response;
      }

      // Profile doesn't exist, create a default one
      AppLogger.info('User profile not found, creating default profile for user: $_currentUserId');

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      // Extract username from email (before @) as fallback
      final emailUsername = user.email?.split('@').first ?? 'user';

      final newProfile = {
        'user_id': _currentUserId,
        'username': emailUsername,
        'display_name': emailUsername,
        'bio': null,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('user_profiles').insert(newProfile);

      AppLogger.info('Created default user profile for user: $_currentUserId');
      return newProfile;
    } catch (e) {
      AppLogger.error('Failed to get current user profile', e);
      return null;
    }
  }

  /// Searches for users by username (excluding deleted users)
  Future<List<Map<String, dynamic>>?> searchUsers(String query) async {
    if (query.isEmpty || query.length < 2) {
      return <Map<String, dynamic>>[];
    }

    try {
      final response = await _client
          .from('user_profiles')
          .select('user_id, username, display_name')
          .ilike('username', '%$query%')
          .filter('deleted_at', 'is', null)  // Exclude deleted users
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Failed to search users: $query', e);
      return <Map<String, dynamic>>[];
    }
  }

  /// Follows a user by their user ID
  Future<bool> followUser(String targetUserId) async {
    if (_currentUserId == null) return false;
    if (_currentUserId == targetUserId) return false; // Can't follow yourself

    try {
      await _client.from('user_relationships').insert({
        'follower_user_id': _currentUserId,
        'followed_user_id': targetUserId,
      });
      AppLogger.debug('Successfully followed user: $targetUserId');
      return true;
    } catch (e) {
      // Check if it's a duplicate key error (already following)
      if (e.toString().contains('duplicate key')) {
        AppLogger.debug('Already following user: $targetUserId');
        return true;
      }
      AppLogger.error('Failed to follow user: $targetUserId', e);
      return false;
    }
  }

  /// Unfollows a user by their user ID
  Future<bool> unfollowUser(String targetUserId) async {
    if (_currentUserId == null) return false;

    try {
      await _client
          .from('user_relationships')
          .delete()
          .eq('follower_user_id', _currentUserId!)
          .eq('followed_user_id', targetUserId);
      AppLogger.debug('Successfully unfollowed user: $targetUserId');
      return true;
    } catch (e) {
      AppLogger.error('Failed to unfollow user: $targetUserId', e);
      return false;
    }
  }

  /// Checks if current user is following another user
  Future<bool> isFollowingUser(String targetUserId) async {
    if (_currentUserId == null) return false;

    try {
      final response = await _client
          .from('user_relationships')
          .select()
          .eq('follower_user_id', _currentUserId!)
          .eq('followed_user_id', targetUserId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      AppLogger.error('Failed to check if following user: $targetUserId', e);
      return false;
    }
  }

  /// Gets the list of users that the current user is following
  Future<List<String>?> getFollowingList() async {
    if (_currentUserId == null) return <String>[];

    try {
      final response = await _client
          .from('user_relationships')
          .select('followed_user_id')
          .eq('follower_user_id', _currentUserId!);

      return List<String>.from(response.map((item) => item['followed_user_id']));
    } catch (e) {
      AppLogger.error('Failed to get following list', e);
      return <String>[];
    }
  }

  /// Gets the list of users following the current user
  Future<List<String>?> getFollowersList() async {
    if (_currentUserId == null) return <String>[];

    try {
      final response = await _client
          .from('user_relationships')
          .select('follower_user_id')
          .eq('followed_user_id', _currentUserId!);

      return List<String>.from(response.map((item) => item['follower_user_id']));
    } catch (e) {
      AppLogger.error('Failed to get followers list', e);
      return <String>[];
    }
  }

  /// Gets username for a user ID (excluding deleted users)
  Future<String?> getUsernameByUserId(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('username')
          .eq('user_id', userId)
          .filter('deleted_at', 'is', null)  // Exclude deleted users
          .maybeSingle();

      return response?['username'] as String?;
    } catch (e) {
      AppLogger.error('Failed to get username for user: $userId', e);
      return null;
    }
  }

  /// Gets user profile by user ID (excluding deleted users)
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .filter('deleted_at', 'is', null)  // Exclude deleted users
          .maybeSingle();

      return response;
    } catch (e) {
      AppLogger.error('Failed to get user profile for: $userId', e);
      return null;
    }
  }

  /// Gets game stats for a specific user
  Future<Map<String, dynamic>?> getGameStatsForUser(String userId) async {
    try {
      final response = await _client
          .from('user_sync_data')
          .select('data')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      final data = response['data'] as Map<String, dynamic>?;
      return data?['game_stats']?['value'] as Map<String, dynamic>?;
    } catch (e) {
      AppLogger.error('Failed to get game stats for user: $userId', e);
      return null;
    }
  }

}