import 'package:flutter/material.dart';
import 'package:bijbelquiz/l10n/strings_nl.dart' as strings;

class SignupScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const SignupScreen({super.key, required this.onSwitchToLogin});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.AppStrings.signup),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: strings.AppStrings.username),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.AppStrings.pleaseEnterUsername;
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: strings.AppStrings.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.AppStrings.pleaseEnterEmail;
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: strings.AppStrings.password),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.AppStrings.pleaseEnterPassword;
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Implement signup logic
                  }
                },
                child: Text(strings.AppStrings.signup),
              ),
              TextButton(
                onPressed: widget.onSwitchToLogin,
                child: Text(strings.AppStrings.alreadyHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
