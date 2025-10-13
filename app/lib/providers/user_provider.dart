import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_stats.dart';
import '../models/purchase.dart';
import '../models/follow.dart';
import '../services/auth_service.dart';
import '../services/stats_sync_service.dart';
import '../services/social_service.dart';
import '../services/purchase_service.dart';
import '../services/logger.dart';

/// Provider for managing user state, authentication, and social features
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StatsSyncService _statsSyncService = StatsSyncService();
  final SocialService _socialService = SocialService();
  final PurchaseService _purchaseService = PurchaseService();
  
  User? _user;
  UserStats? _userStats;
  List<Purchase> _purchases = [];
  List<UserWithFollow> _following = [];
  List<UserWithFollow> _followers = [];
  List<FeedItem> _feed = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  UserStats? get userStats => _userStats;
  List<Purchase> get purchases => _purchases;
  List<UserWithFollow> get following => _following;
  List<UserWithFollow> get followers => _followers;
  List<FeedItem> get feed => _feed;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  /// Initialize the user provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await _authService.initialize();
      
      if (_authService.isAuthenticated) {
        _user = _authService.currentUser;
        await _initializeServices();
        await _loadUserData();
      }
    } catch (e) {
      AppLogger.error('Failed to initialize UserProvider', e);
      _setError('Failed to initialize user system');
    } finally {
      _setLoading(false);
    }
  }

  /// Initialize all services with access token
  Future<void> _initializeServices() async {
    final accessToken = _authService.accessToken;
    await Future.wait([
      _statsSyncService.initialize(accessToken),
      _socialService.initialize(accessToken),
      _purchaseService.initialize(accessToken),
    ]);
  }

  /// Sign up a new user
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      if (result.isSuccess) {
        _user = result.user;
        await _loadUserData();
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Sign up failed');
        return false;
      }
    } catch (e) {
      AppLogger.error('Sign up error', e);
      _setError('An unexpected error occurred during sign up');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        _user = result.user;
        await _loadUserData();
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Sign in failed');
        return false;
      }
    } catch (e) {
      AppLogger.error('Sign in error', e);
      _setError('An unexpected error occurred during sign in');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with username and password
  Future<bool> signInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signInWithUsername(
        username: username,
        password: password,
      );

      if (result.isSuccess) {
        _user = result.user;
        await _loadUserData();
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Sign in failed');
        return false;
      }
    } catch (e) {
      AppLogger.error('Sign in error', e);
      _setError('An unexpected error occurred during sign in');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _clearUserData();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Sign out error', e);
      _setError('Failed to sign out');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      return await _authService.isUsernameAvailable(username);
    } catch (e) {
      AppLogger.error('Username availability check error', e);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

      if (result.isSuccess) {
        _user = result.user;
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Profile update failed');
        return false;
      }
    } catch (e) {
      AppLogger.error('Profile update error', e);
      _setError('Failed to update profile');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load all user data
  Future<void> _loadUserData() async {
    if (_user == null) return;

    try {
      await Future.wait([
        _loadUserStats(),
        _loadPurchases(),
        _loadFollowing(),
        _loadFollowers(),
        _loadFeed(),
      ]);
    } catch (e) {
      AppLogger.error('Failed to load user data', e);
    }
  }

  /// Load user statistics
  Future<void> _loadUserStats() async {
    try {
      _userStats = await _statsSyncService.getUserStats();
      if (_userStats == null) {
        // Create initial stats if none exist
        _userStats = UserStats(
          id: '${_user!.id}_stats',
          userId: _user!.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to load user stats', e);
    }
  }

  /// Load user purchases
  Future<void> _loadPurchases() async {
    try {
      final purchases = await _purchaseService.getUserPurchases();
      _purchases = purchases ?? [];
    } catch (e) {
      AppLogger.error('Failed to load purchases', e);
      _purchases = [];
    }
  }

  /// Load following list
  Future<void> _loadFollowing() async {
    try {
      final following = await _socialService.getFollowing();
      _following = following ?? [];
    } catch (e) {
      AppLogger.error('Failed to load following', e);
      _following = [];
    }
  }

  /// Load followers list
  Future<void> _loadFollowers() async {
    try {
      final followers = await _socialService.getFollowers();
      _followers = followers ?? [];
    } catch (e) {
      AppLogger.error('Failed to load followers', e);
      _followers = [];
    }
  }

  /// Load social feed
  Future<void> _loadFeed() async {
    try {
      final feed = await _socialService.getFeed();
      _feed = feed ?? [];
    } catch (e) {
      AppLogger.error('Failed to load feed', e);
      _feed = [];
    }
  }

  /// Follow a user
  Future<bool> followUser(String username) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _socialService.followUser(username);
      if (success) {
        // Reload following list
        await _loadFollowing();
        notifyListeners();
      } else {
        _setError('Failed to follow user');
      }
      return success;
    } catch (e) {
      AppLogger.error('Follow user error', e);
      _setError('Failed to follow user');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Unfollow a user
  Future<bool> unfollowUser(String username) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _socialService.unfollowUser(username);
      if (success) {
        // Reload following list
        await _loadFollowing();
        notifyListeners();
      } else {
        _setError('Failed to unfollow user');
      }
      return success;
    } catch (e) {
      AppLogger.error('Unfollow user error', e);
      _setError('Failed to unfollow user');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if following a user
  bool isFollowing(String username) {
    return _following.any((user) => user.user.username == username);
  }

  /// Purchase an item
  Future<bool> purchaseItem(StoreItem item) async {
    try {
      _setLoading(true);
      _clearError();

      final purchase = await _purchaseService.createPurchase(item);
      if (purchase != null) {
        _purchases.add(purchase);
        
        // Update user stats (deduct cost)
        if (_userStats != null) {
          _userStats = _userStats!.copyWith(
            score: _userStats!.score - item.cost,
          );
        }
        
        notifyListeners();
        return true;
      } else {
        _setError('Failed to purchase item');
        return false;
      }
    } catch (e) {
      AppLogger.error('Purchase item error', e);
      _setError('Failed to purchase item');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user owns an item
  bool ownsItem(String itemType, String itemId) {
    return _purchases.any((purchase) => 
        purchase.itemType == itemType && 
        purchase.itemId == itemId && 
        purchase.isValid);
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (_user == null) return;
    
    try {
      _setLoading(true);
      await _loadUserData();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to refresh user data', e);
      _setError('Failed to refresh data');
    } finally {
      _setLoading(false);
    }
  }

  /// Sync stats with server
  Future<bool> syncStats() async {
    if (_userStats == null) return false;
    
    try {
      _setLoading(true);
      _clearError();

      final syncedStats = await _statsSyncService.syncStats(_userStats!);
      if (syncedStats != null) {
        _userStats = syncedStats;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to sync stats');
        return false;
      }
    } catch (e) {
      AppLogger.error('Stats sync error', e);
      _setError('Failed to sync stats');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update stats on server
  Future<bool> updateStats(UserStats stats) async {
    try {
      final success = await _statsSyncService.updateUserStats(stats);
      if (success) {
        _userStats = stats;
        notifyListeners();
      }
      return success;
    } catch (e) {
      AppLogger.error('Update stats error', e);
      return false;
    }
  }

  /// Search users
  Future<List<User>?> searchUsers(String query) async {
    try {
      return await _socialService.searchUsers(query);
    } catch (e) {
      AppLogger.error('Search users error', e);
      return null;
    }
  }

  /// Get user profile by username
  Future<User?> getUserProfile(String username) async {
    try {
      return await _socialService.getUserProfile(username);
    } catch (e) {
      AppLogger.error('Get user profile error', e);
      return null;
    }
  }

  /// Get store items
  Future<List<StoreItem>?> getStoreItems({String? itemType}) async {
    try {
      return await _purchaseService.getStoreItems(itemType: itemType);
    } catch (e) {
      AppLogger.error('Get store items error', e);
      return null;
    }
  }

  /// Clear all user data
  void _clearUserData() {
    _user = null;
    _userStats = null;
    _purchases.clear();
    _following.clear();
    _followers.clear();
    _feed.clear();
    _clearError();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}