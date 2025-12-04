import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'logger.dart';
import 'connection_service.dart';
import '../utils/automatic_error_reporter.dart';

import 'sync/conflict_resolver.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  static SyncService get instance => _instance;

  static const String _tableName = 'user_sync_data';
  static const String _queueKey = 'sync_service_queue';
  
  late final SupabaseClient _client;
  late final ConnectionService _connectionService;
  
  String? _currentUserId;
  RealtimeChannel? _channel;
  final Map<String, Function(Map<String, dynamic>)> _listeners = {};
  bool _isListening = false;
  bool _isInitialized = false;

  // Concurrency protection
  final Map<String, bool> _syncInProgress = {}; // Track ongoing sync operations per key
  final Map<String, bool> _realtimeUpdateInProgress = {}; // Track real-time updates per key

  // Offline queue
  final Map<String, Map<String, dynamic>> _pendingSyncs = {};
  Timer? _queueProcessingTimer;

  // Error handling callbacks - now supports multiple listeners
  final Map<String, Function(String, String)> _errorCallbacks = {};
  final Map<String, Function(String)> _successCallbacks = {};

  /// Public getter for connection status
  bool get isConnected => _connectionService.isConnected;

  factory SyncService() {
    return _instance;
  }

  SyncService._internal() {
    _client = SupabaseConfig.client;
    _connectionService = ConnectionService();
  }

  /// Initializes the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _connectionService.initialize();
    _setupAuthListener();
    _setupConnectionListener();
    await _loadQueue();
    _isInitialized = true;
    AppLogger.info('SyncService initialized (Singleton)');
  }

  /// Registers callbacks for a specific data type
  void registerCallbacks(String dataType, {
    Function(String, String)? onSyncError,
    Function(String)? onSyncSuccess,
  }) {
    if (onSyncError != null) {
      _errorCallbacks[dataType] = onSyncError;
    }
    if (onSyncSuccess != null) {
      _successCallbacks[dataType] = onSyncSuccess;
    }
  }

  /// Called when app resumes
  Future<void> syncOnAppResume() async {
    AppLogger.info('App resumed - triggering sync check');
    if (_currentUserId != null && _connectionService.isConnected) {
      await fetchAllData();
      _processQueue();
    }
  }

  /// Called when app pauses
  Future<void> syncOnAppPause() async {
    AppLogger.info('App paused - ensuring queue is saved');
    await _saveQueue();
  }




  /// Syncs data to the server.
  /// If online, attempts immediate sync.
  /// If offline or fails, adds to queue for later retry.
  Future<void> syncData(String key, Map<String, dynamic> data) async {
    // Always add to pending queue first to ensure we have the latest version
    _pendingSyncs[key] = data;
    await _saveQueue();

    if (_connectionService.isConnected && _currentUserId != null) {
      // Try to sync immediately
      _processQueue();
    } else {
      AppLogger.info('Offline or not logged in, added $key to sync queue');
    }
  }

  /// Syncs data to the server immediately (Legacy method, use syncData instead)
  Future<void> syncDataImmediate(String key, Map<String, dynamic> data) async {
    await syncData(key, data);
  }

  /// Sets up auth state listener to handle user login/logout
  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final user = event.session?.user;
      if (user != null) {
        _currentUserId = user.id;
        _startListening();
        AppLogger.info('User logged in, starting sync for user: ${user.id}');
        // Process any pending items in the queue
        _processQueue();
      } else {
        // User logged out - perform complete session cleanup
        _performSessionCleanup();
        AppLogger.info('User logged out, complete session cleanup performed');
      }
    });
  }

  /// Sets up connection listener to retry syncs when online
  void _setupConnectionListener() {
    _connectionService.setConnectionStatusCallback((isConnected, type) {
      if (isConnected) {
        AppLogger.info('Connection restored, processing sync queue...');
        _processQueue();
      }
    });
  }

  /// Performs complete cleanup of user session data
  void _performSessionCleanup() {
    // Stop all sync operations
    _currentUserId = null;
    _stopListening();

    // Reset sync state
    _syncInProgress.clear();
    _realtimeUpdateInProgress.clear();

    // Clear all listeners to prevent cross-user contamination
    _listeners.clear();
    _isListening = false;
    
    // Clear pending syncs as they belong to the previous user
    _pendingSyncs.clear();
    _saveQueue(); // Persist empty queue

    AppLogger.info('Complete session cleanup performed - all user data cleared');
  }

  /// Loads the pending sync queue from persistent storage
  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      if (queueJson != null) {
        final decoded = json.decode(queueJson) as Map<String, dynamic>;
        _pendingSyncs.clear();
        decoded.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            _pendingSyncs[key] = value;
          }
        });
        AppLogger.info('Loaded ${_pendingSyncs.length} pending syncs from storage');
      }
    } catch (e) {
      AppLogger.error('Failed to load sync queue', e);
    }
  }

  /// Saves the pending sync queue to persistent storage
  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_pendingSyncs.isEmpty) {
        await prefs.remove(_queueKey);
      } else {
        await prefs.setString(_queueKey, json.encode(_pendingSyncs));
      }
    } catch (e) {
      AppLogger.error('Failed to save sync queue', e);
    }
  }

  /// Processes the pending sync queue
  Future<void> _processQueue() async {
    if (_pendingSyncs.isEmpty) return;
    if (_currentUserId == null || !_connectionService.isConnected) return;

    // Create a copy of keys to iterate safely
    final keysToSync = List<String>.from(_pendingSyncs.keys);

    for (final key in keysToSync) {
      final data = _pendingSyncs[key];
      if (data != null) {
        await _performSync(key, data);
      }
    }
  }

  /// Performs the actual sync operation with retry logic and error handling
  Future<void> _performSync(String key, Map<String, dynamic> data) async {
    if (_currentUserId == null) {
      AppLogger.warning('Cannot sync data: no user logged in');
      return;
    }

    // Check network connectivity first
    if (!_connectionService.isConnected) {
      AppLogger.warning('Cannot sync data: no network connection');
      if (_errorCallbacks.containsKey(key)) {
        _errorCallbacks[key]!(key, 'No network connection');
      }
      return;
    }

    // Concurrency protection: prevent multiple syncs for the same key
    if (_syncInProgress[key] == true) {
      AppLogger.debug('Sync already in progress for key: $key, skipping');
      return;
    }

    // Wait for any ongoing real-time updates for this key
    while (_realtimeUpdateInProgress[key] == true) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _syncInProgress[key] = true;

    try {
      // Validate data integrity
      if (!_isValidSyncedData(key, data)) {
        AppLogger.error('Invalid $key data, skipping sync');
        if (_errorCallbacks.containsKey(key)) {
          _errorCallbacks[key]!(key, 'Invalid $key data');
        }
        await AutomaticErrorReporter.reportStorageError(
          message: 'Invalid sync data for key: $key',
          additionalInfo: {
            'key': key,
            'dataKeys': data.keys.toList(),
            'userId': _currentUserId,
          },
        );
        // Remove from queue as it's invalid
        _pendingSyncs.remove(key);
        await _saveQueue();
        return;
      }

      AppLogger.info('Starting sync for key: $key, user: $_currentUserId, data keys: ${data.keys.toList()}');

      // Get current user data or create new record
      final userDataResponse = await _client
          .from(_tableName)
          .select('data')
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      final currentData = Map<String, dynamic>.from(
          userDataResponse?['data'] as Map<String, dynamic>? ?? {});

      // Check for potential conflicts using ConflictResolver
      final existingEntry = currentData[key] as Map<String, dynamic>?;
      final now = DateTime.now();
      
      if (existingEntry != null) {
        final existingTimestamp = DateTime.parse(existingEntry['timestamp'] as String);
        final existingValue = existingEntry['value'] as Map<String, dynamic>;
        
        final timeDifference = now.difference(existingTimestamp);
        final shouldMerge = timeDifference.inSeconds < 60;

        if (shouldMerge) {
           final resolver = ConflictResolverFactory.getResolver(key);
           final mergedData = resolver.resolve(existingValue, data);
           
           currentData[key] = {
             'value': mergedData,
             'timestamp': now.toIso8601String(),
           };
           AppLogger.info('Merged $key data due to recent conflict');
        } else {
          // Old data, just overwrite
          currentData[key] = {
            'value': data,
            'timestamp': now.toIso8601String(),
          };
          AppLogger.info('Overwriting old data for key $key');
        }
      } else {
        // No existing data, just set it
        currentData[key] = {
          'value': data,
          'timestamp': now.toIso8601String(),
        };
      }

      // Upsert the user data
      await _client.from(_tableName).upsert({
        'user_id': _currentUserId,
        'data': currentData,
        'updated_at': now.toIso8601String(),
      });

      AppLogger.info('Successfully synced data for key: $key for user: $_currentUserId');
    if (_successCallbacks.containsKey(key)) {
      _successCallbacks[key]!(key);
    }
    
    // Remove from pending queue on success
      _pendingSyncs.remove(key);
      await _saveQueue();

    } catch (e) {
      final isNetworkError = e.toString().toLowerCase().contains('network') ||
                              e.toString().toLowerCase().contains('connection') ||
                              e.toString().toLowerCase().contains('timeout');
      final isAuthError = e.toString().contains('JWT') || 
                          e.toString().toLowerCase().contains('unauthorized') ||
                          e.toString().toLowerCase().contains('expired');

      AppLogger.error('Failed to sync data for key: $key', e);
      
      if (isAuthError) {
         AppLogger.warning('Auth error detected during sync, attempting to refresh session...');
         try {
           await _client.auth.refreshSession();
           // Retry once after refresh
           AppLogger.info('Session refreshed, retrying sync for key: $key');
           // Don't call syncDataImmediate here to avoid infinite recursion, 
           // just let the next queue process handle it or retry logic
           _syncInProgress[key] = false; // Reset flag before retry
           await _performSync(key, data); 
           return;
         } catch (refreshError) {
           AppLogger.error('Failed to refresh session', refreshError);
         }
      }

    if (_errorCallbacks.containsKey(key)) {
      _errorCallbacks[key]!(key, 'Sync failed: ${e.toString()}');
    }
    
    // Report error with appropriate categorization
      if (isNetworkError) {
        await AutomaticErrorReporter.reportNetworkError(
          message: 'Sync network failure for key: $key',
          url: _tableName,
          statusCode: 0,
          additionalInfo: {
            'key': key,
            'error': e.toString(),
          },
        );
      } else {
        await AutomaticErrorReporter.reportStorageError(
          message: 'Sync failure for key: $key',
          additionalInfo: {
            'key': key,
            'error': e.toString(),
          },
        );
      }
    } finally {
      // Reset concurrency flag
      _syncInProgress[key] = false;
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
    if (_isListening) {
      AppLogger.debug('Already listening for real-time updates, skipping');
      return;
    }

    // Unsubscribe from any existing channel
    _stopListening();

    AppLogger.info('Starting real-time sync listening for user: $_currentUserId');
    _isListening = true;

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
         .subscribe((status, error) async {
           if (status == RealtimeSubscribeStatus.subscribed) {
             AppLogger.info('Real-time sync channel subscribed successfully for user: $_currentUserId');
           } else if (status == RealtimeSubscribeStatus.closed) {
             AppLogger.info('Real-time sync channel closed for user: $_currentUserId');
             // Attempt to reconnect if we are still authenticated
             if (_currentUserId != null) {
               AppLogger.info('Attempting to reconnect real-time sync channel...');
               // Add a small delay to avoid rapid loops
               Future.delayed(const Duration(seconds: 5), () {
                 if (_currentUserId != null && _channel == null) { // Check if still relevant
                    _startListening();
                 }
               });
             }
           } else if (status == RealtimeSubscribeStatus.timedOut) {
             AppLogger.error('Real-time sync channel timed out for user: $_currentUserId');
           } else if (status == RealtimeSubscribeStatus.channelError) {
             AppLogger.error('Real-time sync channel error for user: $_currentUserId: $error');
             
             // Check for auth error in channel
             if (error.toString().contains('JWT') || error.toString().contains('expired')) {
               AppLogger.warning('JWT expired in realtime channel, attempting refresh...');
               try {
                 await _client.auth.refreshSession();
                 // Re-subscribe after refresh
                 _startListening();
               } catch (e) {
                 AppLogger.error('Failed to refresh session for realtime', e);
               }
             }
           }
         });
  }

  /// Stops listening for updates
  void _stopListening() {
    if (_channel != null) {
      _channel!.unsubscribe();
      _channel = null;
    }
    _isListening = false;
  }

  /// Notifies all listeners of data changes
  Future<void> _notifyListeners(Map<String, dynamic> data) async {
    AppLogger.debug('Notifying listeners for ${data.length} data keys');
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // Skip if sync is in progress for this key
      if (_syncInProgress[key] == true) {
        AppLogger.debug('Skipping real-time notification for key $key - sync in progress');
        continue;
      }
      
      final listener = _listeners[key];
      if (listener != null && value is Map<String, dynamic>) {
        // Mark that real-time update is in progress
        _realtimeUpdateInProgress[key] = true;
        try {
          AppLogger.info('Notifying listener for key: $key');
          listener(value['value'] as Map<String, dynamic>);
        } finally {
          _realtimeUpdateInProgress[key] = false;
        }
      } else if (listener == null) {
        AppLogger.warning('No listener registered for key: $key');
      }
    }
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

  /// Fetches all user data from the server (for on-boot initialization)
  Future<Map<String, Map<String, dynamic>>?> fetchAllData() async {
    if (_currentUserId == null) {
      AppLogger.warning('Cannot fetch data: no user logged in');
      return null;
    }

    try {
      AppLogger.info('Fetching all user data from server for user: $_currentUserId');
      
      final response = await _client
          .from(_tableName)
          .select('data')
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (response == null) {
        AppLogger.info('No synced data found for user, starting fresh');
        return {};
      }

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final result = <String, Map<String, dynamic>>{};

      // Extract the value from each key's stored format
      for (final entry in data.entries) {
        if (entry.value is Map<String, dynamic>) {
          final valueMap = entry.value as Map<String, dynamic>;
          if (valueMap.containsKey('value')) {
            result[entry.key] = valueMap['value'] as Map<String, dynamic>;
          }
        }
      }

      AppLogger.info('Fetched data for ${result.length} keys: ${result.keys.toList()}');
      return result;
    } catch (e) {
      AppLogger.error('Failed to fetch user data', e);
      await AutomaticErrorReporter.reportNetworkError(
        message: 'Failed to fetch user data on boot',
        url: _tableName,
        statusCode: 0,
        additionalInfo: {
          'userId': _currentUserId,
          'error': e.toString(),
        },
      );
      return null;
    }
  }





  /// Validates synced data before applying
  bool _isValidSyncedData(String key, Map<String, dynamic> data) {
    // Basic validation - we rely on ConflictResolvers to handle data integrity during merge
    // but we can do some high-level checks here.
    if (data.isEmpty && key != 'settings') return false; // Settings can be empty?
    
    // We could delegate to specific validators if needed, but for now we trust the source
    // as we are moving towards a more robust conflict resolution strategy.
    return true;
  }

  /// Disposes the service
  void dispose() {
    _stopListening();
    _queueProcessingTimer?.cancel();
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

  /// Gets top users for leaderboard based on game stats
  Future<List<Map<String, dynamic>>> getTopUsersForLeaderboard({int limit = 5}) async {
    try {
      AppLogger.info('Starting getTopUsersForLeaderboard with limit: $limit');

      // Use the secure database function to get leaderboard data
      // This function uses SECURITY DEFINER to safely bypass RLS and returns ONLY the data needed for leaderboard
      // It does NOT expose any sensitive data like API keys or other user sync data
      final response = await _client
          .rpc('get_public_leaderboard_data', params: {'limit_count': limit})
          .select();

      AppLogger.info('Secure leaderboard function response received');

      if (response.isEmpty) {
        AppLogger.info('No leaderboard data found - this might be expected for new installations');
        return [];
      }

      // Convert the response to the expected format, with safety checks
      final List<Map<String, dynamic>> usersWithScores = [];

      for (final item in response) {
        try {
          // Validate and sanitize the data
          final userId = item['user_id'] as String?;
          final username = item['username'] as String?;
          final displayName = item['display_name'] as String?;
          final score = item['score'] as int? ?? 0;

          // Only include valid entries
          if (userId != null && username != null && username.isNotEmpty) {
            usersWithScores.add({
              'userId': userId,
              'username': username,
              'displayName': displayName?.isNotEmpty == true ? displayName : username,
              'score': score,
            });
          }
        } catch (e) {
          AppLogger.error('Error processing leaderboard item', e);
          continue;
        }
      }

      AppLogger.info('Successfully processed ${usersWithScores.length} leaderboard entries');

      // Sort by score (descending) to ensure proper ordering
      usersWithScores.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

      return usersWithScores;
    } catch (e) {
      AppLogger.error('Failed to get top users for leaderboard via secure function', e);

      // Fallback to the old method if the new function fails
      AppLogger.info('Falling back to original leaderboard method (less secure)');
      return await _getTopUsersForLeaderboardFallback(limit);
    }
  }

  /// Fallback method using the original approach
  Future<List<Map<String, dynamic>>> _getTopUsersForLeaderboardFallback(int limit) async {
    try {
      AppLogger.info('Using fallback method for getTopUsersForLeaderboard with limit: $limit');

      // Get all user profiles (excluding deleted users)
      final profilesResponse = await _client
          .from('user_profiles')
          .select('user_id, username, display_name')
          .filter('deleted_at', 'is', null);

      AppLogger.info('Found ${profilesResponse.length} user profiles in fallback');

      if (profilesResponse.isEmpty) {
        AppLogger.info('No user profiles found in fallback');
        return [];
      }

      final List<Map<String, dynamic>> usersWithScores = [];

      // Get game stats for each user and calculate their score
      for (final profile in profilesResponse) {
        final userId = profile['user_id'] as String;
        final username = profile['username'] as String?;
        final displayName = profile['display_name'] as String? ?? username;

        if (username == null) continue;

        try {
          AppLogger.info('Getting game stats for user (fallback): $userId');
          final stats = await getGameStatsForUser(userId);
          AppLogger.info('Game stats for user $userId (fallback): $stats');
          final score = stats?['score'] ?? 0;
          AppLogger.info('User $userId score (fallback): $score');

          usersWithScores.add({
            'userId': userId,
            'username': username,
            'displayName': displayName,
            'score': score,
          });
        } catch (e) {
          AppLogger.error('Failed to get stats for user $userId (fallback)', e);
          continue;
        }
      }

      AppLogger.info('Users with scores before sorting (fallback): ${usersWithScores.length}');
      AppLogger.info('Users with scores data (fallback): $usersWithScores');

      // Sort by score (descending) and take top N
      usersWithScores.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

      AppLogger.info('Top users after sorting (fallback): ${usersWithScores.take(limit).toList()}');

      return usersWithScores.take(limit).toList();
    } catch (e) {
      AppLogger.error('Failed to get top users for leaderboard (fallback)', e);
      return [];
    }
  }

}