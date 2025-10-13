import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../l10n/strings_nl.dart' as strings;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                Icons.person_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strings.AppStrings.account,
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: strings.AppStrings.signIn),
            Tab(text: strings.AppStrings.signUp),
          ],
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
          indicatorColor: colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 500 : (isTablet ? 400 : double.infinity),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSignInForm(colorScheme, isDesktop, isTablet),
                _buildSignUpForm(colorScheme, isDesktop, isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(ColorScheme colorScheme, bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
        vertical: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.login_rounded,
              size: isDesktop ? 80 : (isTablet ? 70 : 60),
              color: colorScheme.primary,
            ),
            SizedBox(height: isDesktop ? 32 : 24),
        Text(
          strings.AppStrings.welcomeBack,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        Text(
          strings.AppStrings.signInDescription,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
          ),
          textAlign: TextAlign.center,
        ),
            SizedBox(height: isDesktop ? 32 : 24),
            _buildEmailField(colorScheme),
            const SizedBox(height: 16),
            _buildPasswordField(colorScheme, isPassword: true),
            const SizedBox(height: 24),
            _buildSignInButton(colorScheme),
            const SizedBox(height: 16),
            _buildDivider(colorScheme),
            const SizedBox(height: 16),
            _buildUsernameSignInButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm(ColorScheme colorScheme, bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
        vertical: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.person_add_rounded,
              size: isDesktop ? 80 : (isTablet ? 70 : 60),
              color: colorScheme.primary,
            ),
            SizedBox(height: isDesktop ? 32 : 24),
        Text(
          strings.AppStrings.createAccount,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        Text(
          strings.AppStrings.signUpDescription,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
          ),
          textAlign: TextAlign.center,
        ),
            SizedBox(height: isDesktop ? 32 : 24),
            _buildDisplayNameField(colorScheme),
            const SizedBox(height: 16),
            _buildUsernameField(colorScheme),
            const SizedBox(height: 16),
            _buildEmailField(colorScheme),
            const SizedBox(height: 16),
            _buildPasswordField(colorScheme, isPassword: true),
            const SizedBox(height: 16),
            _buildPasswordField(colorScheme, isPassword: false, label: 'Confirm Password'),
            const SizedBox(height: 24),
            _buildSignUpButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayNameField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _displayNameController,
      decoration: InputDecoration(
        labelText: strings.AppStrings.displayName,
        hintText: strings.AppStrings.displayNameHint,
        prefixIcon: const Icon(Icons.person_outline_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return strings.AppStrings.pleaseEnterDisplayName;
        }
        if (value.length < 2) {
          return strings.AppStrings.displayNameTooShort;
        }
        return null;
      },
    );
  }

  Widget _buildUsernameField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: strings.AppStrings.username,
        hintText: strings.AppStrings.usernameHint,
        prefixIcon: const Icon(Icons.alternate_email_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return strings.AppStrings.pleaseEnterUsername;
        }
        if (value.length < 3) {
          return strings.AppStrings.usernameTooShort;
        }
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
          return strings.AppStrings.usernameInvalidChars;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: strings.AppStrings.email,
        hintText: strings.AppStrings.emailHint,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return strings.AppStrings.pleaseEnterEmail;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return strings.AppStrings.pleaseEnterValidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(ColorScheme colorScheme, {required bool isPassword, String? label}) {
    final controller = isPassword ? _passwordController : _confirmPasswordController;
    final isVisible = isPassword ? _isPasswordVisible : _isConfirmPasswordVisible;
    final labelText = label ?? strings.AppStrings.password;

    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: strings.AppStrings.passwordHint,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _isPasswordVisible = !_isPasswordVisible;
              } else {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return strings.AppStrings.pleaseEnterPassword;
        }
        if (value.length < 6) {
          return strings.AppStrings.passwordTooShort;
        }
        if (!isPassword && value != _passwordController.text) {
          return strings.AppStrings.passwordsDoNotMatch;
        }
        return null;
      },
    );
  }

  Widget _buildSignInButton(ColorScheme colorScheme) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return ElevatedButton(
          onPressed: userProvider.isLoading ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: userProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  strings.AppStrings.signIn,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSignUpButton(ColorScheme colorScheme) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return ElevatedButton(
          onPressed: userProvider.isLoading ? null : _handleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: userProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  strings.AppStrings.createAccount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildUsernameSignInButton(ColorScheme colorScheme) {
    return OutlinedButton(
      onPressed: _handleUsernameSignIn,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        strings.AppStrings.signInWithUsername,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.onSurface.withAlpha((0.3 * 255).round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            strings.AppStrings.or,
            style: TextStyle(
              color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.onSurface.withAlpha((0.3 * 255).round()),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      _showErrorDialog(userProvider.error ?? 'Sign in failed');
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      displayName: _displayNameController.text.trim(),
    );

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      _showErrorDialog(userProvider.error ?? 'Sign up failed');
    }
  }

  Future<void> _handleUsernameSignIn() async {
    // Show username sign in dialog
    final username = await _showUsernameSignInDialog();
    if (username != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.signInWithUsername(
        username: username,
        password: _passwordController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _showErrorDialog(userProvider.error ?? 'Sign in failed');
      }
    }
  }

  Future<String?> _showUsernameSignInDialog() async {
    final usernameController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.AppStrings.signInWithUsername),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: strings.AppStrings.username,
            hintText: strings.AppStrings.enterUsername,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(usernameController.text.trim()),
            child: Text(strings.AppStrings.signIn),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.AppStrings.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.AppStrings.ok),
          ),
        ],
      ),
    );
  }
}