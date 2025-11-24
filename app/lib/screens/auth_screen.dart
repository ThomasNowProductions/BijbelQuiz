import 'package:flutter/material.dart';
import '../widgets/auth_view.dart';

class AuthScreen extends StatelessWidget {
  final bool requiredForSocial;
  final VoidCallback? onLoginSuccess;

  const AuthScreen({
    super.key,
    this.requiredForSocial = false,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AuthView(
            requiredForSocial: requiredForSocial,
            onLoginSuccess: () {
              if (onLoginSuccess != null) {
                onLoginSuccess!();
              } else {
                // Default behavior: pop if can pop, otherwise do nothing (auth state change usually triggers navigation elsewhere)
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
