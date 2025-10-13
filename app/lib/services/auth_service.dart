import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import 'logger.dart';

/// Service for handling user authentication and account management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _baseUrl = 'https://api.bijbelquiz.app';
  late final Dio _dio;
  late final SupabaseClient _supabase;

  User? _currentUser;
  String? _accessToken;

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _currentUser != null && _accessToken != null;

  /// Initialize the authentication service
  Future<void> initialize() async {
    try {
      // Initialize Supabase
      await Supabase.initialize(
        url: 'YOUR_SUPABASE_URL', // Replace with actual URL
        anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with actual key
      );
      _supabase = Supabase.instance.client;

      // Initialize Dio for API calls
      _dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      // Add request interceptor to include auth token
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid, clear auth state
            _clearAuthState();
          }
          handler.next(error);
        },
      ));

      // Check if user is already logged in
      await _checkExistingSession();

      AppLogger.info('AuthService initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize AuthService', e);
      rethrow;
    }
  }

  /// Check if there's an existing valid session
  Future<void> _checkExistingSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null && !session.isExpired) {
        _accessToken = session.accessToken;
        await _loadUserProfile();
      }
    } catch (e) {
      AppLogger.error('Error checking existing session', e);
      _clearAuthState();
    }
  }

  /// Load user profile from the API
  Future<void> _loadUserProfile() async {
    try {
      final response = await _dio.get('/api/users/me');
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data['user']);
        AppLogger.info('User profile loaded: ${_currentUser!.username}');
      }
    } catch (e) {
      AppLogger.error('Failed to load user profile', e);
      _clearAuthState();
    }
  }

  /// Sign up a new user
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      AppLogger.info('Attempting to sign up user: $username');

      // Create user with Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'display_name': displayName,
        },
      );

      if (authResponse.user == null) {
        return AuthResult.error('Failed to create user account');
      }

      if (authResponse.session == null) {
        return AuthResult.error('Please check your email to verify your account');
      }

      _accessToken = authResponse.session!.accessToken;
      _currentUser = User(
        id: authResponse.user!.id,
        email: authResponse.user!.email!,
        username: username,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      AppLogger.info('User signed up successfully: $username');
      return AuthResult.success(_currentUser!);
    } on AuthException catch (e) {
      AppLogger.error('Auth error during signup', e);
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('Signup error', e);
      return AuthResult.error('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Attempting to sign in with email: $email');

      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null || authResponse.session == null) {
        return AuthResult.error('Invalid credentials');
      }

      _accessToken = authResponse.session!.accessToken;
      await _loadUserProfile();

      AppLogger.info('User signed in successfully: ${_currentUser?.username}');
      return AuthResult.success(_currentUser!);
    } on AuthException catch (e) {
      AppLogger.error('Auth error during sign in', e);
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('Sign in error', e);
      return AuthResult.error('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign in with username and password
  Future<AuthResult> signInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      AppLogger.info('Attempting to sign in with username: $username');

      final response = await _dio.post('/api/auth/login-username', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        _currentUser = User.fromJson(userData);
        _accessToken = response.data['session']['access_token'];
        
        AppLogger.info('User signed in successfully: $username');
        return AuthResult.success(_currentUser!);
      } else {
        return AuthResult.error('Invalid credentials');
      }
    } on DioException catch (e) {
      AppLogger.error('Sign in error', e);
      if (e.response?.statusCode == 401) {
        return AuthResult.error('Invalid credentials');
      }
      return AuthResult.error('An unexpected error occurred. Please try again.');
    } catch (e) {
      AppLogger.error('Sign in error', e);
      return AuthResult.error('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out user: ${_currentUser?.username}');
      
      await _supabase.auth.signOut();
      _clearAuthState();
      
      AppLogger.info('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out error', e);
      // Clear state even if signout fails
      _clearAuthState();
    }
  }

  /// Check if a username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _dio.get('/api/auth/check-username/$username');
      return response.data['available'] as bool? ?? false;
    } catch (e) {
      AppLogger.error('Username availability check error', e);
      return false;
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      if (_currentUser == null) {
        return AuthResult.error('User not authenticated');
      }

      AppLogger.info('Updating profile for user: ${_currentUser!.username}');

      final response = await _dio.put('/api/users/me', data: {
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data['user']);
        AppLogger.info('Profile updated successfully');
        return AuthResult.success(_currentUser!);
      } else {
        return AuthResult.error('Failed to update profile');
      }
    } on DioException catch (e) {
      AppLogger.error('Profile update error', e);
      return AuthResult.error('Failed to update profile');
    } catch (e) {
      AppLogger.error('Profile update error', e);
      return AuthResult.error('An unexpected error occurred');
    }
  }

  /// Refresh the access token
  Future<bool> refreshToken() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null && session.refreshToken != null) {
        final response = await _supabase.auth.refreshSession();
        if (response.session != null) {
          _accessToken = response.session!.accessToken;
          return true;
        }
      }
      return false;
    } catch (e) {
      AppLogger.error('Token refresh error', e);
      return false;
    }
  }

  /// Clear authentication state
  void _clearAuthState() {
    _currentUser = null;
    _accessToken = null;
  }

  /// Get user-friendly error message from auth exception
  String _getAuthErrorMessage(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password';
      case 'Email not confirmed':
        return 'Please check your email and click the confirmation link';
      case 'User already registered':
        return 'An account with this email already exists';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters long';
      default:
        return e.message;
    }
  }
}

/// Result of an authentication operation
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
  });

  factory AuthResult.success(User user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}