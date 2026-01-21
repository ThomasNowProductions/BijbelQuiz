import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../services/logger.dart';
import '../utils/automatic_error_reporter.dart';
import '../l10n/strings_nl.dart';

class AuthView extends StatefulWidget {
  final bool requiredForSocial;
  final VoidCallback? onLoginSuccess;
  final bool isEmbedded; // To adjust padding/styling if needed

  const AuthView({
    super.key,
    this.requiredForSocial = false,
    this.onLoginSuccess,
    this.isEmbedded = false,
  });

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  bool _isLoginMode = true; // true for login, false for signup
  List<String>? _blacklistedUsernames;

  /// Converts technical error messages to user-friendly messages
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network/connection errors
    if (errorString.contains('failed to fetch') ||
        errorString.contains('network error') ||
        errorString.contains('connection')) {
      return '${AppStrings.connectionError}. ${AppStrings.connectionErrorMsg}';
    }

    // Authentication errors
    if (errorString.contains('invalid login credentials') ||
        errorString.contains('email not confirmed') ||
        errorString.contains('invalid email or password')) {
      return AppStrings.invalidEmailOrPassword;
    }

    if (errorString.contains('email not confirmed')) {
      return AppStrings.emailNotConfirmed;
    }

    if (errorString.contains('too many requests')) {
      return AppStrings.tooManyRequests;
    }

    if (errorString.contains('password should be at least')) {
      return AppStrings.passwordTooShortGeneric;
    }

    if (errorString.contains('unable to validate email address')) {
      return AppStrings.invalidEmailAddress;
    }

    if (errorString.contains('user already registered')) {
      return AppStrings.userAlreadyRegistered;
    }

    if (errorString.contains('signup is disabled')) {
      return AppStrings.signupDisabled;
    }

    if (errorString.contains('weak password')) {
      return AppStrings.weakPassword;
    }

