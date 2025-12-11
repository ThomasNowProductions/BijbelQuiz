import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../services/logger.dart';
import '../utils/automatic_error_reporter.dart';

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
  final TextEditingController _confirmPasswordController = TextEditingController();
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
      return 'Geen internetverbinding. Controleer je verbinding en probeer opnieuw.';
    }
    
    // Authentication errors
    if (errorString.contains('invalid login credentials') ||
        errorString.contains('email not confirmed') ||
        errorString.contains('invalid email or password')) {
      return 'Ongeldig email of wachtwoord. Controleer je gegevens en probeer opnieuw.';
    }
    
    if (errorString.contains('email not confirmed')) {
      return 'Je email is nog niet geverifieerd. Controleer je inbox en klik op de verificatielink.';
    }
    
    if (errorString.contains('too many requests')) {
      return 'Te veel pogingen. Wacht even voordat je opnieuw probeert.';
    }
    
    if (errorString.contains('password should be at least')) {
      return 'Wachtwoord moet minimaal 6 karakters bevatten.';
    }
    
    if (errorString.contains('unable to validate email address')) {
      return 'Ongeldig emailadres. Controleer of je een geldig emailadres hebt ingevoerd.';
    }
    
    if (errorString.contains('user already registered')) {
      return 'Er bestaat al een account met dit emailadres. Probeer in te loggen of gebruik een ander emailadres.';
    }
    
    if (errorString.contains('signup is disabled')) {
      return 'Aanmelden is momenteel uitgeschakeld. Probeer het later opnieuw.';
    }
    
    if (errorString.contains('weak password')) {
      return 'Wachtwoord is te zwak. Kies een sterker wachtwoord met meer karakters.';
    }
    
    // Generic error fallback
    return 'Er is iets misgegaan. Probeer het opnieuw of neem contact op als het probleem aanhoudt.';
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
      final sha1Hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
      final prefix = sha1Hash.substring(0, 5);
      final suffix = sha1Hash.substring(5);

      final url = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        AppLogger.error('Pwned API request failed with status: ${response.statusCode}');
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
        _error = 'Vul je email en wachtwoord in om door te gaan.';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _error = 'Voer een geldig emailadres in.';
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
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || username.isEmpty) {
      setState(() {
        _error = 'Vul alle velden in om een account aan te maken.';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _error = 'Voer een geldig emailadres in.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _error = 'Wachtwoorden komen niet overeen. Controleer of je beide velden hetzelfde hebt ingevuld.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error = 'Wachtwoord moet minimaal 6 karakters bevatten voor je veiligheid.';
      });
      return;
    }

    // Check if password has been pwned
    setState(() {
      _error = 'Wachtwoord wordt gecontroleerd op veiligheid...';
    });

    final pwnedCount = await _checkPwned(password);
    if (pwnedCount > 0) {
      setState(() {
        _error = 'Dit wachtwoord is aangetroffen in datalekken. Kies een ander wachtwoord voor je veiligheid.';
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _error = 'Gebruikersnaam moet minimaal 3 karakters bevatten.';
      });
      return;
    }

    if (username.length > 20) {
      setState(() {
        _error = 'Gebruikersnaam mag maximaal 20 karakters bevatten.';
      });
      return;
    }

    // Check for valid username characters
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(() {
        _error = 'Gebruikersnaam mag alleen letters, cijfers en underscores bevatten.';
      });
      return;
    }

    if (_isUsernameBlacklisted(username)) {
      setState(() {
        _error = 'Deze gebruikersnaam is niet toegestaan. Kies een andere naam.';
      });
      return;
    }

    // Check if username is already taken
    setState(() {
      _error = 'Beschikbaarheid van gebruikersnaam wordt gecontroleerd...';
    });
    
    final usernameTaken = await _isUsernameTaken(username);
    if (usernameTaken) {
      setState(() {
        _error = 'Deze gebruikersnaam is al in gebruik. Kies een andere naam.';
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

          AppLogger.info('Successfully signed up user: ${response.user!.email} with username: $username');
        } catch (profileError) {
          // If profile creation fails, log it but don't fail the signup
          AppLogger.error('Failed to create user profile during signup', profileError);
          // Try to create a basic profile as fallback
          try {
            await Supabase.instance.client.from('user_profiles').insert({
              'user_id': response.user!.id,
              'username': username.toLowerCase().trim(),
              'display_name': username.trim(),
            });
            AppLogger.info('Created basic user profile as fallback');
          } catch (fallbackError) {
            AppLogger.error('Failed to create fallback user profile', fallbackError);
          }
        }

        if (mounted) {
          setState(() {
            _isLoginMode = true; // Switch to login mode after signup
            _usernameController.clear(); // Clear username field
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account aangemaakt! Controleer je email voor verificatie.'),
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
                'Login met je BQID',
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
                      'Maak een account aan om sociale functies te gebruiken, zoals het zoeken naar gebruikers, vrienden maken en berichten versturen.',
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
                      'Inloggen',
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
                      'Aanmelden',
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
              labelText: 'Email',
              hintText: 'jouw@email.com',
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
                borderSide: BorderSide(
                    color: colorScheme.primary, width: 2),
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
                labelText: 'Gebruikersnaam',
                hintText: 'Kies een unieke naam',
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
                  borderSide: BorderSide(
                      color: colorScheme.primary, width: 2),
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
              labelText: 'Wachtwoord',
              hintText: 'Minimaal 6 karakters',
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
                borderSide: BorderSide(
                    color: colorScheme.primary, width: 2),
              ),
            ),
            obscureText: true,
            textInputAction: _isLoginMode
                ? TextInputAction.done
                : TextInputAction.next,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),

          // Confirm password field (only for signup)
          if (!_isLoginMode) ...[
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Bevestig wachtwoord',
                hintText: 'Herhaal je wachtwoord',
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
                  borderSide: BorderSide(
                      color: colorScheme.primary, width: 2),
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
              onPressed: _isLoading
                  ? null
                  : (_isLoginMode ? _signIn : _signUp),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    )
                  : Text(
                      _isLoginMode ? 'Inloggen' : 'Account aanmaken',
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