    // Generic error fallback
    return AppStrings.genericError;
  }

  @override
  void initState() {
    super.initState();
    _loadBlacklistedUsernames();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadBlacklistedUsernames() async {
    try {
      // Load blacklisted usernames from assets
      final String response = await DefaultAssetBundle.of(context)
          .loadString('assets/blacklisted_usernames.json');
      final List<dynamic> jsonData = json.decode(response);
      if (mounted) {
        setState(() {
          _blacklistedUsernames =
              jsonData.map((item) => item.toString().toLowerCase()).toList();
        });
      }
    } catch (e) {
      // Auto-report the error
      await AutomaticErrorReporter.reportStorageError(
        message: 'Error loading blacklisted usernames: ${e.toString()}',
        userMessage: 'Error loading blacklisted usernames',
        operation: 'load_asset',
        additionalInfo: {
          'file': 'assets/blacklisted_usernames.json',
          'error': e.toString(),
          'feature': 'auth',
        },
      );
      AppLogger.error('Error loading blacklisted usernames', e);
      // Set a default list if the file fails to load
      if (mounted) {
        setState(() {
          _blacklistedUsernames = [
            'god',
            'jesus',
            'allah',
            'yahweh',
            'jehovah',
            'christ',
            'buddha',
            'muhammad',
            'holy',
            'sacred',
            'lord',
            'saint',
            'bible',
            'quran',
            'torah',
          ].map((item) => item.toLowerCase()).toList();
        });
      }
    }
  }

  bool _isUsernameBlacklisted(String username) {
    if (_blacklistedUsernames == null || _blacklistedUsernames!.isEmpty) {
      return false;
    }
    final usernameLower = username.toLowerCase().trim();
    return _blacklistedUsernames!.contains(usernameLower);
  }

  Future<bool> _isUsernameTaken(String username) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('user_profiles')
          .select('username')
          .eq('username', username.toLowerCase().trim())
          .maybeSingle();

      return response != null;
    } catch (e) {
      AppLogger.error('Error checking if username is taken', e);
      return false; // Assume not taken on error
    }
  }

  Future<int> _checkPwned(String password) async {
    try {
      final sha1Hash =
          sha1.convert(utf8.encode(password)).toString().toUpperCase();
      final prefix = sha1Hash.substring(0, 5);
      final suffix = sha1Hash.substring(5);

      final url = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        AppLogger.error(
            'Pwned API request failed with status: ${response.statusCode}');
        return 0; // Assume not pwned on API error
      }

      final lines = response.body.split('\n');
      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length == 2 && parts[0] == suffix) {
          return int.tryParse(parts[1].trim()) ?? 0;
        }
      }
      return 0;
    } catch (e) {
      AppLogger.error('Error checking password against pwned database', e);
      return 0; // Assume not pwned on error
    }
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = AppStrings.fillEmailAndPassword;
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _error = AppStrings.enterValidEmail;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        AppLogger.info('Successfully signed in user: ${response.user!.email}');
        widget.onLoginSuccess?.call();
      }
    } catch (e) {
      setState(() {
        _error = _getUserFriendlyErrorMessage(e);
      });
      AppLogger.error('Sign in failed', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();

    // Enhanced field validation with specific messages
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        username.isEmpty) {
      setState(() {
        _error = AppStrings.fillAllFields;
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _error = AppStrings.enterValidEmail;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _error = AppStrings.passwordsDoNotMatch;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error = AppStrings.passwordTooShort;
      });
      return;
    }

    // Check if password has been pwned
    setState(() {
      _error = AppStrings.checkingPassword;
    });

    final pwnedCount = await _checkPwned(password);
    if (pwnedCount > 0) {
      setState(() {
        _error = AppStrings.passwordCompromised;
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _error = AppStrings.usernameTooShort;
      });
      return;
    }

    if (username.length > 20) {
      setState(() {
        _error = AppStrings.usernameSignupTooLong;
      });
      return;
    }

    // Check for valid username characters
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(() {
        _error = AppStrings.usernameInvalidChars;
      });
      return;
    }

    if (_isUsernameBlacklisted(username)) {
      setState(() {
        _error = AppStrings.usernameNotAllowed;
      });
      return;
    }

    // Check if username is already taken
    setState(() {
      _error = AppStrings.checkingUsername;
    });

    final usernameTaken = await _isUsernameTaken(username);
    if (usernameTaken) {
      setState(() {
        _error = AppStrings.thisUsernameAlreadyTaken;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        try {
          // Create user profile with username
          await Supabase.instance.client.from('user_profiles').insert({
            'user_id': response.user!.id,
            'username': username.toLowerCase().trim(),
            'display_name': username.trim(),
            'bio': null,
            'avatar_url': null,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          AppLogger.info(
              'Successfully signed up user: ${response.user!.email} with username: $username');
        } catch (profileError) {
          // If profile creation fails, log it but don't fail the signup
          AppLogger.error(
              'Failed to create user profile during signup', profileError);
          // Try to create a basic profile as fallback
          try {
            await Supabase.instance.client.from('user_profiles').insert({
              'user_id': response.user!.id,
              'username': username.toLowerCase().trim(),
              'display_name': username.trim(),
            });
            AppLogger.info('Created basic user profile as fallback');
          } catch (fallbackError) {
            AppLogger.error(
                'Failed to create fallback user profile', fallbackError);
          }
        }

        if (mounted) {
          setState(() {
            _isLoginMode = true; // Switch to login mode after signup
            _usernameController.clear(); // Clear username field
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.accountCreatedMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = _getUserFriendlyErrorMessage(e);
      });
      AppLogger.error('Sign up failed', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(widget.isEmbedded ? 0 : 20),
      decoration: widget.isEmbedded
          ? null
          : BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error message
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.error),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Social features requirement message
          if (widget.requiredForSocial) ...[
            // Large header
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                AppStrings.loginWithBqid,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.group_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.socialFeaturesMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Mode toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isLoginMode = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isLoginMode
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppStrings.login,
                      style: TextStyle(
                        color: _isLoginMode
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isLoginMode = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isLoginMode
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppStrings.signup,
                      style: TextStyle(
                        color: !_isLoginMode
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email field
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: AppStrings.email,
              hintText: AppStrings.emailHint,
              prefixIcon: const Icon(Icons.email_rounded),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),

          // Username field (only for signup)
          if (!_isLoginMode) ...[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: AppStrings.username,
                hintText: AppStrings.usernameSignupHint,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
          ],

          // Password field
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: AppStrings.password,
              hintText: AppStrings.passwordHint,
              prefixIcon: const Icon(Icons.lock_rounded),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            obscureText: true,
            textInputAction:
                _isLoginMode ? TextInputAction.done : TextInputAction.next,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),

          // Confirm password field (only for signup)
          if (!_isLoginMode) ...[
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: AppStrings.confirmPassword,
                hintText: AppStrings.confirmPasswordHint,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_isLoginMode ? _signIn : _signUp),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isLoginMode
                          ? AppStrings.login
                          : AppStrings.createAccount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
